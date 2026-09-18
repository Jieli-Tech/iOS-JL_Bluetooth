//
//  SimultaneousDetailViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/7/8.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JL_BLEKit

/// 面对面翻译（左耳+右耳）详情页
///
/// 实时展示左耳/右耳两路的原文、译文、统计数据与 TTS 处理状态。
/// 退出页面时自动退出面对面翻译（左耳+右耳）模式。
class SimultaneousDetailViewController: BaseViewController {

    // MARK: - UI

    private let contentScrollView = UIScrollView()
    private let contentView = UIView()

    /// 左耳/右耳转录区域（根据设备 location 动态确定）
    private let masterTranscriptionView: SimultaneousTranscriptionView
    private let slaveTranscriptionView: SimultaneousTranscriptionView

    /// 左耳/右耳统计卡片
    private let masterStatCard: SimultaneousStatCardView
    private let slaveStatCard: SimultaneousStatCardView

    /// 全局统计卡片
    private let globalStatView = UIView()
    private let globalTitleLab = UILabel()
    private let globalOpusReceivedLab = UILabel()
    private let globalPcmDecodedLab = UILabel()
    private let globalTranslatedLab = UILabel()
    private let globalTtsOutputLab = UILabel()
    private let globalOpusSentLab = UILabel()

    /// TTS 当前处理文本
    private let masterTtsTitleLab = UILabel()
    private let masterTtsTextLab = UILabel()
    private let slaveTtsTitleLab = UILabel()
    private let slaveTtsTextLab = UILabel()

    // MARK: - 耳标签（根据设备 location 动态确定）

    private let masterEarLabel: String
    private let slaveEarLabel: String

    // MARK: - 生命周期

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let labels = Self.computeEarLabels()
        self.masterEarLabel = labels.master
        self.slaveEarLabel = labels.slave
        self.masterTranscriptionView = SimultaneousTranscriptionView(role: labels.master)
        self.slaveTranscriptionView = SimultaneousTranscriptionView(role: labels.slave)
        self.masterStatCard = SimultaneousStatCardView(role: labels.master)
        self.slaveStatCard = SimultaneousStatCardView(role: labels.slave)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        let labels = Self.computeEarLabels()
        self.masterEarLabel = labels.master
        self.slaveEarLabel = labels.slave
        self.masterTranscriptionView = SimultaneousTranscriptionView(role: labels.master)
        self.slaveTranscriptionView = SimultaneousTranscriptionView(role: labels.slave)
        self.masterStatCard = SimultaneousStatCardView(role: labels.master)
        self.slaveStatCard = SimultaneousStatCardView(role: labels.slave)
        super.init(coder: coder)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 页面退出 → 退出面对面翻译（左耳+右耳）模式
        let state = TranslateVM.shared.simultaneousState.value
        if state == .working || state == .entering {
            TranslateVM.shared.exitSimultaneousMode { }
        }
    }

    // MARK: - UI 初始化

    override func initUI() {
        navigationView.title = "面对面翻译（左耳+右耳）详情"
        navigationView.leftBtn.setTitle("退出翻译", for: .normal)
        navigationView.leftBtn.isHidden = false

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)

        contentScrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentScrollView.contentLayoutGuide)
            make.width.equalTo(contentScrollView.frameLayoutGuide)
        }

        // 左右并排：左耳 / 右耳转录区域
        let transcriptionRow = UIView()
        contentView.addSubview(transcriptionRow)
        transcriptionRow.addSubview(masterTranscriptionView)
        transcriptionRow.addSubview(slaveTranscriptionView)

        transcriptionRow.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(260)
        }

        masterTranscriptionView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(slaveTranscriptionView)
        }

        slaveTranscriptionView.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(masterTranscriptionView.snp.right).offset(8)
        }

        // 统计卡片：左右并排
        let statRow = UIView()
        contentView.addSubview(statRow)
        statRow.addSubview(masterStatCard)
        statRow.addSubview(slaveStatCard)

        statRow.snp.makeConstraints { make in
            make.top.equalTo(transcriptionRow.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
        }

        masterStatCard.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(slaveStatCard)
        }

        slaveStatCard.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(masterStatCard.snp.right).offset(8)
        }

        // 全局统计卡片
        setupGlobalStatView()

        // TTS 当前处理文本
        contentView.addSubview(masterTtsTitleLab)
        contentView.addSubview(masterTtsTextLab)
        contentView.addSubview(slaveTtsTitleLab)
        contentView.addSubview(slaveTtsTextLab)

        masterTtsTitleLab.font = .boldSystemFont(ofSize: 12)
        masterTtsTitleLab.textColor = .darkGray
        masterTtsTitleLab.text = "🔄 \(masterEarLabel)正在翻译:"

        masterTtsTextLab.font = .systemFont(ofSize: 12)
        masterTtsTextLab.textColor = .systemBlue
        masterTtsTextLab.numberOfLines = 0

        slaveTtsTitleLab.font = .boldSystemFont(ofSize: 12)
        slaveTtsTitleLab.textColor = .darkGray
        slaveTtsTitleLab.text = "🔄 \(slaveEarLabel)正在翻译:"

        slaveTtsTextLab.font = .systemFont(ofSize: 12)
        slaveTtsTextLab.textColor = .systemBlue
        slaveTtsTextLab.numberOfLines = 0

        masterTtsTitleLab.snp.makeConstraints { make in
            make.top.equalTo(globalStatView.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(12)
        }

        masterTtsTextLab.snp.makeConstraints { make in
            make.top.equalTo(masterTtsTitleLab.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(12)
        }

        slaveTtsTitleLab.snp.makeConstraints { make in
            make.top.equalTo(masterTtsTextLab.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(12)
        }

        slaveTtsTextLab.snp.makeConstraints { make in
            make.top.equalTo(slaveTtsTitleLab.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(20)
        }
    }

    private func setupGlobalStatView() {
        globalStatView.backgroundColor = UIColor.eHex("#FFFFFF")
        globalStatView.layer.cornerRadius = 8
        globalStatView.layer.borderWidth = 1
        globalStatView.layer.borderColor = UIColor.eHex("#E0E0E0").cgColor

        contentView.addSubview(globalStatView)

        globalTitleLab.text = "📊 全局统计 (\(masterEarLabel) + \(slaveEarLabel))"
        globalTitleLab.font = .boldSystemFont(ofSize: 12)
        globalTitleLab.textColor = .darkGray

        let labels = [
            globalOpusReceivedLab,
            globalPcmDecodedLab,
            globalTranslatedLab,
            globalTtsOutputLab,
            globalOpusSentLab
        ]
        labels.forEach { lab in
            lab.font = .systemFont(ofSize: 11)
            lab.textColor = .darkText
        }

        globalOpusReceivedLab.text = "收到编码数据: 0 B"
        globalPcmDecodedLab.text = "解码 PCM: 0 B"
        globalTranslatedLab.text = "译文文本: 0 B"
        globalTtsOutputLab.text = "TTS 输出: 0 B"
        globalOpusSentLab.text = "发出编码数据: 0 B"

        globalStatView.addSubview(globalTitleLab)
        globalStatView.addSubview(globalOpusReceivedLab)
        globalStatView.addSubview(globalPcmDecodedLab)
        globalStatView.addSubview(globalTranslatedLab)
        globalStatView.addSubview(globalTtsOutputLab)
        globalStatView.addSubview(globalOpusSentLab)

        globalStatView.snp.makeConstraints { make in
            make.top.equalTo(masterStatCard.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
        }

        globalTitleLab.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(8)
        }

        globalOpusReceivedLab.snp.makeConstraints { make in
            make.top.equalTo(globalTitleLab.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview().inset(8)
        }

        globalPcmDecodedLab.snp.makeConstraints { make in
            make.top.equalTo(globalOpusReceivedLab.snp.bottom).offset(2)
            make.left.right.equalTo(globalOpusReceivedLab)
        }

        globalTranslatedLab.snp.makeConstraints { make in
            make.top.equalTo(globalPcmDecodedLab.snp.bottom).offset(2)
            make.left.right.equalTo(globalOpusReceivedLab)
        }

        globalTtsOutputLab.snp.makeConstraints { make in
            make.top.equalTo(globalTranslatedLab.snp.bottom).offset(2)
            make.left.right.equalTo(globalOpusReceivedLab)
        }

        globalOpusSentLab.snp.makeConstraints { make in
            make.top.equalTo(globalTtsOutputLab.snp.bottom).offset(2)
            make.left.right.equalTo(globalOpusReceivedLab)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    // MARK: - 数据绑定

    override func initData() {
        super.initData()

        // 退出按钮
        navigationView.leftBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                TranslateVM.shared.exitSimultaneousMode { }
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        // 监听面对面翻译（左耳+右耳）状态，自动 pop
        TranslateVM.shared.simultaneousState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .idle:
                    self?.navigationController?.popViewController(animated: true)
                case .error(let msg):
                    self?.view.makeToast("面对面翻译（左耳+右耳）错误: \(msg)", position: .center)
                    self?.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        guard let master = TranslateVM.shared.masterProcessor,
              let slave = TranslateVM.shared.slaveProcessor else {
            return
        }

        // 设置语言方向标签（根据设备实际左右耳归属自动匹配预设译向）
        let masterPair = TranslateVM.shared.simultaneousLanguagePair(forMaster: true)
        let slavePair = TranslateVM.shared.simultaneousLanguagePair(forMaster: false)
        masterTranscriptionView.setLangDirection(
            langDisplay(masterPair.source),
            langDisplay(masterPair.target)
        )
        slaveTranscriptionView.setLangDirection(
            langDisplay(slavePair.source),
            langDisplay(slavePair.target)
        )

        // 主机 — 原文 / 译文
        master.originSubtitleText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.masterTranscriptionView.appendOriginText(text)
            })
            .disposed(by: disposeBag)

        master.translatedSubtitleText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.masterTranscriptionView.appendTranslatedText(text)
            })
            .disposed(by: disposeBag)

        // 主机 — 流式中间结果
        master.originStreamingText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.masterTranscriptionView.showStreamingText(text)
            })
            .disposed(by: disposeBag)

        // 从机 — 原文 / 译文
        slave.originSubtitleText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.slaveTranscriptionView.appendOriginText(text)
            })
            .disposed(by: disposeBag)

        slave.translatedSubtitleText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.slaveTranscriptionView.appendTranslatedText(text)
            })
            .disposed(by: disposeBag)

        // 从机 — 流式中间结果
        slave.originStreamingText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.slaveTranscriptionView.showStreamingText(text)
            })
            .disposed(by: disposeBag)

        // 统计卡片绑定
        masterStatCard.bind(to: master, disposeBag: disposeBag)
        slaveStatCard.bind(to: slave, disposeBag: disposeBag)

        // 全局统计：合并主机 + 从机
        Observable.combineLatest(
            master.statsOpusReceivedBytes,
            slave.statsOpusReceivedBytes
        ) { $0 + $1 }
        .map { "收到编码数据: \(Self.formatBytes($0))" }
        .observe(on: MainScheduler.instance)
        .bind(to: globalOpusReceivedLab.rx.text)
        .disposed(by: disposeBag)

        Observable.combineLatest(
            master.statsPcmDecodedBytes,
            slave.statsPcmDecodedBytes
        ) { $0 + $1 }
        .map { "解码 PCM: \(Self.formatBytes($0))" }
        .observe(on: MainScheduler.instance)
        .bind(to: globalPcmDecodedLab.rx.text)
        .disposed(by: disposeBag)

        Observable.combineLatest(
            master.statsTranslatedTextBytes,
            slave.statsTranslatedTextBytes
        ) { $0 + $1 }
        .map { "译文文本: \(Self.formatBytes($0))" }
        .observe(on: MainScheduler.instance)
        .bind(to: globalTranslatedLab.rx.text)
        .disposed(by: disposeBag)

        Observable.combineLatest(
            master.statsTtsOutputBytes,
            slave.statsTtsOutputBytes
        ) { $0 + $1 }
        .map { "TTS 输出: \(Self.formatBytes($0))" }
        .observe(on: MainScheduler.instance)
        .bind(to: globalTtsOutputLab.rx.text)
        .disposed(by: disposeBag)

        Observable.combineLatest(
            master.statsOpusSentBytes,
            slave.statsOpusSentBytes
        ) { $0 + $1 }
        .map { "发出编码数据: \(Self.formatBytes($0))" }
        .observe(on: MainScheduler.instance)
        .bind(to: globalOpusSentLab.rx.text)
        .disposed(by: disposeBag)

        // TTS 当前文本
        master.currentTtsText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(to: masterTtsTextLab.rx.text)
            .disposed(by: disposeBag)

        slave.currentTtsText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(to: slaveTtsTextLab.rx.text)
            .disposed(by: disposeBag)

        // 同步滚动：KVO 监听 contentOffset
        setupScrollSync()
    }

    private func setupScrollSync() {
        var syncing = false
        let masterTV = masterTranscriptionView.textView
        let slaveTV = slaveTranscriptionView.textView

        masterTV.rx.observe(CGPoint.self, "contentOffset")
            .filter { _ in !syncing }
            .subscribe(onNext: { offset in
                guard let offset = offset, slaveTV.contentOffset != offset else { return }
                syncing = true
                slaveTV.contentOffset = offset
                syncing = false
            })
            .disposed(by: disposeBag)

        slaveTV.rx.observe(CGPoint.self, "contentOffset")
            .filter { _ in !syncing }
            .subscribe(onNext: { offset in
                guard let offset = offset, masterTV.contentOffset != offset else { return }
                syncing = true
                masterTV.contentOffset = offset
                syncing = false
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 工具方法

    /// 根据设备 location 计算左右耳标签
    private static func computeEarLabels() -> (master: String, slave: String) {
        let helper = TranslateVM.shared.translateHelper
        let masterLoc = helper?.masterDevice?.location ?? .unknown
        let slaveLoc = helper?.slaveDevice?.location ?? .unknown
        JLLogManager.logLevel(.DEBUG, content: "Translate Log masterLoc: \(masterLoc), slaveLoc: \(slaveLoc)")
        return (earLabel(masterLoc, fallback: "主机"), earLabel(slaveLoc, fallback: "从机"))
    }

    private static func earLabel(_ loc: JLTranslateTWSLocation, fallback: String) -> String {
        switch loc {
        case .left: return "左耳"
        case .right: return "右耳"
        default: return fallback
        }
    }

    private static func formatBytes(_ bytes: Int) -> String {
        if bytes >= 1_048_576 {
            return String(format: "%.1f MB", Double(bytes) / 1_048_576.0)
        } else if bytes >= 1024 {
            return String(format: "%.1f KB", Double(bytes) / 1024.0)
        } else {
            return "\(bytes) B"
        }
    }

    private func langDisplay(_ lang: TranslateLanguage) -> String {
        switch lang {
        case .zh: return "中文"
        case .en: return "English"
        case .ja: return "日文"
        }
    }
}
