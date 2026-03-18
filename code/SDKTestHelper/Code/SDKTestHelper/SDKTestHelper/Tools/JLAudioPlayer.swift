//
//  JLAudioPlayer.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/26.
//

import AudioToolbox
import AVFoundation
import UIKit

class JLAudioPlayer {
    static let shared = JLAudioPlayer()

    private var audioQueue: AudioQueueRef?
    private var audioFormat: AudioStreamBasicDescription
    private var audioBuffers: [AudioQueueBufferRef] = []
    private let bufferSize: Int = 1024 // 每次播放的数据大小
    private let queueSize: Int = 3 // 缓冲队列的数量
    private var dataQueue: [Data] = [] // 存储拆分后的 PCM 数据块
    private let serialQueue = DispatchQueue(label: "com.jlaudioplayer.serial")
    private var isRunning: Bool = false
    private var hasStarted: Bool = false

    var callBack: ((Data) -> Void)?
    var completionHandler: (() -> Void)?

    // 音频会话配置保存
    private var savedAudioSessionConfig: (category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions)?
    private var tempAudioSessionConfig: (category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions)?

    private init() {
        // 配置音频格式: 16kHz, 16-bit, 单声道, 有符号整数打包
        audioFormat = AudioStreamBasicDescription(
            mSampleRate: 16000,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
            mBytesPerPacket: 2,
            mFramesPerPacket: 1,
            mBytesPerFrame: 2,
            mChannelsPerFrame: 1,
            mBitsPerChannel: 16,
            mReserved: 0
        )
    }

    func start() {
        guard audioQueue == nil else { return }

        var tmpQueue: AudioQueueRef?
        let status = AudioQueueNewOutput(
            &audioFormat,
            { userData, _, buffer in
                let player = Unmanaged<JLAudioPlayer>.fromOpaque(userData!).takeUnretainedValue()
                player.processBuffer(buffer)
            },
            Unmanaged.passUnretained(self).toOpaque(),
            nil, nil, 0,
            &tmpQueue
        )
        guard status == noErr, let queue = tmpQueue else { return }
        audioQueue = queue

        // 分配缓冲区
        for _ in 0 ..< queueSize {
            var bufRef: AudioQueueBufferRef?
            if AudioQueueAllocateBuffer(queue, UInt32(bufferSize), &bufRef) == noErr,
               let buf = bufRef
            {
                audioBuffers.append(buf)
            }
        }

        // 启动队列
        if AudioQueueStart(queue, nil) == noErr {
            hasStarted = true
            isRunning = true
        }

        // 配置 AVAudioSession
        do {
            if let config = tempAudioSessionConfig {
                try JLAudioSessionManager.shared.activate(
                    category: config.category,
                    options: config.options
                )
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                try AVAudioSession.sharedInstance().setActive(true)
            } else {
                try JLAudioSessionManager.shared.activate()
            }
        } catch {
            print("Failed to activate audio session: \(error)")
        }
    }

    func stop() {
        serialQueue.async {
            guard self.isRunning else { return }
            self.isRunning = false
            self.hasStarted = false

            if let queue = self.audioQueue {
                AudioQueueStop(queue, true)
                AudioQueueDispose(queue, true)
                self.audioQueue = nil
            }
            self.dataQueue.removeAll()
            self.audioBuffers.removeAll()
        }
    }

    /// 设置播放完成回调
    /// - Parameter handler: 播放完成时执行的回调
    func onCompletion(_ handler: @escaping () -> Void) {
        completionHandler = handler
    }

    func changeFormat(_ format: AudioStreamBasicDescription) {
        stop()
        audioFormat = format
        start()
    }

    /// 拆分大块 PCM 数据并补齐至 bufferSize
    func enqueuePCMData(_ data: Data) {
        guard !data.isEmpty else { return }
        serialQueue.async {
            var offset = 0
            while offset < data.count {
                let end = min(offset + self.bufferSize, data.count)
                var chunk = data.subdata(in: offset ..< end)
                if chunk.count < self.bufferSize {
                    chunk.append(Data(count: self.bufferSize - chunk.count))
                }
                self.dataQueue.append(chunk)
                offset += self.bufferSize
            }
            if !self.hasStarted {
                self.start()
            }
            self.fillBufferIfNeeded()
        }
    }

    private func processBuffer(_ buffer: AudioQueueBufferRef) {
        buffer.pointee.mAudioDataByteSize = 0
        serialQueue.async {
            self.fillBufferIfNeeded()
        }
    }

    private func fillBufferIfNeeded() {
        guard let queue = audioQueue, isRunning else { return }
        while !dataQueue.isEmpty {
            guard let buffer = audioBuffers.first(where: { $0.pointee.mAudioDataByteSize == 0 }) else { break }
            let chunk = dataQueue.removeFirst()
            memcpy(buffer.pointee.mAudioData, (chunk as NSData).bytes, bufferSize)
            buffer.pointee.mAudioDataByteSize = UInt32(bufferSize)
            if AudioQueueEnqueueBuffer(queue, buffer, 0, nil) != noErr {
                DispatchQueue.main.async { self.stop() }
                return
            }
            DispatchQueue.main.async { self.callBack?(chunk) }
        }
        checkShouldStop()
    }

    private func checkShouldStop() {
        let allEmpty = audioBuffers.allSatisfy { $0.pointee.mAudioDataByteSize == 0 }
        if allEmpty, dataQueue.isEmpty {
            serialQueue.asyncAfter(deadline: .now() + 0.5) {
                self.stop()
                // 通知播放完成
                DispatchQueue.main.async {
                    self.completionHandler?()
                }
            }
        }
    }

    deinit {
        stop()
        if let queue = audioQueue {
            AudioQueueDispose(queue, true)
        }
    }

    // MARK: - 扬声器临时切换功能

    /// 临时切换到扬声器播放音频，播放完成后自动恢复原配置
    /// - Parameters:
    ///   - data: 要播放的PCM音频数据
    ///   - completion: 播放完成回调
    func playTemporarilyThroughSpeaker(_ data: Data, completion: (() -> Void)? = nil) {
        // 保存当前音频会话配置
        saveCurrentAudioSessionConfig()

        // 切换到扬声器模式
        switchToSpeakerMode()

        // 设置播放完成回调以恢复配置
        if let completion = completion {
            onCompletion {
                self.restoreAudioSessionConfig()
                completion()
            }
        } else {
            onCompletion {
                self.restoreAudioSessionConfig()
            }
        }

        // 开始播放音频
        enqueuePCMData(data)
    }

    /// 保存当前音频会话配置
    private func saveCurrentAudioSessionConfig() {
        let session = AVAudioSession.sharedInstance()
        savedAudioSessionConfig = (session.category, session.categoryOptions)
        tempAudioSessionConfig = nil
    }

    /// 切换到扬声器模式
    private func switchToSpeakerMode() {
        do {
            try JLAudioSessionManager.shared.activate(
                category: .playAndRecord,
                options: [.defaultToSpeaker]
            )
            let session = AVAudioSession.sharedInstance()
            tempAudioSessionConfig = (session.category, session.categoryOptions)
        } catch {
            print("Failed to switch to speaker mode: \(error)")
        }
    }

    /// 恢复保存的音频会话配置
    private func restoreAudioSessionConfig() {
        guard let config = savedAudioSessionConfig else { return }

        do {
            try JLAudioSessionManager.shared.activate(
                category: config.category,
                options: config.options
            )
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to restore audio session config: \(error)")
        }

        // 清除保存的配置
        savedAudioSessionConfig = nil
        tempAudioSessionConfig = nil
    }
}
