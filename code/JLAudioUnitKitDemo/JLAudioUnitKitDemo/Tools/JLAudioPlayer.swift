//
//  JLAudioPlayer.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/26.
//

import UIKit
import AVFoundation
import AudioToolbox

class JLAudioPlayer {
    
    static let shared = JLAudioPlayer()
    
    private var audioQueue: AudioQueueRef? = nil
    private var audioFormat: AudioStreamBasicDescription
    private var audioBuffers: [AudioQueueBufferRef] = []
    private let bufferSize: Int = 1024 // 每次播放的数据大小
    private let queueSize: Int = 3 // 缓冲队列的数量
    private var dataQueue: [Data] = [] // 用于存储待播放的 PCM 数据
    private var queueLock = NSLock() // 用于线程安全管理数据队列
    private var playerStatus:OSStatus?
    private var isRunning: Bool = false
    
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
            { userData, queue, buffer in
                // 回调函数，处理缓冲区状态
                let player = Unmanaged<JLAudioPlayer>.fromOpaque(userData!).takeUnretainedValue()
                player.processBuffer(buffer)
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
        for _ in 0..<queueSize {
            var buffer: AudioQueueBufferRef?
            AudioQueueAllocateBuffer(audioQueue!, UInt32(bufferSize), &buffer)
            if let buffer = buffer {
                audioBuffers.append(buffer)
            }
        }
        
        // 启动 AudioQueue
        AudioQueueStart(audioQueue!, nil)
        isRunning = true
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func stop() {
        guard let audioQueue = audioQueue else { return }
        AudioQueueStop(audioQueue, true)
        AudioQueueDispose(audioQueue, true)
        self.audioQueue = nil
        queueLock.lock()
        dataQueue.removeAll()
        queueLock.unlock()
        audioBuffers.removeAll()
        playerStatus = nil
        isRunning = false
    }
    
    func changeFormat(_ format: AudioStreamBasicDescription) {
        stop()
        self.audioFormat = format
        start()
    }
    
    
    func enqueuePCMData(_ data: Data) {
        queueLock.lock()
        dataQueue.append(data) // 添加数据到队列
        queueLock.unlock()
        
        // 尝试填充一个缓冲区
        fillBufferIfNeeded()
    }
    
    private func processBuffer(_ buffer: AudioQueueBufferRef) {
        // 缓冲区回调，标记为可用并重新填充
        buffer.pointee.mAudioDataByteSize = 0
        fillBufferIfNeeded()
    }
    
    private func fillBufferIfNeeded() {
        guard let audioQueue = audioQueue else { return }
        guard isRunning else {
            print("AudioQueue 没有启动")
            return
        }
        guard !dataQueue.isEmpty else {
            print("数据队列为空")
            return
        }
        
        // 找到可用的缓冲区
        for buffer in audioBuffers {
            if buffer.pointee.mAudioDataByteSize == 0 {
                // 检查是否有数据可以填充缓冲区
                queueLock.lock()
                let data = dataQueue.removeFirst()
                queueLock.unlock()
                // 将 PCM 数据填入缓冲区
                data.withUnsafeBytes { bytes in
                    let rawBuffer = buffer.pointee.mAudioData
                    memcpy(rawBuffer, bytes.baseAddress, data.count)
                }
                buffer.pointee.mAudioDataByteSize = UInt32(data.count)
                let callBackData = data
                DispatchQueue.main.async {
                    self.callBack?(callBackData)
                }
                // 将缓冲区入队播放
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
