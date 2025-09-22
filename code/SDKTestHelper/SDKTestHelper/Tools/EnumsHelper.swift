//
//  EnumsHelper.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/18.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import Foundation

extension JL_CardType {
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

extension JL_FileHandleType {
    func beCardType() -> JL_CardType {
        switch self {
        case .SD_0:
            return .SD_0
        case .SD_1:
            return .SD_1
        case .FLASH:
            return .FLASH
        case .USB:
            return .USB
        case .lineIn:
            return .lineIn
        case .FLASH2:
            return .FLASH2
        case .FLASH3:
            return .FLASH3
        case .reservedArea:
            return .reservedArea
        @unknown default:
            return .FLASH
        }
    }
}
