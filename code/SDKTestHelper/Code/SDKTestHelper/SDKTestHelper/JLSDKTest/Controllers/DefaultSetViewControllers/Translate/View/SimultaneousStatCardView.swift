//
//  SimultaneousStatCardView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/7/8.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

/// 面对面翻译（左耳+右耳）统计卡片 View
/// 显示单路的 Opus 收发数量及字节数
class SimultaneousStatCardView: BaseView {

    // MARK: - UI

    private let titleLab = UILabel()
    private let sentCountLab = UILabel()
    private let receivedCountLab = UILabel()
    private let sentBytesLab = UILabel()
    private let receivedBytesLab = UILabel()

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

        titleLab.text = "\(role) 统计"
        titleLab.font = .boldSystemFont(ofSize: 12)
        titleLab.textColor = .darkGray

        sentCountLab.font = .systemFont(ofSize: 11)
        sentCountLab.textColor = .darkText
        sentCountLab.text = "Opus 发出: 0"

        receivedCountLab.font = .systemFont(ofSize: 11)
        receivedCountLab.textColor = .darkText
        receivedCountLab.text = "Opus 收到: 0"

        sentBytesLab.font = .systemFont(ofSize: 11)
        sentBytesLab.textColor = .darkText
        sentBytesLab.text = "发出字节: 0"

        receivedBytesLab.font = .systemFont(ofSize: 11)
        receivedBytesLab.textColor = .darkText
        receivedBytesLab.text = "收到字节: 0"

        addSubview(titleLab)
        addSubview(sentCountLab)
        addSubview(receivedCountLab)
        addSubview(sentBytesLab)
        addSubview(receivedBytesLab)

        titleLab.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(8)
        }

        sentCountLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().inset(8)
        }

        receivedCountLab.snp.makeConstraints { make in
            make.top.equalTo(sentCountLab.snp.bottom).offset(2)
            make.left.right.equalTo(sentCountLab)
        }

        sentBytesLab.snp.makeConstraints { make in
            make.top.equalTo(receivedCountLab.snp.bottom).offset(2)
            make.left.right.equalTo(sentCountLab)
        }

        receivedBytesLab.snp.makeConstraints { make in
            make.top.equalTo(sentBytesLab.snp.bottom).offset(2)
            make.left.right.equalTo(sentCountLab)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    override func initData() {
        super.initData()
    }

    // MARK: - 数据绑定

    /// 绑定 Processor 的统计数据
    func bind(to processor: SimultaneousTranslationProcessor?, disposeBag: DisposeBag) {
        guard let processor = processor else { return }

        processor.statsOpusSent
            .map { "Opus 发出: \($0)" }
            .bind(to: sentCountLab.rx.text)
            .disposed(by: disposeBag)

        processor.statsOpusReceived
            .map { "Opus 收到: \($0)" }
            .bind(to: receivedCountLab.rx.text)
            .disposed(by: disposeBag)

        processor.statsOpusSentBytes
            .map { "发出字节: \(Self.formatBytes($0))" }
            .bind(to: sentBytesLab.rx.text)
            .disposed(by: disposeBag)

        processor.statsOpusReceivedBytes
            .map { "收到字节: \(Self.formatBytes($0))" }
            .bind(to: receivedBytesLab.rx.text)
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
