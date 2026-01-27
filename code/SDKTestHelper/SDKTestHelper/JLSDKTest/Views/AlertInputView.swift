//
//  AlertInputView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/6.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class AlertInputView {
    
    /// 单输入框弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - placeholder: 输入框占位符
    ///   - keyboardType: 键盘类型
    ///   - isSecure: 是否安全输入（密码）
    ///   - inputText: 默认文本
    ///   - confirmTitle: 确认按钮标题
    ///   - cancelTitle: 取消按钮标题
    ///   - controller: 呈现的ViewController
    ///   - completion: 完成回调（返回输入文本）
    static func showSingleInput(
        title: String?,
        message: String?,
        placeholder: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        inputText: String = "",
        confirmTitle: String = R.localStr.confirm(),
        cancelTitle: String? = R.localStr.cancel(),
        in controller: UIViewController,
        completion: @escaping (String?) -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.keyboardType = keyboardType
            textField.isSecureTextEntry = isSecure
            textField.text = inputText
        }
        
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            completion(alert.textFields?.first?.text)
        }
        alert.addAction(confirmAction)
        
        if let cancelTitle = cancelTitle {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
            alert.addAction(cancelAction)
        }
        
        controller.present(alert, animated: true)
    }
    
    /// 多输入框弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - inputs: 输入框配置数组
    ///   - confirmTitle: 确认按钮标题
    ///   - cancelTitle: 取消按钮标题
    ///   - controller: 呈现的ViewController
    ///   - completion: 完成回调（返回输入文本数组）
    static func showMultipleInputs(
        title: String?,
        message: String?,
        inputs: [InputConfig],
        confirmTitle: String = R.localStr.confirm(),
        cancelTitle: String? = R.localStr.cancel(),
        in controller: UIViewController,
        completion: @escaping ([String?]) -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        inputs.forEach { config in
            alert.addTextField { textField in
                textField.placeholder = config.placeholder
                textField.keyboardType = config.keyboardType
                textField.isSecureTextEntry = config.isSecure
                textField.text = config.defaultText
            }
        }
        
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            let texts = alert.textFields?.map { $0.text }
            completion(texts ?? [])
        }
        alert.addAction(confirmAction)
        
        if let cancelTitle = cancelTitle {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
            alert.addAction(cancelAction)
        }
        
        controller.present(alert, animated: true)
    }
    
    /// 带验证的输入框弹窗
    /// - Parameters:
    ///   - title: 标题
    ///   - message: 消息
    ///   - placeholder: 输入框占位符
    ///   - keyboardType: 键盘类型
    ///   - isSecure: 是否安全输入
    ///   - confirmTitle: 确认按钮标题
    ///   - cancelTitle: 取消按钮标题
    ///   - controller: 呈现的ViewController
    ///   - validation: 输入验证闭包
    ///   - completion: 完成回调
    static func showValidatedInput(
        title: String?,
        message: String?,
        placeholder: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        confirmTitle: String = R.localStr.confirm(),
        cancelTitle: String? = R.localStr.cancel(),
        in controller: UIViewController,
        validation: @escaping (String?) -> Bool,
        completion: @escaping (String?) -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.keyboardType = keyboardType
            textField.isSecureTextEntry = isSecure
        }
        
        let confirmAction = UIAlertAction(title: confirmTitle, style: .default) { _ in
            completion(alert.textFields?.first?.text)
        }
        confirmAction.isEnabled = false
        alert.addAction(confirmAction)
        
        if let cancelTitle = cancelTitle {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel)
            alert.addAction(cancelAction)
        }
        
        // 添加文本变化监听
        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: alert.textFields?.first,
            queue: OperationQueue.main
        ) { _ in
            if let text = alert.textFields?.first?.text {
                confirmAction.isEnabled = validation(text)
            }
        }
        
        controller.present(alert, animated: true)
    }
    
    // 输入框配置模型
    struct InputConfig {
        let placeholder: String?
        let keyboardType: UIKeyboardType
        let isSecure: Bool
        let defaultText: String?
        
        init(
            placeholder: String? = nil,
            keyboardType: UIKeyboardType = .default,
            isSecure: Bool = false,
            defaultText: String? = nil
        ) {
            self.placeholder = placeholder
            self.keyboardType = keyboardType
            self.isSecure = isSecure
            self.defaultText = defaultText
        }
    }
}
