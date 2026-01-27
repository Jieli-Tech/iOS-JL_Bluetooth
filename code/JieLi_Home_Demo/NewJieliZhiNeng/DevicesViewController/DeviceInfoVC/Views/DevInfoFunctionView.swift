//
//  DevInfoFunctionView.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/12/22.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation
import SnapKit
import RxSwift

class DevInfoFunctionView: BasicView {
    private let funcImgv = UIImageView()
    private let funcLab = UILabel()
    private let detailLab = UILabel()
    private let nextIconImgv = UIImageView()
    private let switchBtn = UISwitch()
    private let tap = UITapGestureRecognizer()
    
    var switchBlock: ((Bool) -> Void)?
    var tapBlock: (() -> Void)?
    
    override func initUI() {
        super.initUI()
        addSubview(funcImgv)
        addSubview(funcLab)
        addSubview(detailLab)
        addSubview(nextIconImgv)
        addSubview(switchBtn)
        backgroundColor = .white
        addGestureRecognizer(tap)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        // shadowCode
        layer.shadowColor = UIColor(red: 0.8, green: 0.9, blue: 0.98, alpha: 0.2).cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 1
        layer.shadowRadius = 8
        
        funcImgv.contentMode = .scaleAspectFit
        
        funcLab.font = .systemFont(ofSize: 15, weight: .medium)
        funcLab.textColor = .eHex("#242424")
        funcLab.adjustsFontSizeToFitWidth = true
        
        detailLab.font = .systemFont(ofSize: 14, weight: .medium)
        detailLab.textColor = .eHex("#000000",alpha: 0.5)
        detailLab.textAlignment = .right
        detailLab.adjustsFontSizeToFitWidth = true
        
        nextIconImgv.image = R.image.icon_next_gray()
        
        switchBtn.onTintColor = .eHex("#7657EC")
        switchBtn.isOn = false
        switchBtn.isHidden = true
        
        funcImgv.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(32)
        }
        
        funcLab.snp.makeConstraints { make in
            make.left.equalTo(funcImgv.snp.right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalTo(detailLab.snp.left).offset(-4)
        }
        
        detailLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(nextIconImgv.snp.left).offset(-8)
            make.left.equalTo(funcLab.snp.right).offset(4)
        }
        
        nextIconImgv.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }
        
        switchBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
    }
    override func initData() {
        tap.rx.event.bind { [weak self] _ in
            guard let self = self else { return }
            self.tapBlock?()
        }.disposed(by: disposeBag)
        switchBtn.rx.value.bind { [weak self] value in
            guard let self = self else { return }
            self.switchBlock?(value)
        }.disposed(by: disposeBag)
    }
    
    func config(title: String, imgv: String, detail: String, hasSwitch: Bool = false, switchIsOn: Bool = false) {
        funcLab.text = title
        funcImgv.image = R.Image.img(imgv)
        detailLab.text = detail
        switchBtn.isOn = switchIsOn
        switchBtn.isHidden = !hasSwitch
        nextIconImgv.isHidden = hasSwitch
        if hasSwitch {
            removeGestureRecognizer(tap)
        }
    }
    
}
