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
    
    
}
