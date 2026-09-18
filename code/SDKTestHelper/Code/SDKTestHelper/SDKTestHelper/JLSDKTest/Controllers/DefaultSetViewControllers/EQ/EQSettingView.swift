//
//  EQSettingView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/1.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit

protocol EQSettingViewDelegate: AnyObject {
    func eqSettingView(_ view: EQSettingView, didChangeSliderAt index: Int, value: Float)
    func eqSettingView(_ view: EQSettingView, didSelectEQModeAt index: Int)
}

class EQSettingView: BaseView {
    
    weak var delegate: EQSettingViewDelegate?
    
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var eqNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.text = R.localStr.natural()
        return label
    }()
    
    private var sliders: [UISlider] = []
    private var eqLabels: [UILabel] = []
    private var freqLabels: [UILabel] = []
    private var sliderContainerViews: [UIView] = []
    
    private let eqModes: [JL_EQMode] = [.NORMAL, .ROCK, .POP, .CLASSIC, .JAZZ, .COUNTRY, .CUSTOM, .LATIN, .DANCE]
    private var modeButtons: [UIButton] = []
    
    // MARK: - UI Setup
    override func initUI() {
        super.initUI()
        
        setupScrollView()
        setupEQNameLabel()
        setupModeButtons()
    }
    
    private func setupScrollView() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    private func setupEQNameLabel() {
        contentView.addSubview(eqNameLabel)
        eqNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    // MARK: - Dynamic Slider Setup
    func setupSliders(count: Int, frequencies: [String]) {
        // 清除旧的 Slider
        clearSliders()
        
        let sliderHeight: CGFloat = 30
        let labelWidth: CGFloat = 50
        let freqLabelWidth: CGFloat = 60
        let spacing: CGFloat = 15
        let startY: CGFloat = 60
        
        for i in 0..<count {
            // 创建容器视图
            let containerView = UIView()
            contentView.addSubview(containerView)
            sliderContainerViews.append(containerView)
            
            // EQ Value Label (left)
            let eqLabel = UILabel()
            eqLabel.textAlignment = .center
            eqLabel.font = .systemFont(ofSize: 13)
            eqLabel.textColor = .gray
            eqLabel.text = "0"
            eqLabel.tag = i
            containerView.addSubview(eqLabel)
            eqLabels.append(eqLabel)
            
            eqLabel.snp.makeConstraints { make in
                make.left.equalToSuperview()
                make.width.equalTo(labelWidth)
                make.height.equalTo(19)
                make.centerY.equalToSuperview()
            }
            
            // Slider
            let slider = UISlider()
            slider.minimumValue = -8
            slider.maximumValue = 8
            slider.value = 0
            slider.tag = i
            slider.minimumTrackTintColor = .lightGray
            slider.isUserInteractionEnabled = false
            slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
            containerView.addSubview(slider)
            sliders.append(slider)
            
            slider.snp.makeConstraints { make in
                make.left.equalTo(eqLabel.snp.right).offset(8)
                make.right.equalToSuperview().offset(-freqLabelWidth - 8)
                make.height.equalTo(sliderHeight)
                make.centerY.equalToSuperview()
            }
            
            // Frequency Label (right)
            let freqLabel = UILabel()
            freqLabel.textAlignment = .right
            freqLabel.font = .systemFont(ofSize: 12)
            freqLabel.textColor = .gray
            freqLabel.text = i < frequencies.count ? frequencies[i] : ""
            freqLabel.tag = i + 10
            containerView.addSubview(freqLabel)
            freqLabels.append(freqLabel)
            
            freqLabel.snp.makeConstraints { make in
                make.right.equalToSuperview()
                make.width.equalTo(freqLabelWidth)
                make.height.equalTo(14)
                make.centerY.equalToSuperview()
            }
            
            // 容器视图约束
            containerView.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(10)
                make.right.equalToSuperview().offset(-10)
                make.height.equalTo(sliderHeight)
                make.top.equalToSuperview().offset(startY + CGFloat(i) * (sliderHeight + spacing))
            }
        }
        
        // 更新按钮位置
        updateModeButtonsPosition(sliderStartY: startY, sliderCount: count, spacing: spacing, sliderHeight: sliderHeight)
    }
    
    private func clearSliders() {
        sliders.forEach { $0.removeFromSuperview() }
        eqLabels.forEach { $0.removeFromSuperview() }
        freqLabels.forEach { $0.removeFromSuperview() }
        sliderContainerViews.forEach { $0.removeFromSuperview() }
        
        sliders.removeAll()
        eqLabels.removeAll()
        freqLabels.removeAll()
        sliderContainerViews.removeAll()
    }
    
    private func setupModeButtons() {
        let buttonTitles = [
            R.localStr.natural(),
            R.localStr.rock(),
            R.localStr.pop(),
            R.localStr.classic(),
            R.localStr.jazz(),
            R.localStr.country(),
            R.localStr.custom(),
            R.localStr.latin(),
            R.localStr.dance()
        ]
        
        let buttonHeight: CGFloat = 36
        let buttonWidth: CGFloat = 80
        let spacing: CGFloat = 10
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.backgroundColor = .random()
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(modeButtonTapped(_:)), for: .touchUpInside)
            contentView.addSubview(button)
            modeButtons.append(button)
            
            let row = index / 3
            let col = index % 3
            
            button.snp.makeConstraints { make in
                make.width.equalTo(buttonWidth)
                make.height.equalTo(buttonHeight)
                
                if col == 0 {
                    make.left.equalToSuperview().offset(20)
                } else if col == 1 {
                    make.centerX.equalToSuperview()
                } else {
                    make.right.equalToSuperview().offset(-20)
                }
            }
        }
    }
    
    private func updateModeButtonsPosition(sliderStartY: CGFloat, sliderCount: Int, spacing: CGFloat, sliderHeight: CGFloat) {
        let startY = sliderStartY + CGFloat(sliderCount) * (sliderHeight + spacing) + 30
        
        for (index, button) in modeButtons.enumerated() {
            let row = index / 3
            let buttonSpacing: CGFloat = 10
            
            button.snp.remakeConstraints { make in
                make.width.equalTo(80)
                make.height.equalTo(36)
                make.top.equalToSuperview().offset(startY + CGFloat(row) * (36 + buttonSpacing))
                
                let col = index % 3
                if col == 0 {
                    make.left.equalToSuperview().offset(20)
                } else if col == 1 {
                    make.centerX.equalToSuperview()
                } else {
                    make.right.equalToSuperview().offset(-20)
                }
            }
        }
        
        // 更新 contentView 底部约束
        if let lastButton = modeButtons.last {
            contentView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.width.equalToSuperview()
                make.bottom.equalTo(lastButton.snp.bottom).offset(30)
            }
        }
    }
    
    // MARK: - Actions
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let index = sender.tag
        let value = sender.value
        
        // Update label
        if index < eqLabels.count {
            eqLabels[index].text = "\(Int(value))"
        }
        
        delegate?.eqSettingView(self, didChangeSliderAt: index, value: value)
    }
    
    @objc private func modeButtonTapped(_ sender: UIButton) {
        delegate?.eqSettingView(self, didSelectEQModeAt: sender.tag)
    }
    
    // MARK: - Public Methods
    func updateEQName(_ name: String) {
        eqNameLabel.text = name
    }
    
    func updateSlider(at index: Int, value: Float) {
        guard index >= 0 && index < sliders.count else { return }
        
        sliders[index].value = value
        eqLabels[index].text = "\(Int(value))"
    }
    
    func updateSliderColor(at index: Int, color: UIColor) {
        guard index >= 0 && index < sliders.count else { return }
        sliders[index].minimumTrackTintColor = color
    }
    
    func setSliderEnabled(at index: Int, enabled: Bool) {
        guard index >= 0 && index < sliders.count else { return }
        sliders[index].isUserInteractionEnabled = enabled
    }
    
    func setAllSlidersEnabled(_ enabled: Bool) {
        sliders.forEach { $0.isUserInteractionEnabled = enabled }
    }
    
    func updateAllSliders(with values: [Float]) {
        for (index, value) in values.enumerated() {
            guard index < sliders.count else { break }
            updateSlider(at: index, value: value)
        }
    }
    
    func resetSliders() {
        for i in 0..<sliders.count {
            sliders[i].value = 0
            sliders[i].minimumTrackTintColor = .lightGray
            sliders[i].isUserInteractionEnabled = false
            eqLabels[i].text = "0"
        }
    }
    
    func getSliderValues() -> [Float] {
        return sliders.map { $0.value }
    }
    
    func getSliderCount() -> Int {
        return sliders.count
    }
}
