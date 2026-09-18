//
//  CallTranslateDetailViewController.swift
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

/// 通话翻译详情页
///
/// 左右并排展示「己方 / 对方」的原文、译文、流式识别中间结果，
/// 顶部展示编解码/路由状态，底部展示两侧统计卡片。
/// 退出页面时自动退出通话翻译模式。
class CallTranslateDetailViewController: BaseViewController {

    // MARK: - UI

    private let contentScrollView = UIScrollView()
    private let contentView = UIView()

    // 左右并排的转录区域
    private let localTranscriptionView = SimultaneousTranscriptionView(role: R.localStr.localSide())
    private let remoteTranscriptionView = SimultaneousTranscriptionView(role: R.localStr.remoteSide())

    // 左右并排的统计卡片
    private let localStatCard = CallTranslateStatCardView()
    private let remoteStatCard = CallTranslateStatCardView()

    // 顶部状态卡
    private let statusCardView = UIView()
    private let statusTitleLab = UILabel()
    private let modeLab = UILabel()
    private let codecLab = UILabel()
    private let channelLab = UILabel()
    private let sampleRateLab = UILabel()
    private let supportStereoLab = UILabel()
    private let routingLab = UILabel()

    // TTS 当前文本
    private let localTtsTitleLab = UILabel()
    private let localTtsTextLab = UILabel()
    private let remoteTtsTitleLab = UILabel()
    private let remoteTtsTextLab = UILabel()

    // MARK: - 生命周期

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let state = TranslateVM.shared.callTranslateState.value
        if state == .working || state == .entering {
            TranslateVM.shared.exitCallTranslateMode { }
        }
    }

    // MARK: - UI 初始化

    override func initUI() {
        navigationView.title = R.localStr.callTranslateDetailTitle()
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

        // 顶部状态卡
        setupStatusCard()

        // 左右并排：己方 / 对方 转录区域
        let transcriptionRow = UIView()
        contentView.addSubview(transcriptionRow)
        transcriptionRow.addSubview(localTranscriptionView)
        transcriptionRow.addSubview(remoteTranscriptionView)

        transcriptionRow.snp.makeConstraints { make in
            make.top.equalTo(statusCardView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(260)
        }

        localTranscriptionView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(remoteTranscriptionView)
        }

        remoteTranscriptionView.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(localTranscriptionView.snp.right).offset(8)
        }

        // 左右并排：统计卡片
        let statRow = UIView()
        contentView.addSubview(statRow)
        statRow.addSubview(localStatCard)
        statRow.addSubview(remoteStatCard)

        statRow.snp.makeConstraints { make in
            make.top.equalTo(transcriptionRow.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
        }

        localStatCard.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(remoteStatCard)
        }

        remoteStatCard.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(localStatCard.snp.right).offset(8)
        }

        // TTS 当前文本
        contentView.addSubview(localTtsTitleLab)
        contentView.addSubview(localTtsTextLab)
        contentView.addSubview(remoteTtsTitleLab)
        contentView.addSubview(remoteTtsTextLab)

        localTtsTitleLab.font = .boldSystemFont(ofSize: 12)
        localTtsTitleLab.textColor = .darkGray
        localTtsTitleLab.text = "🔄 \(R.localStr.localSide()) 正在翻译:"

        localTtsTextLab.font = .systemFont(ofSize: 12)
        localTtsTextLab.textColor = .systemBlue
        localTtsTextLab.numberOfLines = 0

        remoteTtsTitleLab.font = .boldSystemFont(ofSize: 12)
        remoteTtsTitleLab.textColor = .darkGray
        remoteTtsTitleLab.text = "🔄 \(R.localStr.remoteSide()) 正在翻译:"

        remoteTtsTextLab.font = .systemFont(ofSize: 12)
        remoteTtsTextLab.textColor = .systemBlue
        remoteTtsTextLab.numberOfLines = 0

        localTtsTitleLab.snp.makeConstraints { make in
            make.top.equalTo(statRow.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(12)
        }

        localTtsTextLab.snp.makeConstraints { make in
            make.top.equalTo(localTtsTitleLab.snp.bottom).offset(2)
            make.left.right.equalToSuperview().inset(12)
        }

        remoteTtsTitleLab.snp.makeConstraints { make in
            make.top.equalTo(localTtsTextLab.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(12)
        }

        remoteTtsTextLab.snp.makeConstraints { make in
            make.top.equalTo(remoteTtsTitleLab.snp.bottom).offset(2)
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

        statusTitleLab.text = "📡 \(R.localStr.currentMode()) / \(R.localStr.codec()) / \(R.localStr.routing())"
        statusTitleLab.font = .boldSystemFont(ofSize: 12)
        statusTitleLab.textColor = .darkGray

        let labels = [modeLab, codecLab, channelLab, sampleRateLab, supportStereoLab, routingLab]
        labels.forEach { lab in
            lab.font = .systemFont(ofSize: 11)
            lab.textColor = .darkText
            lab.numberOfLines = 0
        }

        let stack = UIStackView(arrangedSubviews: [statusTitleLab, modeLab, codecLab, channelLab, sampleRateLab, supportStereoLab, routingLab])
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

        // 退出按钮
        navigationView.leftBtn.rx.tap
            .subscribe(onNext: {
                TranslateVM.shared.exitCallTranslateMode { }
            })
            .disposed(by: disposeBag)

        // 状态变化：idle / error 自动 pop
        TranslateVM.shared.callTranslateState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .idle:
                    self?.navigationController?.popViewController(animated: true)
                case .error(let msg):
                    self?.view.makeToast("\(R.localStr.callTranslateError()): \(msg)", position: .center)
                    self?.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        // 顶部状态卡刷新
        TranslateVM.shared.subjectCurrentMode
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.refreshStatusCard()
            })
            .disposed(by: disposeBag)

        refreshStatusCard()

        guard let local = TranslateVM.shared.localCallSide,
              let remote = TranslateVM.shared.remoteCallSide else {
            return
        }

        // 语言方向
        localTranscriptionView.setLangDirection(langDisplay(local.sourceLanguage), langDisplay(local.targetLanguage))
        remoteTranscriptionView.setLangDirection(langDisplay(remote.sourceLanguage), langDisplay(remote.targetLanguage))

        // 己方文本
        local.originStreamingText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.localTranscriptionView.showStreamingText(text)
            })
            .disposed(by: disposeBag)

        local.definiteOriginText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.localTranscriptionView.appendOriginText(text)
            })
            .disposed(by: disposeBag)

        local.definiteTranslatedText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.localTranscriptionView.appendTranslatedText(text)
            })
            .disposed(by: disposeBag)

        // 对方文本
        remote.originStreamingText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.remoteTranscriptionView.showStreamingText(text)
            })
            .disposed(by: disposeBag)

        remote.definiteOriginText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.remoteTranscriptionView.appendOriginText(text)
            })
            .disposed(by: disposeBag)

        remote.definiteTranslatedText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.remoteTranscriptionView.appendTranslatedText(text)
            })
            .disposed(by: disposeBag)

        // 统计卡片
        let codecLabel = codecDisplay(TranslateVM.shared.currentMode)
        localStatCard.bind(to: local, codecLabel: codecLabel, disposeBag: disposeBag)
        remoteStatCard.bind(to: remote, codecLabel: codecLabel, disposeBag: disposeBag)

        // TTS 当前文本
        local.currentTtsText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(to: localTtsTextLab.rx.text)
            .disposed(by: disposeBag)

        remote.currentTtsText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(to: remoteTtsTextLab.rx.text)
            .disposed(by: disposeBag)

        // 左右栏同步滚动
        setupScrollSync()
    }

    private func setupScrollSync() {
        var syncing = false
        let localTV = localTranscriptionView.textView
        let remoteTV = remoteTranscriptionView.textView

        localTV.rx.observe(CGPoint.self, "contentOffset")
            .filter { _ in !syncing }
            .subscribe(onNext: { offset in
                guard let offset = offset, remoteTV.contentOffset != offset else { return }
                syncing = true
                remoteTV.contentOffset = offset
                syncing = false
            })
            .disposed(by: disposeBag)

        remoteTV.rx.observe(CGPoint.self, "contentOffset")
            .filter { _ in !syncing }
            .subscribe(onNext: { offset in
                guard let offset = offset, localTV.contentOffset != offset else { return }
                syncing = true
                localTV.contentOffset = offset
                syncing = false
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 状态卡刷新

    private func refreshStatusCard() {
        let mode = TranslateVM.shared.currentMode
        modeLab.text = "\(R.localStr.currentMode()): \(modeDisplay(mode.modeType))"
        codecLab.text = "\(R.localStr.codec()): \(codecDisplay(mode))"
        channelLab.text = "\(R.localStr.channels()): \(mode.channel)"
        sampleRateLab.text = "\(R.localStr.samplingRate()): \(mode.sampleRate)"
        let support = TranslateVM.shared.twsConfigModel?.isSupportOpusStereo ?? false
        supportStereoLab.text = "\(R.localStr.deviceSupportOpusStereo()): \(support ? "是" : "否")"
        routingLab.text = "\(R.localStr.routing()): \(routingDisplay(mode.modeType))"
    }

    // MARK: - 展示辅助

    private func modeDisplay(_ type: JLTranslateSetModeType) -> String {
        switch type {
        case .idle: return "空闲"
        case .onlyRecord: return "仅录音"
        case .recordTranslate: return "录音翻译"
        case .callTranslate: return "通话翻译"
        case .audioTranslate: return "音频翻译"
        case .faceToFaceTranslate: return "面对面翻译（手机+耳机）"
        case .callTranslateStereo: return "通话立体声翻译"
        case .callRecord: return "通话录音模式"
        case .simultaneous: return "面对面翻译（左耳+右耳）"
        @unknown default: return "未知"
        }
    }

    private func codecDisplay(_ mode: JLTranslateSetMode) -> String {
        switch mode.dataType {
        case .OPUS:
            return mode.modeType == .callTranslateStereo ? "Opus 立体声" : "Opus"
        case .JLA_V2:
            return "JLA_V2 单声道"
        case .PCM:
            return "PCM"
        case .SPEEX:
            return "SPEEX"
        case .MSBC:
            return "MSBC"
        @unknown default:
            return "未知"
        }
    }

    private func routingDisplay(_ type: JLTranslateSetModeType) -> String {
        switch type {
        case .callTranslate:
            return "上行→己方 / 下行→对方"
        case .callTranslateStereo:
            return "左声道=上行→己方 / 右声道=下行→对方"
        default:
            return "-"
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
