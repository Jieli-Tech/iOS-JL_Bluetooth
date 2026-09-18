//
//  StreamTransferViewModel.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/4/14.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import JL_BLEKit
import JLLogHelper

class StreamTransferViewModel: NSObject {
    
    enum StreamStatus {
        case idle
        case fetching
        case transferring
        case error(reason: String)
    }
    
    // MARK: - Inputs
    let fetchDeviceInfoCommand = PublishRelay<Void>()
    let startStreamCommand = PublishRelay<([JLStreamPeripheralRequestModel], UInt16)>()
    let stopStreamCommand = PublishRelay<Void>()
    
    // MARK: - Outputs
    let peripherals: Driver<[JLStreamPeripheralResponseModel]>
    let currentFrameImage: Driver<UIImage?>
    let streamStatus: Driver<StreamStatus>
    let alertMessage: Driver<String>
    
    // MARK: - Private properties
    private let _peripherals = BehaviorRelay<[JLStreamPeripheralResponseModel]>(value: [])
    private let _currentFrameImage = BehaviorRelay<UIImage?>(value: nil)
    private let _streamStatus = BehaviorRelay<StreamStatus>(value: .idle)
    private let _alertMessage = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    private var streamTransfer: JLStreamTransfer?
    private var bleManager: JL_ManagerM?
    
    // 视频帧拼包缓存
    // 现已不需要
    // private var jpegBuffer: NSMutableData?
    
    init(bleManager: JL_ManagerM?) {
        self.bleManager = bleManager
        
        self.peripherals = _peripherals.asDriver()
        self.currentFrameImage = _currentFrameImage.asDriver()
        self.streamStatus = _streamStatus.asDriver()
        self.alertMessage = _alertMessage.asDriver(onErrorJustReturn: "未知错误")
        
        super.init()
        
        if let manager = bleManager {
            self.streamTransfer = JLStreamTransfer(manager: manager)
            self.streamTransfer?.delegate = self
        }
        
        bindCommands()
    }
    
    private func bindCommands() {
        // 1. 获取外设信息
        fetchDeviceInfoCommand
            .subscribe(onNext: { [weak self] in
                guard let self = self, let transfer = self.streamTransfer else {
                    self?._alertMessage.accept("BLE Manager is nil")
                    return
                }
                
                self._streamStatus.accept(.fetching)
                JLLogManager.logLevel(.DEBUG, content: "Fetching stream peripherals info...")
                
                transfer.getInfoWithResult { status, response in
                    if status == .success, let res = response {
                        self._peripherals.accept(res.peripherals)
                        self._streamStatus.accept(.idle)
                        JLLogManager.logLevel(.DEBUG, content: "Successfully fetched \(res.peripherals.count) peripherals.")
                    } else {
                        self._alertMessage.accept("获取外设信息失败: \(status.rawValue)")
                        self._streamStatus.accept(.idle)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 2. 发起开启传输
        startStreamCommand
            .subscribe(onNext: { [weak self] (peripherals, expectedMtu) in
                guard let self = self, let transfer = self.streamTransfer else { return }
                
                let startReq = JLStreamStartTransferModel(expectedMtu: expectedMtu, peripherals: peripherals)
                startReq.dir = 0
                
                for peripheral in peripherals {
                    JLLogManager.logLevel(.DEBUG, content: "Starting stream transfer with peripheral\n")
                    peripheral.logProperties()
                }
                JLLogManager.logLevel(.DEBUG, content: "ex MTU: \(expectedMtu)\nEnd\n")
                self._streamStatus.accept(.fetching)
                JLLogManager.logLevel(.DEBUG, content: "Starting stream transfer with \(peripherals.count) peripherals...")
                
                transfer.start(with: startReq) { status, response in
                    if status == .success, let res = response {
                        self._streamStatus.accept(.transferring)
                        JLLogManager.logLevel(.DEBUG, content: "Start transfer successful, negotiated MTU: \(res.negotiatedMtu)")
                    } else {
                        self._streamStatus.accept(.idle)
                        self._alertMessage.accept("开启流失败: \(status.rawValue)")
                        JLLogManager.logLevel(.ERROR, content: "Start transfer failed with status: \(status.rawValue)")
                    }
                }
            })
            .disposed(by: disposeBag)
        
        // 3. 停止传输
        stopStreamCommand
            .subscribe(onNext: { [weak self] in
                guard let self = self, let transfer = self.streamTransfer, let peripheral = transfer.currentStartRequest?.peripherals else { return }
                
                transfer.stop(with: peripheral) { status in
                    if status == .success {
                        self._streamStatus.accept(.idle)
                        self._currentFrameImage.accept(nil)
                        JLLogManager.logLevel(.DEBUG, content: "Stream transfer stopped successfully.")
                    } else {
                        self._alertMessage.accept("停止流失败: \(status.rawValue)")
                        JLLogManager.logLevel(.ERROR, content: "Stop transfer failed with status: \(status.rawValue)")
                    }
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - JLStreamTransferDelegate
extension StreamTransferViewModel: JLStreamTransferDelegate {
    
    func streamTransfer(_ transfer: JLStreamTransfer, didRecevieComplete dataModel: JLStreamDataModel, peripheral: JLStreamPeripheralResponseModel) {
        if peripheral.type == .camera {
            if let image = UIImage(data: dataModel.payloadData) {
                // JLLogManager.logLevel(.DEBUG, content: "Assembled complete JPEG, size: \(data.count)")
                _currentFrameImage.accept(image)
            } else {
                JLLogManager.logLevel(.ERROR, content: "Failed to create UIImage from JPEG data")
            }
        } else if peripheral.type == .mic {
            // 此处省略音频解码播放的逻辑，直接打印大小
            // JLLogManager.logLevel(.DEBUG, content: "Received audio frame data, size: \(data.count)")
        }
    }
    
    func streamTransfer(_ transfer: JLStreamTransfer, didRecevieError error: Error) {
        JLLogManager.logLevel(.ERROR, content: "Stream transfer error: \(error.localizedDescription)")
    }
    
    func streamTransfer(_ transfer: JLStreamTransfer, didReceiveErrorReport report: JLStreamErrorReportModel) {
        let reasonStr = "Reason: \(report.reason), Seq: \(report.seq)"
        JLLogManager.logLevel(.ERROR, content: "Received Error Report - \(reasonStr)")
        
        self._streamStatus.accept(.error(reason: reasonStr))
        // 丢弃当前正在拼装的帧缓存
        // self.jpegBuffer = nil
    }
    
    func streamTransfer(_ transfer: JLStreamTransfer, didReceiveStartTransferRequest request: JLStreamStartTransferModel) {
        // 当前场景不处理被动推流
    }
    
    func streamTransfer(_ transfer: JLStreamTransfer, didReceiveStopTransferRequest request: JLStreamStopTransferModel) {
        // 当前场景处理对方发起的停止请求
        self._streamStatus.accept(.idle)
        self._currentFrameImage.accept(nil)
        // self.jpegBuffer = nil
    }
}

