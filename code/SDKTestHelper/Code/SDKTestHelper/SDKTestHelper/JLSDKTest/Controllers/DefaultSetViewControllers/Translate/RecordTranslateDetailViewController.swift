//
//  RecordTranslateDetailViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/8/19.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JL_BLEKit

/// 录音翻译详情页
///
/// 顶部展示录音策略 / 音频类型 / 语言方向等状态；
/// 中部以原文 / 译文左右两栏展示并同步滚动；
/// 底部展示统计卡片。
class RecordTranslateDetailViewController: BaseViewController {

    // MARK: - UI

    private let contentScrollView = UIScrollView()
    private let contentView = UIView()

    // 原文 / 译文左右两栏
    private let originView = SimultaneousTranscriptionView(role: R.localStr.originText())
    private let translatedView = SimultaneousTranscriptionView(role: R.localStr.translatedText())

    // 统计卡片
    private let statCard = CallTranslateStatCardView()

    // 顶部状态卡
    private let statusCardView = UIView()
    private let statusTitleLab = UILabel()
    private let modeLab = UILabel()
    private let policyLab = UILabel()
    private let audioTypeLab = UILabel()
    private let channelLab = UILabel()
    private let sampleRateLab = UILabel()
    private let langLab = UILabel()

    // TTS 当前文本
    private let ttsTitleLab = UILabel()
    private let ttsTextLab = UILabel()

    // MARK: - 生命周期

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let state = TranslateVM.shared.recordTranslateState.value
        if state == .working || state == .entering {
            TranslateVM.shared.exitRecordTranslateMode { }
        }
    }

    // MARK: - UI 初始化

    override func initUI() {
        navigationView.title = R.localStr.recordTranslateDetailTitle()
        navigationView.leftBtn.setTitle(R.localStr.exitTranslate(), for: .normal)
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

        setupStatusCard()

        // 原文 / 译文 左右并排
        let textRow = UIView()
        contentView.addSubview(textRow)
        textRow.addSubview(originView)
        textRow.addSubview(translatedView)

        textRow.snp.makeConstraints { make in
            make.top.equalTo(statusCardView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(280)
        }

        originView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(translatedView)
        }

        translatedView.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(originView.snp.right).offset(8)
        }

        // 统计卡片
        contentView.addSubview(statCard)
        statCard.snp.makeConstraints { make in
            make.top.equalTo(textRow.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
        }

        // TTS 当前文本
        contentView.addSubview(ttsTitleLab)
        contentView.addSubview(ttsTextLab)

        ttsTitleLab.font = .boldSystemFont(ofSize: 12)
        ttsTitleLab.textColor = .darkGray
        ttsTitleLab.text = "🔄 \(R.localStr.ttsOutput())"

        ttsTextLab.font = .systemFont(ofSize: 12)
        ttsTextLab.textColor = .systemBlue
        ttsTextLab.numberOfLines = 0

        ttsTitleLab.snp.makeConstraints { make in
            make.top.equalTo(statCard.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(12)
        }

        ttsTextLab.snp.makeConstraints { make in
            make.top.equalTo(ttsTitleLab.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(20)
        }
    }

    private func setupStatusCard() {
        statusCardView.backgroundColor = UIColor.eHex("#FFFFFF")
        statusCardView.layer.cornerRadius = 8
        statusCardView.layer.borderWidth = 1
        statusCardView.layer.borderColor = UIColor.eHex("#E0E0E0").cgColor

        contentView.addSubview(statusCardView)

        statusTitleLab.text = "📡 \(R.localStr.recordPolicy()) / \(R.localStr.audioType())"
        statusTitleLab.font = .boldSystemFont(ofSize: 12)
        statusTitleLab.textColor = .darkGray

        let labels = [modeLab, policyLab, audioTypeLab, channelLab, sampleRateLab, langLab]
        labels.forEach { lab in
            lab.font = .systemFont(ofSize: 11)
            lab.textColor = .darkText
            lab.numberOfLines = 0
        }

        let stack = UIStackView(arrangedSubviews: [statusTitleLab, modeLab, policyLab, audioTypeLab, channelLab, sampleRateLab, langLab])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .fill
        stack.distribution = .fill

        statusCardView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }

        statusCardView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview().inset(8)
        }
    }

    // MARK: - 数据绑定

    override func initData() {
        super.initData()

        navigationView.leftBtn.rx.tap
            .subscribe(onNext: {
                TranslateVM.shared.exitRecordTranslateMode { }
            })
            .disposed(by: disposeBag)

        TranslateVM.shared.recordTranslateState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .idle:
                    self?.navigationController?.popViewController(animated: true)
                case .error(let msg):
                    self?.view.makeToast("\(R.localStr.recordTranslateError()): \(msg)", position: .center)
                    self?.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        TranslateVM.shared.subjectCurrentMode
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.refreshStatusCard()
            })
            .disposed(by: disposeBag)

        refreshStatusCard()

        guard let side = TranslateVM.shared.recordSide else { return }

        // 原文
        side.originStreamingText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.originView.showStreamingText(text)
            })
            .disposed(by: disposeBag)

        side.definiteOriginText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.originView.appendOriginText(text)
            })
            .disposed(by: disposeBag)

        // 译文
        side.definiteTranslatedText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.translatedView.appendTranslatedText(text)
            })
            .disposed(by: disposeBag)

        // 统计卡片
        statCard.bind(to: side, codecLabel: codecDisplay(TranslateVM.shared.currentMode), disposeBag: disposeBag)

        // TTS 当前文本
        side.currentTtsText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(to: ttsTextLab.rx.text)
            .disposed(by: disposeBag)

        // 同步滚动
        setupScrollSync()
    }

    private func setupScrollSync() {
        var syncing = false
        let originTV = originView.textView
        let translatedTV = translatedView.textView

        originTV.rx.observe(CGPoint.self, "contentOffset")
            .filter { _ in !syncing }
            .subscribe(onNext: { offset in
                guard let offset = offset, translatedTV.contentOffset != offset else { return }
                syncing = true
                translatedTV.contentOffset = offset
                syncing = false
            })
            .disposed(by: disposeBag)

        translatedTV.rx.observe(CGPoint.self, "contentOffset")
            .filter { _ in !syncing }
            .subscribe(onNext: { offset in
                guard let offset = offset, originTV.contentOffset != offset else { return }
                syncing = true
                originTV.contentOffset = offset
                syncing = false
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 状态卡刷新

    private func refreshStatusCard() {
        let mode = TranslateVM.shared.currentMode
        let recordType = TranslateVM.shared.translateHelper?.recordtype ?? .byPhone

        modeLab.text = "\(R.localStr.recordTranslate())"
        policyLab.text = "\(R.localStr.recordPolicy()): \(recordPolicyDisplay(recordType))"
        audioTypeLab.text = "\(R.localStr.audioType()): \(audioTypeDisplay(mode, recordType: recordType))"
        channelLab.text = "\(R.localStr.channels()): \(mode.channel)"
        sampleRateLab.text = "\(R.localStr.samplingRate()): \(mode.sampleRate)"
        langLab.text = "\(langDisplay(TranslateVM.shared.translateLanguage.0)) → \(langDisplay(TranslateVM.shared.translateLanguage.1.first ?? .en))"
    }

    // MARK: - 展示辅助

    private func recordPolicyDisplay(_ type: JLTranslateRecordType) -> String {
        switch type {
        case .byPhone:
            return R.localStr.recordPolicyPhone()
        case .byDevice:
            return R.localStr.recordPolicyDevice()
        @unknown default:
            return "?"
        }
    }

    private func audioTypeDisplay(_ mode: JLTranslateSetMode, recordType: JLTranslateRecordType) -> String {
        let output = dataTypeDisplay(mode.dataType)
        if recordType == .byPhone {
            return "PCM → \(output)"
        }
        return output
    }

    private func dataTypeDisplay(_ type: JL_SpeakDataType) -> String {
        switch type {
        case .OPUS: return "OPUS"
        case .JLA_V2: return "JLA_V2"
        case .PCM: return "PCM"
        case .SPEEX: return "SPEEX"
        case .MSBC: return "MSBC"
        @unknown default: return "?"
        }
    }

    private func codecDisplay(_ mode: JLTranslateSetMode) -> String {
        switch mode.dataType {
        case .OPUS: return "Opus"
        case .JLA_V2: return "JLA_V2 单声道"
        case .PCM: return "PCM"
        case .SPEEX: return "SPEEX"
        case .MSBC: return "MSBC"
        @unknown default: return "?"
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
