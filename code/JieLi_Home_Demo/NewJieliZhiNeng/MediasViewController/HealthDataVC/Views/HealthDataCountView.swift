//
//  HealthDataSunView.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/15.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit
import SwiftyAttributes

class HealthDataCountView: BasicView {
    private let titleLab1 = UILabel()
    private let titleLab2 = UILabel()
    private let valueLab1 = UILabel()
    private let valueLab2 = UILabel()
    
    override func initUI() {
        super.initUI()
        self.layer.cornerRadius = 8
        self.backgroundColor = .white
        self.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.eHex("#00124A",alpha: 0.09).cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 0.1
        self.layer.shadowRadius = 8
        
        titleLab1.text = "心率范围"
        titleLab1.textColor = .eHex("#919191")
        titleLab1.font = R.Font.regular(13)
        titleLab1.textAlignment = .center
        
        titleLab2.text = "本日平均"
        titleLab2.textColor = .eHex("#919191")
        titleLab2.font = R.Font.regular(13)
        titleLab2.textAlignment = .center
        
        valueLab1.text = "80-100"
        valueLab2.text = "90"
        valueLab1.textColor = .eHex("#242424")
        valueLab2.textColor = .eHex("#242424")
        valueLab1.font = R.Font.medium(20)
        valueLab2.font = R.Font.medium(20)
        valueLab1.textAlignment = .center
        valueLab2.textAlignment = .center
        
        addSubview(titleLab1)
        addSubview(titleLab2)
        addSubview(valueLab1)
        addSubview(valueLab2)
        
        titleLab1.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview().inset(8)
            make.width.equalTo(titleLab2)
            make.right.equalTo(titleLab2.snp.left)
        }
        titleLab2.snp.makeConstraints { make in
            make.left.equalTo(titleLab1.snp.right)
            make.top.equalTo(titleLab1)
            make.width.equalTo(titleLab1)
            make.right.equalToSuperview()
        }
        valueLab1.snp.makeConstraints { make in
            make.left.equalTo(titleLab1)
            make.top.equalTo(titleLab1.snp.bottom).inset(4)
            make.width.equalTo(valueLab2)
            make.right.equalTo(valueLab2.snp.left)
            make.bottom.equalToSuperview().inset(8)
        }
        
        valueLab2.snp.makeConstraints { make in
            make.left.equalTo(valueLab1.snp.right)
            make.top.equalTo(valueLab1)
            make.width.equalTo(valueLab1)
            make.right.equalToSuperview()
            make.bottom.equalTo(valueLab1)
        }
        
    }
    /// 增加不同类型的初始化内容
    func initWithType(type: HealthMetricType) {
        switch type {
        case .heartRate:
            titleLab1.text = R.Language.lan("Heart rate range")
            titleLab2.text = R.Language.lan("Daily average")
            valueLab1.text = "-"
            valueLab2.text = "-"
        case .spo2:
            titleLab1.text = R.Language.lan("Min-Max")
            titleLab2.text = R.Language.lan("Daily average")
            valueLab1.text = "-"
            valueLab2.text = "-"
        case .steps:
            titleLab2.isHidden = true
            valueLab2.isHidden = true
            titleLab2.snp.removeConstraints()
            valueLab2.snp.removeConstraints()
            
            titleLab1.snp.remakeConstraints { make in
                make.top.equalToSuperview().inset(8)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
            }
            valueLab1.snp.remakeConstraints { make in
                make.top.equalTo(titleLab1.snp.bottom).inset(4)
                make.left.equalTo(titleLab1)
                make.right.equalTo(titleLab1)
                make.bottom.equalToSuperview().inset(8)
            }
            titleLab1.text = R.Language.lan("Total steps")
            valueLab1.text = "-"
        }
    }
    
    func setHeartRate(min: Int, max: Int, avg: Int) {
        titleLab1.text = R.Language.lan("Heart rate range")
        titleLab2.text = R.Language.lan("Daily average")
        let value1 = String(min) + "-" + String(max)
        valueLab1.attributedText = value1.withFont(R.Font.medium(20)).withTextColor(.eHex("#242424"))
        + " ".withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
        + R.Language.lan("BPM").withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
        valueLab2.attributedText = String(avg).withFont(R.Font.medium(20)).withTextColor(.eHex("#242424"))
        + " ".withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
        + R.Language.lan("BPM").withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
    }
    
    func setSpO2(min: Int, max: Int, avg: Int) {
        titleLab1.text = R.Language.lan("Min-Max")
        titleLab2.text = R.Language.lan("Daily average")
        let value1 = String(min) + "-" + String(max)
        valueLab1.attributedText = value1.withFont(R.Font.medium(20)).withTextColor(.eHex("#242424"))
        + " ".withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
        + R.Language.lan("%").withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
        valueLab2.attributedText = String(avg).withFont(R.Font.medium(20)).withTextColor(.eHex("#242424"))
        + " ".withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
        + R.Language.lan("%").withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
    }
    
    
    func setStep(all: Int) {
        titleLab2.isHidden = true
        valueLab2.isHidden = true
        titleLab2.snp.removeConstraints()
        valueLab2.snp.removeConstraints()
        
        titleLab1.snp.remakeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        valueLab1.snp.remakeConstraints { make in
            make.top.equalTo(titleLab1.snp.bottom).inset(4)
            make.left.equalTo(titleLab1)
            make.right.equalTo(titleLab1)
            make.bottom.equalToSuperview().inset(8)
        }
        
        titleLab1.text = R.Language.lan("Total steps")
        valueLab1.attributedText = String(all).withFont(R.Font.medium(20)).withTextColor(.eHex("#242424"))
        + " ".withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
        + R.Language.lan("Step").withFont(R.Font.regular(10)).withTextColor(.eHex("#919191"))
    }
   

}
