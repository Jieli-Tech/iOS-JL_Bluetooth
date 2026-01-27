//
//  SyncTranslationVM.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/24.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation

class SyncTranslationMode {
    var original: String
    var translate: String
    var translateColor: UIColor
    var info: TranslationRecord?
    init(original: String, translate: String, translateColor: UIColor) {
        self.original = original
        self.translate = translate
        self.translateColor = translateColor
    }
}

class SyncTranslationVM {
    let syncSpeakArray = BehaviorRelay<[SyncTranslationMode]>(value: [])
    let timerCounter = BehaviorRelay<String>(value: "00:00:00")
    private let viewController: SyncTranslationVC
    private let themeColor = UIColor.eHex("#000000", alpha: 0.6)
    private var subOriginText: String = ""
    private var subTranslateText: String = ""
    private var groupData: [SyncTranslationMode] = []
    private var currentGroup: String = ""
    private var maxTimerCounter: Int = 15
    private var timerID: String = ""
    private var timerIDTitle: String = ""
    private let disposeBag = DisposeBag()

    init(viewController: SyncTranslationVC) {
        self.viewController = viewController
        _ = TranslationRecordDB.shared
        timerSpeaker()
        timerTitler()
        createGroupItem()
        subscribe()
    }

    func controlAction() {
        if TranslateVM.shared.currentMode.modeType == .recordTranslate {
            exitMode()
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 退出同步翻译. controlAction")
        } else {
            createGroupItem()
            TranslateVM.shared.setMode(type: .sync) { [weak self] type, err in
                guard let self = self else { return }
                if err != nil {
                    viewController.view.makeToast(err?.localizedDescription ?? "")
                } else if type == .success {
                    subscribe()
                }
                timerTitler()
                JLLogManager.logLevel(.DEBUG, content: "Translate Log 进入同步翻译. controlAction")
            }
            timerSpeaker()
        }
    }

    func dicChangeLanguage() {
        let local = viewController.lanSelectView.languangeSelectView.currentOtherSideLanguage
        let target = viewController.lanSelectView.languangeSelectView.currentMySideLanguage
        let chain = JLTaskChain()
        chain.addTask { [weak self] _, comp in
            guard let self = self else { return }
            TranslateVM.shared.exitMode { type, err in
                if err != nil {
                    comp(nil, err)
                } else if type == .success {
                    comp(nil, nil)
                } else {
                    comp(nil, NSError(domain: "exitMode error", code: -1, userInfo: nil))
                }
                TimerHelper.stopTimer(timerID: self.timerID)
            }
        }
        chain.addTask { [weak self] _, complation in
            guard let self = self else { return }
            if let info = groupData.last?.info {
                info.duration = TranslateTools.calculateDuration(dataBytes: info.audioData.count)
                info.audioData = TranslateTools.convert(pcmData: info.audioData)
                info.originText = subOriginText
                info.translateText = subTranslateText
                TranslationRecordDB.shared.save(record: info)
            }
            createGroupItem()
            TranslateVM.shared.translateLanguage = (local, [target])
            TranslateVM.shared.setMode(type: .sync) { [weak self] type, err in
                guard let self = self else { return }
                if err != nil {
                    viewController.view.makeToast(err?.localizedDescription ?? "")
                } else if type == .success {
                    self.subscribe()
                }
                timerTitler()
            }
            self.timerSpeaker()
            complation(nil, nil)
        }
        chain.run(withInitialInput: nil) { _, err in
            if err != nil {
                JLLogManager.logLevel(.ERROR, content: "Translate Log init error:\(String(describing: err))")
            }
        }
    }

    func exitMode(delete: Bool = false) {
        if TranslateVM.shared.currentMode.modeType == .recordTranslate {
            JLLogManager.logLevel(.DEBUG, content: "Translate Log 退出同步翻译. exitMode")
            TranslateVM.shared.exitMode()
            TimerHelper.stopTimer(timerID: timerID)
            TimerHelper.stopTimer(timerID: timerIDTitle)
            if groupData.last?.info?.audioData.count == 0 {
                groupData.removeLast()
                syncSpeakArray.accept(groupData)
            }
            guard let mode = groupData.last else { return }
            let lastTempText = TranslateVM.shared.translateMgr?.subtitleText.value ?? ""
            let lastSubText = TranslateVM.shared.translateMgr?.definiteTextOrigin.value ?? ""
            if !lastSubText.contains(lastTempText) {
                mode.original = mode.original.replacingOccurrences(of: lastTempText, with: "")
                syncSpeakArray.accept(groupData)
            }
            if delete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem(block: {
                    TranslationRecordDB.shared.delete(groupId: self.currentGroup)
                }))
            }
        }
    }

    private func subscribe() {
        guard let tranMgr = TranslateVM.shared.translateMgr else { return }
        // 实时文字
        tranMgr.subtitleText.subscribe(onNext: { [weak self] text in
            guard let self = self, let mode = groupData.last else { return }
            if text.count == 0 { return }
            mode.original = subOriginText + text
            mode.translate = subTranslateText
            syncSpeakArray.accept(groupData)
            timerSpeaker()
        }).disposed(by: disposeBag)

        tranMgr.definiteTextOrigin.subscribe(onNext: { [weak self] text in
            guard let self = self, let mode = groupData.last else { return }
            if text.count == 0 { return }
            subOriginText += text
            mode.original = subOriginText
            mode.translate = subTranslateText
            syncSpeakArray.accept(groupData)
            timerSpeaker()
        }).disposed(by: disposeBag)

        tranMgr.definiteTextTranslate.subscribe(onNext: { [weak self] text in
            guard let self = self, let mode = groupData.last else { return }
            if text.count == 0 { return }
            mode.original = subOriginText
            subTranslateText += text
            mode.translate = subTranslateText
            syncSpeakArray.accept(groupData)
            timerSpeaker()
        }).disposed(by: disposeBag)

        tranMgr.targetPcmData.subscribe(
            onNext: { [weak self] pcmData in
                guard let self = self, let info = groupData.last?.info else { return }
                info.audioData = pcmData.0
                timerSpeaker()
                saveAudioData(pcmData: pcmData.0, texts: pcmData.1)
            }).disposed(by: disposeBag)
    }

    private func timerSpeaker() {
        TimerHelper.stopTimer(timerID: timerID)
        timerID = TimerHelper.createTimer(timeOut: Double(maxTimerCounter)) { _ in
            self.controlAction()
        }
    }

    private func timerTitler() {
        timerIDTitle = TimerHelper.setInterval(
            interval: 1.0,
            completion: { [weak self] _ in
                guard let self = self else { return }
                let dt1 = Date.strBeDate(currentGroup)?.timeIntervalSince1970 ?? 0
                let dt2 = Date().timeIntervalSince1970
                let time = Int(dt2 - dt1)
                let hour = time / 3600
                let min = time / 60
                let sec = time % 60
                let str = String(format: "%02d:%02d:%02d", hour, min, sec)
                self.timerCounter.accept(str)
            }
        )
    }

    private func createGroupItem() {
        currentGroup = Date().getDateStr
        let mode = SyncTranslationMode(original: "...", translate: "", translateColor: themeColor)
        mode.info = TranslationRecord(
            startTime: Date().getDateStr,
            groupId: currentGroup,
            duration: 0,
            originText: "",
            translateText: "",
            audioData: Data()
        )
        groupData.append(mode)
        syncSpeakArray.accept(groupData)
        subOriginText = ""
        subTranslateText = ""
    }

    private func saveAudioData(pcmData: Data, texts: [String]) {
        if let info = groupData.last?.info, texts.count == 2, pcmData.count > 0 {
            info.duration = TranslateTools.calculateDuration(dataBytes: pcmData.count)
            info.audioData = pcmData
            info.originText = texts[1]
            info.startTime = Date().getDateStr
            info.translateText = texts[0]
            TranslationRecordDB.shared.save(record: info)
        }
    }

    deinit {
        TimerHelper.stopTimer(timerID: timerID)
        TimerHelper.stopTimer(timerID: timerIDTitle)
        JLLogManager.logLevel(.DEBUG, content: "Translate Log SyncTranslationVM deinit")
    }
}
