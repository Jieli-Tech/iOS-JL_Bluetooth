//
//  SyncRecordViewModel.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/8/5.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation

class SyncRecordViewModel: NSObject {
    let currentTime = BehaviorRelay<String>(value: "00:00")
    let allTime = BehaviorRelay<String>(value: "00:00")
    let originText = BehaviorRelay<String>(value: "")
    let translateText = BehaviorRelay<String>(value: "")
    let showGroupText = BehaviorRelay<(String, String)>(value: ("", ""))
    let playStatus = BehaviorRelay<Bool>(value: false)
    let currentDuration = BehaviorRelay<Double>(value: 0)
    let progress = BehaviorRelay<Float>(value: 0)

    private var dbList: [TranslationRecord] = []
    private var timepoints: [Double] = []
    private var audioPlayer: JLAudioUnitPlayer?
    func initData(groupId: String) {
        dbList = TranslationRecordDB.shared.getRecordsByGroupId(groupId)
        var originText = ""
        var translateText = ""
        var audioData = Data()
        timepoints.append(0)
        for item in dbList {
            originText += item.originText
            translateText += item.translateText
            audioData.append(item.audioData)
            let time = timepoints.last! + item.duration
            timepoints.append(time)
        }
        let allTime = TranslateTools.calculateDuration(dataBytes: audioData.count)
        let wavData = TranslateTools.convert(pcmData: audioData)

        self.originText.accept(originText)
        self.translateText.accept(translateText)
        currentTime.accept("00:00")
        self.allTime.accept(calculateTime(allTime))
        currentDuration.accept(allTime)

        let path = NSHomeDirectory() + "/Library/Caches/" + groupId + ".wav"
        try? FileManager.default.removeItem(atPath: path)
        FileManager.default.createFile(atPath: path, contents: wavData, attributes: nil)
        audioPlayer = JLAudioUnitPlayer(audioFile: path)
        audioPlayer?.delegate = self
    }

    func ppCtrl() {
        if playStatus.value {
            audioPlayer?.pause()
            playStatus.accept(false)
        } else {
            audioPlayer?.play()
        }
    }

    func stop() {
        audioPlayer?.stop()
        playStatus.accept(false)
    }

    func seekTo(_ time: Double) {
        audioPlayer?.seek(toTime: time)
        audioPlayer?.play()
    }

    // MARK: - 公开的句子时间/分段工具

    /// 返回指定句子索引的起始时间（单位：秒）
    func sentenceStartTime(at index: Int) -> Double {
        guard index >= 0, index < timepoints.count else { return 0 }
        return timepoints[index]
    }

    /// 根据组合文本计算每句的 NSRange（与 dbList 顺序一致）
    func sentenceRanges(forOriginal combinedOriginal: String, translate combinedTranslate: String) -> (orig: [NSRange], trans: [NSRange]) {
        let oStr = combinedOriginal as NSString
        let tStr = combinedTranslate as NSString
        var oRanges: [NSRange] = []
        var tRanges: [NSRange] = []
        var oOffset = 0
        var tOffset = 0
        for item in dbList {
            let oLen = (item.originText as NSString).length
            let tLen = (item.translateText as NSString).length
            // 防越界：如果组合文本长度小于累计长度，提前退出
            if oOffset + oLen <= oStr.length {
                oRanges.append(NSRange(location: oOffset, length: oLen))
            }
            if tOffset + tLen <= tStr.length {
                tRanges.append(NSRange(location: tOffset, length: tLen))
            }
            oOffset += oLen
            tOffset += tLen
        }
        return (oRanges, tRanges)
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

extension SyncRecordViewModel: JLAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_: JLAudioUnitPlayer) {
        playStatus.accept(false)
        progress.accept(0)
        currentTime.accept("00:00")
    }

    func audioPlayer(_: JLAudioUnitPlayer, didFailWithError _: any Error) {
        playStatus.accept(false)
    }

    func audioPlayer(_: JLAudioUnitPlayer, didUpdateProgress currentTime: TimeInterval, duration: TimeInterval) {
        playStatus.accept(true)
        self.currentTime.accept(calculateTime(currentTime))
        allTime.accept(calculateTime(duration))
        let index = findIntervalIndex(for: currentTime, in: timepoints)
        let item = dbList[index]
        showGroupText.accept((item.originText, item.translateText))
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
