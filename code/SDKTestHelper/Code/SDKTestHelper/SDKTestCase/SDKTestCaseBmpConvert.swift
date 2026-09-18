//
//  SDKTestCaseBmpConvert.swift
//  SDKTestCase
//
//  Created by EzioChan on 2026/7/2.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import Foundation
import XCTest
import JLBmpConvertKit

final class SDKTestCaseBmpConvert: XCTestCase {
    
    func testConvert() throws {
        guard let path = Bundle(for: SDKTestCaseBmpConvert.self)
            .path(forResource: "rounded-200x240-BGRA8888", ofType: "bin") else {
            XCTFail("测试资源不存在")
            return
        }
        let op = JLBmpConvertOption()
        op.convertType = .type707N_ARGB_NO_PACK
        let result = JLBmpConvert.convert(with: op, width: 200, height: 240, bmapPath: path)
        XCTAssertGreaterThan(result.result, 0, "转换失败")
        guard let data = result.outFileData else {
            XCTFail("转换结果为空")
            return
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("rounded-200x240-BGRA8888-converted.bin")
        try data.write(to: url)
        print("已保存到: \(url.path)")
        print("数据大小: \(data.count)")
    }
    
}


