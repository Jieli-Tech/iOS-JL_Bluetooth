//
//  AlarmDateSelectModel.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/23.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class AlarmDateSelectModel: NSObject {
    var dateStr = ""
    var isSelected = false
    class func makeWeekDateModel(_ modelValue: UInt8) -> [AlarmDateSelectModel] {
        var modelList: [AlarmDateSelectModel] = []
        if modelValue == 0 {
            for i in 0 ..< 7 {
                let model = AlarmDateSelectModel()
                model.isSelected = false
                model.dateStr = Date.getWeekDay(index: i)
                modelList.append(model)
            }
            return modelList
        }

        if modelValue == 1 {
            for i in 0 ..< 7 {
                let model = AlarmDateSelectModel()
                model.isSelected = true
                model.dateStr = Date.getWeekDay(index: i)
                modelList.append(model)
            }
            return modelList
        }

        for i in 0 ..< 7 {
            let model = AlarmDateSelectModel()
            if modelValue >> (i + 1) & 1 == 1 {
                model.isSelected = true
            } else {
                model.isSelected = false
            }
            model.dateStr = Date.getWeekDay(index: i)
            modelList.append(model)
        }
        return modelList
    }
}

