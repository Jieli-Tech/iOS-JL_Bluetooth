//
//  CallTraTypeKeyBorad.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/22.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class CallTraTypeKeyBorad: BasicView, UITextFieldDelegate {
    let inputTxfd = CallInputTextField()
    let speakBtn = UIButton()
    let sendBtn = UIButton()
    private let lineView = UIView()

    // 防重复调整状态
    private var isKeyboardAdjusted = false
    private var appliedKeyboardOffset: CGFloat = 0
    private var originalTransform: CGAffineTransform = .identity

    override func initUI() {
        super.initUI()
        backgroundColor = .white
        lineView.backgroundColor = .eHex("#EBEBEB")

        inputTxfd.borderStyle = .roundedRect
        inputTxfd.backgroundColor = .eHex("#000000", alpha: 0.1)
        inputTxfd.textColor = .eHex("#000000", alpha: 0.9)
        inputTxfd.font = R.Font.regular(13)
        inputTxfd.layer.cornerRadius = 4
        inputTxfd.layer.masksToBounds = true
        inputTxfd.keyboardType = .default
        inputTxfd.returnKeyType = .send
        inputTxfd.tintColor = .eHex("#7657EC")
        inputTxfd.delegate = self
        inputTxfd.attributedPlaceholder = NSAttributedString(
            string: LanguageCls.localizableTxt("Enter text or switch to voice mode"),
            attributes: [
                .foregroundColor: UIColor.eHex("#9CA3AF"),
                .font: UIFont.systemFont(ofSize: 13), // 字体
            ]
        )
        speakBtn.setImage(R.Image.img("icon_talk"), for: .normal)
        sendBtn.setImage(R.Image.img("icon_send"), for: .normal)

        addSubview(lineView)
        addSubview(inputTxfd)
        addSubview(speakBtn)
        addSubview(sendBtn)

        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalToSuperview()
        }

        inputTxfd.snp.makeConstraints { make in
            make.left.equalTo(speakBtn.snp.right).offset(10)
            make.right.equalTo(sendBtn.snp.left).offset(-10)
            make.height.equalTo(36)
            make.top.equalTo(lineView.snp.bottom).offset(14)
        }
        speakBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalTo(inputTxfd)
            make.height.width.equalTo(32)
        }
        sendBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.height.width.equalTo(32)
            make.centerY.equalTo(inputTxfd)
        }

        setupKeyboardHandling()
    }

    override func initData() {
        super.initData()

        speakBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            inputTxfd.resignFirstResponder()
            self.isHidden = true
            guard let vc = contextView as? CallTranslationVC else { return }
            vc.bottomSpeakView.isHidden = false
        }).disposed(by: disposeBag)
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        sendBtn.sendActions(for: .touchUpInside)
        return false
    }

    /// 监听键盘事件，自动调整视图
    private func setupKeyboardHandling() {
        // 监听键盘弹出事件
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let self = self,
                      let contextView = self.contextView,
                      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

                // 计算控件底部位置
                let bottomY = self.frame.maxY
                let keyboardY = UIScreen.main.bounds.height - keyboardFrame.height
                let safeBottom = (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
                if bottomY > keyboardY {
                    let offset = bottomY - keyboardY - safeBottom + 14
                    let delta = abs(offset - self.appliedKeyboardOffset)

                    // 第一次调整记录原始 transform
                    if !self.isKeyboardAdjusted { self.originalTransform = contextView.view.transform }

                    // 仅当未调整过或偏移变化较大时才执行动画，避免重复调整
                    if !self.isKeyboardAdjusted || delta > 0.5 {
                        UIView.animate(withDuration: 0.3) {
                            contextView.view.transform = self.originalTransform.translatedBy(x: 0, y: -offset)
                        }
                        self.isKeyboardAdjusted = true
                        self.appliedKeyboardOffset = offset
                    }
                }
            })
            .disposed(by: disposeBag)

        // 监听键盘收起事件
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, let contextView = self.contextView else { return }
                // 仅当之前有过键盘调整时才恢复，避免重复恢复导致 UI 异常
                if self.isKeyboardAdjusted {
                    UIView.animate(withDuration: 0.3) {
                        contextView.view.transform = self.originalTransform
                    }
                    self.isKeyboardAdjusted = false
                    self.appliedKeyboardOffset = 0
                    self.originalTransform = .identity
                }
            })
            .disposed(by: disposeBag)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

class CallInputTextField: UITextField {
    var textPadding = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textPadding)
    }
}
