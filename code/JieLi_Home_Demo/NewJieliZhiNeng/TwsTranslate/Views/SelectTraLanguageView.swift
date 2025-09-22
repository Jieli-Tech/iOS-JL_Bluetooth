//
//  SelectTraLanguageView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/8.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

enum TranslationLanguageType {
    case zh
    case en
    case ja

    func title() -> String {
        switch self {
        case .en:
            return LanguageCls.localizableTxt("English")
        case .zh:
            return LanguageCls.localizableTxt("Chinese")
        case .ja:
            return LanguageCls.localizableTxt("Japanese")
        }
    }

    static func allLanguages() -> [TranslationLanguageType] {
        return [.zh, .en, .ja]
    }

    static func commonLanguages() -> [TranslationLanguageType] {
        return [.zh, .en]
    }
}

class SelectTraLanguageView: BasicView {
    private let myWayLab = UILabel()
    private let otherWayLab = UILabel()
    private let myWayImgv = UIImageView()
    private let otherWayImgv = UIImageView()
    private let myWayBtn = UIButton()
    private let otherWayBtn = UIButton()
    private let switchBtn = UIButton()

    private let purpleColor = UIColor.eHex("#7657EC")
    private let whiteColor = UIColor.eHex("#000000", alpha: 0.9)

    private var currentMySideLanguage: TranslationLanguageType = .zh
    private var currentOtherSideLanguage: TranslationLanguageType = .en
    private var _currentBtnTag: Bool = true
    private var currentBtnTag: Bool {
        get {
            return _currentBtnTag
        }
        set {
            _currentBtnTag = newValue
            if newValue {
                myWayBtn.setTitleColor(purpleColor, for: .normal)
                myWayBtn.layer.borderColor = purpleColor.cgColor

                otherWayBtn.setTitleColor(whiteColor, for: .normal)
                otherWayBtn.layer.borderColor = UIColor.clear.cgColor
            } else {
                myWayBtn.setTitleColor(whiteColor, for: .normal)
                myWayBtn.layer.borderColor = UIColor.clear.cgColor

                otherWayBtn.setTitleColor(purpleColor, for: .normal)
                otherWayBtn.layer.borderColor = purpleColor.cgColor
            }
        }
    }

    override func initUI() {
        super.initUI()
        backgroundColor = .clear

        myWayLab.text = LanguageCls.localizableTxt("Our side")
        myWayLab.font = R.Font.medium(11)
        myWayLab.textColor = .eHex("#000000", alpha: 0.6)

        myWayImgv.image = R.Image.img("translation_icon_our")
        myWayImgv.contentMode = .scaleAspectFit

        otherWayLab.text = LanguageCls.localizableTxt("Other side")
        otherWayLab.font = R.Font.medium(11)
        otherWayLab.textColor = .eHex("#000000", alpha: 0.6)

        otherWayImgv.image = R.Image.img("translation_icon_other")
        otherWayImgv.contentMode = .scaleAspectFit

        // 设置按钮样式
        myWayBtn.setTitle(LanguageCls.localizableTxt("Chinese"), for: .normal)
        myWayBtn.setTitleColor(purpleColor, for: .normal)
        myWayBtn.layer.borderColor = purpleColor.cgColor
        myWayBtn.layer.borderWidth = 1
        myWayBtn.layer.cornerRadius = 6
        myWayBtn.backgroundColor = .white
        myWayBtn.titleLabel?.font = R.Font.medium(15)

        otherWayBtn.setTitle(LanguageCls.localizableTxt("English"), for: .normal)
        otherWayBtn.setTitleColor(.eHex("#000000", alpha: 0.9), for: .normal)
        otherWayBtn.backgroundColor = .white
        otherWayBtn.layer.borderColor = UIColor.clear.cgColor
        otherWayBtn.layer.borderWidth = 1
        otherWayBtn.layer.cornerRadius = 6
        otherWayBtn.titleLabel?.font = R.Font.medium(15)

        // 设置交换按钮
        switchBtn.backgroundColor = .white
        switchBtn.layer.cornerRadius = 6
        switchBtn.setImage(R.Image.img("icon_both_sides"), for: .normal)

        // 添加子视图
        addSubview(myWayLab)
        addSubview(myWayImgv)
        addSubview(otherWayLab)
        addSubview(otherWayImgv)
        addSubview(myWayBtn)
        addSubview(otherWayBtn)
        addSubview(switchBtn)

        // 布局约束
        myWayLab.snp.makeConstraints { make in
            make.centerY.equalTo(myWayImgv.snp.centerY)
            make.left.equalTo(myWayImgv.snp.right).offset(4)
            make.right.equalTo(myWayBtn.snp.right)
        }
        myWayImgv.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(14)
            make.width.height.equalTo(12)
        }

        myWayBtn.snp.makeConstraints { make in
            make.top.equalTo(myWayLab.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(otherWayBtn.snp.width)
            make.height.equalTo(40)
            make.right.equalTo(switchBtn.snp.left).offset(-22)
        }

        otherWayLab.snp.makeConstraints { make in
            make.centerY.equalTo(otherWayImgv.snp.centerY)
            make.left.equalTo(otherWayImgv.snp.right).offset(4)
            make.right.equalTo(otherWayBtn.snp.right)
        }
        otherWayImgv.snp.makeConstraints { make in
            make.left.equalTo(otherWayBtn.snp.left).offset(4)
            make.top.equalToSuperview().inset(14)
            make.right.equalTo(otherWayLab.snp.left).offset(-4)
            make.width.height.equalTo(12)
        }
        otherWayBtn.snp.makeConstraints { make in
            make.top.equalTo(otherWayLab.snp.bottom).offset(4)
            make.right.equalToSuperview().inset(16)
            make.width.equalTo(myWayBtn.snp.width)
            make.height.equalTo(40)
            make.left.equalTo(switchBtn.snp.right).offset(22)
        }

        switchBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(myWayBtn.snp.centerY)
            make.width.equalTo(40)
            make.height.equalTo(28)
        }
    }

    override func initData() {
        super.initData()
        switchBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            configLanguage(mySide: currentOtherSideLanguage, otherSide: currentMySideLanguage)
            updateLanguageType()
        }).disposed(by: disposeBag)

        myWayBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            currentBtnTag.toggle()
            updateLanguageType()
        }).disposed(by: disposeBag)

        otherWayBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            currentBtnTag.toggle()
            updateLanguageType()
        }).disposed(by: disposeBag)
    }

    private func updateLanguageType() {
        if currentBtnTag {
            currentLanguageType.accept(currentMySideLanguage)
        } else {
            currentLanguageType.accept(currentOtherSideLanguage)
        }
    }

    // MARK: - Public

    public let currentLanguageType = PublishRelay<TranslationLanguageType>()
    /// 配置语言
    /// - Parameters:
    ///   - mySide: 我方
    ///   - otherSide: 对方
    public func configLanguage(mySide: TranslationLanguageType, otherSide: TranslationLanguageType) {
        myWayBtn.setTitle(mySide.title(), for: .normal)
        otherWayBtn.setTitle(otherSide.title(), for: .normal)
        currentMySideLanguage = mySide
        currentOtherSideLanguage = otherSide
    }

    public func configLanguage(typeMode: TranslationLanguageType) {
        if currentBtnTag {
            myWayBtn.setTitle(typeMode.title(), for: .normal)
            currentMySideLanguage = typeMode
        } else {
            otherWayBtn.setTitle(typeMode.title(), for: .normal)
            currentOtherSideLanguage = typeMode
        }
    }

    public func configLanguageTitle(mySide: String, otherSide: String) {
        myWayLab.text = mySide
        otherWayLab.text = otherSide
    }

    public func configLanguageImage(_ mySideImage: UIImage, _ otherSideImage: UIImage) {
        myWayImgv.image = mySideImage
        otherWayImgv.image = otherSideImage
    }

    public func getSideLanguage() -> (TranslationLanguageType, TranslationLanguageType) {
        return (currentMySideLanguage, currentOtherSideLanguage)
    }
}
