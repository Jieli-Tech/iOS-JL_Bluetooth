//
//  SettingDefault.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/6/12.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class SettingDefault: NSObject {
    
    static func getWeatherPush() -> Bool {
       UserDefaults.standard.bool(forKey: "WeatherPush")
    }
    static func setWeatherPush(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: "WeatherPush")
        UserDefaults.standard.synchronize()
    }
}
