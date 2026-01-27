//
//  HealthTestAlertView.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/16.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit


class HealthTestAlertView: BasicView {

    private let bgView = UIView()
    private let centerView = UIView()
    private let cancelBtn = UIButton()
    private let animationView = UIImageView()
    private let titleLab = UILabel()
    private let tipsLab = UILabel()
    private let progressView = UIProgressView()
    private let progressLab = UILabel()
    private let confirmBtn = UIButton()
    private let failedBtn = UIButton()
    private let retryBtn = UIButton()
    
    override func initUI() {
        super.initUI()
        addSubview(bgView)
        bgView.addSubview(centerView)
        centerView.addSubview(cancelBtn)
        centerView.addSubview(animationView)
        centerView.addSubview(titleLab)
        centerView.addSubview(tipsLab)
        centerView.addSubview(progressView)
        centerView.addSubview(progressLab)
        centerView.addSubview(confirmBtn)
        centerView.addSubview(failedBtn)
        centerView.addSubview(retryBtn)
        
        bgView.backgroundColor = .eHex("#000000", alpha: 0.3)
        
        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 18
        centerView.layer.masksToBounds = true
        
        cancelBtn.setImage(UIImage(named: "health_icon_close"), for: .normal)
        
        
        animationView.contentMode = .scaleAspectFit
        let url = Bundle.main.url(forResource: "heart", withExtension: "gif")
        animationView.sd_setImage(with: url)
        
        titleLab.textColor = .eHex("#000000", alpha: 0.9)
        titleLab.font = R.Font.medium(16)
        titleLab.text = R.Language.lan("Testing in progress")
        titleLab.textAlignment = .center
        
        tipsLab.textColor = .eHex("#919191")
        tipsLab.font = R.Font.regular(13)
        tipsLab.text = R.Language.lan("Please remain still")
        tipsLab.textAlignment = .center
        
        progressView.progress = 0
        progressView.progressTintColor = .eHex("#7657EC")
        progressView.trackTintColor = .eHex("#D8D8D8")
        
        progressLab.textColor = .eHex("#242424")
        progressLab.font = R.Font.medium(18)
        progressLab.text = "0%"
        progressLab.textAlignment = .center
        
        failedBtn.setTitle(R.Language.lan("Cancel"), for: .normal)
        failedBtn.backgroundColor = .eHex("#D8D8D8")
        failedBtn.setTitleColor(.eHex("#000000", alpha: 0.8), for: .normal)
        failedBtn.titleLabel?.font = R.Font.medium(15)
        failedBtn.layer.cornerRadius = 20
        failedBtn.layer.masksToBounds = true
        
        retryBtn.setTitle(R.Language.lan("Retry"), for: .normal)
        retryBtn.backgroundColor = .eHex("#7657EC")
        retryBtn.setTitleColor(.white, for: .normal)
        retryBtn.titleLabel?.font = R.Font.medium(15)
        retryBtn.layer.cornerRadius = 20
        retryBtn.layer.masksToBounds = true
        
        confirmBtn.setTitle(R.Language.lan("confirm"), for: .normal)
        confirmBtn.backgroundColor = .eHex("#7657EC")
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.font = R.Font.medium(15)
        confirmBtn.layer.cornerRadius = 20
        confirmBtn.layer.masksToBounds = true
        
        stepLayout()
    }
    
    private func stepLayout() {
        
        failedBtn.isHidden = true
        retryBtn.isHidden = true
        confirmBtn.isHidden = true
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(24)
            make.height.greaterThanOrEqualTo(330)
        }
        cancelBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(11)
            make.right.equalToSuperview().offset(-11)
            make.width.height.equalTo(26)
        }
        
        animationView.snp.makeConstraints { make in
            make.top.equalTo(cancelBtn.snp.bottom)
            make.centerX.equalToSuperview()
            make.size.equalTo(120)
        }
        
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
        }
        
        tipsLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(22)
        }
        
        progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(40)
            make.top.equalTo(tipsLab.snp.bottom).offset(30)
            make.height.equalTo(6)
        }
        
        progressLab.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        failedBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(32)
            make.top.equalTo(tipsLab.snp.bottom).offset(22)
            make.height.equalTo(40)
            make.width.equalTo(retryBtn)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        retryBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-32)
            make.top.equalTo(tipsLab.snp.bottom).offset(22)
            make.height.equalTo(40)
            make.width.equalTo(failedBtn)
            make.bottom.equalToSuperview().offset(-24)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.right.left.equalToSuperview().inset(32)
            make.top.equalTo(tipsLab.snp.bottom).offset(22)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-24)
        }
        
    }

    override func initData() {
        super.initData()
        cancelBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.isHidden = true
            self?.removeFromSuperview()
        }).disposed(by: disposeBag)
        
        failedBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.isHidden = true
            self?.removeFromSuperview()
        }).disposed(by: disposeBag)
        
        retryBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.isHidden = true
            self?.removeFromSuperview()
        }).disposed(by: disposeBag)
        
        confirmBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.isHidden = true
            self?.removeFromSuperview()
        }).disposed(by: disposeBag)
        
    }
    
    func setMetric(type: HealthMetricType) {
        switch type {
        case .heartRate:
            let url = Bundle.main.url(forResource: "heart", withExtension: "gif")
            animationView.sd_setImage(with: url)
            break
        case .steps:
            JLLogManager.logLevel(.ERROR, content: "not supported")
            break
        case .spo2:
            let url = Bundle.main.url(forResource: "spo", withExtension: "gif")
            animationView.sd_setImage(with: url)
            break
        }
    }

    
    func setProgress(_ progress: Float, _ value: Int) {
        progressView.isHidden = false
        progressLab.isHidden = false
        failedBtn.isHidden = true
        retryBtn.isHidden = true
        confirmBtn.isHidden = true
        
        titleLab.text = R.Language.lan("Testing in progress")
        tipsLab.text = R.Language.lan("Testing in progress")
        tipsLab.font = R.Font.regular(14)
        tipsLab.textColor = .eHex("#000000", alpha: 0.6)
        tipsLab.textAlignment = .center
        
        progressView.progress = progress
        progressLab.text = String(format: "%ds", value)
    }
    
    func setFailed() {
        progressView.isHidden = true
        progressLab.isHidden = true
        failedBtn.isHidden = false
        retryBtn.isHidden = false
        confirmBtn.isHidden = true
        titleLab.text = R.Language.lan("Test failed")
        tipsLab.text = R.Language.lan("health check faild tips")
        tipsLab.font = R.Font.regular(14)
        tipsLab.textColor = .eHex("#000000", alpha: 0.6)
        tipsLab.textAlignment = .left
    }
    
    func setSuccess() {
        progressView.isHidden = true
        progressLab.isHidden = true
        failedBtn.isHidden = true
        retryBtn.isHidden = true
        confirmBtn.isHidden = false
        titleLab.text = R.Language.lan("Test success")
        tipsLab.text = "98%"
        tipsLab.font = R.Font.medium(28)
        tipsLab.textColor = .eHex("#000000", alpha: 0.9)
        tipsLab.textAlignment = .center
    }
    
}
