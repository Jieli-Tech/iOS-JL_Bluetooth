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
    private let bufferSize: Int = 1024
    private let queueSize: Int = 3 // 缓冲队列的数量
    private var dataQueue: [Data] = [] // 用于存储待播放的 PCM 数据
    private var queueLock = NSLock() // 用于线程安全管理数据队列
    private var playerStatus: OSStatus?
    private var isRunning: Bool = false
    private var hasStarted: Bool = false
    private let ioQueue = DispatchQueue(label: "com.jl.audio.player.queue")

    var callBack: ((Data) -> Void)?
    

    private init() {
        // 配置音频格式
        audioFormat = AudioStreamBasicDescription(
            mSampleRate: 16000, // 采样率
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
            mBytesPerPacket: 2, // 每个数据包的字节数
            mFramesPerPacket: 1,
            mBytesPerFrame: 2,
            mChannelsPerFrame: 1, // 单声道
            mBitsPerChannel: 16,
            mReserved: 0
        )
    }

    func start() {
        guard audioQueue == nil else { return }

        var tmpAudioQueue: AudioQueueRef?
        // 创建 AudioQueue
        playerStatus = AudioQueueNewOutput(
            &audioFormat,
            { userData, _, buffer in
                // 回调函数，处理缓冲区状态
                let player = Unmanaged<JLAudioPlayer>.fromOpaque(userData!).takeUnretainedValue()
                player.ioQueue.async {
                    player.processBuffer(buffer)
                }
            },
            Unmanaged.passUnretained(self).toOpaque(),
            nil,
            nil,
            0,
            &tmpAudioQueue
        )

        guard playerStatus == noErr, let _ = tmpAudioQueue else {
            print("AudioQueue 创建失败: \(String(describing: playerStatus))")
            return
        }
        audioQueue = tmpAudioQueue

        // 初始化缓冲区
        for _ in 0 ..< queueSize {
            var buffer: AudioQueueBufferRef?
            AudioQueueAllocateBuffer(audioQueue!, UInt32(bufferSize), &buffer)
            if let buffer = buffer {
                audioBuffers.append(buffer)
            }
        }

        // 启动 AudioQueue
        let status = AudioQueueStart(audioQueue!, nil)
        if status == noErr {
            hasStarted = true
            isRunning = true
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    func stop() {
        guard let audioQueue = audioQueue else { return }
        isRunning = false
        AudioQueueStop(audioQueue, false)
        AudioQueueDispose(audioQueue, true)
        self.audioQueue = nil
        queueLock.lock()
        dataQueue.removeAll()
        queueLock.unlock()
        audioBuffers.removeAll()
        playerStatus = nil
        isRunning = false
        hasStarted = false
    }

    func changeFormat(_ format: AudioStreamBasicDescription) {
        stop()
        audioFormat = format
        start()
    }

    func enqueuePCMData(_ data: Data) {
        queueLock.lock()
        dataQueue.append(data)
        queueLock.unlock()
        if !hasStarted {
            print("尝试重新启动 AudioQueue")
            start()
        }
        // 尝试填充一个缓冲区
        ioQueue.async { [weak self] in
            self?.fillBufferIfNeeded()
        }
    }

    private func processBuffer(_ buffer: AudioQueueBufferRef) {
        // 缓冲区回调，标记为可用并重新填充
        buffer.pointee.mAudioDataByteSize = 0
        fillBufferIfNeeded()
    }

    private func fillBufferIfNeeded() {
        guard let audioQueue = audioQueue, isRunning else { return }
        var shouldStop = false
        queueLock.lock()
        if dataQueue.isEmpty {
            var isAllClean = 0
            for buffer in audioBuffers {
                if buffer.pointee.mAudioDataByteSize == 0 {
                    isAllClean += 1
                }
            }
            if isAllClean == audioBuffers.count {
                shouldStop = true
            }
            queueLock.unlock()
            if shouldStop { ioQueue.async { [weak self] in self?.stop() } }
            return
        }
        defer { queueLock.unlock() }

        for buffer in audioBuffers {
            if buffer.pointee.mAudioDataByteSize == 0 {
                var data = dataQueue.first!
                let maxCopy = min(data.count, bufferSize)
                var copySize = maxCopy
                let frameBytes = Int(audioFormat.mBytesPerFrame)
                if frameBytes > 0 { copySize -= (copySize % frameBytes) }
                if copySize <= 0 { return }

                data.withUnsafeBytes { bytes in
                    let rawBuffer = buffer.pointee.mAudioData
                    memcpy(rawBuffer, bytes.baseAddress, copySize)
                }
                buffer.pointee.mAudioDataByteSize = UInt32(copySize)

                if data.count > copySize {
                    let remain = data.subdata(in: copySize..<data.count)
                    dataQueue[0] = remain
                } else {
                    dataQueue.removeFirst()
                }

                let callBackData = Data(bytes: buffer.pointee.mAudioData, count: copySize)
                DispatchQueue.main.async { [weak self] in
                    self?.callBack?(callBackData)
                }
                let status = AudioQueueEnqueueBuffer(audioQueue, buffer, 0, nil)
                if status != noErr {
                    print("缓冲区入队失败: \(status)")
                }
                break
            }
        }
    }

    // MARK: - Deinitialization

    deinit {
        stop()
        if let audioQueue = audioQueue {
            AudioQueueDispose(audioQueue, true)
        }
    }
}
