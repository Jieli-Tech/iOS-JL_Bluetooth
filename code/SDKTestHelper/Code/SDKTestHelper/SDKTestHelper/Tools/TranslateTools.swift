//
//  TranslateTools.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/3.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

private extension TranslateLanType {
    var key: String {
        switch self {
        case .call:
            return TranslateTools.callLanguage
        case .sync:
            return TranslateTools.syncLanguage
        case .face:
            return TranslateTools.faceLanguage
        }
    }
}

class TranslateTools: NSObject {
    static let syncLanguage = "SyncLanguage"
    static let callLanguage = "CallLanguage"
    static let faceLanguage = "FaceLanguage"

    /// 计算语音时长
    /// - Parameters:
    ///   - dataBytes: 音频数据长度
    ///   - sampleRate: 采样率
    ///   - bitDepth: 采样位深
    ///   - channels: 通道
    /// - Returns: 时长
    static func calculateDuration(dataBytes: Int, sampleRate: Double = 16000, bitDepth: Int = 16, channels: Int = 1) -> Double {
        let bytesPerSecond = sampleRate * Double(channels) * Double(bitDepth) / 8.0
        return Double(dataBytes) / bytesPerSecond
    }

    /// 将 PCM 数据转换为 WAV 格式
    /// - Parameters:
    ///   - pcmData: 原始 PCM 数据
    ///   - sampleRate: 采样率 (如 44100)
    ///   - channels: 声道数 (1 为单声道，2 为立体声)
    ///   - bitsPerSample: 每样本位数 (通常为 16)
    /// - Returns: 转换后的 WAV 数据
    static func convert(pcmData: Data, sampleRate: Int = 16000, channels: Int = 1, bitsPerSample: Int = 16) -> Data {
        let byteRate = sampleRate * channels * bitsPerSample / 8
        let blockAlign = channels * bitsPerSample / 8

        var wavData = Data()
        // RIFF 头
        wavData.append("RIFF".data(using: .ascii)!)
        var fileLength = pcmData.count + 44 - 8
        wavData.append(Data(bytes: &fileLength, count: 4))
        wavData.append("WAVE".data(using: .ascii)!)

        // fmt 子块
        wavData.append("fmt ".data(using: .ascii)!)
        var subchunk1Size: Int32 = 16 // PCM 格式没有额外信息
        wavData.append(Data(bytes: &subchunk1Size, count: 4))

        var audioFormat: Int16 = 1 // PCM = 1
        wavData.append(Data(bytes: &audioFormat, count: 2))

        var numChannels = Int16(channels)
        wavData.append(Data(bytes: &numChannels, count: 2))

        var sampleRateInt32 = Int32(sampleRate)
        wavData.append(Data(bytes: &sampleRateInt32, count: 4))

        var byteRateInt32 = Int32(byteRate)
        wavData.append(Data(bytes: &byteRateInt32, count: 4))

        var blockAlignInt16 = Int16(blockAlign)
        wavData.append(Data(bytes: &blockAlignInt16, count: 2))

        var bitsPerSampleInt16 = Int16(bitsPerSample)
        wavData.append(Data(bytes: &bitsPerSampleInt16, count: 2))

        // data 子块
        wavData.append("data".data(using: .ascii)!)
        var subchunk2Size = Int32(pcmData.count)
        wavData.append(Data(bytes: &subchunk2Size, count: 4))

        // 添加 PCM 数据
        wavData.append(pcmData)

        return wavData
    }
    
    static func saveConvertedPcmData(_ pcm: Data, file: String = "/test.wav") {
        let path = _R.path.transportFilePath + file
        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        guard let fileHandle = FileHandle(forWritingAtPath: path) else { return }
        fileHandle.seekToEndOfFile()
        fileHandle.write(pcm)
        fileHandle.closeFile()
    }

    // MARK: - 预设的翻译语言

    static func saveLanguages(_ languages: (TranslateLanguage, TranslateLanguage), type: TranslateLanType) {
        let array = [languages.0.rawValue, languages.1.rawValue]
        UserDefaults.standard.set(array, forKey: type.key)
    }

    static func getLanguages(_ type: TranslateLanType) -> (TranslateLanguage, TranslateLanguage) {
        let languages = UserDefaults.standard.stringArray(forKey: type.key)
        guard let languages = languages else { return (.zh, .en) }
        guard languages.count == 2 else { return (.zh, .en) }
        let result = (
            TranslateLanguage(rawValue: languages[0]) ?? .zh,
            TranslateLanguage(rawValue: languages[1]) ?? .en
        )
        return result
    }
}
