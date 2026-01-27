//
//  ScreenLightSetView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/12/5.
//  Copyright © 2023 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class ScreenLightSetView: UIView {
    var lightLab = UILabel()
    weak var publicSetting: PublicSettingViewModel?
    private let leftImgv = UIImageView()
    private let rightImgv = UIImageView()
    private let lightSlider = LighgSlider()
    private let disposeBag = DisposeBag()
    override init(frame: CGRect) {
        super.init(frame: frame)
        LanguageCls.share().add(self)
        
        backgroundColor = UIColor.white
        addSubview(lightLab)
        addSubview(rightImgv)
        addSubview(leftImgv)
        addSubview(lightSlider)
        layer.cornerRadius = 12
        layer.masksToBounds = true

        lightLab.textColor = UIColor(fromRGBAArray: [0, 0, 0, 0.9])
        lightLab.font = R.Font.medium(15)
        lightLab.text = R.Language.lan("Brightness")
        
        leftImgv.image = R.Image.img("Theme.bundle/bay_icon_brightness_reduece")
        rightImgv.image = R.Image.img("Theme.bundle/bay_icon_brightness_plus")

        lightSlider.maximumValue = 100
        lightSlider.minimumValue = 0
        lightSlider.setThumbImage(R.Image.img("Theme.bundle/bay_slider"), for: .normal)
        lightSlider.maximumTrackTintColor = UIColor(fromHexString: "#CACACA")
        lightSlider.minimumTrackTintColor = UIColor(fromHexString: "#7657EC")
        lightSlider.value = 50

        lightLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(14)
            make.height.equalTo(20)
        }
        leftImgv.snp.makeConstraints { make in
            make.top.equalTo(lightLab.snp.bottom).offset(26)
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(lightSlider.snp.left).offset(-12)
            make.width.height.equalTo(24)
        }
        rightImgv.snp.makeConstraints { make in
            make.top.equalTo(lightLab.snp.bottom).offset(26)
            make.left.equalTo(lightSlider.snp.right).offset(12)
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        lightSlider.snp.makeConstraints { make in
            make.left.equalTo(leftImgv.snp.right).offset(12)
            make.right.equalTo(rightImgv.snp.left).offset(-12)
            make.centerY.equalTo(rightImgv)
            make.height.equalTo(24)
        }

    }

    func addHandle() {
        lightSlider.addTarget(self, action: #selector(sliderValueChange), for: .touchUpInside)
        lightSlider.addTarget(self, action: #selector(sliderValueChange), for: .touchUpOutside)
        publicSetting?.currentLight.subscribe(onNext: { [weak self] value in
            guard let `self` = self else { return }
            self.lightSlider.setValue(Float(value), animated: true)
        }).disposed(by: disposeBag)
    }

    func sliderValueChange() {
        let value = lightSlider.value
        publicSetting?.updateLightValue(UInt8(value))
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
private class LighgSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: bounds.midY-3, width: bounds.width, height: 6)
    }
}
extension ScreenLightSetView:LanguagePtl{
    func languageChange() {
        lightLab.text = R.Language.lan("Brightness")
    }
}
