//
//  JLEcDataTools.swift
//  JLUsefulTools
//
//  Created by EzioChan on 2021/9/3.
//

import Foundation

public extension Data {
    var eUint8: UInt8 {
        UInt8(littleEndian: [UInt8](self).first ?? 0x00)
    }

    var eUint16: UInt16 {
        if count < 2 {
            return 0x00
        } else {
            return withUnsafeBytes { $0.load(as: UInt16.self) }
        }
    }

    var eBool: Bool {
        let v = UInt8(littleEndian: [UInt8](self).first ?? 0x00)
        if v == 0x00 {
            return false
        } else {
            return true
        }
    }

    var eUint32: UInt32 {
        let i32array = withUnsafeBytes { $0.load(as: UInt32.self) }
        return i32array
    }

    var eint_8: Int {
        let value = UInt8(littleEndian: [UInt8](self).first!)
        return Int(value)
    }

    var eInt16BigEndian: Int {
        var value: UInt16 = 0
        let data = NSData(bytes: [UInt8](self), length: count)
        data.getBytes(&value, length: data.count)
        value = UInt16(bigEndian: value)
        return Int(value)
    }

    var eInt16LittleEndian: Int {
        var value: UInt16 = 0
        let data = NSData(bytes: [UInt8](self), length: count)
        data.getBytes(&value, length: data.count)
        value = UInt16(littleEndian: value)
        return Int(value)
    }

    var eInt8Nature: Int {
        let byte = eUint8
        if byte >> 7 == 0x00 {
            return Int(byte)
        }
        if byte >> 7 == 0x01 {
            let k = 0xFF - byte + 1
            return -Int(k)
        }
        return Int(byte)
    }

    var eInt16Nature: Int {
        let byte = eUint16.byteSwapped
        if byte >> 15 == 0x00 {
            return Int(byte)
        }
        if byte >> 15 == 0x01 {
            let k = 0xFFFF - byte + 1
            return -Int(k)
        }
        return Int(byte)
    }

    var eInt32Nature: Int {
        let byte = eUint32
        if byte >> 31 == 0x00 {
            return Int(byte)
        }
        if byte >> 31 == 0x01 {
            let k = 0xFFFF_FFFF - byte + 1
            return -Int(k)
        }
        return Int(byte)
    }

    var eSwapSelf: Data {
        let list = [UInt8](self)
        var len = list.count - 1
        var newArr: [UInt8] = []
        while len >= 0 {
            newArr.append(list[len])
            len -= 1
        }
        return Data(bytes: newArr, count: list.count)
    }

//    func eHex()->String{
//        map {
//            String(format: "%02", $0)
//        }.joined(separator: " ")
//    }

    var eHex: String {
        map {
            String(format: "%02x", $0).uppercased()
        }.joined()
    }

    var eString: String {
        var subStr = ""
        for i: Int in 0 ..< count {
            let str = self[i]
            subStr = subStr + String(str)
        }
        return subStr
    }

    func eNS(num: UInt8) -> Data {
        let dt: [UInt8] = [num]
        return dt + self
    }

    func subRange(_ location: NSInteger, _ len: NSInteger) -> Data? {
        let data = self as NSData
        if (location + len) > data.length || len < 1 {
            // 越界了
//            ECPrint("stack overflow \(data.count),form:\(location),size:\(len)")
            return nil
        }
        let dt = data.subdata(with: NSRange(location: location, length: len))
        return dt
    }

    /// 数据分段
    /// - Parameters:
    ///   - dt: 数据
    ///   - len: 按长度
    /// - Returns: 分段数组
    func sections(_ len: Int) -> [Data] {
        let dt = self
        var arr: [Data] = []
        let current = dt.count / Int(len)
        for item in 0 ..< current {
            let data = dt.subRange(item * len, len) ?? Data()
            arr.append(data)
        }
        if current * Int(len) < dt.count {
            let data = dt.subRange(current * len, dt.count - current * len) ?? Data()
            arr.append(data)
        }
        return arr
    }

    func ebeginOf(_ index: NSInteger) -> Data? {
        let data = self as NSData
        if index > data.length {
            ECPrint("stack overflow \(data),beginAt:\(index),size:\(data.length - index)")
            return nil
        }
        let dt = data.subdata(with: NSRange(location: index, length: data.length - index))
        return dt
    }

    func eEndOf(_ index: NSInteger) -> Data? {
        let data = self as NSData
        if index > data.length {
            ECPrint("stack overflow \(data),endAt:\(index),size:\(index)")
            return nil
        }
        let dt = data.subdata(with: NSRange(location: 0, length: index))
        return dt
    }

    static func boolData(status: Bool) -> Data {
        let u8: [UInt8] = [status == true ? 0x01 : 0x00]
        return Data(bytes: u8, count: 1)
    }
}

public extension UInt8 {
    var eData: Data {
        Data(bytes: [self], count: 1)
    }
}

public extension UInt16 {
    var eData: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}

public extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }

    var date: Date {
        let s = self & 0x3F
        let m = (self >> 6) & 0x3F
        let h = (self >> 12) & 0x1F
        let day = (self >> 17) & 0x1F
        let mon = (self >> 22) & 0xF
        let year = ((self >> 26) & 0x3F) + 2010
        let str = String(Int(year)) + "-" + String(Int(mon)) + "-" + String(Int(day)) + " " + String(Int(h)) + ":" + String(Int(m)) + ":" + String(Int(s))
        let fm = DateFormatter()
        fm.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dte = fm.date(from: str) ?? Date()
//        ECPrintError("时间转换失败",self, "\(#function)", #line)
        return dte
    }
}

public extension Date {
    var data: Data {
        let fm = DateFormatter()
        fm.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let strArr = fm.string(from: self).components(separatedBy: "-")
        var u32: UInt32 = 0x00
        let year = UInt32(Int(strArr[0])! - 2010) << 26
        let month = UInt32(strArr[1])! << 22
        let day = UInt32(strArr[2])! << 17
        let HH = UInt32(strArr[3])! << 12
        let mm = UInt32(strArr[4])! << 6
        let ss = UInt32(strArr[5])!
        //
//        ECPrintInfo("\(year.data.eHex),\(month.data.eHex),\(day.data.eHex),\(HH.data.eHex),\(mm.data.eHex),\(ss.data.eHex)",self, "\(#function)", #line)
        u32 = u32 | year | month | day | HH | mm | ss
        return u32.data
    }
}

public extension Bool {
    var eData: Data {
        if self {
            let v: [UInt8] = [0x01]
            return Data(bytes: v, count: 1)
        } else {
            let v: [UInt8] = [0x00]
            return Data(bytes: v, count: 1)
        }
    }

    var rawValue: UInt8 {
        if self {
            return 0x01
        } else {
            return 0x00
        }
    }
}

open class DataTools: NSObject {
    // 1bytes转Int
    public class func ez_1BytesToInt(data: Data) -> Int {
        var value: UInt8 = 0
        let data = NSData(bytes: [UInt8](data), length: data.count)
        data.getBytes(&value, length: data.count)
        value = UInt8(littleEndian: value)
        return Int(value)
    }

    // 2bytes转Int
    public class func ec_2BytesToInt(data: Data) -> Int {
        var value: UInt16 = 0
        let data = NSData(bytes: [UInt8](data), length: data.count)
        data.getBytes(&value, length: data.count)
        value = UInt16(bigEndian: value)
        return Int(value)
    }

    // 4bytes转Int
    public class func ec_4BytesToInt(data: Data) -> Int {
        var value: UInt32 = 0
        let data = NSData(bytes: [UInt8](data), length: data.count)
        data.getBytes(&value, length: data.count)
        value = UInt32(bigEndian: value)
        return Int(value)
    }
}

public extension String {
    /// HexString to Data
    var beData: Data {
        let bytes = self.bytes(from: self)
        return Data(bytes: bytes, count: bytes.count)
    }

    // 将16进制字符串转化为 [UInt8]
    // 使用的时候直接初始化出 Data
    // Data(bytes: Array<UInt8>)
    func bytes(from hexStr: String) -> [UInt8] {
        assert(hexStr.count % 2 == 0, "输入字符串格式不对，8位代表一个字符")
        var bytes = [UInt8]()
        var sum = 0
        // 整形的 utf8 编码范围
        let intRange = 48 ... 57
        // 小写 a~f 的 utf8 的编码范围
        let lowercaseRange = 97 ... 102
        // 大写 A~F 的 utf8 的编码范围
        let uppercasedRange = 65 ... 70
        for (index, c) in hexStr.utf8CString.enumerated() {
            var intC = Int(c.byteSwapped)
            if intC == 0 {
                break
            } else if intRange.contains(intC) {
                intC -= 48
            } else if lowercaseRange.contains(intC) {
                intC -= 87
            } else if uppercasedRange.contains(intC) {
                intC -= 55
            } else {
                assertionFailure("输入字符串格式不对，每个字符都需要在0~9，a~f，A~F内")
            }
            sum = sum * 16 + intC
            // 每两个十六进制字母代表8位，即一个字节
            if index % 2 != 0 {
                bytes.append(UInt8(sum))
                sum = 0
            }
        }
        return bytes
    }
}

public extension NSObject {
    /// 打印所有属性的值
    @discardableResult func printfAllPropertys() -> String {
        let mirro = Mirror(reflecting: self)
        var pkgStr = ""
        for item in mirro.children {
            let name = item.label ?? "unKnow"
            var str = " \(name):\(item.value)"
            if let dt = item.value as? Data {
                str = " \(name):\(dt.eHex)"
            }
            pkgStr.append(str + "\n")
        }
        return pkgStr
    }
}

public extension Array where Element == UInt8 {
    var data: Data {
        Data(bytes: self, count: count)
    }
}
