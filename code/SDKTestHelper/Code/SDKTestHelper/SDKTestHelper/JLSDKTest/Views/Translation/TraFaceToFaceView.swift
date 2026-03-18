//
//  TraFaceToFaceView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/9.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class TraFaceToFaceView: BaseView {
    private let appRecordBtn = EcButton()
    private let headEarRecordBtn = EcButton()
    
    override func initData() {
        super.initData()
        
    }
    
    override func initUI() {
        super.initUI()
        addSubview(appRecordBtn)
        addSubview(headEarRecordBtn)
        appRecordBtn.setTitle(R.localStr.appRecording(), for: .normal)
        headEarRecordBtn.setTitle(R.localStr.headphoneRecording(), for: .normal)
        
        appRecordBtn.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(40)
        }
        headEarRecordBtn.snp.makeConstraints { make in
            make.top.equalTo(appRecordBtn.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(40)
        }
    }
    
}

