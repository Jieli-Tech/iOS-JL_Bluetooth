//
//  StreamPreviewView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/4/14.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// 实时视频流预览控件
class StreamPreviewView: UIView {
    
    private let imageView = UIImageView()
    private let statusLabel = UILabel()
    private let fpsLabel = UILabel()
    private let disposeBag = DisposeBag()
    
    // 帧率统计
    private var frameCount: Int = 0
    private var lastFpsUpdateTime: TimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .black
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        imageView.contentMode = .scaleAspectFit
        self.addSubview(imageView)
        
        statusLabel.textColor = .white
        statusLabel.font = .systemFont(ofSize: 12)
        statusLabel.text = "等待视频流..."
        statusLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        statusLabel.layer.cornerRadius = 4
        statusLabel.clipsToBounds = true
        self.addSubview(statusLabel)
        
        // 帧率统计标签
        fpsLabel.textColor = .white
        fpsLabel.font = .systemFont(ofSize: 12)
        fpsLabel.text = "FPS: 0"
        fpsLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        fpsLabel.layer.cornerRadius = 4
        fpsLabel.clipsToBounds = true
        self.addSubview(fpsLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        statusLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-8)
        }
        
        fpsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
        }
    }
    
    /// 更新帧率统计
    private func updateFPS() {
        frameCount += 1
        let currentTime = CACurrentMediaTime()
        let timeElapsed = currentTime - lastFpsUpdateTime
        
        // 每秒更新一次帧率显示
        if timeElapsed >= 1.0 {
            let fps = Double(frameCount) / timeElapsed
            fpsLabel.text = String(format: "FPS: %.1f", fps)
            frameCount = 0
            lastFpsUpdateTime = currentTime
        }
    }
    
    /// 绑定图片数据源
    func bind(imageDriver: Driver<UIImage?>) {
        imageDriver
            .drive(onNext: { [weak self] image in
                self?.imageView.image = image
                self?.statusLabel.isHidden = (image != nil)
                // 有图片时更新帧率统计
                if image != nil {
                    self?.updateFPS()
                }
            })
            .disposed(by: disposeBag)
    }
    
    /// 绑定状态信息（例如异常或提示）
    func bind(statusDriver: Driver<String>) {
        statusDriver
            .drive(onNext: { [weak self] status in
                self?.statusLabel.text = " \(status) "
                self?.statusLabel.isHidden = false
            })
            .disposed(by: disposeBag)
    }
}
