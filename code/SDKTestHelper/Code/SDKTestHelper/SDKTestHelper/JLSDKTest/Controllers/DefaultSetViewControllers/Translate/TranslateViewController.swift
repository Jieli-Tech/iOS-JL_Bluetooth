//
//  TranslateViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/1/6.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JLAudioUnitKit
import UIKit
import JL_BLEKit

class TranslateViewController: BaseViewController {

    let contentScrollView = UIScrollView()
    let contentView = UIView()

    /// 垂直排列所有内容，隐藏的 arrangedSubview 自动折叠不占空间
    lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .fill
        stack.distribution = .fill
        return stack
    }()

    // Container references for views that get hidden/shown — hide container, not child, so stack collapses
    private var translateDeliveryContainer: UIView!
    private var callStereoDeliverContainer: UIView!
    private var recordPolicyContainer: UIView!
    private var simContainer: UIView!
    private var originTextTypeContainer: UIView!
    private var translateTextTypeContainer: UIView!
    private var recordTsBtnContainer: UIView!
    private var stopBtnContainer: UIView!

    let modeTitleLab = UILabel()
    var modeSelectView: WrapChipSelectView<String> = WrapChipSelectView<String>()
    var recordPolicyView: SegmentSelectView<String> = SegmentSelectView<String>()
    var audioTypeView: ChipSelectView<String> = ChipSelectView<String>()
    var channelView: SegmentSelectView<Int> = SegmentSelectView<Int>()
    var originTextTypeView: ChipSelectView<String> = ChipSelectView<String>()
    var translateTextTypeView: ChipSelectView<String> = ChipSelectView<String>()
    var rateSelect: InputView = InputView()
    var testAV2Helper: TranslateAV2Helper?
    var translateDeliveryView: SegmentSelectView<String> = SegmentSelectView<String>()
    var callStereoDeliverView: ChipSelectView<String> = ChipSelectView<String>()

    // MARK: - 面对面翻译（左耳+右耳） UI
    var simultaneousConfigView = UIView()
    var simultaneousTitleLab = UILabel()
    var leftOriginLangView: ChipSelectView<String> = ChipSelectView<String>()
    var leftTargetLangView: ChipSelectView<String> = ChipSelectView<String>()
    var rightOriginLangView: ChipSelectView<String> = ChipSelectView<String>()
    var rightTargetLangView: ChipSelectView<String> = ChipSelectView<String>()
    var simultaneousActionBtn = UIButton()

    private let loadingOverlay: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        view.isHidden = true
        return view
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        return indicator
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "正在建立面对面翻译（左耳+右耳）连接..."
        label.textColor = .white
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        return label
    }()
    
    let recordTsBtn = UIButton()
    let stopBtn = UIButton()
    let viewRecordFilesBtn = UIButton()
    let statusLab = UILabel()
    let subTextLab = UILabel()
    let traAudioView = TraAudioView()
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let mgr = BleManager.shared.currentCmdMgr else { return }
        SoundInfoManager.share.addSendToDev(mgr)
        if TranslateVM.shared.translateHelper == nil {
            TranslateVM.shared.initTranslateMgr(mgr)
        }
        checkServerKey()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SoundInfoManager.share.removeSendToDev()
        // 如果是 push 到通话翻译 / 录音翻译 / 面对面翻译（左耳+右耳）详情页，不清理
        if navigationController?.topViewController is SimultaneousDetailViewController ||
           navigationController?.topViewController is CallTranslateDetailViewController ||
           navigationController?.topViewController is RecordTranslateDetailViewController ||
           navigationController?.topViewController is FaceToFaceTranslateDetailViewController {
            return
        }
        // 如果处于面对面翻译（左耳+右耳）模式，先退出面对面翻译（左耳+右耳）（内部释放资源：停止录音、断开从机、清理引擎）
        if TranslateVM.shared.simultaneousState.value == .working || TranslateVM.shared.simultaneousState.value == .entering {
            TranslateVM.shared.exitSimultaneousMode { }
        }
        // 如果处于通话翻译模式，先退出通话翻译（再清理）
        if TranslateVM.shared.callTranslateState.value == .working || TranslateVM.shared.callTranslateState.value == .entering {
            TranslateVM.shared.exitCallTranslateMode { }
        }
        // 如果处于录音翻译模式，先退出录音翻译（再清理）
        if TranslateVM.shared.recordTranslateState.value == .working || TranslateVM.shared.recordTranslateState.value == .entering {
            TranslateVM.shared.exitRecordTranslateMode { }
        }
        // 如果处于面对面翻译（手机+耳机）模式，先退出（再清理）
        if TranslateVM.shared.faceToFaceState.value == .working || TranslateVM.shared.faceToFaceState.value == .entering {
            TranslateVM.shared.exitFaceToFaceMode { }
        }
        TranslateVM.shared.clear()
    }

    override func initUI() {
        navigationView.title = "耳机翻译"
        navigationView.rightBtn.setTitle(R.localStr.configuration(), for: .normal)
        navigationView.rightBtn.isHidden = false
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        modeSelectViewInit()
        recordPolicyViewInit()
        audioTypeViewInit()
        channelViewInit()
        originalViewInit()
        targetViewInit()
        rateSelectInit()
        translateDeliveryViewInit()
        callStereoDeliverViewInit()
        simultaneousConfigViewInit()
        
        // MARK: Stack-based dynamic layout — hidden views auto-collapse
        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)
        contentScrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentScrollView.contentLayoutGuide)
            make.width.equalTo(contentScrollView.frameLayoutGuide)
        }

        contentView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-20)
        }

        // MARK: 分组卡片

        // 1) 翻译设置卡
        let modeCard = buildCard(title: "翻译设置", rows: [
            modeSelectView,                                            // 多行包裹，动态高度
            makeFixedRow(audioTypeView, height: 44),
            makeFixedRow(channelView, height: 44),
            makeFixedRow(rateSelect, height: 44)
        ])
        contentStackView.addArrangedSubview(modeCard)
        contentStackView.setCustomSpacing(10, after: modeCard)

        // 2) 语言设置卡
        originTextTypeContainer = makeFixedRow(originTextTypeView, height: 44)
        translateTextTypeContainer = makeFixedRow(translateTextTypeView, height: 44)
        let langCard = buildCard(title: "语言设置", rows: [originTextTypeContainer, translateTextTypeContainer])
        contentStackView.addArrangedSubview(langCard)
        contentStackView.setCustomSpacing(10, after: langCard)

        // 3) 录音与下发卡
        recordPolicyContainer = makeFixedRow(recordPolicyView, height: 44)
        translateDeliveryContainer = makeFixedRow(translateDeliveryView, height: 44)
        callStereoDeliverContainer = makeFixedRow(callStereoDeliverView, height: 44)
        let recordCard = buildCard(title: "录音与下发", rows: [
            recordPolicyContainer,
            translateDeliveryContainer,
            callStereoDeliverContainer
        ])
        contentStackView.addArrangedSubview(recordCard)
        contentStackView.setCustomSpacing(10, after: recordCard)

        // 4) 面对面翻译（左耳+右耳）卡（隐藏时可折叠）
        simContainer = makeRowContainer(simultaneousConfigView, hInset: 0)
        contentStackView.addArrangedSubview(simContainer)
        contentStackView.setCustomSpacing(10, after: simContainer)

        // 状态 + 操作按钮
        let actionSpacing: CGFloat = 10
        contentStackView.addArrangedSubview(statusLab)
        contentStackView.setCustomSpacing(actionSpacing, after: statusLab)

        recordTsBtnContainer = makeRowContainer(recordTsBtn, hInset: 0, height: 44)
        contentStackView.addArrangedSubview(recordTsBtnContainer)
        contentStackView.setCustomSpacing(actionSpacing, after: recordTsBtnContainer)

        stopBtnContainer = makeRowContainer(stopBtn, hInset: 0, height: 44)
        contentStackView.addArrangedSubview(stopBtnContainer)
        contentStackView.setCustomSpacing(actionSpacing, after: stopBtnContainer)

        contentStackView.addArrangedSubview(makeRowContainer(viewRecordFilesBtn, hInset: 0, height: 44))
        contentStackView.setCustomSpacing(actionSpacing, after: contentStackView.arrangedSubviews.last!)

        contentStackView.addArrangedSubview(subTextLab)

        // traAudioView — sequential, only one visible at a time
        contentStackView.addArrangedSubview(traAudioView)

        view.addSubview(loadingOverlay)
        loadingOverlayInit()

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

        viewRecordFilesBtn.setTitle("查看录音文件", for: .normal)
        viewRecordFilesBtn.setTitleColor(.white, for: .normal)
        viewRecordFilesBtn.backgroundColor = UIColor.random()
        viewRecordFilesBtn.layer.cornerRadius = 10
        viewRecordFilesBtn.layer.masksToBounds = true
        viewRecordFilesBtn.titleLabel?.adjustsFontSizeToFitWidth = true

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

        traAudioView.isHidden = true

        // Container initial hidden state — set AFTER stack layout creates all containers
        translateDeliveryContainer.isHidden = true
        callStereoDeliverContainer.isHidden = true
        simContainer.isHidden = true
        stopBtnContainer.isHidden = true
        // originTextTypeContainer & translateTextTypeContainer start visible (not hidden)
       
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
            if mode.modeType == .faceToFaceTranslate {
                TranslateVM.shared.enterFaceToFaceMode()
            } else if mode.modeType == .recordTranslate {
                TranslateVM.shared.enterRecordTranslateMode()
            } else if mode.modeType == .callTranslate || mode.modeType == .callTranslateStereo {
                TranslateVM.shared.enterCallTranslateMode()
            } else {
                TranslateVM.shared.translateHelper?.trStartTranslate(mode)
            }
        }.disposed(by: disposeBag)
        
        
        stopBtn.rx.tap.subscribe {  _ in
            TranslateVM.shared.exitMode()
        }.disposed(by: disposeBag)
        
        viewRecordFilesBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            let vc = CallRecordFilesViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        
        
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
        
        // 面对面翻译（左耳+右耳）状态订阅
        TranslateVM.shared.simultaneousState.subscribe(onNext: { [weak self] state in
            guard let self = self else { return }
            self.updateSimultaneousUI(state: state)
        }).disposed(by: disposeBag)
        
        // 通话翻译状态订阅
        TranslateVM.shared.callTranslateState.subscribe(onNext: { [weak self] state in
            guard let self = self else { return }
            self.updateCallTranslateUI(state: state)
        }).disposed(by: disposeBag)

        // 录音翻译状态订阅
        TranslateVM.shared.recordTranslateState.subscribe(onNext: { [weak self] state in
            guard let self = self else { return }
            self.updateRecordTranslateUI(state: state)
        }).disposed(by: disposeBag)

        // 面对面翻译（手机+耳机）状态订阅
        TranslateVM.shared.faceToFaceState.subscribe(onNext: { [weak self] state in
            guard let self = self else { return }
            self.updateFaceToFaceUI(state: state)
        }).disposed(by: disposeBag)

        // 面对面翻译（左耳+右耳）进入/退出按钮
        simultaneousActionBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            let state = TranslateVM.shared.simultaneousState.value
            if state == .working {
                self.exitSimultaneousMode()
            } else if state != .entering, state != .exiting {
                self.enterSimultaneousMode()
            }
        }).disposed(by: disposeBag)
    }
    
    private func updateMode(_ mode: JLTranslateSetMode) {
        if mode.modeType != .idle {
            statusLab.text = R.localStr.opened()
            stopBtn.isUserInteractionEnabled = true
            stopBtnContainer.isHidden = false
        } else {
            traAudioView.isHidden = true
            stopBtnContainer.isHidden = true
            stopBtn.isUserInteractionEnabled = false
            recordTsBtn.isUserInteractionEnabled = true
            statusLab.text = R.localStr.unopened()
        }
        let str = getSourceType(mode.modeType)
        modeSelectView.scrollToItem(str)
        if mode.modeType == .recordTranslate {
            stopBtnContainer.isHidden = false
        }
        if mode.modeType == .callTranslateStereo {
            stopBtnContainer.isHidden = false
        }
        if mode.modeType == .callRecord {
            stopBtnContainer.isHidden = false
        }
        if mode.modeType == .audioTranslate {
            traAudioView.isHidden = false
            if SettingInfo.getByteDanceSecret().count == 0 {
                self.view.makeToast("尚未配置在线翻译密钥")
                return
            }
        }
    }
    
    private func updateCallTranslateUI(state: CallTranslateUIState) {
        switch state {
        case .entering:
            showLoading(R.localStr.enteringCallTranslate())
        case .working:
            hideLoading()
            if !(navigationController?.topViewController is CallTranslateDetailViewController) {
                navigationController?.pushViewController(CallTranslateDetailViewController(), animated: true)
            }
        case .error(let msg):
            hideLoading()
            self.view.makeToast("\(R.localStr.callTranslateError()): \(msg)", position: .center)
        case .idle, .exiting:
            hideLoading()
        }
    }

    private func updateFaceToFaceUI(state: FaceToFaceUIState) {
        switch state {
        case .entering:
            showLoading(R.localStr.enteringFaceToFace())
        case .working:
            hideLoading()
            if !(navigationController?.topViewController is FaceToFaceTranslateDetailViewController) {
                navigationController?.pushViewController(FaceToFaceTranslateDetailViewController(), animated: true)
            }
        case .error(let msg):
            hideLoading()
            self.view.makeToast("\(R.localStr.faceToFaceError()): \(msg)", position: .center)
        case .idle:
            hideLoading()
        }
    }

    private func updateRecordTranslateUI(state: RecordTranslateUIState) {
        switch state {
        case .entering:
            showLoading(R.localStr.enteringRecordTranslate())
        case .working:
            hideLoading()
            if !(navigationController?.topViewController is RecordTranslateDetailViewController) {
                navigationController?.pushViewController(RecordTranslateDetailViewController(), animated: true)
            }
        case .error(let msg):
            hideLoading()
            self.view.makeToast("\(R.localStr.recordTranslateError()): \(msg)", position: .center)
        case .idle, .exiting:
            hideLoading()
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
        originTextTypeView.defaultValue = "中文"
        originTextTypeView.onSelect = { item in
            TranslateVM.shared.setSourceLanguage(TranslateLanguage.from(item))
        }
    }
    
    private func targetViewInit() {
        translateTextTypeView.title = "翻译语言"
        let items = ["中文", "英文", "日文"]
        translateTextTypeView.updateItems(items)
        translateTextTypeView.defaultValue = "英文"
        translateTextTypeView.onSelect = { item in
            TranslateVM.shared.setTargetLanguage(TranslateLanguage.from(item))
        }
    }
    
    private func rateSelectInit() {
        rateSelect.configure(title: R.localStr.samplingRate(), placeholder: "16000", "16000")
        rateSelect.textField.keyboardType = .numberPad
        rateSelect.contextView = self
        rateSelect.textObservable.subscribe(onNext: { value in
            TranslateVM.shared.currentMode.sampleRate = Int(value) ?? 0
        }).disposed(by: disposeBag)
        let tapges = UITapGestureRecognizer(target: self, action: #selector(tapToCloseEdit))
        tapges.cancelsTouchesInView = false
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
            R.localStr.faceToFaceTranslationPhoneEarbud(),
            "通话立体声翻译",
            "通话录音模式",
            "面对面翻译（左耳+右耳）"
        ]
        modeSelectView.updateItems(items)
        modeSelectView.onSelect = { item in
            self.recordTsBtnContainer.isHidden = false
            switch item {
            case R.localStr.idle():
                TranslateVM.shared.currentMode.modeType = .idle
            case R.localStr.recordingTranslation():
                TranslateVM.shared.currentMode.modeType = .recordTranslate
                self.audioTypeView.scrollToItem("OPUS")
                TranslateVM.shared.currentMode.dataType = .OPUS
            case R.localStr.recordingOnly():
                TranslateVM.shared.currentMode.modeType = .onlyRecord
                self.recordPolicyView.scrollToItem(R.localStr.deviceRecordingUpload())
                TranslateVM.shared.translateHelper?.recordtype = .byDevice
                // 仅录音模式强制不下发译文
                TranslateVM.shared.isDeliverTranslation = false
                self.translateDeliveryView.scrollToItem("不下发")
            case R.localStr.callTranslation():
                TranslateVM.shared.currentMode.modeType = .callTranslate
                self.audioTypeView.scrollToItem("JLA_V2")
                TranslateVM.shared.currentMode.dataType = .JLA_V2
            case R.localStr.audioTranslation():
                TranslateVM.shared.currentMode.modeType = .audioTranslate
            case R.localStr.faceToFaceTranslationPhoneEarbud():
                TranslateVM.shared.currentMode.modeType = .faceToFaceTranslate
            case "通话立体声翻译":
                TranslateVM.shared.currentMode.modeType = .callTranslateStereo
                TranslateVM.shared.currentMode.channel = 2
                self.channelView.scrollToItem(2)
                self.recordPolicyView.scrollToItem(R.localStr.deviceRecordingUpload())
                TranslateVM.shared.translateHelper?.recordtype = .byDevice
            case "通话录音模式":
                TranslateVM.shared.currentMode.modeType = .callRecord
                self.audioTypeView.scrollToItem("OPUS")
                TranslateVM.shared.currentMode.dataType = .OPUS
            case "面对面翻译（左耳+右耳）":
                TranslateVM.shared.currentMode.modeType = .simultaneous
                self.audioTypeView.scrollToItem("OPUS")
                TranslateVM.shared.currentMode.dataType = .OPUS
                TranslateVM.shared.currentMode.channel = 1
                TranslateVM.shared.currentMode.sampleRate = 16000
                self.recordTsBtnContainer.isHidden = true
                self.recordPolicyView.scrollToItem(R.localStr.deviceRecordingUpload())
                TranslateVM.shared.translateHelper?.recordtype = .byDevice
            default:
                break
            }
            
            // 控制译文下发选项的显示/隐藏
            let modesWithTranslation: [String] = [
                R.localStr.recordingTranslation(),
                R.localStr.faceToFaceTranslationPhoneEarbud(),
                R.localStr.callTranslation(),
                R.localStr.audioTranslation(),
                "通话录音模式"
            ]
            self.translateDeliveryContainer.isHidden = !modesWithTranslation.contains(item)
            self.callStereoDeliverContainer.isHidden = (item != "通话立体声翻译")

            // 通话立体声翻译隐藏录音策略行（不占空间）
            self.recordPolicyContainer.isHidden = (item == "通话立体声翻译")
            
            // 面对面翻译（左耳+右耳）设置区显隐
            let isSimultaneous = (item == "面对面翻译（左耳+右耳）")
            self.simContainer.isHidden = !isSimultaneous
            self.originTextTypeContainer.isHidden = isSimultaneous
            self.translateTextTypeContainer.isHidden = isSimultaneous
        }
    }
    
    private func translateDeliveryViewInit() {
        translateDeliveryView.title = "是否下发译文内容"
        let items = ["不下发", "下发"]
        translateDeliveryView.updateItems(items)
        translateDeliveryView.defaultValue = "不下发"
        translateDeliveryView.onSelect = { item in
            TranslateVM.shared.isDeliverTranslation = (item == "下发")
        }
    }
    
    private func callStereoDeliverViewInit() {
        callStereoDeliverView.title = "立体声回写"
        let items = ["只发上游", "只发下游", "都发", "都不发"]
        callStereoDeliverView.updateItems(items)
        callStereoDeliverView.defaultValue = "只发下游"
        callStereoDeliverView.onSelect = { item in
            switch item {
            case "只发上游":
                TranslateVM.shared.callStereoDeliverMode = .upOnly
            case "只发下游":
                TranslateVM.shared.callStereoDeliverMode = .downOnly
            case "都发":
                TranslateVM.shared.callStereoDeliverMode = .both
            case "都不发":
                TranslateVM.shared.callStereoDeliverMode = .none
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
            return "面对面翻译（手机+耳机）"
        case .callTranslateStereo:
            return "通话立体声翻译"
        case .callRecord:
            return "通话录音模式"
        case .simultaneous:
            return "面对面翻译（左耳+右耳）"
        @unknown default:
            return "未知"
        }
    }
    
    // MARK: - 面对面翻译（左耳+右耳） UI 初始化与交互
    
    private func simultaneousConfigViewInit() {
        simultaneousConfigView.backgroundColor = UIColor.eHex("#F0F2F5")
        simultaneousConfigView.layer.cornerRadius = 10

        simultaneousTitleLab.text = "面对面翻译（左耳+右耳）设置（预设左右耳译向）"
        simultaneousTitleLab.font = .boldSystemFont(ofSize: 14)
        simultaneousTitleLab.textColor = .darkGray

        let langItems = ["中文", "英文", "日文"]

        leftOriginLangView.title = "左耳源语言"
        leftOriginLangView.updateItems(langItems)
        leftOriginLangView.defaultValue = "中文"
        leftOriginLangView.onSelect = { item in
            TranslateVM.shared.simultaneousConfig.leftOrigin = TranslateLanguage.from(item)
        }

        leftTargetLangView.title = "左耳目标语言"
        leftTargetLangView.updateItems(langItems)
        leftTargetLangView.defaultValue = "英文"
        leftTargetLangView.onSelect = { item in
            TranslateVM.shared.simultaneousConfig.leftTarget = TranslateLanguage.from(item)
        }

        rightOriginLangView.title = "右耳源语言"
        rightOriginLangView.updateItems(langItems)
        rightOriginLangView.defaultValue = "英文"
        rightOriginLangView.onSelect = { item in
            TranslateVM.shared.simultaneousConfig.rightOrigin = TranslateLanguage.from(item)
        }

        rightTargetLangView.title = "右耳目标语言"
        rightTargetLangView.updateItems(langItems)
        rightTargetLangView.defaultValue = "中文"
        rightTargetLangView.onSelect = { item in
            TranslateVM.shared.simultaneousConfig.rightTarget = TranslateLanguage.from(item)
        }

        simultaneousActionBtn.setTitle("进入面对面翻译（左耳+右耳）", for: .normal)
        simultaneousActionBtn.setTitleColor(.white, for: .normal)
        simultaneousActionBtn.backgroundColor = .systemBlue
        simultaneousActionBtn.layer.cornerRadius = 10
        simultaneousActionBtn.layer.masksToBounds = true
        simultaneousActionBtn.titleLabel?.adjustsFontSizeToFitWidth = true

        simultaneousConfigView.addSubview(simultaneousTitleLab)
        simultaneousConfigView.addSubview(leftOriginLangView)
        simultaneousConfigView.addSubview(leftTargetLangView)
        simultaneousConfigView.addSubview(rightOriginLangView)
        simultaneousConfigView.addSubview(rightTargetLangView)
        simultaneousConfigView.addSubview(simultaneousActionBtn)

        simultaneousTitleLab.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(12)
        }

        leftOriginLangView.snp.makeConstraints { make in
            make.top.equalTo(simultaneousTitleLab.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(44)
        }

        leftTargetLangView.snp.makeConstraints { make in
            make.top.equalTo(leftOriginLangView.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(44)
        }

        rightOriginLangView.snp.makeConstraints { make in
            make.top.equalTo(leftTargetLangView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(44)
        }

        rightTargetLangView.snp.makeConstraints { make in
            make.top.equalTo(rightOriginLangView.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(44)
        }

        simultaneousActionBtn.snp.makeConstraints { make in
            make.top.equalTo(rightTargetLangView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    private func loadingOverlayInit() {
        loadingOverlay.addSubview(loadingIndicator)
        loadingOverlay.addSubview(loadingLabel)
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        loadingLabel.snp.makeConstraints { make in
            make.top.equalTo(loadingIndicator.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        
        loadingOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func updateSimultaneousUI(state: SimultaneousUIState) {
        switch state {
        case .idle:
            simultaneousActionBtn.setTitle("进入面对面翻译（左耳+右耳）", for: .normal)
            simultaneousActionBtn.backgroundColor = .systemBlue
            simultaneousActionBtn.isEnabled = true
            simultaneousActionBtn.layer.borderWidth = 0
            simultaneousActionBtn.layer.removeAllAnimations()
            setSimultaneousDropdownsEnabled(true)
            subTextLab.text = ""
            hideLoading()
        case .entering:
            simultaneousActionBtn.isEnabled = false
            setSimultaneousDropdownsEnabled(false)
            showLoading("正在建立面对面翻译（左耳+右耳）连接...")
        case .working:
            simultaneousActionBtn.setTitle("再按一下退出面对面翻译（左耳+右耳）", for: .normal)
            simultaneousActionBtn.backgroundColor = .systemRed
            simultaneousActionBtn.isEnabled = true
            simultaneousActionBtn.layer.borderColor = UIColor.systemRed.cgColor
            simultaneousActionBtn.layer.borderWidth = 2.0
            startPulsingAnimation(on: simultaneousActionBtn)
            setSimultaneousDropdownsEnabled(false)
            hideLoading()
            statusLab.text = "面对面翻译（左耳+右耳）工作中"
            subTextLab.text = "再次点击按钮即可退出面对面翻译（左耳+右耳）模式"
        case .exiting:
            simultaneousActionBtn.isEnabled = false
            simultaneousActionBtn.layer.removeAllAnimations()
            showLoading("正在退出面对面翻译（左耳+右耳）...")
        case .error(let msg):
            simultaneousActionBtn.setTitle("进入面对面翻译（左耳+右耳）", for: .normal)
            simultaneousActionBtn.backgroundColor = .systemBlue
            simultaneousActionBtn.isEnabled = true
            simultaneousActionBtn.layer.borderWidth = 0
            simultaneousActionBtn.layer.removeAllAnimations()
            setSimultaneousDropdownsEnabled(true)
            subTextLab.text = ""
            hideLoading()
            self.view.makeToast("面对面翻译（左耳+右耳）错误: \(msg)", position: .center)
        }
    }

    /// 脉冲动画 — 呼吸灯效果，提示"再按即退出"
    private func startPulsingAnimation(on button: UIButton) {
        button.layer.removeAllAnimations()
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.05
        pulse.duration = 0.8
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        button.layer.add(pulse, forKey: "pulse")

        let borderPulse = CABasicAnimation(keyPath: "borderWidth")
        borderPulse.fromValue = 2.0
        borderPulse.toValue = 4.0
        borderPulse.duration = 0.8
        borderPulse.autoreverses = true
        borderPulse.repeatCount = .infinity
        borderPulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        button.layer.add(borderPulse, forKey: "borderPulse")
    }

    /// 面对面翻译（左耳+右耳）工作时锁定语言下拉框，防止误操作
    private func setSimultaneousDropdownsEnabled(_ enabled: Bool) {
        leftOriginLangView.isUserInteractionEnabled = enabled
        leftTargetLangView.isUserInteractionEnabled = enabled
        rightOriginLangView.isUserInteractionEnabled = enabled
        rightTargetLangView.isUserInteractionEnabled = enabled
        leftOriginLangView.alpha = enabled ? 1.0 : 0.5
        leftTargetLangView.alpha = enabled ? 1.0 : 0.5
        rightOriginLangView.alpha = enabled ? 1.0 : 0.5
        rightTargetLangView.alpha = enabled ? 1.0 : 0.5
    }
    
    private func enterSimultaneousMode() {
        // 检查 AI 授权密钥，缺失时禁止进入面对面翻译（左耳+右耳）
        guard let auth = KeyAuth.ByteDance.getAiAuth(), !auth.accessKeyId.isEmpty, !auth.appid.isEmpty else {
            DispatchQueue.main.async {
                self.view.makeToast("未配置 AI 在线翻译密钥，无法使用面对面翻译（左耳+右耳）")
            }
            return
        }
        TranslateVM.shared.enterSimultaneousMode { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    let detailVC = SimultaneousDetailViewController()
                    self?.navigationController?.pushViewController(detailVC, animated: true)
                } else {
                    // 失败时调用 exitSimultaneousMode 重置底层 JLTranslationManager 内部状态，
                    // 避免 ObjC 层 stuck 在 Entering 状态导致下次进入报 "already in simultaneous mode"
                    TranslateVM.shared.exitSimultaneousMode { }
                }
            }
        }
    }
    
    private func exitSimultaneousMode() {
        TranslateVM.shared.exitSimultaneousMode { [weak self] in
            DispatchQueue.main.async {
                self?.statusLab.text = R.localStr.unopened()
            }
        }
    }
    
    private func showLoading(_ message: String) {
        loadingLabel.text = message
        loadingOverlay.isHidden = false
        loadingIndicator.startAnimating()
        view.isUserInteractionEnabled = false
    }
    
    private func hideLoading() {
        loadingOverlay.isHidden = true
        loadingIndicator.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    /// 进入页面时检查服务器翻译密钥是否存在及是否过期
    private func checkServerKey() {
        guard let auth = KeyAuth.ByteDance.getAiAuth() else {
            self.view.makeToast("未配置 AI 在线翻译密钥", position: .center)
            return
        }
        if auth.accessKeyId.isEmpty || auth.appid.isEmpty {
            self.view.makeToast("AI 在线翻译密钥不完整", position: .center)
            return
        }
        // 注：isInvalid() 沿用现有实现，返回 true 表示仍在有效期内
        if !auth.isInvalid() {
            self.view.makeToast("AI 在线翻译密钥已过期", position: .center)
        }
    }

    /// 创建分组卡片（标题 + 内容垂直栈）
    private func buildCard(title: String, rows: [UIView]) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.eHex("#EEF0F3").cgColor

        let titleLab = UILabel()
        titleLab.text = title
        titleLab.font = .boldSystemFont(ofSize: 15)
        titleLab.textColor = .darkGray

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fill

        card.addSubview(titleLab)
        card.addSubview(stack)

        titleLab.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(14)
        }

        stack.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
        }

        rows.forEach { stack.addArrangedSubview($0) }
        return card
    }

    /// 固定高度的行容器
    private func makeFixedRow(_ view: UIView, height: CGFloat) -> UIView {
        let container = UIView()
        container.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        container.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        return container
    }

    /// 将 view 包装在容器中，控制水平内边距和固定高度
    private func makeRowContainer(_ content: UIView, hInset: CGFloat, height: CGFloat? = nil) -> UIView {
        let container = UIView()
        container.addSubview(content)
        content.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(hInset)
        }
        if let h = height {
            container.snp.makeConstraints { make in
                make.height.equalTo(h)
            }
        }
        return container
    }
}



