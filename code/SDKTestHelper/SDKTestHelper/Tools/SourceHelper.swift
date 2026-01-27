//
//  SourceHelper.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/27.
//

import Foundation

let kJL_CONNECT_FAILED: String = "kJL_CONNECT_FAILED"

extension _R {
    var localStr: _R.string.localizable {
        R.string.localizable
    }
    
    var isZh: Bool {
        let languageCode = Locale.current.languageCode
        return languageCode == "zh" || languageCode?.hasPrefix("zh-") == true
    }
    
    var codeDict: [String: String] {
        if let url = R.file.codeExamplePlist.url(),
           let data = try? Data(contentsOf: url)
        {
            let decoder = PropertyListDecoder()
            if let plistData = try? decoder.decode([String: String].self, from: data) {
                return plistData
            }
        }
        return [:]
    }
    
    static func initFold() {
        try? FileManager.default.createDirectory(atPath: _R.path.transportFilePath, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.watchFilePath, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.smallFiles, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.otas, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.srcs, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.ota4gfile, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.tipsVoice, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.gif2Rgb, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.pcmPath, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.opusPath, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.image2Bin, withIntermediateDirectories: true, attributes: nil)
        try? FileManager.default.createDirectory(atPath: _R.path.jlaV2Path, withIntermediateDirectories: true, attributes: nil)
    }
    
    enum path {
        static let document = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        static let library = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
        static let transportFilePath = path.document + "/transportFile"
        static let watchFilePath = path.document + "/watchs"
        static let smallFiles = path.document + "/smallFiles"
        static let otas = path.document + "/otas"
        static let srcs = path.document + "/srcs"
        static let ota4gfile = path.document + "/ota4gfile"
        static let tipsVoice = path.document + "/tipsVoice"
        static let gif2Rgb = path.document + "/gif2rgb"
        static let image2Bin = path.document + "/image2Bin"
        static let pcmPath = path.document + "/pcmPath"
        static let opusPath = path.document + "/opusPath"
        static let jlaV2Path = path.document + "/jlaV2Path"
    }
    
    static func sizeForFilePath(_ filePath: String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size] {
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
        var convertedValue = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    
    static func saveToTmpFile(data: Data) {
        let filePath = path.document + "/tmp.bin"
        try? FileManager.default.removeItem(atPath: filePath)
        try? data.write(to: URL(fileURLWithPath: filePath))
    }
    
    static func appendToFile(filePath: String?, data: Data) {
        guard let filePath = filePath else { return }
        let fileURL = URL(fileURLWithPath: filePath)
        
        do {
            if !FileManager.default.fileExists(atPath: filePath) {
                FileManager.default.createFile(atPath: filePath, contents: data)
                return
            }
            
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            try fileHandle.close()
        } catch {
            
            JLLogManager.logLevel(.ERROR, content: "append data to filepath failed:\(error)")
            
        }

    }
}

extension JL_FileHandleType {
    func beString() -> String {
        switch self {
        case .FLASH:
            return "FLASH"
        case .SD_0:
            return "SD_0"
        case .USB:
            return "USB"
        case .SD_1:
            return "SD_1"
        case .lineIn:
            return "lineIn"
        case .FLASH2:
            return "FLASH2"
        case .FLASH3:
            return "FLASH3"
        case .reservedArea:
            return "reservedArea"
        @unknown default:
            return "未知"
        }
    }
}


