//
//  TranslateViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/1/6.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JLAudioUnitKit
import UIKit

class TranslateViewController: BaseViewController {
    var translateHelper: JLTranslationManager?
    var currentAudioData: JLTranslateAudio?
    var currentMode: JLTranslateSetMode = JLTranslateSetMode()
    let modeTitleLab = UILabel()
    var modeSelectView: DropdownView<String> = DropdownView<String>()
    var recordPolicyView: DropdownView<String> = DropdownView<String>()
    var audioTypeView: DropdownView<String> = DropdownView<String>()
    var channelView: DropdownView<Int> = DropdownView<Int>()
    var rateSelect: InputView = InputView()
    var switchLocal: EcLabSwitch = EcLabSwitch()
    var testAV2Helper: TranslateAV2Helper?
  

    let recordTsBtn = UIButton()
    let sendOpusBtn = UIButton()
    let stopBtn = UIButton()
    let statusLab = UILabel()
    let configBtn = UIButton()
    let testBtn = UIButton()
    let subTextLab = UILabel()
    
    private var audioData: JLTranslateAudio?
    private var isCallObs: NSKeyValueObservation?
    private var isLocal:Bool = true
    private var subscribeTarget: Disposable?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let mgr = BleManager.shared.currentCmdMgr else { return }
        SoundInfoManager.share.addSendToDev(mgr)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SoundInfoManager.share.removeSendToDev()
        translateHelper?.trDestory()
        translateHelper = nil
        TranslateVM.shared.clear()
        subscribeTarget?.dispose()
        isCallObs?.invalidate()
    }

    
    override func initUI() {
        navigationView.title = R.localStr.translateTransfer()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        navigationView.rightBtn.setTitle("Config", for: .normal)
        navigationView.rightBtn.isHidden = false
        
        switchLocal.configSwitch(title: "Local Only", isOn: true)
        
        currentMode.modeType = .idle
        currentMode.channel = 1
        currentMode.dataType = .OPUS
        currentMode.sampleRate = 16000
        modeSelectViewInit()
        recordPolicyViewInit()
        audioTypeViewInit()
        channelViewInit()
        rateSelectInit()
        
        view.addSubview(modeTitleLab)
        view.addSubview(modeSelectView)
        view.addSubview(recordPolicyView)
        view.addSubview(audioTypeView)
        view.addSubview(channelView)
        view.addSubview(rateSelect)
        view.addSubview(switchLocal)

        view.addSubview(recordTsBtn)
        view.addSubview(sendOpusBtn)
        view.addSubview(statusLab)
        view.addSubview(stopBtn)
        view.addSubview(configBtn)
        view.addSubview(testBtn)
        view.addSubview(subTextLab)

        recordTsBtn.setTitle("Set Mode", for: .normal)
        recordTsBtn.setTitleColor(.white, for: .normal)
        recordTsBtn.backgroundColor = UIColor.random()
        recordTsBtn.layer.cornerRadius = 10
        recordTsBtn.layer.masksToBounds = true
        recordTsBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        recordTsBtn.isUserInteractionEnabled = false

        sendOpusBtn.setTitle(R.localStr.sendOpus(), for: .normal)
        sendOpusBtn.setTitleColor(.white, for: .normal)
        sendOpusBtn.backgroundColor = UIColor.random()
        sendOpusBtn.layer.cornerRadius = 10
        sendOpusBtn.layer.masksToBounds = true
        sendOpusBtn.alpha = 0.5
        sendOpusBtn.titleLabel?.adjustsFontSizeToFitWidth = false

        stopBtn.setTitle(R.localStr.exitTranslateMode(), for: .normal)
        stopBtn.setTitleColor(.white, for: .normal)
        stopBtn.backgroundColor = UIColor.random()
        stopBtn.layer.cornerRadius = 10
        stopBtn.layer.masksToBounds = true
        stopBtn.titleLabel?.adjustsFontSizeToFitWidth = true

        statusLab.text = R.localStr.unopened()
        statusLab.textColor = .black
        statusLab.font = .boldSystemFont(ofSize: 12)
        statusLab.adjustsFontSizeToFitWidth = true
        statusLab.textAlignment = .center
        
        configBtn.setTitle("Config", for: .normal)
        configBtn.setTitleColor(.white, for: .normal)
        configBtn.backgroundColor = UIColor.random()
        configBtn.layer.cornerRadius = 10
        configBtn.layer.masksToBounds = true
        
        testBtn.setTitle("Test", for: .normal)
        testBtn.setTitleColor(.white, for: .normal)
        testBtn.backgroundColor = UIColor.random()
        testBtn.layer.cornerRadius = 10
        testBtn.layer.masksToBounds = true
        
        subTextLab.text = ""
        subTextLab.textColor = .black
        subTextLab.font = .boldSystemFont(ofSize: 12)
        subTextLab.adjustsFontSizeToFitWidth = true
        subTextLab.textAlignment = .center

        modeTitleLab.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }

        modeSelectView.snp.makeConstraints { make in
            make.top.equalTo(modeTitleLab.snp.bottom)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        audioTypeView.snp.makeConstraints { make in
            make.top.equalTo(modeSelectView.snp.bottom)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        recordPolicyView.snp.makeConstraints { make in
            make.top.equalTo(audioTypeView.snp.bottom)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        channelView.snp.makeConstraints { make in
            make.top.equalTo(recordPolicyView.snp.bottom)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        rateSelect.snp.makeConstraints { make in
            make.top.equalTo(channelView.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        switchLocal.snp.makeConstraints { make in
            make.top.equalTo(rateSelect.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(35)
        }

        statusLab.snp.makeConstraints { make in
            make.top.equalTo(switchLocal.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }

        recordTsBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.top.equalTo(statusLab.snp.bottom).offset(10)
        }

        sendOpusBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.top.equalTo(recordTsBtn.snp.bottom).offset(10)
        }

        stopBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.top.equalTo(sendOpusBtn.snp.bottom).offset(10)
        }
        
        configBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.right.equalTo(testBtn.snp.left).offset(-10)
            make.height.equalTo(40)
            make.width.equalTo(testBtn.snp.width)
            make.top.equalTo(stopBtn.snp.bottom).offset(10)
        }
        
        testBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.left.equalTo(configBtn.snp.right).offset(10)
            make.height.equalTo(40)
            make.width.equalTo(configBtn.snp.width)
            make.top.equalTo(stopBtn.snp.bottom).offset(10)
        }

        subTextLab.snp.makeConstraints { make in
            make.top.equalTo(configBtn.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        AVAudioSession.sharedInstance().requestRecordPermission { grand in
            if !grand {
                self.view.makeToast("User denied microphone permission", position: .center)
            }
        }
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            self.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        navigationView.rightBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.navigationController?.pushViewController(TranslateSetViewController(), animated: true)
        }).disposed(by: disposeBag)

        recordTsBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            if self.translateHelper?.trIsWorking() == true {
                self.view.makeToast(R.localStr.pleaseExitOtherModesFirst(), position: .center)
                return
            }
            self.translateHelper?.trStartTranslate(currentMode) { _, _ in
                // TODO: 根据回调结果再决定要不要下发语音数据给设备
                // 或者这里有个标记位，待设备返回后再下发语音数据给设备
                // self.translateHelper?.trWrite(currentAudioData, translate: localOpusData)
            }
        }.disposed(by: disposeBag)

        sendOpusBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self,
                  let dataUrl = R.file.test_translationOpus(),
                  let data = try? Data(contentsOf: dataUrl) else { return }
            let audio = JLTranslateAudio()
            audio.audioType = .OPUS
            audio.sourceType = .typePhoneMic
            self.translateHelper?.trWrite(audio, translate: data)
//            TranslateVM.shared.sendOpusTest(data)
        }.disposed(by: disposeBag)

        stopBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            self.translateHelper?.trExitMode { _, _ in
            }
        }.disposed(by: disposeBag)
        


        // 初始化翻译传输管理
        if let manater = BleManager.shared.currentCmdMgr {
            translateHelper = JLTranslationManager(delegate: self, manager: manater) { [weak self] state, err in
                self?.handleIsCalling()
            }
        }
        
        testBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            if let path = R.file.convertedPcm() {
                let data = try! Data(contentsOf: path)
                self.testAV2Helper?.pcmToEnCodeData(data)
            }
        }).disposed(by: disposeBag)
        
        JLAudioPlayer.shared.start()
       
        testAV2Helper = TranslateAV2Helper({ pcm in
            JLAudioPlayer.shared.enqueuePCMData(pcm)
        }, { [weak self] encodeData in
            self?.testAV2Helper?.decodeDataToPcm(encodeData)
        })
        
        switchLocal.swBtn.rx.value.subscribe(onNext: { [weak self] isOn in
            guard let `self` = self else { return }
            isLocal = isOn
        }).disposed(by: disposeBag)
        
    }
    
    private func handleIsCalling() {
        isCallObs = translateHelper?.observe(\.isCalling,options: [.new], changeHandler: { [weak self] mgr, change in
           guard let `self` = self else { return }
            guard let value = change.newValue else { return }
            let tips = value ? "通话中" : "不在通话中"
            let currentThead = Thread.current
            if !currentThead.isMainThread {
                DispatchQueue.main.async {
                    self.view.makeToast(tips, position: .center)
                }
            } else {
                self.view.makeToast(tips, position: .center)
            }
            if translateHelper?.isCalling == true && translateHelper?.translateMode.modeType != .callTranslate {
                self.translateHelper?.trExitMode({ _, err in
                    if let err = err {
                        self.view.makeToast("退出通话失败:\(err)", position: .center)
                    }
                })
            }
        })
    }
    
    private func recordPolicyViewInit(){
        let items = ["APP 录音下发", "设备录音上传"]
        recordPolicyView.updateItems(items)
        recordPolicyView.onSelect = { item in
            switch item {
            case "APP 录音下发":
                self.translateHelper?.recordtype = .byPhone
            case "设备录音上传":
                self.translateHelper?.recordtype = .byDevice
            default:
                break
            }
        }
        recordPolicyView.title = "录音策略"
        recordPolicyView.defaultValue = "APP 录音下发"
        recordPolicyView.show(false)
    }

    private func audioTypeViewInit() {
        audioTypeView.title = "音频类型"
        let items = ["PCM", "Opus", "SPEEX", "MSBC", "JLA_V2"]
        audioTypeView.updateItems(items)
        audioTypeView.defaultValue = "Opus"
        audioTypeView.onSelect = { item in
            switch item {
            case "PCM":
                self.currentAudioData?.audioType = .PCM
            case "Opus":
                self.currentAudioData?.audioType = .OPUS
            case "SPEEX":
                self.currentAudioData?.audioType = .SPEEX
            case "MSBC":
                self.currentAudioData?.audioType = .MSBC
            case "JLA_V2":
                self.currentAudioData?.audioType = .JLA_V2
            default:
                break
            }
        }
        
    }
    
    private func channelViewInit() {
        channelView.title = "声道"
        let items = [1, 2]
        channelView.updateItems(items)
        channelView.onSelect = { item in
            self.currentMode.channel = item
        }
    }
    
    private func rateSelectInit() {
        rateSelect.configure(title: "采样率", placeholder: "16000", "16000")
        rateSelect.textField.keyboardType = .numberPad
        rateSelect.textObservable.subscribe(onNext: { value in
            self.currentMode.sampleRate = Int(value) ?? 0
        }).disposed(by: disposeBag)
        let tapges = UITapGestureRecognizer(target: self, action: #selector(tapToCloseEdit))
        self.view.addGestureRecognizer(tapges)
    }
    
    @objc private func tapToCloseEdit() {
        rateSelect.textField.endEditing(true)
    }
    
    private func modeSelectViewInit() {
        modeSelectView.title = "翻译模式"
        let items = ["空闲", "录音翻译", "仅录音", "通话翻译", "音频翻译", "面对面翻译"]
        modeSelectView.updateItems(items)
        modeSelectView.onSelect = { item in
            self.recordPolicyView.show(false)
            switch item {
            case "空闲":
                self.currentMode.modeType = .idle
            case "录音翻译":
                self.currentMode.modeType = .recordTranslate
                self.recordPolicyView.show(true)
            case "仅录音":
                self.currentMode.modeType = .onlyRecord
            case "通话翻译":
                self.currentMode.modeType = .callTranslate
            case "音频翻译":
                self.currentMode.modeType = .audioTranslate
            case "面对面翻译":
                self.currentMode.modeType = .faceToFaceTranslate
            default:
                break
            }
        }
    }
    
    private func getSourceType(_ sourceType: JLTranslateSetModeType) -> String {
        switch sourceType {
        case .idle:
            return "空闲"
        case .onlyRecord:
            return "仅录音"
        case .recordTranslate:
            return "录音翻译"
        case .callTranslate:
            return "通话翻译"
        case .audioTranslate:
            return "音频翻译"
        case .faceToFaceTranslate:
            return "面对面翻译"
        @unknown default:
            return "未知"
        }
    }
    private func submitData(){
        subscribeTarget?.dispose()
        
        subscribeTarget = TranslateVM.shared.targetData.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            if translateHelper?.trIsPlayWithA2dp() ?? false {
                JLAudioPlayer.shared.enqueuePCMData(data)
            } else {
                if let audioData = self.audioData {
                    translateHelper?.trWrite(audioData, translate: data)
                }
            }
        })
    }
    
}

extension TranslateViewController: JLTranslationManagerDelegate {
    func onInitSuccess(_: String) {
        recordTsBtn.isUserInteractionEnabled = true
    }

    func onModeChange(_: String, mode: JLTranslateSetMode) {
        if mode.modeType != .idle {
            statusLab.text = R.localStr.opened()
            stopBtn.isUserInteractionEnabled = true
        } else {
            stopBtn.isUserInteractionEnabled = false
            statusLab.text = R.localStr.unopened()
            sendOpusBtn.isUserInteractionEnabled = false
            sendOpusBtn.alpha = 0.5
        }
        currentMode = mode
        let str = getSourceType(mode.modeType)
        modeSelectView.scrollToItem(str)
        
        JLLogManager.logLevel(.DEBUG, content: "modeType:\(String(describing: mode.modeType))")
        if mode.modeType == .recordTranslate && translateHelper?.recordtype == .byPhone {
            sendOpusBtn.isUserInteractionEnabled = true
            sendOpusBtn.alpha = 1
        }
        
        if currentMode.modeType == .recordTranslate &&
            self.translateHelper?.recordtype == .byDevice {
            if isLocal {
                return
            }
            let isUseA2dp = self.translateHelper?.trIsPlayWithA2dp() ?? false
            TranslateVM.shared.configTranslate(currentMode.dataType, isUseA2dp) { [weak self] state in
                guard let self = self else { return }
                submitData()
            }
        }
        
        
        if currentMode.modeType == .recordTranslate &&
            self.translateHelper?.recordtype == .byPhone {
            if isLocal {
                TranslateVM.shared.startRecord(audioType: currentMode.dataType)
                self.audioData = JLTranslateAudio()
                self.audioData?.audioType = self.currentAudioData?.audioType ?? .OPUS
                self.audioData?.sourceType = .typePhoneMic
                submitData()
                return
            }
        }
        
        if currentMode.modeType == .callTranslate {
            if isLocal {
                return
            }
            let isUseA2dp = self.translateHelper?.trIsPlayWithA2dp() ?? false
            TranslateVM.shared.configTranslate(currentMode.dataType, isUseA2dp) { [weak self] state in
                guard let self = self else { return }
                submitData()
            }
        }
        
        if mode.modeType == .idle {
            TranslateVM.shared.clear()
        }
    }

    func onReceiveAudioData(_: String, audioData data: JLTranslateAudio) {
        JLLogManager.logLevel(.COMPLETE, content: "收到翻译音频数据")
        let mode = currentMode
        audioData = data
        // 判断数据格式
        if mode.dataType == .OPUS {
            if mode.modeType == .recordTranslate {
                // TODO: 翻译后再处理数据
                // 赋值记录当前设备原语音数据信息，用于数据回传，若果为仅录音模式，则可以不需要此记录
                // 将翻译好的数据传给设备，这里未将数据进行翻译
                // 后续可以进行翻译，这里需要将翻译后的数据压缩成 OPUS 后才能传入
//                JLLogManager.logLevel(.COMPLETE, content: "收到翻译音频数据:\(data.sourceType)")

                if isLocal {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: DispatchWorkItem(block: { [weak self] in
                        guard let self = self else { return }
                        translateHelper?.trWrite(data, translate: data.data)
                    }))
                    return
                }
                TranslateVM.shared.input(data: data, self.translateHelper!)
            }

            if mode.modeType == .onlyRecord {
                // TODO: 存储录音数据
                // 这里测试时将数据传给解码器
//                opusDecoder.opusDecoderInputData(data.data)
                
            }
            if mode.modeType == .callTranslate {
                // TODO: 翻译后再处理数据
                // 赋值记录当前设备原语音数据信息，用于数据回传，若果为仅录音模式，则可以不需要此记录
//                JLLogManager.logLevel(.COMPLETE, content: "收到翻译音频数据:\(data.sourceType)")
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: DispatchWorkItem(block: { [weak self] in
//                    guard let self = self else { return }
//                    TranslateVM.shared.input(data: data, self.translateHelper!)
//                }))
                TranslateVM.shared.sendOpusTest(data.data)
            }
        }
    }
    

    func onError(_: String, error err: any Error) {
        JLLogManager.logLevel(.ERROR, content: "error:\(String(describing: err))")
        view.makeToast("error:\(String(describing: err))", position: .center)
    }
}


