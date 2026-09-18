//
//  SimultaneousTranscriptionView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/7/8.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

/// 面对面翻译（左耳+右耳）原文/译文展示 View
/// 内部包含一个只读 UITextView（最终确定的文本）和一个流式文本标签（实时中间结果）
class SimultaneousTranscriptionView: BaseView {

    // MARK: - UI

    private let roleLab = UILabel()
    private let langDirectionLab = UILabel()
    let textView = UITextView()
    let streamingLab = UILabel()

    // MARK: - 配置

    private let role: String

    // MARK: - 初始化

    init(role: String) {
        self.role = role
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 布局

    override func initUI() {
        backgroundColor = UIColor.eHex("#FFFFFF")
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.eHex("#E0E0E0").cgColor

        roleLab.text = role
        roleLab.font = .boldSystemFont(ofSize: 13)
        roleLab.textColor = .darkGray
        roleLab.textAlignment = .center

        langDirectionLab.font = .systemFont(ofSize: 11)
        langDirectionLab.textColor = .gray
        langDirectionLab.textAlignment = .center
        langDirectionLab.text = ""

        streamingLab.font = .italicSystemFont(ofSize: 10)
        streamingLab.textColor = .systemOrange
        streamingLab.numberOfLines = 2
        streamingLab.text = ""

        textView.isEditable = false
        textView.isSelectable = true
        textView.font = .systemFont(ofSize: 11)
        textView.textColor = .darkText
        textView.backgroundColor = UIColor.eHex("#FAFAFA")
        textView.layer.cornerRadius = 4
        textView.textContainerInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        textView.text = ""

        addSubview(roleLab)
        addSubview(langDirectionLab)
        addSubview(streamingLab)
        addSubview(textView)

        roleLab.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.right.equalToSuperview().inset(6)
        }

        langDirectionLab.snp.makeConstraints { make in
            make.top.equalTo(roleLab.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(6)
        }

        streamingLab.snp.makeConstraints { make in
            make.top.equalTo(langDirectionLab.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(4)
            make.height.equalTo(16)
        }

        textView.snp.makeConstraints { make in
            make.top.equalTo(streamingLab.snp.bottom).offset(2)
            make.left.right.bottom.equalToSuperview().inset(4)
        }
    }

    override func initData() {
        super.initData()
    }

    // MARK: - 公共方法

    /// 设置语言方向标签 (如 "中文 → 英文")
    func setLangDirection(_ origin: String, _ target: String) {
        langDirectionLab.text = "\(origin) → \(target)"
    }

    /// 显示流式中间结果（实时更新，最终文本到达后被覆盖/清空）
    func showStreamingText(_ text: String) {
        streamingLab.text = text
        streamingLab.isHidden = text.isEmpty
    }

    /// 追加最终确定原文行（同时清空流式文本）
    func appendOriginText(_ text: String) {
        guard !text.isEmpty else { return }
        streamingLab.text = ""
        streamingLab.isHidden = true
        appendLine("📝 \(text)", scrollToBottom: true)
    }

    /// 追加最终确定译文行（同时清空流式文本）
    func appendTranslatedText(_ text: String) {
        guard !text.isEmpty else { return }
        streamingLab.text = ""
        streamingLab.isHidden = true
        appendLine("🌐 \(text)", scrollToBottom: true)
    }

    // MARK: - 内部方法

    private func appendLine(_ line: String, scrollToBottom: Bool) {
        let currentText = textView.text ?? ""
        let newText = currentText.isEmpty ? line : currentText + "\n" + line
        textView.text = newText

        // 限制最大行数，超过 1000 行裁剪旧内容
        let lines = newText.components(separatedBy: "\n")
        if lines.count > 1000 {
            let trimmed = lines.suffix(500).joined(separator: "\n")
            textView.text = trimmed
        }

        guard scrollToBottom else { return }
        let range = NSRange(location: (textView.text as NSString).length - 1, length: 1)
        textView.scrollRangeToVisible(range)
    }
}
