//
//  SDKTestCaseSystemInfo.swift
//  SDKTestCase
//
//  Created by EzioChan on 2026/5/11.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import XCTest
import JL_BLEKit

final class SDKTestCaseSystemInfo: XCTestCase {
 
    func testTargetInfo() throws {
        let dataStr = "0200200501360610010902fff13d52f3b68e0107040000000100000305000102060a03071b3404080001010409000000050a68016320110b68453979667365583655644b37724668150c6a6c5f73646b5f61633639375f7075626c697368050d0110021c081100fff13d52f3b602120003130600051500000000"
        let data = JL_Tools.hex(toData: dataStr)
        let deviceModel = JLModel_Device()
        deviceModel.deviceInfoData(data as Data)
    }
    
    func testSystemInfo() throws {
        let dataStr = "ff0200360201060c040000000000000000000000020600630c0a001f003e007d00fa01f403e807d00fa01f403e80000000000000000000000001fe000204fefe0000040402030100fefcfcfe0001020300080804000000000202040000000404040002030405fe0000020200000004040600000000000000000000020f00"
        let data = JL_Tools.hex(toData: dataStr)
        let deviceModel = JLModel_Device()
        deviceModel.deviceModeInfoData(data as Data)
    }
    
}
