//
//  HealthStepsSettingView.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/16.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class HealthStepsSettingView: BasicView {

    private let bgView = UIView()
    private let centerView = UIView()
    private let titleLab = UILabel()
    private let tipsLab = UILabel()
    private let slider = UISlider()
    private let beginLab = UILabel()
    private let endLab = UILabel()
    private let middleLab = UILabel()
    private let cancelBtn = UIButton()
    private let confirmBtn = UIButton()
    
    // MARK: - Slider Logic
    private var stepValues: [Int] = [5, 10, 60] // 三个固定档位值，与底部 label 保持一致
    private var currentIndex: Int = 1           // 默认中间档位
    private var lastHapticIndex: Int = -1       // 记录上次触发震动的档位索引
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    
    override func initUI() {
        super.initUI()
        addSubview(bgView)
        bgView.addSubview(centerView)
        centerView.addSubview(titleLab)
        centerView.addSubview(tipsLab)
        centerView.addSubview(slider)
        centerView.addSubview(beginLab)
        centerView.addSubview(endLab)
        centerView.addSubview(middleLab)
        centerView.addSubview(cancelBtn)
        centerView.addSubview(confirmBtn)
        
        bgView.backgroundColor = .eHex("#000000", alpha: 0.2)
        
        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 18
        centerView.layer.masksToBounds = true
        
        titleLab.textColor = .eHex("#000000", alpha: 0.8)
        titleLab.font = R.Font.medium(18)
        titleLab.text = R.Language.lan("setting")
        titleLab.textAlignment = .center
        
        tipsLab.textColor = .eHex("#919191")
        tipsLab.font = R.Font.regular(15)
        tipsLab.text = R.Language.lan("Step count update frequency (s)")
        
        // 将 slider 映射为 0~2 三等分，对应 [5,10,60]
        slider.minimumValue = 0
        slider.maximumValue = 2
        slider.value = 1
        slider.isContinuous = true
        slider.minimumTrackTintColor = .eHex("#7657EC")
        slider.setThumbImage(UIImage(named: "health_icon_slider_nol"), for: .normal)
        
        beginLab.textColor = .eHex("#4B4B4B")
        beginLab.font = R.Font.regular(12)
        beginLab.text = "5"
        
        endLab.textColor = .eHex("#4B4B4B")
        endLab.font = R.Font.regular(12)
        endLab.text = "60"
        
        middleLab.textColor = .eHex("#4B4B4B")
        middleLab.font = R.Font.regular(12)
        middleLab.text = "10"
        
        cancelBtn.setTitle(R.Language.lan("Cancel"), for: .normal)
        cancelBtn.setTitleColor(.eHex("#558CFF"), for: .normal)
        cancelBtn.titleLabel?.font = R.Font.medium(18)
        cancelBtn.backgroundColor = .white
  
        
        confirmBtn.setTitle(R.Language.lan("confirm"), for: .normal)
        confirmBtn.setTitleColor(.eHex("#558CFF"), for: .normal)
        confirmBtn.backgroundColor = .white
        confirmBtn.titleLabel?.font = R.Font.medium(18)
        
        let line = UIView()
        line.backgroundColor = .eHex("#F7F7F7")
        centerView.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.bottom.equalTo(confirmBtn.snp.top)
        }
        
        let line1 = UIView()
        line1.backgroundColor = .eHex("#F7F7F7")
        centerView.addSubview(line1)
        line1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.equalTo(confirmBtn)
            make.top.equalTo(line.snp.bottom)
        }
        
        setupConstraints()
        installSliderLogic()
        
    }
    
    override func initData() {
        super.initData()
        confirmBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.removeFromSuperview()
        }).disposed(by: disposeBag)
        
        cancelBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.removeFromSuperview()
        }).disposed(by: disposeBag)
    }
    
    private func setupConstraints() {
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        centerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(250)
        }
        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.left.right.equalToSuperview()
        }
        tipsLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(20)
        }
        slider.snp.makeConstraints { make in
            make.top.equalTo(tipsLab.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(20)
        }
        beginLab.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(4)
            make.left.equalTo(slider)
        }
        endLab.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(4)
            make.right.equalTo(slider)
        }
        middleLab.snp.makeConstraints { make in
            make.top.equalTo(slider.snp.bottom).offset(4)
            make.centerX.equalTo(slider)
        }
        cancelBtn.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(confirmBtn)
            make.height.equalTo(50)
            make.right.equalTo(confirmBtn.snp.left)
        }
        confirmBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(cancelBtn)
            make.height.equalTo(50)
            make.left.equalTo(cancelBtn.snp.right)
        }
    }
    
    // MARK: - Slider Three-Stop Logic
    private func installSliderLogic() {
        // 从底部 label 读取数值，确保与文案一致
        let beginVal = Int(beginLab.text ?? "5") ?? 5
        let middleVal = Int(middleLab.text ?? "10") ?? 10
        let endVal = Int(endLab.text ?? "60") ?? 60
        stepValues = [beginVal, middleVal, endVal]
        // 准备震动反馈
        selectionFeedback.prepare()
        // 事件绑定
        slider.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDidEnd(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        // 初始 UI 状态
        updateLabelsSelection(selectedIndex: currentIndex, animated: false)
    }

    @objc private func sliderDidChange(_ sender: UISlider) {
        // 计算最近档位（不立即吸附，仅进行预反馈）
        let nearest = nearestIndex(for: sender.value)
        // 档位变化触发轻微震动与高亮预览
        if nearest != lastHapticIndex {
            lastHapticIndex = nearest
            selectionFeedback.selectionChanged()
            updateLabelsSelection(selectedIndex: nearest, animated: true)
        }
    }

    @objc private func sliderDidEnd(_ sender: UISlider) {
        // 吸附到最近档位并动画
        let nearest = nearestIndex(for: sender.value)
        currentIndex = nearest
        slider.setValue(Float(nearest), animated: true)
        updateLabelsSelection(selectedIndex: nearest, animated: true)
        // 结束后准备下次震动
        selectionFeedback.prepare()
    }

    private func nearestIndex(for value: Float) -> Int {
        // 将滑动值四舍五入到 0/1/2
        let clamped = max(0, min(2, value))
        return Int(round(clamped))
    }

    private func updateLabelsSelection(selectedIndex: Int, animated: Bool) {
        // 颜色与字号反馈：选中高亮，其他为常规
        let normalColor = UIColor.eHex("#4B4B4B")
        let selectedColor = UIColor.eHex("#7657EC")
        let normalFont = R.Font.regular(12)
        let selectedFont = R.Font.medium(12)
        
        func apply(_ label: UILabel, isSelected: Bool) {
            label.textColor = isSelected ? selectedColor : normalColor
            label.font = isSelected ? selectedFont : normalFont
            if animated {
                UIView.animate(withDuration: 0.15) {
                    label.transform = isSelected ? CGAffineTransform(scaleX: 1.06, y: 1.06) : .identity
                }
            } else {
                label.transform = isSelected ? CGAffineTransform(scaleX: 1.06, y: 1.06) : .identity
            }
        }
        apply(beginLab, isSelected: selectedIndex == 0)
        apply(middleLab, isSelected: selectedIndex == 1)
        apply(endLab, isSelected: selectedIndex == 2)
    }

    // MARK: - Public
    /// 当前选中的步数更新频率（秒）
    func getSelectedStepSeconds() -> Int {
        return stepValues[currentIndex]
    }

}
