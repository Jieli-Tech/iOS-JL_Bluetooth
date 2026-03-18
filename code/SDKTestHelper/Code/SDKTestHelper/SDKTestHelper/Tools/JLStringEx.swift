//
//  JLStringEx.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/10.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

extension String {
    var hexToBytes: [UInt8] {
        var start = startIndex
        return stride(from: 0, to: count, by: 2).compactMap { _ in
            let end = index(after: start)
            defer { start = index(after: end) }
            return UInt8(self[start ... end], radix: 16)
        }
    }
    func listFile() -> [String]? {
        if !FileManager.default.fileExists(atPath: self) {
            return nil
        }
        if let arr = try? FileManager.default.contentsOfDirectory(atPath: self) {
            var items = [String]()
            for item in arr {
                items.append(self + "/" + item)
            }
            items = items.sorted(by: <)
            return items
        }
        return nil
    }
    
    func jsonStrBeDict() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else {
            print("无法将字符串转换为Data")
            return nil
        }
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = jsonObject as? [String: Any] {
                return dictionary
            } else {
                print("JSON不是字典格式")
                return nil
            }
        } catch {
            print("JSON解析错误: \(error.localizedDescription)")
            return nil
        }
    }
    
    func textAutoWidth(height: CGFloat, font: UIFont) -> CGFloat {
        let string = self as NSString
        let origin = NSStringDrawingOptions.usesLineFragmentOrigin
        let lead = NSStringDrawingOptions.usesFontLeading
        let rect = string.boundingRect(with: CGSize(width: 0, height: height), options: [origin, lead], attributes: [NSAttributedString.Key.font: font], context: nil)
        return rect.width
    }
}



