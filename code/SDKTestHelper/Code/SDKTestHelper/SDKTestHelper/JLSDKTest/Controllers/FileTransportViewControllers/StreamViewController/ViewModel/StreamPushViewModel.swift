//
//  StreamPushViewModel.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/5/28.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import JL_BLEKit
import JLVideoTool
import JLLogHelper

enum PushStatus: Equatable {
    case idle
    case preparing
    case pushing(frameIndex: Int, totalFrames: Int)
    case paused(frameIndex: Int)
    case completed
    case error(reason: String, isRetryable: Bool)
}

enum PushSessionState {
    case disconnected
    case connecting
    case connected
    case ready
}

enum StreamCodecType: Int {
    case jpeg = 0  // JLStreamCameraCodecTypeJPEG = 0x00
    case h264 = 1  // JLStreamCameraCodecTypeH264 = 0x01
}

enum JPEGPushError: Error {
    case fileNotFound
    case fileParseFailed
    case invalidFileFormat
    case frameReadFailed
    case headerExtractFailed
    case bleNotConnected
    case pushSessionFailed
    case pushDataFailed
    case deviceError
    case converterNotReady
    case codecNotSupported
}

class StreamPushViewModel: NSObject {

    // MARK: - Inputs
    let startPushCommand = PublishRelay<Void>()
    let pausePushCommand = PublishRelay<Void>()
    let resumePushCommand = PublishRelay<Void>()
    let stopPushCommand = PublishRelay<Void>()
    let resetPushCommand = PublishRelay<Void>()
    let closePushCommand = PublishRelay<Void>()
    let retryPushCommand = PublishRelay<Void>()
    let increaseFPSCommand = PublishRelay<Void>()
    let decreaseFPSCommand = PublishRelay<Void>()
    let selectCodecCommand = PublishRelay<StreamCodecType>()

    // MARK: - Outputs
    let pushStatus: Driver<PushStatus>
    let sessionState: Driver<PushSessionState>
    let currentFrameIndex: Driver<Int>
    let totalFrames: Driver<Int>
    let fps: Driver<Int>
    let previewImage: Driver<UIImage?>
    let alertMessage: Driver<String>

    let selectedCodec: Driver<StreamCodecType>
    let isCodecSelectable: Driver<Bool>
    let converterStatistics: Driver<JLConverterStatistics?>

    let isStartButtonEnabled: Driver<Bool>
    let isPauseButtonEnabled: Driver<Bool>
    let isResumeButtonEnabled: Driver<Bool>
    let isStopButtonEnabled: Driver<Bool>
    let isResetButtonEnabled: Driver<Bool>
    let isCloseButtonEnabled: Driver<Bool>
    let isRetryButtonVisible: Driver<Bool>
    let isFPSIncreaseEnabled: Driver<Bool>
    let isFPSDecreaseEnabled: Driver<Bool>

    // MARK: - Private properties
    private let disposeBag = DisposeBag()
    private let _pushStatus = BehaviorRelay<PushStatus>(value: .idle)
    private let _sessionState = BehaviorRelay<PushSessionState>(value: .disconnected)
    private let _currentFrameIndex = BehaviorRelay<Int>(value: 0)
    private let _totalFrames = BehaviorRelay<Int>(value: 0)
    private let _fps = BehaviorRelay<Int>(value: 10)
    private let _previewImage = BehaviorRelay<UIImage?>(value: nil)
    private let _alertMessage = PublishRelay<String>()
    private let _selectedCodec = BehaviorRelay<StreamCodecType>(value: .jpeg)
    private let _isCodecSelectable = BehaviorRelay<Bool>(value: true)
    private let _converterStatistics = BehaviorRelay<JLConverterStatistics?>(value: nil)

    private var streamTransfer: JLStreamTransfer?
    private var jpegParser: JPEGStreamParser?
    private var jpegEncoder: JLJPEGEncoder?
    private var bleManager: JL_ManagerM?

    // H264 related
    private var h264Converter: H264StreamConverter?
    private var h264Decoder: JLH264Decoder?

    private var pushTimer: Timer?
    private var isPushing = false
    private var isPaused = false
    private var targetFPS: Int = 10
    private var sharedHeaderData: Data?
    private var totalFrameCount: Int = 0

    // Device capability
    private var deviceSupportsH264 = false
    private var deviceSupportsJPEG = true

    // MARK: - Init
    override init() {
        pushStatus = _pushStatus.asDriver()
        sessionState = _sessionState.asDriver()
        currentFrameIndex = _currentFrameIndex.asDriver()
        totalFrames = _totalFrames.asDriver()
        fps = _fps.asDriver()
        previewImage = _previewImage.asDriver()
        alertMessage = _alertMessage.asDriver(onErrorJustReturn: "未知错误")
        selectedCodec = _selectedCodec.asDriver()
        isCodecSelectable = _isCodecSelectable.asDriver()
        converterStatistics = _converterStatistics.asDriver()

        isStartButtonEnabled = _pushStatus.asDriver().map { $0 == .idle }
        isPauseButtonEnabled = _pushStatus.asDriver().map { status in
            if case .pushing = status { return true }
            return false
        }
        isResumeButtonEnabled = _pushStatus.asDriver().map { status in
            if case .paused = status { return true }
            return false
        }
        isStopButtonEnabled = _pushStatus.asDriver().map { status in
            switch status {
            case .pushing, .paused: return true
            default: return false
            }
        }
        isResetButtonEnabled = _pushStatus.asDriver().map { status in
            switch status {
            case .paused, .completed, .error: return true
            default: return false
            }
        }
        isCloseButtonEnabled = _pushStatus.asDriver().map { status in
            switch status {
            case .idle, .completed, .error: return true
            default: return false
            }
        }
        isRetryButtonVisible = _pushStatus.asDriver().map { status in
            if case .error = status { return true }
            return false
        }
        isFPSIncreaseEnabled = _fps.asDriver().map { $0 < 60 }
        isFPSDecreaseEnabled = _fps.asDriver().map { $0 > 1 }

        super.init()
        setupBLE()
        setupParser()
        bindCommands()
    }

    // MARK: - Setup
    private func setupBLE() {
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 开始初始化BLE...")
        guard let manager = BleManager.shared.currentCmdMgr else {
            JLLogManager.logLevel(.ERROR, content: "[StreamPush] BLE未连接，无法初始化推流功能")
            return
        }
        bleManager = manager
        streamTransfer = JLStreamTransfer(manager: manager)
        streamTransfer?.delegate = self
        jpegEncoder = JLJPEGEncoder()
        jpegEncoder?.globalTargetSize = CGSize(width: 240, height: 320)
        _sessionState.accept(.connected)
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] BLE初始化完成，StreamTransfer已创建")

        // Query device capabilities
        queryDeviceCapabilities()
    }

    private func queryDeviceCapabilities() {
        guard let streamTransfer = streamTransfer else { return }
        streamTransfer.getInfoWithResult { [weak self] status, response in
            guard let self = self else { return }
            guard status == .success, let peripherals = response?.peripherals else {
                JLLogManager.logLevel(.WARN, content: "[StreamPush] 获取设备能力失败，默认仅支持JPEG")
                return
            }
            
            if let localDevice = peripherals.first(where: { $0.type == .localDevice }),
               let videoConfig = localDevice.videoConfig {
                self.deviceSupportsJPEG = (videoConfig.codec & (1 << 0)) != 0
                self.deviceSupportsH264 = (videoConfig.codec & (1 << 1)) != 0
                JLLogManager.logLevel(.INFO, content: "[StreamPush] 本机设备能力: JPEG=\(self.deviceSupportsJPEG), H264=\(self.deviceSupportsH264)")

                if self.deviceSupportsH264 {
                    self._selectedCodec.accept(.h264)
                } else if self.deviceSupportsJPEG {
                    self._selectedCodec.accept(.jpeg)
                }
                self._isCodecSelectable.accept(self.deviceSupportsH264 && self.deviceSupportsJPEG)
            }
        }
    }

    private func setupParser() {
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 开始解析JPEG流文件...")
        guard let filePath = Bundle.main.path(forResource: "jpeg_stream_data", ofType: "data") else {
            JLLogManager.logLevel(.ERROR, content: "[StreamPush] jpeg_stream_data.data 文件未找到")
            return
        }
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 找到文件: \(filePath)")
        guard let parser = JPEGStreamParser(filePath: filePath) else {
            JLLogManager.logLevel(.ERROR, content: "[StreamPush] JPEG流文件解析失败")
            return
        }
        jpegParser = parser
        totalFrameCount = parser.totalFrames
        _totalFrames.accept(totalFrameCount)
        JLLogManager.logLevel(.INFO, content: "[StreamPush] 文件解析成功，总帧数: \(totalFrameCount)")
    }

    // MARK: - Command Bindings
    private func bindCommands() {
        startPushCommand
            .subscribe(onNext: { [weak self] in
                self?.handleStartPush()
            })
            .disposed(by: disposeBag)

        pausePushCommand
            .subscribe(onNext: { [weak self] in
                self?.handlePause()
            })
            .disposed(by: disposeBag)

        resumePushCommand
            .subscribe(onNext: { [weak self] in
                self?.handleResume()
            })
            .disposed(by: disposeBag)

        stopPushCommand
            .subscribe(onNext: { [weak self] in
                self?.handleStop()
            })
            .disposed(by: disposeBag)

        resetPushCommand
            .subscribe(onNext: { [weak self] in
                self?.handleReset()
            })
            .disposed(by: disposeBag)

        closePushCommand
            .subscribe(onNext: { [weak self] in
                self?.handleClose()
            })
            .disposed(by: disposeBag)

        retryPushCommand
            .subscribe(onNext: { [weak self] in
                self?.handleRetry()
            })
            .disposed(by: disposeBag)

        increaseFPSCommand
            .subscribe(onNext: { [weak self] in
                self?.handleIncreaseFPS()
            })
            .disposed(by: disposeBag)

        decreaseFPSCommand
            .subscribe(onNext: { [weak self] in
                self?.handleDecreaseFPS()
            })
            .disposed(by: disposeBag)

        selectCodecCommand
            .subscribe(onNext: { [weak self] codec in
                self?.handleSelectCodec(codec)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Codec Selection
    private func handleSelectCodec(_ codec: StreamCodecType) {
        guard !isPushing else {
            JLLogManager.logLevel(.WARN, content: "[StreamPush] 推流中，无法切换编码格式")
            _alertMessage.accept("推流中无法切换编码格式")
            return
        }

        switch codec {
        case .h264:
            guard deviceSupportsH264 else {
                _alertMessage.accept("设备不支持H264编码")
                return
            }
        case .jpeg:
            guard deviceSupportsJPEG else {
                _alertMessage.accept("设备不支持JPEG编码")
                return
            }
        }

        _selectedCodec.accept(codec)
        JLLogManager.logLevel(.INFO, content: "[StreamPush] 编码格式已切换为: \(codec == .h264 ? "H264" : "JPEG")")
    }

    // MARK: - Push Session Management
    private func handleStartPush() {
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] ========== 开始推流流程 ==========")
        guard let streamTransfer = streamTransfer, let parser = jpegParser else {
            JLLogManager.logLevel(.ERROR, content: "[StreamPush] 推流初始化失败: streamTransfer=\(streamTransfer != nil), parser=\(jpegParser != nil)")
            handleError(.bleNotConnected, isRetryable: false)
            return
        }

        let codec = _selectedCodec.value
        JLLogManager.logLevel(.INFO, content: "[StreamPush] 使用编码格式: \(codec == .h264 ? "H264" : "JPEG")")

        _pushStatus.accept(.preparing)

        if codec == .jpeg {
            startJPEGPush(streamTransfer: streamTransfer, parser: parser)
        } else {
            startH264Push(streamTransfer: streamTransfer, parser: parser)
        }
    }

    private func startJPEGPush(streamTransfer: JLStreamTransfer, parser: JPEGStreamParser) {
        guard let encoder = jpegEncoder else {
            handleError(.bleNotConnected, isRetryable: false)
            return
        }

        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 状态: preparing，开始提取JPEG Header...")

        // Extract and cache first frame header
        if let header = parser.extractFirstFrameHeader(encoder: encoder) {
            sharedHeaderData = header
            streamTransfer.setJPEGHeaderData(header, for: 1)
            JLLogManager.logLevel(.DEBUG, content: "[StreamPush] JPEG Header已缓存，大小: \(header.count) bytes")
        } else {
            JLLogManager.logLevel(.WARN, content: "[StreamPush] 未能提取JPEG Header，将发送完整JPEG数据")
        }

        let cameraReq = JLStreamPeripheralRequestModel(
            type: .camera,
            index: 1,
            number: 1,
            codec: UInt8(StreamCodecType.jpeg.rawValue)
        )
        cameraReq.fps = UInt8(targetFPS)
        cameraReq.width = 320
        cameraReq.height = 240
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 创建JPEG推送请求: index=1, fps=\(targetFPS), width=320, height=240, mtu=512")

        let pushReq = JLStreamStartTransferModel(expectedMtu: 512, peripherals: [cameraReq])
        pushReq.dir = 1

        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 正在建立BLE推送会话...")
        streamTransfer.startPushStream(with: pushReq) { [weak self] status, response in
            guard let self = self else { return }
            if status == .success {
                let mtu = response?.negotiatedMtu ?? 0
                JLLogManager.logLevel(.INFO, content: "[StreamPush] BLE推送会话建立成功，协商MTU: \(mtu)")
                self._sessionState.accept(.ready)
                self.startPushing()
            } else {
                JLLogManager.logLevel(.ERROR, content: "[StreamPush] BLE推送会话建立失败，状态码: \(status.rawValue)")
                self.handleError(.pushSessionFailed, isRetryable: true)
            }
        }
    }

    private func startH264Push(streamTransfer: JLStreamTransfer, parser: JPEGStreamParser) {
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 状态: preparing，初始化H264转换器...")

        // Initialize H264 converter
        if h264Converter == nil {
            guard let converter = H264StreamConverter(
                width: 320,
                height: 240,
                fps: targetFPS,
                bitrate: 0,
                encoderType: .auto
            ) else {
                JLLogManager.logLevel(.ERROR, content: "[StreamPush] H264转换器初始化失败")
                handleError(.converterNotReady, isRetryable: false)
                return
            }
            h264Converter = converter
            converter.onFrameConverted = { [weak self] frame in
                // Frame is queued, will be picked up by push loop
                JLLogManager.logLevel(.DEBUG, content: "[StreamPush] H264帧 #\(frame.frameIndex) 转码完成, size=\(frame.h264Data.count)")
            }
            converter.onError = { [weak self] error in
                JLLogManager.logLevel(.ERROR, content: "[StreamPush] H264转换错误: \(error.localizedDescription)")
                self?.handleError(.converterNotReady, isRetryable: true)
            }
            converter.onStatisticsUpdate = { [weak self] stats in
                self?._converterStatistics.accept(stats)
            }
        }

        h264Converter?.startConverting()

        // Initialize H264 decoder for preview
        if h264Decoder == nil {
            h264Decoder = JLH264Decoder()
            h264Decoder?.supportsBFrames = false
        }

        let cameraReq = JLStreamPeripheralRequestModel(
            type: .camera,
            index: 1,
            number: 1,
            codec: UInt8(StreamCodecType.h264.rawValue)
        )
        cameraReq.fps = UInt8(targetFPS)
        cameraReq.width = 320
        cameraReq.height = 240
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 创建H264推送请求: index=1, fps=\(targetFPS), width=320, height=240, mtu=1024")

        // H264 uses larger MTU since frames are larger after encoding
        let pushReq = JLStreamStartTransferModel(expectedMtu: 1024, peripherals: [cameraReq])
        pushReq.dir = 1

        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 正在建立BLE推送会话...")
        streamTransfer.startPushStream(with: pushReq) { [weak self] status, response in
            guard let self = self else { return }
            if status == .success {
                let mtu = response?.negotiatedMtu ?? 0
                JLLogManager.logLevel(.INFO, content: "[StreamPush] BLE推送会话建立成功，协商MTU: \(mtu)")
                self._sessionState.accept(.ready)
                self.startPushing()
            } else {
                JLLogManager.logLevel(.ERROR, content: "[StreamPush] BLE推送会话建立失败，状态码: \(status.rawValue)")
                self.handleError(.pushSessionFailed, isRetryable: true)
            }
        }
    }

    private func handleClose() {
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] ========== 关闭推流会话 ==========")
        stopPushLoop()
        isPushing = false
        isPaused = false
        _currentFrameIndex.accept(0)
        clearError()
        sharedHeaderData = nil
        h264Converter?.stopConverting()

        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 正在发送停止推流命令...")
        streamTransfer?.stopPushStream(withIndices: [1]) { [weak self] status in
            JLLogManager.logLevel(.INFO, content: "[StreamPush] BLE推送会话已关闭，状态码: \(status.rawValue)")
            self?._sessionState.accept(.disconnected)
            self?._pushStatus.accept(.idle)
        }
    }

    // MARK: - Push Control
    private func startPushing() {
        guard jpegParser != nil else {
            JLLogManager.logLevel(.ERROR, content: "[StreamPush] 开始推流失败: parser未初始化")
            handleError(.fileParseFailed, isRetryable: false)
            return
        }

        isPushing = true
        isPaused = false
        _currentFrameIndex.accept(0)
        _pushStatus.accept(.pushing(frameIndex: 0, totalFrames: totalFrameCount))
        JLLogManager.logLevel(.INFO, content: "[StreamPush] ========== 推流开始 ==========")
        JLLogManager.logLevel(.INFO, content: "[StreamPush] 总帧数: \(totalFrameCount), 目标FPS: \(targetFPS), 间隔: \(String(format: "%.3f", 1.0/Double(targetFPS)))s")

        // Push first frame immediately
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 立即推送第0帧...")
        pushFrame(at: 0)
        _currentFrameIndex.accept(1)

        startPushLoop()
    }

    private func startPushLoop() {
        stopPushLoop()

        let interval = 1.0 / Double(targetFPS)
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 启动定时器，间隔: \(String(format: "%.3f", interval))s")
        pushTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else {
                JLLogManager.logLevel(.WARN, content: "[StreamPush] 定时器回调: self已释放")
                return
            }
            guard self.isPushing else {
                JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 定时器回调: isPushing=false，跳过")
                return
            }
            guard !self.isPaused else {
                JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 定时器回调: isPaused=true，跳过")
                return
            }

            let frameIndex = self._currentFrameIndex.value
            guard frameIndex < self.totalFrameCount else {
                JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 所有帧推送完成，当前帧索引: \(frameIndex)")
                self.handlePushCompleted()
                return
            }

            self.pushFrame(at: frameIndex)
            self._currentFrameIndex.accept(frameIndex + 1)
        }
    }

    private func stopPushLoop() {
        if pushTimer != nil {
            JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 停止定时器")
            pushTimer?.invalidate()
            pushTimer = nil
        }
    }

    private func restartPushLoop() {
        guard isPushing && !isPaused else { return }
        startPushLoop()
    }

    private func pushFrame(at index: Int) {
        guard let streamTransfer = streamTransfer, let parser = jpegParser else {
            JLLogManager.logLevel(.ERROR, content: "[StreamPush] 推送帧失败: streamTransfer=\(streamTransfer != nil), parser=\(jpegParser != nil)")
            return
        }

        let codec = _selectedCodec.value

        if codec == .jpeg {
            pushJPEGFrame(at: index, streamTransfer: streamTransfer, parser: parser)
        } else {
            pushH264Frame(at: index, streamTransfer: streamTransfer, parser: parser)
        }
    }

    private func pushJPEGFrame(at index: Int, streamTransfer: JLStreamTransfer, parser: JPEGStreamParser) {
        guard let frameData = parser.getFrame(at: index) else {
            JLLogManager.logLevel(.ERROR, content: "[StreamPush] 读取帧数据失败，帧索引: \(index)")
            handleError(.frameReadFailed, isRetryable: true)
            return
        }

        let frameSize = frameData.count
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 推送JPEG帧 #\(index)/\(totalFrameCount), 大小: \(frameSize) bytes")

        do {
            try streamTransfer.pushStreamData(frameData, index: 1)
            JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 帧 #\(index) 推送成功")
        } catch {
            JLLogManager.logLevel(.ERROR, content: "[StreamPush] 推送帧 #\(index) 失败: \(error.localizedDescription)")
            handleError(.pushDataFailed, isRetryable: true)
            return
        }

        // Update preview
        if let encoder = jpegEncoder, let header = sharedHeaderData {
            if let scan = try? encoder.extractScanData(frameData) {
                var previewData = Data()
                previewData.append(header)
                previewData.append(scan)
                if let image = UIImage(data: previewData) {
                    _previewImage.accept(image)
                    JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 预览图更新成功 (使用header+scan)")
                }
            }
        } else if let image = UIImage(data: frameData) {
            _previewImage.accept(image)
            JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 预览图更新成功 (使用完整帧)")
        }

        _pushStatus.accept(.pushing(frameIndex: index, totalFrames: totalFrameCount))
    }

    private func pushH264Frame(at index: Int, streamTransfer: JLStreamTransfer, parser: JPEGStreamParser) {
        guard let converter = h264Converter else {
            JLLogManager.logLevel(.ERROR, content: "[StreamPush] H264转换器未初始化")
            handleError(.converterNotReady, isRetryable: false)
            return
        }

        guard let jpegData = parser.getFrame(at: index) else {
            JLLogManager.logLevel(.ERROR, content: "[StreamPush] 读取帧数据失败，帧索引: \(index)")
            handleError(.frameReadFailed, isRetryable: true)
            return
        }

        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 转换H264帧 #\(index)/\(totalFrameCount)...")

        // Async convert JPEG to H264 (non-blocking)
        converter.convertFrame(jpegData, frameIndex: index) { [weak self] h264Frame in
            guard let self = self else { return }

            guard let h264Frame = h264Frame else {
                JLLogManager.logLevel(.ERROR, content: "[StreamPush] H264转码失败，帧索引: \(index)")
                // For H264, continue with next frame instead of stopping
                self._pushStatus.accept(.pushing(frameIndex: index, totalFrames: self.totalFrameCount))
                return
            }

            let frameSize = h264Frame.h264Data.count
            JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 推送H264帧 #\(index), 大小: \(frameSize) bytes, keyFrame=\(h264Frame.isKeyFrame)")

            do {
                try streamTransfer.pushStreamData(h264Frame.h264Data, index: 1)
                JLLogManager.logLevel(.DEBUG, content: "[StreamPush] H264帧 #\(index) 推送成功")
            } catch {
                JLLogManager.logLevel(.ERROR, content: "[StreamPush] 推送H264帧 #\(index) 失败: \(error.localizedDescription)")
                // For H264, continue with next frame instead of stopping
                self._pushStatus.accept(.pushing(frameIndex: index, totalFrames: self.totalFrameCount))
                return
            }

            // Update preview using JPEG data (since H264 preview requires decoding)
            if let image = UIImage(data: jpegData) {
                self._previewImage.accept(image)
                JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 预览图更新成功 (使用原始JPEG)")
            }

            self._pushStatus.accept(.pushing(frameIndex: index, totalFrames: self.totalFrameCount))
        }
    }

    private func handlePause() {
        isPaused = true
        let frameIndex = _currentFrameIndex.value
        _pushStatus.accept(.paused(frameIndex: frameIndex))
        JLLogManager.logLevel(.INFO, content: "[StreamPush] 推流已暂停，当前帧: \(frameIndex)")
    }

    private func handleResume() {
        isPaused = false
        let frameIndex = _currentFrameIndex.value
        _pushStatus.accept(.pushing(frameIndex: frameIndex, totalFrames: totalFrameCount))
        JLLogManager.logLevel(.INFO, content: "[StreamPush] 推流已继续，从帧 \(frameIndex) 开始")
    }

    private func handleStop() {
        JLLogManager.logLevel(.INFO, content: "[StreamPush] ========== 停止推流 ==========")
        stopPushLoop()
        isPushing = false
        isPaused = false
        _currentFrameIndex.accept(0)
        h264Converter?.stopConverting()
        _pushStatus.accept(.idle)
        JLLogManager.logLevel(.INFO, content: "[StreamPush] 推流已停止，进度已重置")
    }

    private func handleReset() {
        JLLogManager.logLevel(.INFO, content: "[StreamPush] ========== 重置推流状态 ==========")
        stopPushLoop()
        isPushing = false
        isPaused = false
        _currentFrameIndex.accept(0)
        _previewImage.accept(nil)
        clearError()
        sharedHeaderData = nil
        h264Converter?.reset()
        _pushStatus.accept(.idle)
        JLLogManager.logLevel(.INFO, content: "[StreamPush] 推流状态已重置，header缓存已清空")
    }

    private func handleRetry() {
        guard case .error = _pushStatus.value else {
            JLLogManager.logLevel(.WARN, content: "[StreamPush] 重试失败: 当前状态不是error")
            return
        }
        JLLogManager.logLevel(.INFO, content: "[StreamPush] ========== 重试推流 ==========")
        clearError()
        handleStartPush()
    }

    private func handlePushCompleted() {
        JLLogManager.logLevel(.INFO, content: "[StreamPush] ========== 推流完成 ==========")
        stopPushLoop()
        isPushing = false
        isPaused = false
        h264Converter?.stopConverting()
        _pushStatus.accept(.completed)
        JLLogManager.logLevel(.INFO, content: "[StreamPush] 推流已完成，共推送 \(totalFrameCount) 帧")
    }

    // MARK: - FPS Control
    private func handleIncreaseFPS() {
        guard targetFPS < 60 else {
            JLLogManager.logLevel(.WARN, content: "[StreamPush] 帧率已达最大值 60 FPS")
            return
        }
        targetFPS += 1
        _fps.accept(targetFPS)
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 帧率已增加到 \(targetFPS) FPS")
        if isPushing && !isPaused {
            JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 推流中，重新启动定时器以应用新帧率")
            restartPushLoop()
        }
    }

    private func handleDecreaseFPS() {
        guard targetFPS > 1 else {
            JLLogManager.logLevel(.WARN, content: "[StreamPush] 帧率已达最小值 1 FPS")
            return
        }
        targetFPS -= 1
        _fps.accept(targetFPS)
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 帧率已减少到 \(targetFPS) FPS")
        if isPushing && !isPaused {
            JLLogManager.logLevel(.DEBUG, content: "[StreamPush] 推流中，重新启动定时器以应用新帧率")
            restartPushLoop()
        }
    }

    // MARK: - Error Handling
    private func handleError(_ error: JPEGPushError, isRetryable: Bool) {
        JLLogManager.logLevel(.ERROR, content: "[StreamPush] ========== 推流错误 ==========")
        stopPushLoop()
        isPushing = false
        isPaused = false
        h264Converter?.stopConverting()

        let reason: String
        switch error {
        case .fileNotFound:
            reason = "JPEG流文件未找到"
        case .fileParseFailed:
            reason = "JPEG流文件解析失败"
        case .invalidFileFormat:
            reason = "无效的文件格式"
        case .frameReadFailed:
            reason = "帧数据读取失败"
        case .headerExtractFailed:
            reason = "JPEG Header提取失败"
        case .bleNotConnected:
            reason = "蓝牙未连接"
        case .pushSessionFailed:
            reason = "推送会话建立失败"
        case .pushDataFailed:
            reason = "数据推送失败"
        case .deviceError:
            reason = "设备端异常"
        case .converterNotReady:
            reason = "H264转换器未就绪"
        case .codecNotSupported:
            reason = "设备不支持该编码格式"
        }

        _pushStatus.accept(.error(reason: reason, isRetryable: isRetryable))
        JLLogManager.logLevel(.ERROR, content: "[StreamPush] 错误原因: \(reason), 是否可重试: \(isRetryable)")
    }

    private func clearError() {
        // Error state cleared by transitioning to another state
    }

    deinit {
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] ViewModel deinit")
        stopPushLoop()
        h264Converter?.stopConverting()
        if isPushing {
            JLLogManager.logLevel(.DEBUG, content: "[StreamPush] deinit时停止推流会话")
            streamTransfer?.stopPushStream(withIndices: [1]) { _ in }
        }
    }
}

// MARK: - JLStreamTransferDelegate
extension StreamPushViewModel: JLStreamTransferDelegate {
    func streamTransfer(_ transfer: JLStreamTransfer, didRecevieComplete dataModel: JLStreamDataModel, peripheral: JLStreamPeripheralResponseModel) {
        // Push mode does not handle received data
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] Delegate: 收到数据 (推送模式下忽略)")
    }

    func streamTransfer(_ transfer: JLStreamTransfer, didRecevieError error: Error) {
        JLLogManager.logLevel(.ERROR, content: "[StreamPush] Delegate: 传输错误 - \(error.localizedDescription)")
    }

    func streamTransfer(_ transfer: JLStreamTransfer, didReceiveErrorReport report: JLStreamErrorReportModel) {
        JLLogManager.logLevel(.ERROR, content: "[StreamPush] Delegate: 设备端错误报告 - Reason: \(report.reason), Seq: \(report.seq)")
        // For JPEG: reset header state (SDK handles this automatically)
        // For H264: directly send next complete frame (no special handling needed)
        handleError(.deviceError, isRetryable: true)
    }

    func streamTransfer(_ transfer: JLStreamTransfer, didReceiveStartTransferRequest request: JLStreamStartTransferModel) {
        JLLogManager.logLevel(.DEBUG, content: "[StreamPush] Delegate: 收到开始传输请求")
    }

    func streamTransfer(_ transfer: JLStreamTransfer, didReceiveStopTransferRequest request: JLStreamStopTransferModel) {
        JLLogManager.logLevel(.INFO, content: "[StreamPush] Delegate: 设备端请求停止推流")
        stopPushLoop()
        isPushing = false
        isPaused = false
        h264Converter?.stopConverting()
        _pushStatus.accept(.idle)
    }
}
