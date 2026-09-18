//
//  StreamControlPanelView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/4/14.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 关闭流与异常状态显示面板
class StreamControlPanelView: UIView {
    
    let stopButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor.compatibleSystemBackground
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        
        statusLabel.text = "当前状态: 空闲"
        statusLabel.font = .systemFont(ofSize: 14)
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        self.addSubview(statusLabel)
        
        stopButton.setTitle("停止当前传输", for: .normal)
        stopButton.backgroundColor = UIColor.compatibleSystemRed
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 8
        self.addSubview(stopButton)
        
        statusLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }
        
        stopButton.snp.makeConstraints { make in
            make.top.equalTo(statusLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
    }
    
    /// 绑定 ViewModel 状态
    func bind(statusDriver: Driver<StreamTransferViewModel.StreamStatus>) {
        statusDriver
            .drive(onNext: { [weak self] status in
                guard let self = self else { return }
                
                switch status {
                case .idle:
                    self.statusLabel.text = "当前状态: 空闲"
                    self.statusLabel.textColor = UIColor.compatibleLabel
                    self.stopButton.isEnabled = false
                    self.stopButton.alpha = 0.5
                case .fetching:
                    self.statusLabel.text = "正在获取设备外设信息..."
                    self.statusLabel.textColor = UIColor.compatibleSystemBlue
                    self.stopButton.isEnabled = false
                    self.stopButton.alpha = 0.5
                case .transferring:
                    self.statusLabel.text = "流已开启，正在传输..."
                    self.statusLabel.textColor = UIColor.compatibleSystemGreen
                    self.stopButton.isEnabled = true
                    self.stopButton.alpha = 1.0
                case .error(let reason):
                    self.statusLabel.text = "发生异常: \(reason)"
                    self.statusLabel.textColor = UIColor.compatibleSystemRed
                    self.stopButton.isEnabled = true // 允许在异常时强制停止
                    self.stopButton.alpha = 1.0
                }
            })
            .disposed(by: disposeBag)
    }
}
