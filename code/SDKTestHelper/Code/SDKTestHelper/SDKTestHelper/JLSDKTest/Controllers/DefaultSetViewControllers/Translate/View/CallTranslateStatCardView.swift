//
//  CallTranslateStatCardView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/8/19.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

/// 通话翻译统计卡片
///
/// 展示单侧（己方 / 对方）的输入音频、输出音频、TTS 输出、原文/译文文本字节统计，
/// 顶部显示当前编解码标签（JLA_V2 单声道 / Opus 立体声）。
class CallTranslateStatCardView: BaseView {

    // MARK: - UI

    private let titleLab = UILabel()
    private let codecLab = UILabel()
    private let inputLab = UILabel()
    private let outputLab = UILabel()
    private let ttsLab = UILabel()
    private let originTextLab = UILabel()
    private let translatedTextLab = UILabel()

    // MARK: - 初始化

    override init() {
        super.init()
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

        titleLab.font = .boldSystemFont(ofSize: 12)
        titleLab.textColor = .darkGray

        codecLab.font = .boldSystemFont(ofSize: 11)
        codecLab.textColor = .systemBlue

        [inputLab, outputLab, ttsLab, originTextLab, translatedTextLab].forEach { lab in
            lab.font = .systemFont(ofSize: 11)
            lab.textColor = .darkText
            lab.text = ""
        }

        let stack = UIStackView(arrangedSubviews: [titleLab, codecLab, inputLab, outputLab, ttsLab, originTextLab, translatedTextLab])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .fill
        stack.distribution = .fill
        addSubview(stack)

        stack.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    override func initData() {
        super.initData()
    }

    // MARK: - 数据绑定

    /// 绑定单侧数据模型
    /// - Parameters:
    ///   - model: 己方 / 对方 side model
    ///   - codecLabel: 当前编解码展示文本
    ///   - disposeBag: 页面 disposeBag
    func bind(to model: CallTranslateSideModel?, codecLabel: String, disposeBag: DisposeBag) {
        guard let model = model else {
            titleLab.text = ""
            codecLab.text = ""
            return
        }

        titleLab.text = "\(model.roleText) \(R.localStr.stats())"
        codecLab.text = "\(R.localStr.codec()): \(codecLabel)"

        // 输入音频同时展示字节与包数
        Observable.combineLatest(model.statsInputBytes, model.statsInputPackets) { bytes, packets in
            "\(R.localStr.inputAudio()): \(Self.formatBytes(bytes)) · \(packets) \(R.localStr.packets())"
        }
        .bind(to: inputLab.rx.text)
        .disposed(by: disposeBag)

        Observable.combineLatest(model.statsOutputBytes, model.statsOutputPackets) { bytes, packets in
            "\(R.localStr.outputAudio()): \(Self.formatBytes(bytes)) · \(packets) \(R.localStr.packets())"
        }
        .bind(to: outputLab.rx.text)
        .disposed(by: disposeBag)

        model.statsTtsOutputBytes
            .map { "\(R.localStr.ttsOutput()): \(Self.formatBytes($0))" }
            .bind(to: ttsLab.rx.text)
            .disposed(by: disposeBag)

        model.statsOriginTextBytes
            .map { "\(R.localStr.originTextBytes()): \(Self.formatBytes($0))" }
            .bind(to: originTextLab.rx.text)
            .disposed(by: disposeBag)

        model.statsTranslatedTextBytes
            .map { "\(R.localStr.translatedTextBytes()): \(Self.formatBytes($0))" }
            .bind(to: translatedTextLab.rx.text)
            .disposed(by: disposeBag)
    }

    // MARK: - 工具方法

    private static func formatBytes(_ bytes: Int) -> String {
        if bytes >= 1_048_576 {
            return String(format: "%.1f MB", Double(bytes) / 1_048_576.0)
        } else if bytes >= 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024.0)
        } else {
            return "\(bytes) B"
        }
    }
}
