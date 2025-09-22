//
//  InputView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/2/13.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

class InputView: BaseView {
    // 左侧标题
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .darkGray
        return label
    }()

    // 右侧输入框
    let textField: UITextField = {
        let field = UITextField()
        field.textColor = .darkGray
        field.backgroundColor = .white
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 16)
        field.keyboardType = .default
        field.returnKeyType = .done
        return field
    }()

    // 公开的输入内容 Observable
    var textObservable: RxSwift.Observable<String> {
        return textField.rx.text.orEmpty.asObservable()
    }

    override func initUI() {
        addSubview(titleLabel)
        addSubview(textField)

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(80) // 可调整宽度
        }

        textField.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }

        setupKeyboardHandling()
    }

    /// 配置输入框的标题
    func configure(title: String, placeholder: String, _ text: String? = nil) {
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.text = text
    }
    
    

    /// 监听键盘事件，自动调整视图
    private func setupKeyboardHandling() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let _ = scene.windows.first else { return }

        // 监听键盘弹出事件
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe(onNext: { [weak self] notification in
                guard let self = self,
                      let contextView = self.contextView,
                      let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

                // 计算控件底部位置
                let bottomY = self.frame.maxY
                let keyboardY = UIScreen.main.bounds.height - keyboardFrame.height
                if bottomY > keyboardY {
                    let offset = bottomY - keyboardY + 50
                    UIView.animate(withDuration: 0.3) {
                        contextView.view.transform = CGAffineTransform(translationX: 0, y: -offset)
                    }
                }
            })
            .disposed(by: disposeBag)

        // 监听键盘收起事件
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(onNext: { [weak self] _ in
                guard let contextView = self?.contextView else { return }
                UIView.animate(withDuration: 0.3) {
                    contextView.view.transform = .identity
                }
            })
            .disposed(by: disposeBag)

        // 点击空白区域收起键盘
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false // 关键：允许点击事件传递到子视图
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.endEditing(true) // 仅对当前视图收起键盘
            })
            .disposed(by: disposeBag)

        // 添加手势到当前视图，而非整个 window
        self.addGestureRecognizer(tapGesture)
    }
}
