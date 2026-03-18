//
//  AlarmCell.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/22.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class AlarmCell: UITableViewCell {
    let titleLab = UILabel()
    let detailLab = UILabel()
    let switchView = UISwitch()
    var alarmModel: JLModel_RTC?
    var isOnBlock: (() -> Void)?
    private let disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white
        layer.cornerRadius = 10
        layer.masksToBounds = true

        contentView.addSubview(titleLab)
        contentView.addSubview(detailLab)
        contentView.addSubview(switchView)

        titleLab.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLab.adjustsFontSizeToFitWidth = true
        titleLab.textAlignment = .left
        titleLab.textColor = .darkText

        detailLab.font = UIFont.systemFont(ofSize: 14, weight: .heavy)
        detailLab.adjustsFontSizeToFitWidth = true
        detailLab.textColor = .gray

        switchView.onTintColor = UIColor.random()
        switchView.isOn = false

        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(6)
            make.top.equalToSuperview().inset(4)
            make.height.equalTo(30)
            make.right.equalTo(switchView.snp.left).offset(-12)
        }
        detailLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(6)
            make.right.equalTo(switchView.snp.left).offset(-12)
            make.top.equalTo(titleLab.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(4)
        }
        switchView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(6)
            make.centerY.equalToSuperview()
        }
        initData()
    }

    func bind(_ item: JLModel_RTC) {
        titleLab.text = item.rtcName + " " + String(format: "%.2d:%.2d", item.rtcHour, item.rtcMin)
        detailLab.text = rtcModeToString(mode: item.rtcMode)
        switchView.isOn = item.rtcEnable
        alarmModel = item
    }

    private func initData() {
        switchView.rx.controlEvent(.valueChanged).subscribe { [weak self] _ in
            guard let `self` = self else { return }
            self.alarmModel?.rtcEnable = self.switchView.isOn
            self.isOnBlock?()
        }.disposed(by: disposeBag)
    }

    private func rtcModeToString(mode: UInt8) -> String {
        var tmpStr = ""
        if mode == 0x00 {
            return R.localStr.once()
        }
        if mode & 0x01 == 0x01 {
            return R.localStr.everyday()
        }
        if (mode >> 1) & 0x01 == 0x01 {
            tmpStr += R.localStr.mon()
        }
        if (mode >> 2) & 0x01 == 0x01 {
            tmpStr += R.localStr.tue()
        }
        if (mode >> 3) & 0x01 == 0x01 {
            tmpStr += R.localStr.web()
        }
        if (mode >> 4) & 0x01 == 0x01 {
            tmpStr += R.localStr.thu()
        }
        if (mode >> 5) & 0x01 == 0x01 {
            tmpStr += R.localStr.fir()
        }
        if (mode >> 6) & 0x01 == 0x01 {
            tmpStr += R.localStr.sat()
        }
        if (mode >> 7) & 0x01 == 0x01 {
            tmpStr += R.localStr.sun()
        }
        return tmpStr
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
