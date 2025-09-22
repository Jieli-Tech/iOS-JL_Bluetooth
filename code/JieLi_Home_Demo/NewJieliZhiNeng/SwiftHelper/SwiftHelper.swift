//
//  SwiftHelper.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/24.
//  Copyright © 2022 杰理科技. All rights reserved.
//

import Foundation
@_exported import SnapKit
@_exported import RxSwift
@_exported import RxCocoa
@_exported import MarqueeLabel
@_exported import Toast_Swift

class R {
    struct Font{
        static func medium(_ size: CGFloat)->UIFont{
            UIFont(name: "PingFangSC-Medium", size: size)!
        }
        static func regular(_ size: CGFloat)->UIFont{
            UIFont(name: "PingFangSC-Regular", size: size)!
        }
    }
    
    struct Language{
        static func lan(_ str:String,_ type: LanguageType = .auto)->String{
            if type == .auto {
                return LanguageCls.localizableTxt(str)
            } else {
                return LanguageCls.localizableTxt(str, table: type.rawValue)
            }
        }
    }
    
    enum LanguageType : String {
        case en = "en"
        case zh = "zh-Hans"
        case ja = "ja"
        case auto = "auto"
    }
    
    struct Image{
        static func img(_ imgName:String)->UIImage{
            UIImage(named: imgName) ?? UIImage()
        }
    }
    static let shared = R()
    init() {
        try?FileManager.default.createDirectory(atPath: R.path.transportFilePath, withIntermediateDirectories: true, attributes: nil)
        try?FileManager.default.createDirectory(atPath: R.path.watchFilePath, withIntermediateDirectories: true, attributes: nil)
        try?FileManager.default.createDirectory(atPath: R.path.smallFiles, withIntermediateDirectories: true, attributes: nil)
        try?FileManager.default.createDirectory(atPath: R.path.otas, withIntermediateDirectories: true, attributes: nil)
        try?FileManager.default.createDirectory(atPath: R.path.protectCustom, withIntermediateDirectories: true, attributes: nil)
        try?FileManager.default.createDirectory(atPath: R.path.wallPaperCustom, withIntermediateDirectories: true, attributes: nil)
    }
    
    struct path{
        static let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        static let transportFilePath = path.document + "/transportFile"
        static let watchFilePath = path.document + "/watchs"
        static let smallFiles = path.document + "/smallFiles"
        static let otas = path.document + "/otas"
        static let protectCustom = path.document + "/protectCustom"
        static let wallPaperCustom = path.document + "/wallPaperCustom"
    }
    
    
    
    static func sizeForFilePath(_ filePath:String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    
    static func covertToFileString(_ size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
}

