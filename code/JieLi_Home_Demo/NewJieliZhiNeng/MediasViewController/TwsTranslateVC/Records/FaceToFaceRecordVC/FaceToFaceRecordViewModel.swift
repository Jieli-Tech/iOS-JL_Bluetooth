//
//  FaceToFaceRecordViewModel.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/9/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation

class FaceToFaceRecordViewModel: NSObject {
    let groupId: BehaviorRelay<Date> = BehaviorRelay(value: Date())
    let currentTime = BehaviorRelay<String>(value: "00:00")
    let allTime = BehaviorRelay<String>(value: "00:00")
    let showGroupText = BehaviorRelay<(String, String)>(value: ("", ""))
    let playStatus = BehaviorRelay<Bool>(value: false)
    let currentDuration = BehaviorRelay<Double>(value: 0)
    let progress = BehaviorRelay<Float>(value: 0)
    let messageList: BehaviorRelay<[ChatMessageInfo]> = BehaviorRelay(value: [])
    let currentPlayIndex = BehaviorRelay<Int>(value: 0)
    let allDuration: BehaviorRelay<Float> = BehaviorRelay(value: 100)

    private var dbList: [FaceToFaceRecord] = []
    private var timepoints: [Double] = []
    private var playPath: String = ""
    private var audioPlayer: JLAudioUnitPlayer?

    init(groupId: Date) {
        super.init()
        self.groupId.accept(groupId)
        initData()
    }

    private func initData() {
        dbList = TranslationFaceToFaceDB.share.getRecords(groupId: groupId.value.getDateStr)
        var audioData = Data()
        timepoints = []
        var messageList: [ChatMessageInfo] = []
        timepoints.append(0)
        var countTime:Double = 0.0
        for item in dbList {
            audioData.append(item.audioData)
            let time = timepoints.last! + TranslateTools.calculateDuration(dataBytes: item.audioData.count)
            timepoints.append(time)
            let color: UIColor = item.deviceType == .phone ? .eHex("#47E45F") : .eHex("#DB5252")
            let message = ChatMessageInfo(startTime: countTime, title: item.deviceType.title, titleColor: color, original: item.originalText, translate: item.translatedText, translateColor: .eHex("#000000", alpha: 0.5))
            message.faceInfo = item
            messageList.append(message)
            countTime += TranslateTools.calculateDuration(dataBytes: item.audioData.count)
        }
        self.messageList.accept(messageList)
        let allTime = TranslateTools.calculateDuration(dataBytes: audioData.count)
        
        allDuration.accept(Float(allTime))
        self.allTime.accept(calculateTime(allTime))

        let wavData = TranslateTools.convert(pcmData: audioData)

        currentTime.accept("00:00")
        playPath = NSHomeDirectory() + "/Library/Caches/" + groupId.value.getDateStr + ".wav"
        try? FileManager.default.removeItem(atPath: playPath)
        FileManager.default.createFile(atPath: playPath, contents: wavData, attributes: nil)
        audioPlayer = JLAudioUnitPlayer(audioFile: playPath)
        audioPlayer?.delegate = self
    }

    func play() {
        audioPlayer?.play()
        playStatus.accept(true)
    }

    func seekTo(_ time: Double) {
        audioPlayer?.seek(toTime: time)
        audioPlayer?.play()
    }

    func pause() {
        audioPlayer?.pause()
        playStatus.accept(false)
    }

    func stop() {
        audioPlayer?.stop()
        playStatus.accept(false)
        let msgList = messageList.value
        for i in 0 ..< msgList.count {
            let item = msgList[i]
            item.originalColor = .eHex("#000000", alpha: 0.9)
            item.translateColor = .eHex("#000000", alpha: 0.5)
            messageList.accept(msgList)
        }
    }

    private func calculateTime(_ time: Double) -> String {
        if time / 3600 >= 1 {
            let hour = Int(time / 3600)
            let min = Int(time / 60) % 60
            let sec = Int(time) % 60
            return String(format: "%02d:%02d:%02d", hour, min, sec)
        } else {
            let min = Int(time / 60)
            let sec = Int(time) % 60
            return String(format: "%02d:%02d", min, sec)
        }
    }
}

extension FaceToFaceRecordViewModel: JLAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_: JLAudioUnitPlayer) {
        playStatus.accept(false)
        let msgList = messageList.value
        for i in 0 ..< msgList.count {
            let item = msgList[i]
            item.originalColor = .eHex("#000000", alpha: 0.9)
            item.translateColor = .eHex("#000000", alpha: 0.5)
            messageList.accept(msgList)
        }
        currentPlayIndex.accept(0)
    }

    func audioPlayer(_: JLAudioUnitPlayer, didFailWithError _: any Error) {
        playStatus.accept(false)
    }

    func audioPlayer(_: JLAudioUnitPlayer, didUpdateProgress currentTime: TimeInterval, duration: TimeInterval) {
        playStatus.accept(true)
        self.currentTime.accept(calculateTime(currentTime))
        allTime.accept(calculateTime(duration))
        let index = findIntervalIndex(for: currentTime, in: timepoints)
        if currentPlayIndex.value == 0 || index != currentPlayIndex.value {
            let msgList = messageList.value
            for i in 0 ..< msgList.count {
                let item = msgList[i]
                item.originalColor = .eHex("#000000", alpha: 0.9)
                item.translateColor = .eHex("#000000", alpha: 0.5)
                if i == index {
                    item.originalColor = .eHex("#F89514")
                    item.translateColor = .eHex("#F89514")
                }
                messageList.accept(msgList)
            }
            currentPlayIndex.accept(index)
        }
        progress.accept(Float(currentTime))
    }

    func findIntervalIndex(for targetValue: Double, in cumulativeArray: [Double]) -> Int {
        guard cumulativeArray.count > 1 else { return 0 }
        for i in 1 ..< cumulativeArray.count {
            let lowerBound = cumulativeArray[i - 1]
            let upperBound = cumulativeArray[i]
            if targetValue >= lowerBound && targetValue < upperBound {
                return i - 1
            }
        }
        return 0
    }
}
