//
//  SDKTestCaseDataFormat.swift
//  SDKTestCase
//
//  Created by EzioChan on 2026/5/12.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import XCTest
import JL_AdvParse
import JL_BLEKit

final class SDKTestCaseDataFormat: XCTestCase {
    
    func testDataTest() throws {
        let advData = "d605c0800de022313309d7a38ef646000018a40002010a1009484f434f20455131        303120414e4300"
        let data = JL_Tools.hex(toData: advData)
        let dict: [String: Any] = ["kCBAdvDataManufacturerData":data, "kCBAdvDataLocalName":"dataFormat"]
        let dictInfo = JLAdvParse.bluetoothAdvParse(nil, advData: dict) as! [String : Any] 
        print(dictInfo)
        
        let info = JL_BLEAction.bluetoothKey_1(Data(), filter: dict)
        print(info)
    }
    
    func testD9Params() throws {
        let payload = "01001202010002020102030d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        
        // 使用 JL_Tools 将 hex 字符串转换为 Data
        let payloadData = JL_Tools.hex(toData: payload) as Data
        
        // 使用 JLDeviceConfigBasic 解析基础配置
        let config = JLDeviceConfigBasic(payloadData)
        
        // 验证基础属性
        print("deviceType: \(config.deviceType)")
        print("version: \(config.version)")
        print("basicData 长度: \(config.basicData.count)")
        
        // 断言验证
        XCTAssertTrue(config.deviceType >= 0 && config.deviceType <= 3, "deviceType 应在 0-3 范围内")
        XCTAssertEqual(config.version, 0, "version 应为 0")
        XCTAssertEqual(config.basicData, payloadData, "basicData 应与原始 payload 一致")
        
        // 根据 deviceType 进一步解析具体配置
        // 参考 JLDeviceConfig.m 中的解析逻辑
        switch config.deviceType {
        case 0:
            // 手表类型
            print("设备类型: 手表 (Watch)")
            let watchConfig = JLDeviceConfigModel(config.basicData)
            print("手表配置解析完成")
            XCTAssertNotNil(watchConfig.basicFunc, "应包含基础功能配置")
            
        case 1:
            // TWS 类型
            print("设备类型: TWS耳机")
            let twsConfig = JLDeviceConfigTws(config.basicData)
            print("TWS 配置解析完成")
            XCTAssertEqual(twsConfig.deviceType, 1, "deviceType 应为 1")
            
        case 2:
            // SoundBox 类型
            print("设备类型: SoundBox")
            let soundBoxConfig = JLDeviceConfigSoundBox(config.basicData)
            print("SoundBox 配置解析完成")
            XCTAssertEqual(soundBoxConfig.deviceType, 2, "deviceType 应为 2")
            
        case 3:
            // Dongle 类型
            print("设备类型: Dongle")
            let dongleConfig = JLDeviceConfigDongle(config.basicData)
            print("Dongle 配置解析完成")
            XCTAssertEqual(dongleConfig.deviceType, 3, "deviceType 应为 3")
            
        default:
            XCTFail("未知的 deviceType: \(config.deviceType)")
        }
    }

}
