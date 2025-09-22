//
//  JLEcFileSystem.swift
//  JLUsefulTools
//
//  Created by EzioChan on 2022/3/9.
//

import Foundation

public extension String {
    // weather long file name
    var islongFN: Bool {
        let strArray = (self as NSString).components(separatedBy: ".")
        let strData = (strArray.first ?? "").data(using: .utf8) ?? Data()
        if strData.count >= 8 {
            return true
        } else {
            return false
        }
    }

    /// 正则替换
    /// - Parameters:
    ///   - regex: 正则表达式
    ///   - content: 替换内容
    /// - Returns: 字符串
    func replace(regex: String, content: String) -> String {
        do {
            let RE = try NSRegularExpression(pattern: regex, options: .caseInsensitive)
            let modified = RE.stringByReplacingMatches(in: self, options: .reportProgress, range: NSRange(location: 0, length: count), withTemplate: content)
            return modified
        } catch {
            return self
        }
    }

    /// 去掉特殊字符
    /// - Returns: 字符串
    func deleteSpecialCharacters() -> String {
        let pattern = "[^a-zA-Z0-9\u{4e00}-\u{9fa5}]"
        let express = try! NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        return express.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, count), withTemplate: "")
    }
}

public class LogText {
    public class func save(data: Data, name: String? = nil) {
        var realName = "tempLog.data"
        if let n = name {
            realName = n
        }
        let savePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/" + realName
        if FileManager.default.fileExists(atPath: savePath) {
            try? FileManager.default.removeItem(atPath: savePath)
        }
        FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
    }
}
