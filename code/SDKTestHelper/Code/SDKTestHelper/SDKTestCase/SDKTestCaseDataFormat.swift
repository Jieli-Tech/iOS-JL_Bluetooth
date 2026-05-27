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

}
