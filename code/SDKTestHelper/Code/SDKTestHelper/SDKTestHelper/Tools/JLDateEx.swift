//
//  JLDateEx.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/10.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

extension Date {
    
    var getDateStr:String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMddHHmmss"
        return dateFormat.string(from: self)
    }
    
    static func getWeekDay(index: Int) -> String {
        switch index {
        case 0:
            return R.localStr.mon()
        case 1:
            return R.localStr.tue()
        case 2:
            return R.localStr.web()
        case 3:
            return R.localStr.thu()
        case 4:
            return R.localStr.fir()
        case 5:
            return R.localStr.sat()
        case 6:
            return R.localStr.sun()
        default:
            return ""
        }
    }
    
}
