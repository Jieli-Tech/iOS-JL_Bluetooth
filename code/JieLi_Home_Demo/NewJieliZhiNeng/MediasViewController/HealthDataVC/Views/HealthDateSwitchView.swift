//
//  HealthDateSwitchView.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/14.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit
import SwiftyAttributes

class HealthDateSwitchView: BasicView {

    private let preBtn = UIButton()
    private let nextBtn = UIButton()
    private let dateLab = UILabel()
    private let iconImgv = UIImageView()
    private let valueLab = UILabel()
    private let iconDateImgv = UIImageView()
    private let dateDetailLab = UILabel()
    private let settingBtn = UIButton()
    private let startBtn = UIButton()
    
    // MARK: - 时间范围匹配支持
    /// 当前展示的日期（用于构造当天的时间段范围）
    private var currentDate: Date = Date()
    /// 当天的时间范围集合（默认按小时切分 24 段）
    private var timeRanges: [DateInterval] = []
    /// 选中/当前展示的时间范围
    private var selectedRange: DateInterval?
    /// 显示 "HH:mm" 的时间格式化器
    private lazy var timeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "zh_Hans_CN")
        df.dateFormat = "HH:mm"
        return df
    }()
    
    var preBtnClick: (()->Void)?
    var nextBtnClick: (()->Void)?
    var settingBtnClick: (()->Void)?
    var startBtnClick: (()->Void)?
    
    override func initUI() {
        super.initUI()
        preBtn.setImage(UIImage(named: "icon_left_nor"), for: .normal)
        nextBtn.setImage(UIImage(named: "icon_right_dis"), for: .normal)
        dateLab.font = R.Font.regular(14)
        dateLab.text = "2022年 01 月 01 日 周一"
        dateLab.textAlignment = .center
        dateLab.textColor = .eHex("#242424")
        
        iconImgv.contentMode = .scaleAspectFit
        iconImgv.image = UIImage(named: "icon_heart")
        valueLab.font = R.Font.medium(18)
        valueLab.attributedText = "0".withFont(Font.systemFont(ofSize: 18, weight: .medium)).withTextColor(.eHex("#242424"))
        + " ".withFont(Font.systemFont(ofSize: 18, weight: .regular))
        + R.Language.lan("BPM").withFont(Font.systemFont(ofSize: 12, weight: .regular)).withTextColor(.eHex("#919191"))
        
        
        iconDateImgv.image = UIImage(named: "icon_time")
        dateDetailLab.font = R.Font.regular(14)
        dateDetailLab.text = "10:00 - 11:00"
        dateDetailLab.textColor = .eHex("#919191")
        
        // 左图右字样式
        startBtn.setImage(UIImage(named: "health_icon_search"), for: .normal)
        startBtn.setTitle(R.Language.lan("Start monitoring"), for: .normal)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.semanticContentAttribute = .forceLeftToRight
        startBtn.contentHorizontalAlignment = .center
        startBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        startBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        startBtn.backgroundColor = .eHex("#7657EC")
        startBtn.layer.cornerRadius = 16
        startBtn.layer.masksToBounds = true
        startBtn.titleLabel?.font = R.Font.medium(13)
        
        settingBtn.setImage(UIImage(named: "step_icon_settle"), for: .normal)
        settingBtn.contentMode = .scaleAspectFit
        
        self.addSubview(preBtn)
        self.addSubview(nextBtn)
        self.addSubview(dateLab)
        self.addSubview(iconImgv)
        self.addSubview(valueLab)
        self.addSubview(iconDateImgv)
        self.addSubview(dateDetailLab)
        self.addSubview(settingBtn)
        self.addSubview(startBtn)
        
        stepLayout()
    }
    
    private func stepLayout() {
        preBtn.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.left.top.equalToSuperview().inset(18)
        }
        dateLab.snp.makeConstraints { make in
            make.left.equalTo(preBtn.snp.right).offset(6)
            make.centerY.equalTo(preBtn)
            make.right.equalTo(nextBtn.snp.left).offset(-6)
        }
        nextBtn.snp.makeConstraints { make in
            make.size.equalTo(preBtn)
            make.top.equalTo(preBtn)
            make.right.equalToSuperview().inset(18)
        }
        
        iconImgv.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(18)
            make.top.equalTo(preBtn.snp.bottom).offset(16)
            make.size.equalTo(20)
        }
        valueLab.snp.makeConstraints { make in
            make.left.equalTo(iconImgv.snp.right).offset(4)
            make.centerY.equalTo(iconImgv)
        }
        
        iconDateImgv.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(18)
            make.top.equalTo(iconImgv.snp.bottom).offset(6)
            make.size.equalTo(16)
        }
        dateDetailLab.snp.makeConstraints { make in
            make.left.equalTo(iconDateImgv.snp.right).offset(4)
            make.centerY.equalTo(iconDateImgv)
        }
        
        settingBtn.snp.makeConstraints { make in
            make.right.equalTo(startBtn.snp.left).offset(-12)
            make.centerY.equalTo(startBtn)
            make.size.equalTo(32)
        }
        
        startBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(18)
            make.top.equalTo(iconImgv.snp.top).offset(6)
            make.height.equalTo(32)
            make.width.greaterThanOrEqualTo(100)
        }
    }
    
    override func initData() {
        super.initData()
        // 初始化当天的默认时间范围（每小时一段）
        timeRanges = buildDefaultHourlyRanges(for: currentDate)
        selectedRange = timeRanges.first
        preBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            setDisplayDate(currentDate.previousDay())
            dateLab.text = currentDate.toStringFull()
            preBtnClick?()
            nextBtn.setImage(UIImage(named: "icon_right_nol"), for: .normal)
            nextBtn.isUserInteractionEnabled = true
        }).disposed(by: disposeBag)
        
        nextBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            let nextDay = currentDate.nextDay()
            
            if !nextDay.isAfterToday() {
                setDisplayDate(nextDay)
                dateLab.text = currentDate.toStringFull()
                nextBtnClick?()
                if nextDay.isSameDate(Date()) {
                    nextBtn.setImage(UIImage(named: "icon_right_dis"), for: .normal)
                    nextBtn.isUserInteractionEnabled = false
                }
            }
        }).disposed(by: disposeBag)
        
        startBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.startBtnClick?()
        }).disposed(by: disposeBag)
        
        settingBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.settingBtnClick?()
        }).disposed(by: disposeBag)
    }
    
    func setHeartRate(){
        dateDetailLab.text = "00:00 - 00:00"
        dateLab.text = currentDate.toStringFull()
        startBtn.setImage(UIImage(named: "health_icon_start"), for: .normal)
        startBtn.setTitle(R.Language.lan("Start monitoring"), for: .normal)
        settingBtn.isHidden = true
        setHeartRateValue(value: "0", time: Date())
    }
    
    func setHeartRateValue(value: String, time: Date) {
        valueLab.attributedText = value.withFont(Font.systemFont(ofSize: 18, weight: .medium)).withTextColor(.eHex("#242424"))
        + " ".withFont(Font.systemFont(ofSize: 18, weight: .regular))
        + R.Language.lan("BPM").withFont(Font.systemFont(ofSize: 12, weight: .regular)).withTextColor(.eHex("#919191"))
        updateRangeLabel(for: time)
    }
   
    // MARK: - 公开方法（可选）
    /// 设置当前展示的日期，同时重建当天的时间范围集合
    func setDisplayDate(_ date: Date) {
        currentDate = date
        timeRanges = buildDefaultHourlyRanges(for: date)
        selectedRange = timeRanges.first
    }

    /// 外部直接设置一个自定义的时间范围并刷新显示
    func setTimeRange(start: Date, end: Date) {
        guard start < end else { return }
        selectedRange = DateInterval(start: start, end: end)
        dateDetailLab.text = formatRange(selectedRange!)
    }
    
    /// 批量设置可用的时间范围集合（例如 30 分钟一段、或来源于数据库的监测区间）
    func setAvailableRanges(_ ranges: [DateInterval]) {
        timeRanges = ranges
        selectedRange = ranges.first
        if let first = ranges.first {
            dateDetailLab.text = formatRange(first)
        }
    }
    
    /// 判断传入的精确时间值是否落在当前选中的时间范围内
    func isTimeWithinSelectedRange(_ time: Date) -> Bool {
        if let r = selectedRange { return r.start <= time && time < r.end }
        // 若当前尚未选择范围，则尝试按默认范围匹配
        if let matched = findRangeContaining(time) {
            selectedRange = matched
            return true
        }
        return false
    }

    /// 判断传入的精确时间值是否落在标签显示的时间范围内（解析 "HH:mm - HH:mm"）
    func isTimeWithinLabelRange(_ time: Date, baseDate: Date? = nil) -> Bool {
        let label = dateDetailLab.text ?? ""
        guard let interval = parseRangeLabel(label, baseDate: baseDate ?? currentDate) else { return false }
        return interval.start <= time && time < interval.end
    }

    // MARK: - 范围匹配核心逻辑
    /// 构建某天的默认 24 个整点小时段 [00:00-01:00, 01:00-02:00, ...]
    private func buildDefaultHourlyRanges(for date: Date) -> [DateInterval] {
        let cal = Calendar.current
        let startOfDay = cal.startOfDay(for: date)
        var ranges: [DateInterval] = []
        for hour in 0..<24 {
            let start = cal.date(byAdding: .hour, value: hour, to: startOfDay) ?? startOfDay
            let end = cal.date(byAdding: .hour, value: hour + 1, to: startOfDay) ?? start
            ranges.append(DateInterval(start: start, end: end))
        }
        return ranges
    }

    /// 查找包含指定时间点的范围（半开区间 [start, end)）
    private func findRangeContaining(_ time: Date) -> DateInterval? {
        let cal = Calendar.current
        if let anyRange = timeRanges.first, !cal.isDate(anyRange.start, inSameDayAs: time) {
            timeRanges = buildDefaultHourlyRanges(for: time)
        } else if timeRanges.isEmpty {
            timeRanges = buildDefaultHourlyRanges(for: time)
        }
        return timeRanges.first { $0.start <= time && time < $0.end }
    }

    /// 更新时间范围标签
    private func updateRangeLabel(for time: Date) {
        if let matched = findRangeContaining(time) {
            selectedRange = matched
            dateDetailLab.text = formatRange(matched)
        } else {
            // 未匹配到范围，显示单点时间（降级显示）
            let t = timeFormatter.string(from: time)
            dateDetailLab.text = "\(t) - \(t)"
        }
    }

    /// 将范围格式化为 "HH:mm - HH:mm" 文本
    private func formatRange(_ interval: DateInterval) -> String {
        let startStr = timeFormatter.string(from: interval.start)
        let endStr = timeFormatter.string(from: interval.end)
        return "\(startStr) - \(endStr)"
    }

    /// 解析标签上的范围字符串（例如 "10:00 - 11:00"）为 DateInterval（基于 baseDate 的年月日）
    private func parseRangeLabel(_ text: String, baseDate: Date) -> DateInterval? {
        let parts = text.components(separatedBy: "-").map { $0.trimmingCharacters(in: .whitespaces) }
        guard parts.count == 2 else { return nil }
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day], from: baseDate)
        // 解析 HH:mm
        func parseTime(_ hhmm: String) -> Date? {
            let seg = hhmm.components(separatedBy: ":")
            guard seg.count == 2, let h = Int(seg[0]), let m = Int(seg[1]) else { return nil }
            comps.hour = h
            comps.minute = m
            return cal.date(from: comps)
        }
        guard let start = parseTime(parts[0]), let end = parseTime(parts[1]), start < end else { return nil }
        return DateInterval(start: start, end: end)
    }


}
