//
//  JLAudioRecoder.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/26.
//

import AVFoundation

// 录音配置结构体
public struct RecorderConfig {
    public let sampleRate: Double // 采样率
    public let bitDepth: Int // 位深（16 或 32）
    public let channels: AVAudioChannelCount // 通道数（单声道、立体声）
    public let bufferSize: AVAudioFrameCount // 每次回调的帧数量

    // 根据位深自动选择 AVAudioCommonFormat 格式
    public var commonFormat: AVAudioCommonFormat {
        switch bitDepth {
        case 32: return .pcmFormatFloat32
        default: return .pcmFormatInt16
        }
    }

    // 计算每帧所占字节数（用于数据写入）
    public var bytesPerFrame: Int { (bitDepth / 8) * Int(channels) }

    // 默认配置（16kHz 单声道 16bit）
    public static let `default` = RecorderConfig(
        sampleRate: 16000,
        bitDepth: 16,
        channels: 1,
        bufferSize: 1024
    )
}

// 录音错误类型
enum RecorderError: Error {
    case permissionDenied // 没有麦克风权限
    case engineSetupFailed // AVAudioEngine 初始化失败
    case engineStartFailed(Error) // 启动失败
    case fileCreationFailed(Error) // 文件创建失败
    case bufferConversionFailed // 缓冲区转换失败
}

// 主录音类
class JLAudioRecoder {
    static let shared = JLAudioRecoder()
    dynamic var pcmData = Data() {
        didSet {
            pcmUpdateHandler?(pcmData)
        }
    }
    
    var pcmUpdateHandler: ((Data) -> Void)?
    
    private var audioEngine: AVAudioEngine?
    private var converter: AVAudioConverter?
    private var frameCallback: ((Data) -> Void)?
    private var isRecording = false
    private var currentConfig: RecorderConfig?
    private var fileHandle: FileHandle?
    private var outputFormat: AVAudioFormat!
    
    /// 开始录音并保存到文件
    public func startRecording(toFile path: String,
                               config: RecorderConfig = .default) throws
    {
        frameCallback = nil // 不使用回调
        try commonStart(config: config)
        try prepareFileHandle(at: path)
        installTap(config: config)
        try startEngine()
    }
    
    /// 按帧回调 PCM 数据（不写入文件）
    public func startRecording(frameCallback: @escaping (Data) -> Void,
                               config: RecorderConfig = .default) throws
    {
        self.frameCallback = frameCallback
        try commonStart(config: config)
        installTap(config: config)
        try startEngine()
    }
    
    /// 停止录音
    public func stop() {
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        isRecording = false
        try? fileHandle?.close()
        fileHandle = nil
    }
    
    /// 销毁实例（释放资源）
    public func destroy() {
        stop()
        audioEngine = nil
        converter = nil
        frameCallback = nil
    }
    
    // MARK: - 初始化音频引擎和音频会话
    
    private func commonStart(config: RecorderConfig) throws {
        guard AVAudioSession.sharedInstance().recordPermission == .granted else {
            throw RecorderError.permissionDenied
        }
        try JLAudioSessionManager.shared.activate()
        currentConfig = config
        
        // 初始化音频引擎
        audioEngine = AVAudioEngine()
        guard let inputNode = audioEngine?.inputNode else {
            throw RecorderError.engineSetupFailed
        }
        
        // 输入节点的原始格式（可能与输出格式不同）
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // 配置目标格式
        outputFormat = AVAudioFormat(commonFormat: config.commonFormat,
                                     sampleRate: config.sampleRate,
                                     channels: config.channels,
                                     interleaved: false)
        
        // 转换器：将输入格式转换为目标格式
        converter = AVAudioConverter(from: inputFormat, to: outputFormat)
    }
    
    // MARK: - 准备文件写入句柄
    
    private func prepareFileHandle(at path: String) throws {
        let url = URL(fileURLWithPath: path)
        
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(),
                                                withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(at: url)
        }
        FileManager.default.createFile(atPath: path, contents: nil)
        
        guard let handle = FileHandle(forWritingAtPath: path) else {
            throw RecorderError.fileCreationFailed(NSError(domain: "AudioRecoder",
                                                           code: -1,
                                                           userInfo: nil))
        }
        fileHandle = handle
    }
    
    // MARK: - 安装 Tap 获取 PCM 数据
    
    private func installTap(config: RecorderConfig) {
        guard let engine = audioEngine,
              let converter = converter,
              let outFmt = outputFormat else { return }
        
        let inputNode = engine.inputNode
        inputNode.installTap(onBus: 0,
                             bufferSize: config.bufferSize,
                             format: inputNode.outputFormat(forBus: 0))
        { [weak self] buffer, _ in
            guard let self = self else { return }
            
            // 根据目标格式采样率，计算对应的输出帧数量
            let frameCount = AVAudioFrameCount(Double(buffer.frameLength) * outFmt.sampleRate / buffer.format.sampleRate)
            
            guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: outFmt, frameCapacity: frameCount) else { return }
            
            // 执行格式转换（例如从 Float32 转 Int16）
            var error: NSError?
            let status = converter.convert(to: pcmBuffer, error: &error) { _, outStatus in
                outStatus.pointee = .haveData
                return buffer
            }
            guard status != .error, error == nil else { return }
            
            // 计算当前数据的字节数，并复制出 Data
            let byteCount = Int(pcmBuffer.frameLength) * config.bytesPerFrame
            let mBuf = pcmBuffer.audioBufferList.pointee.mBuffers
            guard let dataPtr = mBuf.mData else { return }
            let data = Data(bytes: dataPtr, count: byteCount)
            
            // 写入文件（如果有）
            if let handle = self.fileHandle {
                handle.seekToEndOfFile()
                handle.write(data)
            }
            
            self.pcmData = data
            
            // 触发回调（如果设置了）
            self.frameCallback?(data)
        }
    }
    
    // MARK: - 启动引擎
    
    private func startEngine() throws {
        guard let engine = audioEngine, !isRecording else { return }
        do {
            try engine.start()
            isRecording = true
        } catch {
            throw RecorderError.engineStartFailed(error)
        }
    }
    
    /// 检查并请求麦克风权限，权限就绪后自动开始录音（写文件）
    public func startRecordingWithPermission(toFile path: String,
                                             config: RecorderConfig = .default,
                                             onDenied: (() -> Void)? = nil) {
        requestMicPermissionIfNeeded { [weak self] granted in
            guard let self = self else { return }
            if granted {
                do {
                    try self.startRecording(toFile: path, config: config)
                } catch {
                    // 可以根据需要将错误反馈出去
                    print("startRecording failed: \(error)")
                }
            } else {
                onDenied?()
            }
        }
    }
    
    /// 检查并请求麦克风权限，权限就绪后自动开始录音（按帧回调）
    public func startRecordingWithPermission(frameCallback: @escaping (Data) -> Void,
                                             config: RecorderConfig = .default,
                                             onDenied: (() -> Void)? = nil) {
        requestMicPermissionIfNeeded { [weak self] granted in
            guard let self = self else { return }
            if granted {
                do {
                    try self.startRecording(frameCallback: frameCallback, config: config)
                } catch {
                    print("startRecording failed: \(error)")
                }
            } else {
                onDenied?()
            }
        }
    }
    
    /// 如果未授权则请求授权；若已拒绝则直接返回 false；授权成功返回 true
    private func requestMicPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        let session = AVAudioSession.sharedInstance()
        switch session.recordPermission {
        case .granted:
            completion(true)
        case .undetermined:
            session.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}
