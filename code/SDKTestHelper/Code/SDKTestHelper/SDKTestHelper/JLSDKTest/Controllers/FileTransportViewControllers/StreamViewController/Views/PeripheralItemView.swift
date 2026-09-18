//
//  PeripheralItemView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/4/14.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JL_BLEKit

/// 可折叠的单个设备外设参数展示控件
class PeripheralItemView: UIView {
    
    private let titleButton = UIButton(type: .system)
    private let detailContainerView = UIView()
    private let detailStackView = UIStackView()
    private let disposeBag = DisposeBag()
    
    // UI 扩展性：可以在这里维护折叠状态
    private let isExpanded = BehaviorRelay<Bool>(value: false)
    
    // 高度约束引用
    private var containerHeightConstraint: Constraint?
    
    init(model: JLStreamPeripheralResponseModel) {
        super.init(frame: .zero)
        setupUI(with: model)
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(with model: JLStreamPeripheralResponseModel) {
        self.backgroundColor = UIColor.compatibleSecondarySystemBackground
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        let typeName = model.type == .camera ? "摄像头" : "麦克风"
        titleButton.setTitle("▶ \(typeName)(\(model.number))", for: .normal)
        titleButton.contentHorizontalAlignment = .left
        titleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        titleButton.setTitleColor(UIColor.compatibleLabel, for: .normal)
        self.addSubview(titleButton)
        
        // 使用容器视图包裹 detailStackView，便于控制高度
        detailContainerView.clipsToBounds = true
        self.addSubview(detailContainerView)
        
        detailStackView.axis = .vertical
        detailStackView.spacing = 4
        detailContainerView.addSubview(detailStackView)
        
        titleButton.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(44)
        }
        
        detailContainerView.snp.makeConstraints { make in
            make.top.equalTo(titleButton.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            // 初始高度为0（收起状态）
            self.containerHeightConstraint = make.height.equalTo(0).constraint
        }
        
        detailStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(12)
        }
        
        // 动态生成详情标签
        addDetailLabel(title: "Number", value: "\(model.number)")
        if model.type == .camera {
            // Camera codec: bit0: JPEG, bit1: H.264
            let cameraCodecs = getCameraCodecNames(mask: model.codec)
            addDetailLabel(title: "Codec", value: cameraCodecs.isEmpty ? "Unknown" : cameraCodecs.joined(separator: ", "))
            addDetailLabel(title: "FPS", value: "\(model.fps)")
            addDetailLabel(title: "Resolution", value: "\(model.width)x\(model.height)")
        } else if model.type == .mic {
            // Mic codec: bit0: PCM, bit1: speex, bit2: opus, bit3: msbc, bit4: jla_v2
            let micCodecs = getMicCodecNames(mask: model.codec)
            addDetailLabel(title: "Codec", value: micCodecs.isEmpty ? "Unknown" : micCodecs.joined(separator: ", "))
            // Mic sample rate: bit0~bit8 对应 8000~48000Hz
            let sampleRates = getMicSampleRateNames(mask: model.sr)
            addDetailLabel(title: "Sample Rate", value: sampleRates.isEmpty ? "Unknown" : sampleRates.joined(separator: ", "))
        }
    }
    
    // Mic codec: bit0: PCM, bit1: speex, bit2: opus, bit3: msbc, bit4: jla_v2
    private func getMicCodecNames(mask: UInt32) -> [String] {
        var names = [String]()
        if mask & (1 << 0) != 0 { names.append("PCM") }
        if mask & (1 << 1) != 0 { names.append("SPEEX") }
        if mask & (1 << 2) != 0 { names.append("OPUS") }
        if mask & (1 << 3) != 0 { names.append("MSBC") }
        if mask & (1 << 4) != 0 { names.append("JLA_V2") }
        return names
    }
    
    // Camera codec: bit0: JPEG, bit1: H.264
    private func getCameraCodecNames(mask: UInt32) -> [String] {
        var names = [String]()
        if mask & (1 << 0) != 0 { names.append("JPEG") }
        if mask & (1 << 1) != 0 { names.append("H.264") }
        return names
    }
    
    // Mic sample rate: bit0~bit8 对应 8000, 11025, 12000, 16000, 22050, 24000, 32000, 44100, 48000 Hz
    private func getMicSampleRateNames(mask: UInt32) -> [String] {
        let rates = [8000, 11025, 12000, 16000, 22050, 24000, 32000, 44100, 48000]
        var names = [String]()
        for (i, rate) in rates.enumerated() {
            if mask & (1 << i) != 0 {
                names.append("\(rate)Hz")
            }
        }
        return names
    }
    
    private func addDetailLabel(title: String, value: String) {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor.compatibleSecondaryLabel
        label.text = "\(title): \(value)"
        detailStackView.addArrangedSubview(label)
    }
    
    private func bindUI() {
        titleButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isExpanded.accept(!self.isExpanded.value)
            })
            .disposed(by: disposeBag)
        
        isExpanded.asDriver()
            .drive(onNext: { [weak self] expanded in
                guard let self = self else { return }
                
                // 更新标题箭头
                let currentTitle = self.titleButton.title(for: .normal) ?? ""
                let newTitle = expanded ? currentTitle.replacingOccurrences(of: "▶", with: "▼") : currentTitle.replacingOccurrences(of: "▼", with: "▶")
                self.titleButton.setTitle(newTitle, for: .normal)
                
                // 动画更新容器高度和内部视图可见性
                if expanded {
                    // 展开：先显示内容，再取消高度约束
                    self.detailStackView.isHidden = false
                    self.containerHeightConstraint?.deactivate()
                } else {
                    // 收起：先激活高度约束，再隐藏内容
                    self.containerHeightConstraint?.activate()
                    self.detailStackView.isHidden = true
                }
                
                // 触发动画重新布局
                UIView.animate(withDuration: 0.3) {
                    self.superview?.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }
}
