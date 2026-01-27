//
//  FaceToFaceTranslateVM.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/24.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation

class FaceToFaceTranslateVM {
    let syncSpeakArray: BehaviorRelay<[ChatMessageInfo]> = BehaviorRelay(value: [])
    let countTimerStr: BehaviorRelay<String> = BehaviorRelay(value: "00:00:00")
    var isInDeviceSpeak: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private let viewController: FaceToFaceTranslateVC
    private let disposeBag = DisposeBag()
    private var groupItems: [ChatMessageInfo] = []
    private var groupId: String = ""
    private var subOriginText: String = ""
    private var subTranslateText: String = ""
    private var originColor: UIColor = .eHex("#000000", alpha: 0.9)
    private var translateColor: UIColor = .eHex("#000000", alpha: 0.5)
    private var countTimerUID: String = ""
    private var isTTSing: Bool = false
    private var isFinish: Bool = false
    private var isOverListen: Bool = false
    private var phoneMessageInfo: ChatMessageInfo?
    private var earpieceMessageInfo: ChatMessageInfo?
    private var obsSendQueue: Disposable?
    private var pcmAudioDataObserver: Disposable?

    init(viewController: FaceToFaceTranslateVC) {
        self.viewController = viewController
        groupId = Date().getDateStr
        TranslateVM.shared.subjectCurrentMode.subscribe(onNext: { [weak self] mode in
            guard let self = self else { return }
            if mode.modeType == .idle {
                TimerHelper.stopTimer(timerID: self.countTimerUID)
            }
        }).disposed(by: disposeBag)
        isInDeviceSpeak.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            self.viewController.bottomView.isDeviceSpeak(value)
        }).disposed(by: disposeBag)

        TranslateVM.shared.isRecordByDevice.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            self.isInDeviceSpeak.accept(value)
            DispatchQueue.main.async {
                if self.phoneMessageInfo != nil {
                    self.viewController.bottomView.headPhonesCtrlBtn.cancelTracking(with: .none)
                    self.sendAndExit()
                }
            }
        }).disposed(by: disposeBag)
        timerAction()
    }

    func startPhoneRecord() {
        if isInDeviceSpeak.value == true {
            viewController.bottomView.headPhonesCtrlBtn.cancelTracking(with: .none)
            viewController.view.makeToast(R.Language.lan("The other party is talking..."), position: .center)
            return
        }
        createGroupItem(.phone)
        isFinish = false
        TranslateVM.shared.startRecordFaceToFace { [weak self] status in
            guard let self = self else { return }
            if !status {
                self.viewController.view.makeToast(R.Language.lan("Start recording failed"))
                return
            }
            pcmAudioDataObserver?.dispose()
            pcmAudioDataObserver = TranslateVM.shared.recordPcmData.subscribe(onNext: { [weak self] data in
                guard let self = self else { return }
                JLLogManager.logLevel(.DEBUG, content: "pcmAudioData:\(data.count)")
                DispatchQueue.main.async {
                    self.viewController.bottomView.spectogramView.appendPCMData(from: data)
                }
            })
            subscribe()
        }
    }

    func startEarpieceRecord() {
        if phoneMessageInfo != nil {
            viewController.view.makeToast(R.Language.lan("Our translation is not yet completed"), position: .center)
            return
        }
        TranslateVM.shared.startRecordByDevFaceToFace { [weak self] status in
            guard let self = self else { return }
            if status {
                createGroupItem(.earpiece)
                isTTSing = true
                isFinish = false
                subscribe()
                isInDeviceSpeak.accept(true)
            }
        }
    }

    func stopEarpieceRecord() {
        isFinish = true
        if groupItems.last?.original.count == 0 {
            TranslateVM.shared.stopRecordByDevFaceToFace()
            groupItems.removeAll(where: { $0.faceInfo?.startTime == self.earpieceMessageInfo?.faceInfo?.startTime })
            syncSpeakArray.accept(groupItems)
            return
        }
        guard isTTSing == false, let model = groupItems.last else { return }
        saveAndSendToDev(model)
    }

    func sendAndExit() {
        isFinish = true
        if groupItems.last?.original.count == 0 {
            TranslateVM.shared.translateMgr?.endTranslate()
            groupItems.removeAll(where: { $0.faceInfo?.startTime == phoneMessageInfo?.faceInfo?.startTime })
            syncSpeakArray.accept(groupItems)
            phoneMessageInfo = nil
            JLAudioRecoder.shared.stop()
        }
        guard isTTSing == false, let model = groupItems.last else { return }
        saveAndSendToDev(model)
    }

    func exitTimer() {
        TimerHelper.stopTimer(timerID: countTimerUID)
        if isInDeviceSpeak.value {
            TranslateVM.shared.stopRecordByDevFaceToFace()
            TranslateVM.shared.isRecordByDevice.accept(false)
        }
    }

    func dicChangeLanguage(languages: (TranslateLanguage, TranslateLanguage)) {
        let chain = JLTaskChain()
        if isInDeviceSpeak.value {
            chain.addTask { [weak self] _, completion in
                guard let self = self else { return }
                TranslateVM.shared.exitMode { [weak self] _, err in
                    guard let self = self else { return }
                    if err != nil {
                        JLLogManager.logLevel(.ERROR, content: "exit error:\(String(describing: err))")
                        completion(nil, err)
                        return
                    }
                    cancelSend()
                    completion(nil, nil)
                }
            }
        }
        chain.addTask { _, _ in
            TranslateVM.shared.translateLanguage = (languages.0, [languages.1])
        }
        chain.run(withInitialInput: nil) { [weak self] _, err in
            guard let self = self else { return }
            if err != nil {
                JLLogManager.logLevel(.ERROR, content: "set language error:\(String(describing: err))")
                self.viewController.view.makeToast(err?.localizedDescription ?? "")
            }
        }
    }

    func cancelSend() {
        obsSendQueue?.dispose()
        JLLogManager.logLevel(.DEBUG, content: "cancelSend")
        groupItems.removeAll(where: { $0.faceInfo?.startTime == phoneMessageInfo?.faceInfo?.startTime })
        groupItems.removeAll(where: { $0.faceInfo?.startTime == earpieceMessageInfo?.faceInfo?.startTime })
        syncSpeakArray.accept(groupItems)
        TranslateVM.shared.stopRecordFaceToFace()
    }

    private func subscribe() {
        guard let tranMgr = TranslateVM.shared.translateMgr else { return }
        JLLogManager.logLevel(.DEBUG, content: "tranMgr subscribe\(tranMgr)")
        isOverListen = false
        JLLogManager.logLevel(.DEBUG, content: "subscribe")
        tranMgr.isTTSing.subscribe(onNext: { [weak self] isTTSing in
            guard let self = self else { return }
            self.isTTSing = isTTSing
        }).disposed(by: disposeBag)
        // 实时文字
        tranMgr.subtitleText.subscribe(onNext: { [weak self] text in
            guard let self = self, let mode = groupItems.last else { return }
            if text.count == 0 { return }
            if isOverListen { return }
            mode.original = subOriginText + text
            mode.translate = subTranslateText
            syncSpeakArray.accept(groupItems)
        }).disposed(by: disposeBag)

        tranMgr.definiteTextOrigin.subscribe(onNext: { [weak self] text in
            guard let self = self, let mode = groupItems.last else { return }
            if text.count == 0 { return }
            if isOverListen { return }
            subOriginText += text
            mode.original = subOriginText
            mode.translate = subTranslateText
            syncSpeakArray.accept(groupItems)
        }).disposed(by: disposeBag)

        tranMgr.definiteTextTranslate.subscribe(onNext: { [weak self] text in
            guard let self = self, let mode = groupItems.last else {
                JLLogManager.logLevel(.DEBUG, content: "definiteTextTranslate error")
                return
            }
            if text.count == 0 { return }
            if isOverListen { return }
            mode.original = subOriginText
            subTranslateText += text
            mode.translate = subTranslateText
            syncSpeakArray.accept(groupItems)
        }).disposed(by: disposeBag)

        tranMgr.targetPcmData.subscribe(
            onNext: { [weak self] pcmData in
                guard let self = self, let info = groupItems.last?.faceInfo, let model = groupItems.last else {
                    JLLogManager.logLevel(.DEBUG, content: "targetPcmData error")
                    return
                }
                info.audioData.append(pcmData.0)
                if !isTTSing {
                    saveAndSendToDev(model)
                }
            }).disposed(by: disposeBag)
    }

    private func saveAndSendToDev(_ model: ChatMessageInfo) {
        guard let info = model.faceInfo else { return }
        if info.audioData.count == 0, isFinish {
            if info.audioData.count == 0 {
                if model.original.count == 0, model.original.count == 0 {
                    groupItems.removeAll(where: { $0.faceInfo?.startTime == self.phoneMessageInfo?.faceInfo?.startTime })
                    syncSpeakArray.accept(groupItems)
                    return
                }
            }
            return
        }
        
        if info.audioData.count > 0, isFinish {
            if let info = groupItems.last?.faceInfo, info.audioData.count > 0 {
                info.duration = Int(TranslateTools.calculateDuration(dataBytes: info.audioData.count))
                info.originalText = subOriginText
                info.translatedText = subTranslateText
                TranslationFaceToFaceDB.share.saveRecord(info)
            }
            if phoneMessageInfo != nil {
                JLLogManager.logLevel(.DEBUG, content: "will send audioData:\(info.audioData.count)")
                TranslateVM.shared.translateMgr?.endTranslate()
                if model.original.count == 0 {
                    groupItems.removeAll(where: { $0.faceInfo?.startTime == self.phoneMessageInfo?.faceInfo?.startTime })
                    syncSpeakArray.accept(groupItems)
                    self.phoneMessageInfo = nil
                    return
                }
                JLAudioRecoder.shared.stop()
                TranslateVM.shared.translateMgr?.sendPcmDataToDevice(info.audioData)
                self.phoneMessageInfo = nil
            }

            // MARK: 测试保存数据用

            /*
             let path = NSHomeDirectory() + "/Library/Caches/" + groupId + ".wav"
             try?FileManager.default.removeItem(atPath: path)
             let data = TranslateTools.convert(pcmData: info.audioData)
             FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
             */
            if isInDeviceSpeak.value == true {
                isInDeviceSpeak.accept(false)
                TranslateVM.shared.translateMgr?.endTranslate()
                if info.audioData.count == 0 {
                    groupItems.removeAll(where: { $0.faceInfo?.startTime == self.earpieceMessageInfo?.faceInfo?.startTime })
                    syncSpeakArray.accept(groupItems)
                    self.earpieceMessageInfo = nil
                    return
                }
                if TranslateVM.shared.isDeviceSpeak {
                    TranslateVM.shared.stopRecordByDevFaceToFace()
                }
                JLLogManager.logLevel(.DEBUG, content: "Try to play audio data with size: \(info.audioData.count)")
                JLAudioPlayer.shared.playTemporarilyThroughSpeaker(info.audioData)
                self.earpieceMessageInfo = nil
            }
        }
    }

    private func createGroupItem(_ type: FaceDeviceType) {
        let item = ChatMessageInfo(startTime: Date().timeIntervalSince1970, title: type.title, titleColor: type.color, original: "", translate: "", translateColor: translateColor)
        resetCache()
        item.faceInfo = FaceToFaceRecord(
            groupId: groupId,
            startTime: Int(Date().timeIntervalSince1970),
            duration: 0,
            originalText: "",
            translatedText: "",
            deviceType: type
        )
        if type == .earpiece {
            earpieceMessageInfo = item
        } else {
            phoneMessageInfo = item
        }
        groupItems.append(item)
        syncSpeakArray.accept(groupItems)
    }

    private func resetCache() {
        subOriginText = ""
        subTranslateText = ""
    }

    private func timerAction() {
        TimerHelper.stopTimer(timerID: countTimerUID)
        countTimerUID = TimerHelper.setInterval(interval: 1, completion: { [weak self] _ in
            guard let self = self else { return }
            let date0 = Date.strBeDate(self.groupId) ?? Date()
            let date1 = Date()
            let count = date1.timeIntervalSince1970 - date0.timeIntervalSince1970
            let hour = Int(count / 3600)
            let min = Int(count / 60)
            let sec = Int(count.truncatingRemainder(dividingBy: 60))
            let str = String(format: "%02d:%02d:%02d", hour, min, sec)
            self.countTimerStr.accept(str)
        })
    }

    deinit {
        TimerHelper.stopTimer(timerID: countTimerUID)
        JLLogManager.logLevel(.DEBUG, content: "FaceToFaceTranslateVM deinit")
    }
    
    
    
    
    
}
