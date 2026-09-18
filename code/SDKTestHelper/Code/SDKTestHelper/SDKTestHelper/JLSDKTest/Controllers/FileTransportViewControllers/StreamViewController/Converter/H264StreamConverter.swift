//
//  H264StreamConverter.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/8.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import Foundation
import CoreMedia
import JLVideoTool
import JLLogHelper

/// H264 帧数据结构
struct H264FrameData {
    let frameIndex: Int
    let h264Data: Data       // 完整 H264 NALU 数据（含起始码）
    let timestamp: CMTime
    let isKeyFrame: Bool     // 是否为 I 帧
}

/// H264 推流错误类型
enum H264StreamError: Error {
    case converterInitFailed
    case notRunning
    case queueFull
    case convertFailed
    case invalidJPEGData
}

/// JPEG → H264 流式转换器封装
/// 基于 JLJpegToH264Converter，提供同步/异步转码接口和状态管理
class H264StreamConverter: NSObject {

    // MARK: - Properties

    /// 转码配置选项
    private let options: JLJpegToH264Options

    /// 底层转换器实例
    private var converter: JLJpegToH264Converter?

    /// 转码状态
    private(set) var isConverting = false

    /// 输出队列（缓存转码后的 H264 数据）
    private var outputQueue: [H264FrameData] = []
    private let queueLock = NSLock()
    private let maxQueueSize = 10

    /// 转码统计信息
    private(set) var statistics: JLConverterStatistics?

    /// 帧级异步回调映射（frameIndex → completion）
    private var pendingCallbacks: [Int: (H264FrameData?) -> Void] = [:]

    /// 当前是否使用硬件加速
    private(set) var isHardwareAccelerated = false

    /// 编码器回退原因
    private(set) var fallbackReason: String?

    // MARK: - Callbacks
    var onFrameConverted: ((H264FrameData) -> Void)?
    var onError: ((Error) -> Void)?
    var onStatisticsUpdate: ((JLConverterStatistics) -> Void)?

    // MARK: - Init

    /// 初始化转换器
    /// - Parameters:
    ///   - width: 输出宽度
    ///   - height: 输出高度
    ///   - fps: 目标帧率
    ///   - bitrate: 目标码率（bps），为 0 时自动计算
    ///   - encoderType: 编码器类型
    init?(width: Int, height: Int, fps: Int, bitrate: Int = 0, encoderType: JLEncoderType = .auto) {
        let options = JLJpegToH264Options()
        options.outputWidth = width
        options.outputHeight = height
        options.frameRate = fps
        options.encoderType = encoderType
        options.decodeFormat = .YUV420P
        options.resizeMode = .aspectFit
        options.keepAspectRatio = true
        options.hardwareRealtimeEncoding = true
        options.h264Profile = .baseline
        options.hardwareRateControlEnabled = true

        // 自动计算码率：width * height * fps * 0.1
        let calculatedBitrate = bitrate > 0 ? bitrate : Int(Double(width * height * fps) * 0.1)
        options.bitrate = calculatedBitrate
        options.keyFrameInterval = fps

        self.options = options
        super.init()

        let converter = JLJpegToH264Converter(options: options)
        converter.delegate = self
        self.converter = converter

        JLLogManager.logLevel(.INFO, content: "[H264Converter] 初始化成功: \(width)x\(height), \(fps)fps, \(calculatedBitrate)bps, encoder=\(encoderType)")
    }

    // MARK: - Control

    /// 开始转码会话
    func startConverting() {
        guard !isConverting else { return }
        isConverting = true
        queueLock.lock()
        outputQueue.removeAll()
        pendingCallbacks.removeAll()
        queueLock.unlock()
        JLLogManager.logLevel(.DEBUG, content: "[H264Converter] 转码会话已启动")
    }

    /// 停止转码会话
    func stopConverting() {
        guard isConverting else { return }
        isConverting = false
        converter?.stop()
        queueLock.lock()
        outputQueue.removeAll()
        let callbacks = pendingCallbacks.values
        pendingCallbacks.removeAll()
        queueLock.unlock()
        callbacks.forEach { $0(nil) }
        JLLogManager.logLevel(.DEBUG, content: "[H264Converter] 转码会话已停止")
    }

    /// 重置转换器状态
    func reset() {
        isConverting = false
        converter?.reset()
        queueLock.lock()
        outputQueue.removeAll()
        let callbacks = pendingCallbacks.values
        pendingCallbacks.removeAll()
        queueLock.unlock()
        callbacks.forEach { $0(nil) }
        statistics = nil
        JLLogManager.logLevel(.DEBUG, content: "[H264Converter] 转换器已重置")
    }

    // MARK: - Conversion

    /// 异步输入 JPEG 数据，通过回调返回转码结果（非阻塞）
    /// - Parameters:
    ///   - jpegData: JPEG 原始数据
    ///   - frameIndex: 帧序号
    ///   - completion: 完成回调（工作线程调用），返回转码后的 H264 数据，失败/超时返回 nil
    func convertFrame(_ jpegData: Data, frameIndex: Int, completion: @escaping (H264FrameData?) -> Void) {
        guard isConverting else {
            JLLogManager.logLevel(.WARN, content: "[H264Converter] 转换失败：未启动")
            completion(nil)
            return
        }
        guard let converter = converter else {
            JLLogManager.logLevel(.ERROR, content: "[H264Converter] 转换失败：converter 为 nil")
            completion(nil)
            return
        }

        let timestamp = CMTimeMake(value: Int64(frameIndex), timescale: Int32(options.frameRate))

        // 注册回调
        queueLock.lock()
        pendingCallbacks[frameIndex] = completion
        queueLock.unlock()

        // 超时兜底（500ms）
        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
            guard let self = self else { return }
            self.queueLock.lock()
            if let cb = self.pendingCallbacks.removeValue(forKey: frameIndex) {
                self.queueLock.unlock()
                JLLogManager.logLevel(.WARN, content: "[H264Converter] 帧 #\(frameIndex) 转码超时")
                cb(nil)
            } else {
                self.queueLock.unlock()
            }
        }

        // 异步入队（非阻塞）
        converter.feedJpegData(jpegData, timestamp: timestamp)
    }

    /// 异步输入 JPEG 数据（非阻塞，用于批量处理）
    /// - Parameters:
    ///   - jpegData: JPEG 原始数据
    ///   - frameIndex: 帧序号
    func feedFrame(_ jpegData: Data, frameIndex: Int) {
        guard isConverting, let converter = converter else { return }

        let timestamp = CMTimeMake(value: Int64(frameIndex), timescale: Int32(options.frameRate))
        converter.feedJpegData(jpegData, timestamp: timestamp)
    }

    /// 刷新缓冲区，强制输出所有待处理数据
    func flush() {
        converter?.flush()
    }

    // MARK: - Queue Management

    /// 获取当前输出队列大小
    func outputQueueSize() -> Int {
        queueLock.lock()
        let size = outputQueue.count
        queueLock.unlock()
        return size
    }

    /// 清空输出队列
    func clearQueue() {
        queueLock.lock()
        outputQueue.removeAll()
        queueLock.unlock()
    }
}

// MARK: - JLJpegToH264ConverterDelegate

extension H264StreamConverter: JLJpegToH264ConverterDelegate {

    func jpeg(_ converter: JLJpegToH264Converter,
              didOutputH264Data h264Data: Data,
              timestamp: CMTime,
              isKeyFrame: Bool) {
        let frameIndex = Int(timestamp.value)

        let frame = H264FrameData(
            frameIndex: frameIndex,
            h264Data: h264Data,
            timestamp: timestamp,
            isKeyFrame: isKeyFrame
        )

        queueLock.lock()
        outputQueue.append(frame)
        // 限制队列大小
        while outputQueue.count > maxQueueSize {
            outputQueue.removeFirst()
        }
        let callback = pendingCallbacks.removeValue(forKey: frameIndex)
        queueLock.unlock()

        onFrameConverted?(frame)
        // 在锁外调用回调，避免死锁
        callback?(frame)
    }

    func jpeg(_ converter: JLJpegToH264Converter,
              didChange state: JLConverterState) {
        JLLogManager.logLevel(.DEBUG, content: "[H264Converter] 状态变化: \(state)")
    }

    func jpeg(_ converter: JLJpegToH264Converter,
              didFailWithError error: Error) {
        JLLogManager.logLevel(.ERROR, content: "[H264Converter] 错误: \(error.localizedDescription)")
        onError?(error)
    }

    func jpeg(_ converter: JLJpegToH264Converter,
              inputQueueDidChangeSize queueSize: NSInteger,
              maxQueueSize: NSInteger) {
        if queueSize >= maxQueueSize {
            JLLogManager.logLevel(.WARN, content: "[H264Converter] 输入队列已满: \(queueSize)/\(maxQueueSize)")
        }
    }

    func jpeg(_ converter: JLJpegToH264Converter,
              didUpdate statistics: JLConverterStatistics) {
        self.statistics = statistics
        onStatisticsUpdate?(statistics)
    }
}
