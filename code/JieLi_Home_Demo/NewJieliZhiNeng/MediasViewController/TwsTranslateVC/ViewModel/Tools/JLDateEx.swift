//
//  JLDateEx.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/10.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

// MARK: - 日期工具扩展

extension Date {
    var getDateStr: String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMddHHmmss"
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        return dateFormat.string(from: self)
    }

    static func strBeDate(_ str: String) -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyyMMddHHmmss"
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        return dateFormat.date(from: str)
    }

    var beHHmm: String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "HH:mm"
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        return dateFormat.string(from: self)
    }

    var beYyyyMMdd: String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy/MM/dd"
        dateFormat.locale = Locale(identifier: "en_US_POSIX")
        return dateFormat.string(from: self)
    }

    /// 当月第一天
    var firstDayOfMonth: Date {
        let comp = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: comp)!
    }

    /// 当月天数
    var numberOfDaysInMonth: Int {
        Calendar.current.range(of: .day, in: .month, for: self)!.count
    }

    /// 星期偏移（周日=1，周一=2...）
    var weekdayOfFirst: Int {
        Calendar.current.component(.weekday, from: firstDayOfMonth)
    }

    /// 格式化输出
    func toString(_ format: String = "yyyy-MM") -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = format
        return df.string(from: self)
    }

    /// 加减月
    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self)!
    }

    func isSameDate(_ date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    ///判断时间是否超过当天
    func isAfterToday() -> Bool {
        self > Date()
    }

    /// 下一天
    func nextDay() -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }

    /// 前一天
    func previousDay() -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }

    //format 2022年 01 月 01 日 周一
    func toStringFull() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: LanguageCls.currentLocalization())
        df.dateFormat = R.Language.lan("yMMMMdEEEE")
        return df.string(from: self)
    }

    /// 是否与另一日期处于同一月份（忽略日）
    func isSameMonth(_ other: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: other, toGranularity: .month)
    }

    /// 是否晚于另一日期所在的月份（忽略日）
    func isAfterMonth(_ other: Date) -> Bool {
        self.firstDayOfMonth > other.firstDayOfMonth
    }
}
