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

    let modeTitleLab = UILabel()
    var modeSelectView: DropdownView<String> = DropdownView<String>()
    var recordPolicyView: DropdownView<String> = DropdownView<String>()
    var audioTypeView: DropdownView<String> = DropdownView<String>()
    var channelView: DropdownView<Int> = DropdownView<Int>()
    var originTextTypeView: DropdownView<String> = DropdownView<String>()
    var translateTextTypeView: DropdownView<String> = DropdownView<String>()
    var rateSelect: InputView = InputView()
    var testAV2Helper: TranslateAV2Helper?
    var switchLocal: EcLabSwitch = EcLabSwitch()
    var switchTransWay: EcLabSwitch = EcLabSwitch()
    
    let recordTsBtn = UIButton()
    let stopBtn = UIButton()
    let statusLab = UILabel()
    let subTextLab = UILabel()
    let traAudioView = TraAudioView()
    let traFaceView = TraFaceToFaceView()
    let traRecordOnly = TraRecordOnlyView()
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let mgr = BleManager.shared.currentCmdMgr else { return }
        SoundInfoManager.share.addSendToDev(mgr)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SoundInfoManager.share.removeSendToDev()
        TranslateVM.shared.clear()
    }
    
    
    override func initUI() {
        navigationView.title = R.localStr.translateTransfer()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        navigationView.rightBtn.setTitle(R.localStr.configuration(), for: .normal)
        navigationView.rightBtn.isHidden = false
        
        switchLocal.configSwitch(title: R.localStr.useLocalResourcesOnly(), isOn: SettingInfo.getByteDanceAppId().count == 0)
        TranslateVM.shared.isLocal = SettingInfo.getByteDanceAppId().count == 0
        
        switchTransWay.configSwitch(title: "启用无需交互的下发", isOn: false)
        
        modeSelectViewInit()
        recordPolicyViewInit()
        audioTypeViewInit()
        channelViewInit()
        originalViewInit()
        targetViewInit()
        rateSelectInit()
        
        view.addSubview(modeTitleLab)
        view.addSubview(modeSelectView)
        view.addSubview(recordPolicyView)
        view.addSubview(audioTypeView)
        view.addSubview(channelView)
        view.addSubview(originTextTypeView)
        view.addSubview(translateTextTypeView)
        view.addSubview(rateSelect)
        view.addSubview(switchLocal)
        view.addSubview(switchTransWay)
        
        view.addSubview(recordTsBtn)
        view.addSubview(statusLab)
        view.addSubview(stopBtn)
        view.addSubview(subTextLab)
        view.addSubview(traFaceView)
        view.addSubview(traAudioView)
        view.addSubview(traRecordOnly)
        
        recordTsBtn.setTitle(R.localStr.setupMode(), for: .normal)
        recordTsBtn.setTitleColor(.white, for: .normal)
        recordTsBtn.backgroundColor = UIColor.random()
        recordTsBtn.layer.cornerRadius = 10
        recordTsBtn.layer.masksToBounds = true
        recordTsBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        recordTsBtn.isUserInteractionEnabled = false
        
        
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
        
        
        subTextLab.text = ""
        subTextLab.textColor = .black
        subTextLab.font = .boldSystemFont(ofSize: 12)
        subTextLab.adjustsFontSizeToFitWidth = true
        subTextLab.textAlignment = .center
        
        traFaceView.isHidden = true
        traAudioView.isHidden = true
        traRecordOnly.isHidden = true
        
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
        
        originTextTypeView.snp.makeConstraints { make in
            make.top.equalTo(channelView.snp.bottom)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        translateTextTypeView.snp.makeConstraints { make in
            make.top.equalTo(originTextTypeView.snp.bottom)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        rateSelect.snp.makeConstraints { make in
            make.top.equalTo(translateTextTypeView.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        switchLocal.snp.makeConstraints { make in
            make.top.equalTo(rateSelect.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(35)
        }
        
        switchTransWay.snp.makeConstraints { make in
            make.top.equalTo(switchLocal.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(35)
        }
        
        statusLab.snp.makeConstraints { make in
            make.top.equalTo(switchTransWay.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
        
        recordTsBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.top.equalTo(statusLab.snp.bottom).offset(10)
        }
        
        stopBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
            make.top.equalTo(recordTsBtn.snp.bottom).offset(10)
        }
        
        subTextLab.snp.makeConstraints { make in
            make.top.equalTo(stopBtn.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
        }
        traAudioView.snp.makeConstraints { make in
            make.top.equalTo(subTextLab.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
        }
        traFaceView.snp.makeConstraints { make in
            make.top.equalTo(subTextLab.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
        }
        traRecordOnly.snp.makeConstraints { make in
            make.top.equalTo(subTextLab.snp.bottom).offset(6)
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
        
        recordTsBtn.rx.tap.subscribe { _ in
            let mode = TranslateVM.shared.currentMode
            TranslateVM.shared.translateHelper?.trStartTranslate(mode)
        }.disposed(by: disposeBag)
        
        
        stopBtn.rx.tap.subscribe {  _ in
            TranslateVM.shared.exitMode()
        }.disposed(by: disposeBag)
        
        
        
        // 初始化翻译传输管理
        if let manater = BleManager.shared.currentCmdMgr {
            TranslateVM.shared.initTranslateMgr(manater)
        }
        
        JLAudioPlayer.shared.start()
        
        testAV2Helper = TranslateAV2Helper({ pcm in
            JLAudioPlayer.shared.enqueuePCMData(pcm)
        }, { [weak self] encodeData in
            self?.testAV2Helper?.decodeDataToPcm(encodeData)
        })
        
        switchLocal.swBtn.rx.value.subscribe(onNext: {  isOn in
            TranslateVM.shared.isLocal = isOn
        }).disposed(by: disposeBag)
        
        switchTransWay.swBtn.rx.value.subscribe(onNext: {  isOn in
            TranslateVM.shared.writeWithoutResponse = isOn
        }).disposed(by: disposeBag)
        
        TranslateVM.shared.subjectCurrentMode.subscribe(onNext: {[weak self] mode in
            guard let `self` = self else { return }
            updateMode(mode)
        }).disposed(by: disposeBag)
        
        TranslateVM.shared.translateMgr?.subtitleText.subscribe(onNext: { [weak self] contextStr in
            guard let self = self else { return }
            traAudioView.updateText(contextStr)
        }).disposed(by: disposeBag)
        TranslateVM.shared.translateMgr?.definiteTextOrigin.subscribe(onNext: { [weak self] contextStr in
            guard let self = self else { return }
            traAudioView.updateText(contextStr)
        }).disposed(by: disposeBag)
        TranslateVM.shared.translateMgr?.definiteTextTranslate.subscribe(onNext: { [weak self] contextStr in
            guard let self = self else { return }
            traAudioView.updateText(contextStr)
        }).disposed(by: disposeBag)
        
        
    }
    
    private func updateMode(_ mode: JLTranslateSetMode) {
        if mode.modeType != .idle {
            statusLab.text = R.localStr.opened()
            stopBtn.isUserInteractionEnabled = true
            stopBtn.isHidden = false
        } else {
            traAudioView.isHidden = true
            traFaceView.isHidden = true
            traRecordOnly.isHidden = true
            stopBtn.isHidden = true
            stopBtn.isUserInteractionEnabled = false
            recordTsBtn.isUserInteractionEnabled = true
            statusLab.text = R.localStr.unopened()
        }
        let str = getSourceType(mode.modeType)
        modeSelectView.scrollToItem(str)
        if mode.modeType == .recordTranslate {
            stopBtn.isHidden = false
        }
        if mode.modeType == .callTranslate {
            stopBtn.isHidden = false
        }
        if mode.modeType == .audioTranslate {
            traAudioView.isHidden = false
            if TranslateVM.shared.isLocal {
                return
            }
            if SettingInfo.getByteDanceSecret().count == 0 {
                self.view.makeToast("尚未配置在线翻译密钥")
                return
            }
        }
        if mode.modeType == .onlyRecord {
            traRecordOnly.isHidden = false
        }
        // 面对面翻译
        if mode.modeType == .faceToFaceTranslate {
            traFaceView.isHidden = false
        }
    }
    
    private func recordPolicyViewInit(){
        let items = [R.localStr.appRecordingDownload(), R.localStr.deviceRecordingUpload()]
        recordPolicyView.updateItems(items)
        recordPolicyView.onSelect = { item in
            switch item {
            case R.localStr.appRecordingDownload():
                TranslateVM.shared.translateHelper?.recordtype = .byPhone
            case R.localStr.deviceRecordingUpload():
                TranslateVM.shared.translateHelper?.recordtype = .byDevice
            default:
                break
            }
        }
        recordPolicyView.title = R.localStr.recordingStrategy()
        recordPolicyView.defaultValue = R.localStr.appRecordingDownload()
        recordPolicyView.show(false)
    }
    
    private func audioTypeViewInit() {
        audioTypeView.title = R.localStr.audioType()
        let items = ["PCM", "Opus", "SPEEX", "MSBC", "JLA_V2"]
        audioTypeView.updateItems(items)
        audioTypeView.defaultValue = "Opus"
        audioTypeView.onSelect = { item in
            switch item {
            case "PCM":
                TranslateVM.shared.currentMode.dataType = .PCM
            case "Opus":
                TranslateVM.shared.currentMode.dataType = .OPUS
            case "SPEEX":
                TranslateVM.shared.currentMode.dataType = .SPEEX
            case "MSBC":
                TranslateVM.shared.currentMode.dataType = .MSBC
            case "JLA_V2":
                TranslateVM.shared.currentMode.dataType = .JLA_V2
            default:
                break
            }
        }
        
    }
    
    private func channelViewInit() {
        channelView.title = R.localStr.channels()
        let items = [1, 2]
        channelView.updateItems(items)
        channelView.onSelect = { item in
            TranslateVM.shared.currentMode.channel = item
        }
    }
    
    private func originalViewInit() {
        originTextTypeView.title = "原文语言"
        let items = ["中文", "英文", "日文"]
        originTextTypeView.updateItems(items)
        originTextTypeView.onSelect = { item in
            let group = TranslateVM.shared.translateLanguage
            switch item {
            case "中文":
                let newGroup = TranslateVM.LanguageGroup(.zh,group.1)
                TranslateVM.shared.translateLanguage = newGroup
                TranslateVM.shared.translateCallLanguage = (newGroup.1[0], [newGroup.0])
            case "英文":
                let newGroup = TranslateVM.LanguageGroup(.en,group.1)
                TranslateVM.shared.translateLanguage = newGroup
                TranslateVM.shared.translateCallLanguage = (newGroup.1[0], [newGroup.0])
            case "日文":
                let newGroup = TranslateVM.LanguageGroup(.ja,group.1)
                TranslateVM.shared.translateLanguage = newGroup
                TranslateVM.shared.translateCallLanguage = (newGroup.1[0], [newGroup.0])
            default:
                break
            }
        }
    }
    
    private func targetViewInit() {
        translateTextTypeView.title = "翻译语言"
        let items = ["中文", "英文", "日文"]
        translateTextTypeView.updateItems(items)
        translateTextTypeView.onSelect = { item in
            let group = TranslateVM.shared.translateLanguage
            switch item {
            case "中文":
                let newGroup = TranslateVM.LanguageGroup(group.0,[.zh])
                TranslateVM.shared.translateLanguage = newGroup
                TranslateVM.shared.translateCallLanguage = (newGroup.1[0], [newGroup.0])
            case "英文":
                let newGroup = TranslateVM.LanguageGroup(group.0,[.en])
                TranslateVM.shared.translateLanguage = newGroup
                TranslateVM.shared.translateCallLanguage = (newGroup.1[0], [newGroup.0])
            case "日文":
                let newGroup = TranslateVM.LanguageGroup(group.0,[.ja])
                TranslateVM.shared.translateLanguage = newGroup
                TranslateVM.shared.translateCallLanguage = (newGroup.1[0], [newGroup.0])
            default:
                break
            }
        }
    }
    
    private func rateSelectInit() {
        rateSelect.configure(title: R.localStr.samplingRate(), placeholder: "16000", "16000")
        rateSelect.textField.keyboardType = .numberPad
        rateSelect.textObservable.subscribe(onNext: { value in
            TranslateVM.shared.currentMode.sampleRate = Int(value) ?? 0
        }).disposed(by: disposeBag)
        let tapges = UITapGestureRecognizer(target: self, action: #selector(tapToCloseEdit))
        self.view.addGestureRecognizer(tapges)
    }
    
    @objc private func tapToCloseEdit() {
        rateSelect.textField.endEditing(true)
    }
    
    private func modeSelectViewInit() {
        modeSelectView.title = R.localStr.translationMode()
        let items = [
            R.localStr.idle(),
            R.localStr.recordingTranslation(),
            R.localStr.recordingOnly(),
            R.localStr.callTranslation(),
            R.localStr.audioTranslation(),
            R.localStr.faceToFaceTranslation(),
            "通话立体声翻译"
        ]
        modeSelectView.updateItems(items)
        modeSelectView.onSelect = { item in
            self.recordPolicyView.show(false)
            switch item {
            case R.localStr.idle():
                TranslateVM.shared.currentMode.modeType = .idle
            case R.localStr.recordingTranslation():
                TranslateVM.shared.currentMode.modeType = .recordTranslate
                self.recordPolicyView.show(true)
                self.audioTypeView.scrollToItem("OPUS")
                TranslateVM.shared.currentMode.dataType = .OPUS
            case R.localStr.recordingOnly():
                TranslateVM.shared.currentMode.modeType = .onlyRecord
            case R.localStr.callTranslation():
                TranslateVM.shared.currentMode.modeType = .callTranslate
                self.audioTypeView.scrollToItem("JLA_V2")
                TranslateVM.shared.currentMode.dataType = .JLA_V2
            case R.localStr.audioTranslation():
                TranslateVM.shared.currentMode.modeType = .audioTranslate
            case R.localStr.faceToFaceTranslation():
                TranslateVM.shared.currentMode.modeType = .faceToFaceTranslate
            case "通话立体声翻译":
                TranslateVM.shared.currentMode.modeType = .callTranslateStereo
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
        case .callTranslateStereo:
            return "通话立体声翻译"
        @unknown default:
            return "未知"
        }
    }
}



