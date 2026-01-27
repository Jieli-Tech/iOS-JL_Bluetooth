//
//  BluetoothDeviceParse.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import CoreBluetooth

/// 蓝牙设备解析工具类
/// 负责根据设备信息（ManufacturerData、Name）解析出对应的图标或描述
class BluetoothDeviceParse: NSObject {
    
    static let shared = BluetoothDeviceParse()
    
    private override init() {}
    
    /// 根据扫描到的设备信息解析出对应的图标
    /// - Parameter device: 发现的设备模型
    /// - Returns: 设备图标 (UIImage)
    func parseIcon(for device: DiscoveredDevice) -> UIImage? {
        let name = (device.name ?? "").lowercased()
        
        // 1. 解析 Manufacturer ID (Little Endian)
        var manufId: Int = -1
        if let data = device.manufacturerData, data.count >= 2 {
            manufId = Int(data[0]) | (Int(data[1]) << 8)
        }
        
        // 2. 优先匹配特定厂商 (Manufacturer ID 或 强名称匹配)
        
        // Apple (0x004C)
        if manufId == 0x004C {
            if #available(iOS 13.0, *) {
                return UIImage(systemName: "applelogo")
            } else {
                return ImageCreater.create(from: "")
            }
        }
        
        // Jieli (0x05D6)
        if manufId == 0x05D6 || name.contains("jieli") || name.contains("jl") {
            return parseJieliDevice(name: name)
        }
        
        // 3. 匹配常见品牌
        if let brandIcon = parseBrand(manufId: manufId, name: name) {
            return brandIcon
        }
        
        // 4. 匹配通用设备类型
        if let typeIcon = parseGenericType(name: name) {
            return typeIcon
        }
        
        // 5. 有名称的设备：生成首字母图标
        if let name = device.name, !name.isEmpty {
            let prefix = String(name.prefix(1)).uppercased()
            return ImageCreater.create(from: prefix)
        }
        
        return ImageCreater.create(from:"N/A")
    }
    
    /// 根据扫描到的设备信息解析出厂商名称
    /// - Parameter device: 发现的设备模型
    /// - Returns: 厂商名称 (String)
    func parseCompanyName(for device: DiscoveredDevice) -> String? {
        // 1. 解析 Manufacturer ID (Little Endian)
        var manufId: Int = -1
        if let data = device.manufacturerData, data.count >= 2 {
            manufId = Int(data[0]) | (Int(data[1]) << 8)
        }
        
        // 2. 匹配常见厂商 ID
        switch manufId {
        case 0x004C: return "Apple Inc."
        case 0x05D6: return "Zhuhai Jieli Technology Co.,Ltd"
        case 0x038F, 0x2D01: return "Xiaomi Inc."
        case 0x027D: return "Huawei Technologies Co., Ltd."
        case 0x0075: return "Samsung Electronics Co., Ltd."
        case 0x0054: return "Sony Corporation"
        case 0x0006: return "Microsoft Corporation"
        case 0x00E0: return "Google"
        default: break
        }
        
        // 3. 尝试从名称猜测 (如果 ID 未匹配)
        let name = (device.name ?? "").lowercased()
        if name.contains("vivo") { return "Vivo Mobile Communication" }
        if name.contains("oppo") { return "OPPO Mobile Telecommunications" }
        if name.contains("bluetrum") || name.contains("ab53") { return "Bluetrum Technology" }
        
        return nil
    }
    
    // MARK: - Private Parsing Logic
    
    /// 解析杰理设备的具体类型
    private func parseJieliDevice(name: String) -> UIImage? {
        ImageCreater.create(from: "JL")
    }
    
    /// 解析其他品牌
    private func parseBrand(manufId: Int, name: String) -> UIImage? {
        // Xiaomi / Redmi (0x038F, 0x2D01)
        if manufId == 0x038F || manufId == 0x2D01 || name.contains("xiaomi") || name.contains("mi ") || name.contains("redmi") {
            return ImageCreater.create(from: "Mi")
        }
        
        // Huawei / Honor (0x027D)
        if manufId == 0x027D || name.contains("huawei") || name.contains("honor") {
            return ImageCreater.create(from: "HW")
        }
        
        // Samsung (0x0075)
        if manufId == 0x0075 || name.contains("samsung") || name.contains("galaxy") {
            return ImageCreater.create(from: "Sam")
        }
        
        // Sony (0x0054)
        if manufId == 0x0054 || name.contains("sony") {
            return ImageCreater.create(from: "Sony")
        }
        
        // Vivo
        if name.contains("vivo") {
            return ImageCreater.create(from: "Vi")
        }
        
        // Oppo
        if name.contains("oppo") {
            return ImageCreater.create(from: "Op")
        }
        
        // Bluetrum (蓝讯) - 通常没有固定厂商ID暴露，主要靠名字
        if name.contains("bluetrum") || name.contains("ab53") {
            return ImageCreater.create(from: "Blue")
        }
        
        // Microsoft (0x0006)
        if manufId == 0x0006 || name.contains("microsoft") {
            return ImageCreater.create(from: "MS")
        }
        
        // Google (0x00E0)
        if manufId == 0x00E0 || name.contains("google") {
            return ImageCreater.create(from: "G")
        }
        
        return nil
    }
    
    /// 解析通用设备类型
    private func parseGenericType(name: String) -> UIImage? {
        if name.contains("beacon") || name.contains("ibeacon") {
            return ImageCreater.create(from: "iB")
        }
        if name.contains("tv") || name.contains("television") {
            return ImageCreater.create(from: "TV")
        }
        if name.contains("watch") || name.contains("band") {
            return ImageCreater.create(from: "W")
        }
        if name.contains("print") {
            return ImageCreater.create(from: "P")
        }
        return nil
    }
}
