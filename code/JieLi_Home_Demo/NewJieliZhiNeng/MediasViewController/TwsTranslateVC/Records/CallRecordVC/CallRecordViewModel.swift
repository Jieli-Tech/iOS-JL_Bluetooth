//
//  CallRecordViewModel.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/8/26.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation

class CallRecordViewModel: NSObject {
    let groupId: BehaviorRelay<Date> = BehaviorRelay(value: Date())
    let messageList: BehaviorRelay<[ChatMessageInfo]> = BehaviorRelay(value: [])
    let allDuration: BehaviorRelay<Float> = BehaviorRelay(value: 100)
    let playStatus = BehaviorRelay<Bool>(value: false)
    let currentTime = BehaviorRelay<String>(value: "00:00")
    let allTime = BehaviorRelay<String>(value: "00:00")
    let showGroupText = BehaviorRelay<(String, String)>(value: ("", ""))
    let progress = BehaviorRelay<Float>(value: 0)
    let currentPlayIndex = BehaviorRelay<Int>(value: 0)
    

    private var audioPlayer: JLAudioUnitPlayer?
    private var timepoints: [Double] = []
    private var currentAudioType: CallRecordTextType = .original

    init(groupId: Date) {
        super.init()
        self.groupId.accept(groupId)
        initData()
    }

    private func initData() {
        let groudID = groupId.value.getDateStr
        let list = TranslationCallDB.share.query(groupID: groudID)
        var messageList: [ChatMessageInfo] = []
        for item in list {
            let color: UIColor = item.direction == .mySide ? .eHex("#47E45F") : .eHex("#DB5252")
            let message = ChatMessageInfo(startTime: 0, title: item.direction.sideStr, titleColor: color, original: item.originText, translate: item.translateText, translateColor: .eHex("#000000", alpha: 0.5))
            message.info = item
            messageList.append(message)
        }
        self.messageList.accept(messageList)
    }

    func play(_ type: CallRecordTextType) {
        var allTime: Double = 0
        timepoints = []
        currentAudioType = type
        timepoints.append(0)
        var pcmData = Data()
        for item in messageList.value {
            var audioData = Data()
            if type == .original {
                audioData = item.info!.audioDataOrigin
            } else {
                audioData = item.info!.audioData
            }
            item.startTime = allTime
            let duration = TranslateTools.calculateDuration(dataBytes: audioData.count)
            allTime += duration
            timepoints.append(allTime)
            pcmData.append(audioData)
        }
        allDuration.accept(Float(allTime))
        let wavData = TranslateTools.convert(pcmData: pcmData)
        let path = NSHomeDirectory() + "/Library/Caches/" + groupId.value.getDateStr + ".wav"
        try? FileManager.default.removeItem(atPath: path)
        FileManager.default.createFile(atPath: path, contents: wavData, attributes: nil)
        audioPlayer = JLAudioUnitPlayer(audioFile: path)
        audioPlayer?.delegate = self
        if currentPlayIndex.value != 0 {
            let dt = timepoints[currentPlayIndex.value]
            audioPlayer?.seek(toTime: dt)
            currentTime.accept(calculateTime(dt))
            let msgList = messageList.value
            for i in 0 ..< msgList.count {
                let item = msgList[i]
                item.originalColor = .eHex("#000000", alpha: 0.9)
                item.translateColor = .eHex("#000000", alpha: 0.5)
                if currentAudioType == .original {
                    if i == currentPlayIndex.value {
                        item.originalColor = .eHex("#F89514")
                    }
                } else {
                    if i == currentPlayIndex.value {
                        item.translateColor = .eHex("#448EFF")
                    }
                }
                messageList.accept(msgList)
            }
            currentPlayIndex.accept(currentPlayIndex.value)
        }
        audioPlayer?.play()
    }

    func seekTo(_ time: Double) {
        audioPlayer?.seek(toTime: time)
        audioPlayer?.play()
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

extension CallRecordViewModel: JLAudioPlayerDelegate {
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
                if currentAudioType == .original {
                    if i == index {
                        item.originalColor = .eHex("#F89514")
                    }
                } else {
                    if i == index {
                        item.translateColor = .eHex("#448EFF")
                    }
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
