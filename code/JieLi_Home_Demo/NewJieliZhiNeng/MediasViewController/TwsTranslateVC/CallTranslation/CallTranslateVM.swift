//
//  CallTranslateVM.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/17.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class CallTranslateVM {
    let syncSpeakArray: BehaviorRelay<[ChatMessageInfo]> = BehaviorRelay(value: [])
    let currentCountTime: BehaviorRelay<String> = BehaviorRelay(value: "00:00")
    private let disposeBag = DisposeBag()
    private let endSpeakColor = UIColor.eHex("#000000", alpha: 0.5)
    private let speakingColor: UIColor = .eHex("#448EFF")
    private let _viewController: CallTranslationVC
    private var ttsMgrMySide: VolcesTTSMgr?
    private var ttsMgrOtherSide: VolcesTTSMgr?
    private var subOriginTextMySide: String = ""
    private var subTranslateTextMySide: String = ""
    private var subOriginTextOtherSide: String = ""
    private var subTranslateTextOtherSide: String = ""
    private var groupData: [ChatMessageInfo] = []
    private var originInfoDict: [String: CallRecord] = [:]
    private var groupId: String = ""
    private var mysideTimerUid = ""
    private var otherSideTimerUid = ""
    private var currentTimerUid = ""
    private var needCreateNewModelMyside = false
    private var needCreateNewModelOtherSide = false
    private var isFinished: Bool = false

    init(_ viewController: CallTranslationVC) {
        _viewController = viewController
        ttsMgrMySide = VolcesTTSMgr()
        ttsMgrMySide?.start { _ in
        } _: { [weak self] pcmData, uuid, isEnd, _ in
            guard let self = self else { return }
            self.updateOrigin(pcmData, uuid, isEnd)
        }
        ttsMgrOtherSide = VolcesTTSMgr()
        ttsMgrOtherSide?.start { _ in
        } _: { [weak self] pcmData, uuid, isEnd, _ in
            guard let self = self else { return }
            self.updateOrigin(pcmData, uuid, isEnd)
        }
        prepareStatus()
    }

    func resetLanguage(languages: (TranslateLanguage, TranslateLanguage), result: @escaping ((TranslateLanguage, TranslateLanguage), Error?) -> Void) {
        let chain = JLTaskChain()
        chain.addTask {
            _,
            completion in
            TranslateVM.shared.exitMode {
                [weak self] _,
                err in
                guard let self = self else { return }
                if err != nil {
                    JLLogManager.logLevel(.ERROR, content: "exit error:\(String(describing: err))")
                    completion(nil, err)
                    return
                }
                self.resetStatus()
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 1,
                    execute: DispatchWorkItem(block: {                
                        completion(nil, nil)
                    })
                )
            }
        }
        chain.addTask { _, completion in
            TranslateTools.saveLanguages(languages, type: .call)
            TranslateVM.shared.translateLanguage = (
                languages.0,
                [languages.1]
            )
            TranslateVM.shared.translateCallLanguage = (
                languages.1,
                [languages.0]
            )
            TranslateVM.shared.setMode(type: .call) { _, err in
                if err != nil {
                    completion(nil, err)
                    return
                }
                self.prepareStatus()
                completion(nil, nil)
            }
        }

        chain.run(withInitialInput: nil) { _, err in
            if err != nil {
                JLLogManager.logLevel(.ERROR, content: "reset error:\(String(describing: err))")
                result(languages, err)
                return
            }
            result(languages, nil)
        }
    }

    func dispose() {
        TimerHelper.stopTimer(timerID: currentTimerUid)
        TimerHelper.stopTimer(timerID: mysideTimerUid)
        TimerHelper.stopTimer(timerID: otherSideTimerUid)
        isFinished = true
    }

    func sendText(text: String) {
        if text.isEmpty {
            return
        }
        let sideType = CallRecordSideType.mySide
        subOriginTextMySide = text
        let startTime = Date()
        let info = ChatMessageInfo(
            startTime: startTime.timeIntervalSince1970,
            title: sideType.sideStr,
            titleColor: sideType.sideColor,
            original: subOriginTextMySide,
            translate: "",
            translateColor: endSpeakColor
        )
        info.info = CallRecord(
            groupID: groupId,
            startTime: startTime.timeIntervalSince1970,
            originText: subOriginTextMySide,
            translateText: "",
            direction: sideType,
            audioData: Data(),
            audioDataOrigin: Data()
        )
        groupData.append(info)
        syncSpeakArray.accept(groupData)
        TextTranslateMgr.share.startTranslate(groupID: groupId, origin: subOriginTextMySide, Date: startTime) { [weak self] record in
            guard let self = self else { return }
            guard let item = syncSpeakArray.value.first(where: { $0.info?.groupID == record.groupID &&  $0.info?.startTime == record.startTime }) else { return }
            item.translate = record.translateText
            item.info?.translateText = record.translateText
            item.info?.audioData = record.audioData
            item.info?.audioDataOrigin = record.audioDataOrigin
            syncSpeakArray.accept(groupData)
            guard let info = item.info else { return }
            TranslateVM.shared.translateMgr?.sendPcmDataToDevice(record.audioDataOrigin)
            _ = TranslationCallDB.share.save(record: info)
        }
    }

    private func resetStatus() {
        TimerHelper.stopTimer(timerID: currentTimerUid)
        TimerHelper.stopTimer(timerID: mysideTimerUid)
        TimerHelper.stopTimer(timerID: otherSideTimerUid)
        groupId = Date().getDateStr
        groupData = []
        subOriginTextMySide = ""
        subTranslateTextMySide = ""
        subOriginTextOtherSide = ""
        subTranslateTextOtherSide = ""
    }

    private func prepareStatus() {
        groupId = Date().getDateStr
        subscribe()
        TimerHelper.stopTimer(timerID: currentTimerUid)
        currentTimerUid = TimerHelper.setInterval(interval: 1, completion: { [weak self] _ in
            guard let self = self else { return }
            let date0 = Date.strBeDate(groupId) ?? Date()
            let date1 = Date()
            let count = date1.timeIntervalSince1970 - date0.timeIntervalSince1970
            let hour = Int(count / 3600)
            let min = Int(count / 60)
            let sec = Int(count.truncatingRemainder(dividingBy: 60))
            let str = String(format: "%02d:%02d:%02d", hour, min, sec)
            self.currentCountTime.accept(str)
        })
    }

    private func updateOrigin(_ pcmData: Data, _ uuid: UUID, _ isEnd: Bool) {
        guard let info = originInfoDict[uuid.uuidString] else { return }
        info.audioDataOrigin.append(pcmData)
        if isEnd {
            _ = TranslationCallDB.share.save(record: info)
            originInfoDict.removeValue(forKey: uuid.uuidString)

            if isFinished {
                ttsMgrMySide?.stop()
                ttsMgrMySide = nil
                ttsMgrOtherSide?.stop()
                ttsMgrOtherSide = nil
            }
        }
    }

    // MARK: - 订阅

    private func subscribe() {
        // MARK: myside 的实时内容

        guard let mysideMgr = TranslateVM.shared.translateMgr else { return }
        mysideMgr.subtitleText.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            if text.count == 0 { return }
            let mode = getCurrentMode(sideType: .mySide)
            mode.original = subOriginTextMySide + text
            mode.translate = subTranslateTextMySide
            mode.translateColor = speakingColor
            syncSpeakArray.accept(groupData)
            TimerHelper.stopTimer(timerID: mysideTimerUid)
            JLLogManager.logLevel(.DEBUG, content: "subSrcibe 正在说")
        }).disposed(by: disposeBag)

        mysideMgr.definiteTextOrigin.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            if text.count == 0 { return }
            let mode = getCurrentMode(sideType: .mySide)
            subOriginTextMySide += text
            mode.original = subOriginTextMySide
            mode.translate = subTranslateTextMySide
            mode.translateColor = speakingColor
            syncSpeakArray.accept(groupData)
            JLLogManager.logLevel(.DEBUG, content: "subSrcibe 原文")
        }).disposed(by: disposeBag)

        mysideMgr.definiteTextTranslate.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            if text.count == 0 { return }
            let mode = getCurrentMode(sideType: .mySide)
            mode.original = subOriginTextMySide
            subTranslateTextMySide += text
            mode.translate = subTranslateTextMySide
            mode.translateColor = speakingColor
            syncSpeakArray.accept(groupData)
            mysideTimeOutCheck(mode)
            JLLogManager.logLevel(.DEBUG, content: "subSrcibe 译文")
        }).disposed(by: disposeBag)

        mysideMgr.targetPcmData.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            if data.0.count == 0 {
                return
            }
            let mode = getCurrentMode(sideType: .mySide)
            mode.original = subOriginTextMySide
            mode.translate = subTranslateTextMySide
            mode.translateColor = endSpeakColor
            mode.info?.audioData.append(data.0)
            syncSpeakArray.accept(groupData)
            JLLogManager.logLevel(.DEBUG, content: "subSrcibe 语音")
        }).disposed(by: disposeBag)

        // MARK: otherSide 的实时内容

        guard let otherSideMgr = TranslateVM.shared.callTranslateMgr else { return }
        otherSideMgr.subtitleText.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            if text.count == 0 { return }
            let mode = getCurrentMode(sideType: .otherSide)
            mode.original = subOriginTextOtherSide + text
            mode.translate = subTranslateTextOtherSide
            mode.translateColor = speakingColor
            syncSpeakArray.accept(groupData)
            TimerHelper.stopTimer(timerID: otherSideTimerUid)
        }).disposed(by: disposeBag)

        otherSideMgr.definiteTextOrigin.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            if text.count == 0 { return }
            let mode = getCurrentMode(sideType: .otherSide)
            subOriginTextOtherSide += text
            mode.original = subOriginTextOtherSide
            mode.translate = subTranslateTextOtherSide
            mode.translateColor = speakingColor
            syncSpeakArray.accept(groupData)
        }).disposed(by: disposeBag)

        otherSideMgr.definiteTextTranslate.subscribe(onNext: { [weak self] text in
            guard let self = self else { return }
            if text.count == 0 { return }
            let mode = getCurrentMode(sideType: .otherSide)
            mode.original = subOriginTextOtherSide
            subTranslateTextOtherSide += text
            mode.translate = subTranslateTextOtherSide
            mode.translateColor = speakingColor
            syncSpeakArray.accept(groupData)
            othersideTimeOutCheck(mode)
        }).disposed(by: disposeBag)

        otherSideMgr.targetPcmData.subscribe(onNext: { [weak self] data in
            guard let self = self else { return }
            if data.0.count == 0 {
                return
            }
            let mode = getCurrentMode(sideType: .otherSide)
            mode.original = subOriginTextOtherSide
            mode.translate = subTranslateTextOtherSide
            mode.translateColor = endSpeakColor
            mode.info?.audioData.append(data.0)
            syncSpeakArray.accept(groupData)
        }).disposed(by: disposeBag)
    }

    private func mysideTimeOutCheck(_ mode: ChatMessageInfo) {
        TimerHelper.stopTimer(timerID: mysideTimerUid)
        mysideTimerUid = TimerHelper.createTimer(timeOut: 3) { _ in
            self.needCreateNewModelMyside = true
            self.subOriginTextMySide = ""
            self.subTranslateTextMySide = ""
            guard let info = mode.info else { return }
            info.originText = mode.original
            info.translateText = mode.translate
            _ = TranslationCallDB.share.save(record: info)
            let newInfo = info.copy() as! CallRecord
            let keyUUID = UUID()
            self.originInfoDict.updateValue(newInfo, forKey: keyUUID.uuidString)
            self.ttsMgrMySide?.sendText([newInfo.originText, newInfo.translateText], keyUUID)
        }
    }

    private func othersideTimeOutCheck(_ mode: ChatMessageInfo) {
        TimerHelper.stopTimer(timerID: otherSideTimerUid)
        otherSideTimerUid = TimerHelper.createTimer(timeOut: 3) { _ in
            self.needCreateNewModelOtherSide = true
            self.subOriginTextOtherSide = ""
            self.subTranslateTextOtherSide = ""
            guard let info = mode.info else { return }
            info.originText = mode.original
            info.translateText = mode.translate
            _ = TranslationCallDB.share.save(record: info)
            let newInfo = info.copy() as! CallRecord
            let keyUUID = UUID()
            self.originInfoDict.updateValue(newInfo, forKey: keyUUID.uuidString)
            self.ttsMgrOtherSide?.sendText([newInfo.originText, newInfo.translateText], keyUUID)
        }
    }

    private func getCurrentMode(sideType: CallRecordSideType) -> ChatMessageInfo {
        let newList = groupData.filter {
            $0.title == sideType.sideStr
        }
        if newList.isEmpty {
            let info = ChatMessageInfo(
                startTime: Date().timeIntervalSince1970,
                title: sideType.sideStr,
                titleColor: sideType.sideColor,
                original: "",
                translate: "",
                translateColor: speakingColor
            )
            info.info = CallRecord(
                groupID: groupId,
                startTime: Date().timeIntervalSince1970,
                originText: "",
                translateText: "",
                direction: sideType,
                audioData: Data(),
                audioDataOrigin: Data()
            )
            groupData.append(info)
            needCreateNewModelMyside = false
            needCreateNewModelOtherSide = false
            return info
        } else {
            if needCreateNewModelMyside || needCreateNewModelOtherSide {
                JLLogManager.logLevel(.DEBUG, content: "needCreateNewModelMyside \(needCreateNewModelMyside) needCreateNewModelOtherSide \(needCreateNewModelOtherSide)")
                needCreateNewModelMyside = false
                needCreateNewModelOtherSide = false
                let info = ChatMessageInfo(
                    startTime: Date().timeIntervalSince1970,
                    title: sideType.sideStr,
                    titleColor: sideType.sideColor,
                    original: "",
                    translate: "",
                    translateColor: speakingColor
                )
                info.info = CallRecord(
                    groupID: groupId,
                    startTime: Date().timeIntervalSince1970,
                    originText: "",
                    translateText: "",
                    direction: sideType,
                    audioData: Data(),
                    audioDataOrigin: Data()
                )
                groupData.append(info)
                return groupData.last!
            }
            return groupData.first(where: { $0.uid == newList.last!.uid })!
        }
    }

    deinit {
        print("CallTranslateVM deinit")
        ttsMgrMySide?.stop()
        ttsMgrOtherSide?.stop()
//        testTimer?.invalidate()
//        testTimer = nil
    }
    
    
    // private var testTimer: Timer?
    // private var costomMgr: JL_CustomManager?
    
    // func startHeartBeat() {
    //     costomMgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mCustomManager
    //     costomMgr?.delegate = self
    //     testTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(testAction), userInfo: nil, repeats: true)
    //     testTimer?.fire()
    // }
    
    // func stopHeartBeat() {
    //     testTimer?.invalidate()
    //     testTimer = nil
    // }
    
    // @objc func testAction() {
    //     let dtStr = "00aa"
    //     let data = JL_Tools.hex(toData: dtStr) as Data
    //     costomMgr?.cmdCustomData(data, isNeedResponse: true)
    // }
    
}

extension CallTranslateVM : JLCustomCmdPtl {
    func isEqual(_ object: Any?) -> Bool {
        true
    }
    
    var hash: Int {
        0
    }
    
    var superclass: AnyClass? {
        nil
    }
    
    func `self`() -> Self {
        self
    }
    
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! {
        // Check if the selector is implemented
        guard responds(to: aSelector) else {
            return nil
        }
        
        // Perform the selector and return the result
        return perform(aSelector)
    }

    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! {
        guard responds(to: aSelector) else {
            return nil
        }
        
        return perform(aSelector, with: object)
    }

    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! {
        guard responds(to: aSelector) else {
            return nil
        }
        
        return perform(aSelector, with: object1, with: object2)
    }
    
    func isProxy() -> Bool {
        true
    }
    
    func isKind(of aClass: AnyClass) -> Bool {
        true
    }
    
    func isMember(of aClass: AnyClass) -> Bool {
        true
    }
    
    func conforms(to aProtocol: Protocol) -> Bool {
        true
    }
    
    func responds(to aSelector: Selector!) -> Bool {
        true
    }
    
    var description: String {
        ""
    }
    
    func customCmdResponse(_ manager: JL_ManagerM, status: UInt8, with data: Data) {
        
    }
    
    func customCmdRequire(_ manager: JL_ManagerM, with data: Data, isNeedResponse: Bool, sn: UInt8) {
        
    }
    
}
