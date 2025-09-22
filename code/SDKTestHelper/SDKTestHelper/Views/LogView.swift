//
//  LogView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/17.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class LogView: BaseView {
    let titleLab = UILabel()
    let cleanBtn = UIButton()
    let logContextView = UITextView()
    private var logText: BehaviorRelay<String> = BehaviorRelay(value: "")
    
    override func initUI() {
        super.initUI()
        titleLab.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLab.textColor = .black
        titleLab.text = R.localStr.log()
        addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(40)
        }
        
        cleanBtn.setTitle(R.localStr.clean(), for: .normal)
        cleanBtn.backgroundColor = .random()
        cleanBtn.setTitleColor(.white, for: .normal)
        cleanBtn.layer.cornerRadius = 5
        cleanBtn.layer.masksToBounds = true
        addSubview(cleanBtn)
        cleanBtn.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(40)
        }
        
        logContextView.font = .systemFont(ofSize: 12, weight: .medium)
        logContextView.textColor = .black
        logContextView.backgroundColor = .eHex("#F5F5F5")
        logContextView.layer.cornerRadius = 5
        logContextView.layer.masksToBounds = true
        logContextView.isEditable = false
        logContextView.isSelectable = false
        logContextView.text = ""
        addSubview(logContextView)
        logContextView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    override func initData() {
        super.initData()
        cleanBtn.rx.tap.subscribe { [weak self] _ in
            self?.logText.accept("")
        }.disposed(by: disposeBag)
        
        logText.bind(to: logContextView.rx.text).disposed(by: disposeBag)
        
        JLLogManager.collectLog { [weak self] log in
            guard let self = self else { return }
            let newLog = logText.value + log
            logText.accept(newLog)   
            DispatchQueue.main.async {
                let range = NSMakeRange(self.logContextView.text.count, 0)
                self.logContextView.scrollRangeToVisible(range)
            }
        }
    }
    


}
