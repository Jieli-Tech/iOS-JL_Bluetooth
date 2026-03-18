//
//  JLEcLog.swift
//  JLUsefulTools
//
//  Created by EzioChan on 2021/8/27.
//

import Foundation

@objc public enum LogLevel: UInt8 {
    case NoLog = 0xFF
    case info = 0x00
    case debug = 0x01
    case warning = 0x02
    case error = 0x03
}

var logLevel: LogLevel = .info
var logIsSave = false

public func ECPrintLevel(_ level: LogLevel) {
    logLevel = level
}

@objc public class JLLogLevel: NSObject {
    @objc public class func setLevel(_ level: LogLevel) {
        ECPrintLevel(level)
    }

    @objc public class func saveToDocument() {
        logIsSave = true
        SaveLog.share.create()
    }

    @objc public class func getLevel() -> LogLevel {
        logLevel
    }
}

class SaveLog {
    var path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/Log"

    static let share = SaveLog()

    func create() {
        let fm = DateFormatter()
        fm.dateFormat = "yyyyMMddHHmmss.txt"
        let dateStr = fm.string(from: Date())
        path.append("_\(dateStr)")
        if FileManager.default.isExecutableFile(atPath: path) {
            try? FileManager.default.removeItem(atPath: path)
        }
        FileManager.default.createFile(atPath: path, contents: Data())
    }

    func save(str: String) {
        let fileHandle = FileHandle(forWritingAtPath: path)
        fileHandle?.seekToEndOfFile()
        fileHandle?.write(str.data(using: .utf8) ?? Data())
        fileHandle?.closeFile()
    }
}

public func ECPrintInfo(_ any: Any, _ obj: Any, _ funcName: Any, _ line: Int) {
    if logLevel.rawValue > LogLevel.info.rawValue { return }
    let date = Date()
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

    print(timeFormatter.string(from: date), obj, "func:", funcName, "line:", line, "\n====>", any, "\n")
    if logIsSave {
        SaveLog.share.save(str: timeFormatter.string(from: date) + "func:+\(funcName)\n\(any)\n")
    }
}

public func ECPrintDebug(_ any: Any, _ obj: Any, _ funcName: Any, _ line: Int) {
    if logLevel.rawValue > LogLevel.debug.rawValue { return }
    let date = Date()
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    print(timeFormatter.string(from: date), obj, "func:", funcName, "line:", line, "\n====>", any, "\n")
    if logIsSave {
        SaveLog.share.save(str: timeFormatter.string(from: date) + "func:+\(funcName)\n\(any)\n")
    }
}

public func ECPrintWarning(_ any: Any, _ obj: Any, _ funcName: Any, _ line: Int) {
    if logLevel.rawValue > LogLevel.warning.rawValue { return }
    let date = Date()
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    print(timeFormatter.string(from: date), obj, "func:", funcName, "line:", line, "\n====>", any, "\n")
    if logIsSave {
        SaveLog.share.save(str: timeFormatter.string(from: date) + "func:+\(funcName)\n\(any)\n")
    }
}

public func ECPrintError(_ any: Any, _ obj: Any, _ funcName: Any, _ line: Int) {
    if logLevel.rawValue > LogLevel.error.rawValue { return }
    let date = Date()
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    print(timeFormatter.string(from: date), obj, "func:", funcName, "line:", line, "\n====>", any, "\n")
    if logIsSave {
        SaveLog.share.save(str: timeFormatter.string(from: date) + "func:+\(funcName)\n\(any)\n")
    }
}

public func ECPrint(_ any: Any, _ obj: Any, _ funcName: Any) {
    if logLevel == .NoLog { return }
    let date = Date()
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    print(timeFormatter.string(from: date), obj, "func:", funcName, "\n", any, "\n")
    if logIsSave {
        SaveLog.share.save(str: timeFormatter.string(from: date) + "func:+\(funcName)\n\(any)\n")
    }
}

public func ECPrint(_ any: Any, _ obj: Any) {
    if logLevel == .NoLog { return }
    let date = Date()
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    print(timeFormatter.string(from: date), obj, "\n====>", any, "\n")
    if logIsSave {
        SaveLog.share.save(str: timeFormatter.string(from: date) + "\(any)\n")
    }
}

public func ECPrint(_ any: Any) {
    if logLevel == .NoLog { return }
    let date = Date()
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    print(timeFormatter.string(from: date), "\n====>", any, "\n")
    if logIsSave {
        SaveLog.share.save(str: timeFormatter.string(from: date) + "\(any)\n")
    }
}
