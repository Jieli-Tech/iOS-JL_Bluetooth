//
//  SyncPlayBackView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/8/5.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation
import SwiftyAttributes

class SyncPlayBackView: BasicView {
    let originalLab = UILabel()
    let translateLab = UILabel()
    private let mainView = UIView()

    // 句子分段范围（与 dbList 顺序一致）
    private var originalSegments: [NSRange] = []
    private var translateSegments: [NSRange] = []

    // 点击回调（返回句子索引）
    var onOriginalSentenceTap: ((Int) -> Void)?
    var onTranslateSentenceTap: ((Int) -> Void)?

    // 高亮与默认颜色
    private let highlightColor = UIColor.eHex("#F89514")
    private let originalDefaultColor = UIColor.eHex("#000000", alpha: 0.9)
    private let translateDefaultColor = UIColor.eHex("#000000", alpha: 0.5)

    override func initUI() {
        backgroundColor = .clear
        mainView.backgroundColor = .eHex("#F3F4F6")
        mainView.layer.cornerRadius = 8
        mainView.layer.masksToBounds = true

        originalLab.textColor = originalDefaultColor
        originalLab.numberOfLines = 0
        originalLab.font = R.Font.medium(14)
        originalLab.isUserInteractionEnabled = true

        translateLab.textColor = translateDefaultColor
        translateLab.numberOfLines = 0
        translateLab.font = R.Font.medium(14)
        translateLab.isUserInteractionEnabled = true

        addSubview(mainView)
        mainView.addSubview(originalLab)
        mainView.addSubview(translateLab)

        mainView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(8)
        }

        originalLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(translateLab.snp.top).offset(-8)
        }

        translateLab.snp.makeConstraints { make in
            make.top.equalTo(originalLab.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }

        // 添加点击手势
        let oTap = UITapGestureRecognizer(target: self, action: #selector(handleTapOriginal(_:)))
        originalLab.addGestureRecognizer(oTap)
        let tTap = UITapGestureRecognizer(target: self, action: #selector(handleTapTranslate(_:)))
        translateLab.addGestureRecognizer(tTap)
    }

    // 配置句子分段范围（VC 依据 VM 的 dbList 传入）
    func configureSegments(originalSegments: [NSRange], translateSegments: [NSRange]) {
        self.originalSegments = originalSegments
        self.translateSegments = translateSegments
    }

    // 根据点击坐标计算字符索引
    private func characterIndex(in label: UILabel, at point: CGPoint) -> Int? {
        let attributedText: NSAttributedString
        if let att = label.attributedText {
            attributedText = att
        } else if let text = label.text, let font = label.font {
            attributedText = NSAttributedString(string: text, attributes: [
                .font: font,
                .foregroundColor: label.textColor ?? UIColor.black,
            ])
        } else {
            return nil
        }

        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // UILabel 的文本通常从左上角开始绘制，这里直接使用点击点
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        let charIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        return charIndex
    }

    @objc private func handleTapOriginal(_ gr: UITapGestureRecognizer) {
        let point = gr.location(in: originalLab)
        guard let charIndex = characterIndex(in: originalLab, at: point) else { return }
        for (idx, range) in originalSegments.enumerated() {
            if NSLocationInRange(charIndex, range) {
                onOriginalSentenceTap?(idx)
                // 同步更新原文与译文的高亮
                highlightSentence(at: idx)
                return
            }
        }
    }

    @objc private func handleTapTranslate(_ gr: UITapGestureRecognizer) {
        let point = gr.location(in: translateLab)
        guard let charIndex = characterIndex(in: translateLab, at: point) else { return }
        for (idx, range) in translateSegments.enumerated() {
            if NSLocationInRange(charIndex, range) {
                onTranslateSentenceTap?(idx)
                // 同步更新原文与译文的高亮
                highlightSentence(at: idx)
                return
            }
        }
    }

    // 同步高亮指定索引的原文与译文
    func highlightSentence(at index: Int) {
        if let text = originalLab.text, let font = originalLab.font, index >= 0, index < originalSegments.count {
            let attr = NSMutableAttributedString(string: text, attributes: [
                .font: font,
                .foregroundColor: originalDefaultColor,
            ])
            let range = originalSegments[index]
            if range.location >= 0 && NSMaxRange(range) <= (text as NSString).length {
                attr.addAttributes([
                    .foregroundColor: highlightColor,
                ], range: range)
            }
            originalLab.attributedText = attr
        }
        if let text = translateLab.text, let font = translateLab.font, index >= 0, index < translateSegments.count {
            let attr = NSMutableAttributedString(string: text, attributes: [
                .font: font,
                .foregroundColor: translateDefaultColor,
            ])
            let range = translateSegments[index]
            if range.location >= 0 && NSMaxRange(range) <= (text as NSString).length {
                attr.addAttributes([
                    .foregroundColor: highlightColor,
                ], range: range)
            }
            translateLab.attributedText = attr
        }
    }

    func currentHightText(_ text: String, translateText: String) {
        if text.count == 0 || translateText.count == 0 { return }
        guard let originArrays = originalLab.text?.components(separatedBy: text) else { return }
        guard let translateArrays = translateLab.text?.components(separatedBy: translateText) else { return }
        if originArrays.count == 2 {
            let att = originArrays[0].withFont(R.Font.medium(14)).withTextColor(originalDefaultColor) + text.withFont(R.Font.medium(14)).withTextColor(highlightColor) + originArrays[1].withFont(R.Font.medium(14)).withTextColor(originalDefaultColor)
            originalLab.attributedText = att
        }
        if originArrays.count == 1 {
            let att = text.withFont(R.Font.medium(14)).withTextColor(highlightColor) + originArrays[0].withFont(R.Font.medium(14)).withTextColor(originalDefaultColor)
            originalLab.attributedText = att
        }

        if translateArrays.count == 2 {
            let att = translateArrays[0].withFont(R.Font.medium(14)).withTextColor(translateDefaultColor) + translateText.withFont(R.Font.medium(14)).withTextColor(highlightColor) + translateArrays[1].withFont(R.Font.medium(14)).withTextColor(translateDefaultColor)
            translateLab.attributedText = att
        }

        if translateArrays.count == 1 {
            let att = text.withFont(R.Font.medium(14)).withTextColor(highlightColor) + translateArrays[0].withFont(R.Font.medium(14)).withTextColor(translateDefaultColor)
            translateLab.attributedText = att
        }
    }
}
