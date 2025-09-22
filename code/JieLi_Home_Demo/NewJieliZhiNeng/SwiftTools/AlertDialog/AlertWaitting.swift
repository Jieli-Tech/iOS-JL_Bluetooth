//
//  AlertWaitting.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/10.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class AlertWaitting: BasicView {

    let bgView = UIView()
    let cententView = UIView()
    let loadingView = UIActivityIndicatorView()
    let titleLab = UILabel()

    override func initUI() {
        super.initUI()
        addSubview(bgView)
        addSubview(cententView)
        cententView.addSubview(loadingView)
        cententView.addSubview(titleLab)
        
        bgView.backgroundColor = .eHex("#000000", alpha: 0.6)
        cententView.backgroundColor = .black
        cententView.layer.cornerRadius = 12
        cententView.layer.masksToBounds = true
        titleLab.textColor = .white
        titleLab.font = R.Font.medium(15)
        titleLab.textAlignment = .center
        titleLab.adjustsFontSizeToFitWidth = true
        titleLab.numberOfLines = 0
        loadingView.color = .white
        loadingView.startAnimating()
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cententView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.greaterThanOrEqualTo(100)
            make.height.greaterThanOrEqualTo(100)
        }
        loadingView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }
        titleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(5)
        }
    }
    
    func show(title: String) {
        titleLab.text = title
        self.isHidden = false
        loadingView.startAnimating()
    }
    
    func hide() {
        loadingView.stopAnimating()
        self.isHidden = true
        removeFromSuperview()
    }
}
