//
//  JLAudioRecoder.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/26.
//

import AVFoundation

// 录音配置：采样率、位深、通道数、Buffer 大小
public struct RecorderConfig {
    public let sampleRate: Double
    public let bitDepth: Int
    public let channels: AVAudioChannelCount
    public let bufferSize: AVAudioFrameCount
    
    /// 根据位深匹配 AVAudioCommonFormat，目前支持 16 和 32 位
    public var commonFormat: AVAudioCommonFormat {
        switch bitDepth {
        case 32: return .pcmFormatFloat32
        default: return .pcmFormatInt16
        }
    }
    
    /// 每帧字节数 = 位深/8 * 通道数
    public var bytesPerFrame: Int {
        (bitDepth / 8) * Int(channels)
    }
    
    public static let `default` = RecorderConfig(
        sampleRate: 16000,
        bitDepth: 16,
        channels: 1,
        bufferSize: 1024
    )
}

enum RecorderError: Error {
    case permissionDenied
    case engineSetupFailed
    case engineStartFailed(Error)
    case fileCreationFailed(Error)
    case bufferConversionFailed
}

class JLAudioRecoder {
    // MARK: - 公有接口
    static let shared = JLAudioRecoder()
    // MARK: - 公共接口
    /// 录制并保存到文件（纯 PCM 原始数据）
    public func startRecording(toFile path: String,
                               config: RecorderConfig = .default) throws {
        if isRecording {
            return
        }
        try checkPermission()
        try prepareEngine(with: config)
        try prepareFileHandle(at: path)
        installTap(config: config)
        try startEngine()
    }
    
    /// 按帧回调 PCM 数据
    public func startRecording(frameCallback: @escaping (Data) -> Void,
                               config: RecorderConfig = .default) throws {
        if isRecording {
            return
        }
        try checkPermission()
        try prepareEngine(with: config)
        self.frameCallback = frameCallback
        installTap(config: config)
        try startEngine()
    }
    
    /// 停止录音
    public func stop() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        isRecording = false
        // 关闭文件句柄
        try? fileHandle?.close()
        fileHandle = nil
    }
    
    /// 销毁资源
    public func destroy() {
        stop()
        audioEngine = nil
        converter = nil
        frameCallback = nil
    }
    
    // MARK: - 私有属性
    private var audioEngine: AVAudioEngine?
    private var converter: AVAudioConverter?
    private var frameCallback: ((Data) -> Void)?
    private var isRecording = false
    private var currentConfig: RecorderConfig?
    private var fileHandle: FileHandle?
    private var outputFormat: AVAudioFormat!
    
    // MARK: - 准备方法
    private func checkPermission() throws {
        let session = AVAudioSession.sharedInstance()
        guard session.recordPermission == .granted else {
            throw RecorderError.permissionDenied
        }
    }
    
    private func prepareEngine(with config: RecorderConfig) throws {
        currentConfig = config
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.mixWithOthers])
        try session.setActive(true)
        
        audioEngine = AVAudioEngine()
        guard let inputNode = audioEngine?.inputNode else {
            throw RecorderError.engineSetupFailed
        }
        // 输入格式用于转换映射
        let inputFormat = inputNode.outputFormat(forBus: 0)
        // 输出为 PCM
        outputFormat = AVAudioFormat(
            commonFormat: config.commonFormat,
            sampleRate: config.sampleRate,
            channels: config.channels,
            interleaved: false
        )
        converter = AVAudioConverter(from: inputFormat, to: outputFormat)
    }
    
    private func prepareFileHandle(at path: String) throws {
        let url = URL(fileURLWithPath: path)
        let dir = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: dir,
            withIntermediateDirectories: true,
            attributes: nil
        )
        // 如果已存在，删除旧文件
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(at: url)
        }
        // 创建空文件
        FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        // 打开文件句柄
        guard let handle = FileHandle(forWritingAtPath: path) else {
            throw RecorderError.fileCreationFailed(NSError(
                domain: "SimpleAudioRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法打开文件句柄"]))
        }
        fileHandle = handle
    }
    
    private func installTap(config: RecorderConfig) {
        guard let engine = audioEngine,
              let converter = converter,
              let outputFormat = outputFormat else { return }
        
        let inputNode = engine.inputNode
        inputNode.installTap(onBus: 0,
                             bufferSize: config.bufferSize,
                             format: inputNode.outputFormat(forBus: 0)) { [weak self] buffer, _ in
            guard let self = self else { return }
            
            // 转换为 PCM 数据
            let frameCap = AVAudioFrameCount(
                Double(buffer.frameLength)
                * outputFormat.sampleRate
                / buffer.format.sampleRate
            )
            guard let pcmBuffer = AVAudioPCMBuffer(
                pcmFormat: outputFormat,
                frameCapacity: frameCap
            ) else { return }
            
            var err: NSError?
            let status = converter.convert(
                to: pcmBuffer,
                error: &err) { _, outStatus in
                    outStatus.pointee = .haveData
                    return buffer
                }
            guard status != .error, err == nil, pcmBuffer.frameLength > 0 else {
                return
            }
            
            // 提取字节
            let byteCount = Int(pcmBuffer.frameLength) * config.bytesPerFrame
            let mBuf = pcmBuffer.audioBufferList.pointee.mBuffers
            let dataPtr = mBuf.mData!.assumingMemoryBound(to: UInt8.self)
            let data = Data(bytes: dataPtr, count: byteCount)
            
            // 写入文件句柄
            if let handle = self.fileHandle {
                handle.seekToEndOfFile()
                handle.write(data)
            }
            // 回调
            self.frameCallback?(data)
        }
    }
    
    private func startEngine() throws {
        guard let engine = audioEngine, !isRecording else { return }
        do {
            try engine.start()
            isRecording = true
        } catch {
            throw RecorderError.engineStartFailed(error)
        }
    }
}


