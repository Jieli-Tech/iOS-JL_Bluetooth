//
//  LancerDeviceSetTableViewCell.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/10/8.
//

import UIKit

class LancerDeviceSetTableViewCell: UITableViewCell {
    private let nameLab = UILabel()
    private let secondLab = UILabel()
    private let rightImgv = UIImageView()
    private let selectSwitch = UISwitch()
    private let slider = UISlider()
    private let sliderLab = UILabel()
    private let subMaskView = UIView()
    private var currentModel: LancerDeviceSetModel!
    private let disposeBag: DisposeBag = .init()

    var callBackSlider: ((_ value: Float, _ model: LancerDeviceSetModel) -> Void)?
    var callBackSwitch: ((_ value: Bool, _ model: LancerDeviceSetModel) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        contentView.addSubview(nameLab)
        contentView.addSubview(secondLab)
        contentView.addSubview(rightImgv)
        contentView.addSubview(selectSwitch)
        contentView.addSubview(slider)
        contentView.addSubview(sliderLab)
        contentView.addSubview(subMaskView)

        nameLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nameLab.textColor = R.color.fontBackText242424()
        nameLab.adjustsFontSizeToFitWidth = true

        secondLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        secondLab.textColor = R.color.fontBackText_50()
        secondLab.adjustsFontSizeToFitWidth = true
        secondLab.textAlignment = .right
        secondLab.isHidden = true

        rightImgv.image = R.image.icon_next_gray()
        rightImgv.isHidden = true

        selectSwitch.onTintColor = R.color.btnBlueText()
        selectSwitch.isOn = false
        selectSwitch.isHidden = true

        slider.setThumbImage(R.image.slider_02_nor(), for: .normal)
        slider.maximumValue = 100
        slider.minimumValue = 0
        slider.tintColor = R.color.btnBlueText()
        slider.isHidden = true

        sliderLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sliderLab.textColor = R.color.fontBackText_50()
        sliderLab.adjustsFontSizeToFitWidth = true
        sliderLab.textAlignment = .right
        sliderLab.isHidden = true

        subMaskView.backgroundColor = .eHex("#FFFFFF", alpha: 0.4)
        subMaskView.isHidden = true

        subMaskView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        nameLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(16)
        }

        secondLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(rightImgv.snp.left).offset(-8)
        }

        rightImgv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
            make.right.equalToSuperview().inset(16)
        }

        selectSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(28)
        }

        slider.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(sliderLab.snp.left).offset(-16)
            make.width.equalTo(186)
        }

        sliderLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(16)
        }

        initData()
    }

    func configCell(_ model: LancerDeviceSetModel) {
        currentModel = model
        nameLab.text = model.name
        secondLab.text = model.detailContext
        if model.detailContext != nil {
            secondLab.isHidden = false
        } else {
            secondLab.isHidden = true
        }
        rightImgv.isHidden = !model.showRightArrow
        selectSwitch.isHidden = !model.isShowSelect
        slider.isHidden = !model.showSlider
        sliderLab.isHidden = !model.showSlider
        slider.maximumValue = model.maxValue
        slider.minimumValue = model.minValue
        slider.value = model.sliderValue
        if model.showSlider {
            let value = slider.value / (slider.maximumValue) * 100
            sliderLab.text = String(format: "%.0f%%", value)
        }
        subMaskView.isHidden = model.isEnable
    }

    private func initData() {
        slider.rx.value.subscribe { value in
            let value = value / (self.slider.maximumValue) * 100
            self.sliderLab.text = String(format: "%.0f%%", value)
        }.disposed(by: disposeBag)

        slider.rx.controlEvent(.editingDidEnd).subscribe { _ in
            self.slider.value = Float(Int(self.slider.value * 100) / 100)
            self.callBackSlider?(self.slider.value, self.currentModel)
        }.disposed(by: disposeBag)

        selectSwitch.rx.value.subscribe { value in
            self.callBackSwitch?(value, self.currentModel)
        }.disposed(by: disposeBag)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



class LancerDeviceSetModel: NSObject {
    var name: String
    var detailContext: String?
    var showRightArrow: Bool = false
    var selectSwitchStatus: Bool = false
    var isShowSelect: Bool = false
    var showSlider: Bool = false
    var sliderValue: Float = 0.0
    var maxValue: Float = 0.0
    var volumeStep: Int = 1
    var minValue: Float = 0
    var isEnable: Bool = true

    init(name: String,
         detailContext: String? = nil,
         showRightArrow: Bool = false,
         selectSwitchStatus: Bool = false,
         isShowSelect: Bool = false,
         showSlider: Bool = false,
         sliderValue: Float = 0.0) {
        self.name = name
        self.detailContext = detailContext
        self.showRightArrow = showRightArrow
        self.selectSwitchStatus = selectSwitchStatus
        self.isShowSelect = isShowSelect
        self.showSlider = showSlider
        self.sliderValue = sliderValue
    }
}
