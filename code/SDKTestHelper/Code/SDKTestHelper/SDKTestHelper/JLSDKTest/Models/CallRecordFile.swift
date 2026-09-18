//
//  CallRecordFile.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/8.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import Foundation

/// 录音数据来源类型
enum CallRecordSourceType: String {
    /// 上行（己方说话）
    case up = "Up"
    /// 下行（对方说话）
    case down = "Down"
    /// 立体声
    case stereo = "Stereo"
    /// 面对面翻译（左耳+右耳）主机音频
    case simultaneousMaster = "Master"
    /// 面对面翻译（左耳+右耳）从机音频
    case simultaneousSlave = "Slave"
    
    /// 从文件名解析来源类型
    static func from(fileName: String) -> CallRecordSourceType {
        if fileName.contains("_Up") {
            return .up
        } else if fileName.contains("_Down") {
            return .down
        } else if fileName.contains("_Stereo") {
            return .stereo
        } else if fileName.contains("_Master") {
            return .simultaneousMaster
        } else if fileName.contains("_Slave") {
            return .simultaneousSlave
        }
        return .up
    }
    
    /// 显示名称
    var displayName: String {
        switch self {
        case .up:
            return "己方(上行)"
        case .down:
            return "对方(下行)"
        case .stereo:
            return "立体声"
        case .simultaneousMaster:
            return "面对面翻译（左耳+右耳）(主机)"
        case .simultaneousSlave:
            return "面对面翻译（左耳+右耳）(从机)"
        }
    }
}

/// 通话录音文件数据模型
struct CallRecordFile {
    /// 文件URL
    let url: URL
    /// 文件名
    let name: String
    /// 文件大小（字节）
    let size: UInt64
    /// 创建时间
    let createDate: Date
    /// 数据来源类型
    let sourceType: CallRecordSourceType
    /// 录音时长（秒）
    let duration: Double
    
    /// 格式化文件大小
    var sizeString: String {
        return _R.covertToFileString(size)
    }
    
    /// 格式化时长
    var durationString: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 格式化创建时间
    var createDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.string(from: createDate)
    }
}
