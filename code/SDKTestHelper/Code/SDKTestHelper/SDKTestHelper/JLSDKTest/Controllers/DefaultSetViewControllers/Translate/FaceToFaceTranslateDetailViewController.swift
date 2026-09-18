//
//  FaceToFaceTranslateDetailViewController.swift
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

/// 面对面翻译（手机+耳机）详情页
///
/// 双栏展示耳机端 / 手机端的原文与译文，左右同步滚动；底部统计卡片与控制按钮。
/// 支持手机端与耳机端同时双向翻译。
class FaceToFaceTranslateDetailViewController: BaseViewController {

    // MARK: - UI

    private let contentScrollView = UIScrollView()
    private let contentView = UIView()

    // 双栏：耳机端 / 手机端
    private let earbudView = SimultaneousTranscriptionView(role: R.localStr.earbudSide())
    private let phoneView = SimultaneousTranscriptionView(role: R.localStr.phoneSide())

    // 统计卡片
    private let earbudStatCard = CallTranslateStatCardView()
    private let phoneStatCard = CallTranslateStatCardView()

    // 顶部状态卡
    private let statusCardView = UIView()
    private let statusTitleLab = UILabel()
    private let modeLab = UILabel()
    private let audioTypeLab = UILabel()
    private let phoneLangLab = UILabel()
    private let earbudLangLab = UILabel()

    // 控制按钮
    private let phoneStartBtn = UIButton(type: .system)
    private let phoneStopBtn = UIButton(type: .system)
    private let earbudStartBtn = UIButton(type: .system)
    private let earbudStopBtn = UIButton(type: .system)
    private let phoneSourceLab = UILabel()
    private let earbudSourceLab = UILabel()

    private var phoneBound = false
    private var deviceBound = false

    // MARK: - 生命周期

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let st = TranslateVM.shared.faceToFaceState.value
        if st == .working || st == .entering {
            TranslateVM.shared.exitFaceToFaceMode { }
        }
    }

    // MARK: - UI 初始化

    override func initUI() {
        navigationView.title = R.localStr.faceToFacePhoneEarbudDetailTitle()
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
        setupTextRow()
        setupStatRow()
        setupControlRow()
    }

    private func setupStatusCard() {
        statusCardView.backgroundColor = UIColor.eHex("#FFFFFF")
        statusCardView.layer.cornerRadius = 8
        statusCardView.layer.borderWidth = 1
        statusCardView.layer.borderColor = UIColor.eHex("#E0E0E0").cgColor

        contentView.addSubview(statusCardView)

        statusTitleLab.text = "📡 面对面翻译（手机+耳机）"
        statusTitleLab.font = .boldSystemFont(ofSize: 12)
        statusTitleLab.textColor = .darkGray

        let labels = [modeLab, audioTypeLab, phoneLangLab, earbudLangLab]
        labels.forEach { lab in
            lab.font = .systemFont(ofSize: 11)
            lab.textColor = .darkText
            lab.numberOfLines = 0
        }

        let stack = UIStackView(arrangedSubviews: [statusTitleLab, modeLab, audioTypeLab, phoneLangLab, earbudLangLab])
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

    private func setupTextRow() {
        let row = UIView()
        contentView.addSubview(row)
        row.addSubview(earbudView)
        row.addSubview(phoneView)

        row.snp.makeConstraints { make in
            make.top.equalTo(statusCardView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
            make.height.equalTo(260)
        }

        earbudView.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(phoneView)
        }

        phoneView.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(earbudView.snp.right).offset(8)
        }
    }

    private func setupStatRow() {
        let row = UIView()
        contentView.addSubview(row)
        row.addSubview(earbudStatCard)
        row.addSubview(phoneStatCard)

        row.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
        }

        earbudStatCard.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(phoneStatCard)
        }

        phoneStatCard.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(earbudStatCard.snp.right).offset(8)
        }
    }

    private func setupControlRow() {
        [phoneStartBtn, phoneStopBtn, earbudStartBtn, earbudStopBtn].forEach { btn in
            btn.titleLabel?.font = .boldSystemFont(ofSize: 13)
            btn.layer.cornerRadius = 8
            btn.clipsToBounds = true
        }

        phoneStartBtn.setTitle(R.localStr.phoneStartRecording(), for: .normal)
        phoneStartBtn.backgroundColor = UIColor.eHex("#34C759")
        phoneStartBtn.setTitleColor(.white, for: .normal)

        phoneStopBtn.setTitle(R.localStr.phoneStopRecording(), for: .normal)
        phoneStopBtn.backgroundColor = UIColor.eHex("#FF3B30")
        phoneStopBtn.setTitleColor(.white, for: .normal)
        phoneStopBtn.isEnabled = false

        earbudStartBtn.setTitle(R.localStr.earbudStartRecording(), for: .normal)
        earbudStartBtn.backgroundColor = UIColor.eHex("#007AFF")
        earbudStartBtn.setTitleColor(.white, for: .normal)

        earbudStopBtn.setTitle(R.localStr.earbudStopRecording(), for: .normal)
        earbudStopBtn.backgroundColor = UIColor.eHex("#FF9500")
        earbudStopBtn.setTitleColor(.white, for: .normal)
        earbudStopBtn.isEnabled = false

        [phoneSourceLab, earbudSourceLab].forEach { lab in
            lab.font = .systemFont(ofSize: 10)
            lab.textColor = .gray
            lab.text = ""
        }

        let phoneRow = UIStackView(arrangedSubviews: [phoneStartBtn, phoneStopBtn])
        phoneRow.axis = .horizontal
        phoneRow.spacing = 8
        phoneRow.distribution = .fillEqually

        let earbudRow = UIStackView(arrangedSubviews: [earbudStartBtn, earbudStopBtn])
        earbudRow.axis = .horizontal
        earbudRow.spacing = 8
        earbudRow.distribution = .fillEqually

        let container = UIStackView(arrangedSubviews: [phoneRow, phoneSourceLab, earbudRow, earbudSourceLab])
        container.axis = .vertical
        container.spacing = 6
        container.alignment = .fill

        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.equalTo(earbudStatCard.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(20)
        }

        phoneStartBtn.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        earbudStartBtn.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }

    // MARK: - 数据绑定

    override func initData() {
        super.initData()

        navigationView.leftBtn.rx.tap
            .subscribe(onNext: {
                TranslateVM.shared.exitFaceToFaceMode { }
            })
            .disposed(by: disposeBag)

        TranslateVM.shared.faceToFaceState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                switch state {
                case .idle:
                    self?.navigationController?.popViewController(animated: true)
                case .error(let msg):
                    self?.view.makeToast("\(R.localStr.faceToFaceError()): \(msg)", position: .center)
                    self?.navigationController?.popViewController(animated: true)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        // 手机端状态
        TranslateVM.shared.phoneRecordState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.refreshPhoneButton(state: state)
                if state == .recording { self?.bindSidesIfNeeded() }
            })
            .disposed(by: disposeBag)

        TranslateVM.shared.phoneRecordSource
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] source in
                self?.phoneSourceLab.text = self?.sourceDisplay(source)
            })
            .disposed(by: disposeBag)

        // 耳机端状态
        TranslateVM.shared.deviceRecordState
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                self?.refreshEarbudButton(state: state)
                if state == .recording { self?.bindSidesIfNeeded() }
            })
            .disposed(by: disposeBag)

        TranslateVM.shared.deviceRecordSource
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] source in
                self?.earbudSourceLab.text = self?.sourceDisplay(source)
            })
            .disposed(by: disposeBag)

        // 按钮动作
        phoneStartBtn.rx.tap
            .subscribe(onNext: { TranslateVM.shared.startPhoneFaceToFace() })
            .disposed(by: disposeBag)

        phoneStopBtn.rx.tap
            .subscribe(onNext: { TranslateVM.shared.stopPhoneFaceToFace() })
            .disposed(by: disposeBag)

        earbudStartBtn.rx.tap
            .subscribe(onNext: { TranslateVM.shared.startDeviceFaceToFace() })
            .disposed(by: disposeBag)

        earbudStopBtn.rx.tap
            .subscribe(onNext: { TranslateVM.shared.stopDeviceFaceToFace() })
            .disposed(by: disposeBag)

        refreshStatusCard()
        bindSidesIfNeeded()
        setupScrollSync()
    }

    private func bindSidesIfNeeded() {
        if !phoneBound, let side = TranslateVM.shared.facePhoneSide {
            phoneBound = true
            phoneView.setLangDirection(langDisplay(side.sourceLanguage), langDisplay(side.targetLanguage))
            bindSide(side, to: phoneView)
            phoneStatCard.bind(to: side, codecLabel: dataTypeDisplay(TranslateVM.shared.currentMode.dataType), disposeBag: disposeBag)
        }
        if !deviceBound, let side = TranslateVM.shared.faceDeviceSide {
            deviceBound = true
            earbudView.setLangDirection(langDisplay(side.sourceLanguage), langDisplay(side.targetLanguage))
            bindSide(side, to: earbudView)
            earbudStatCard.bind(to: side, codecLabel: dataTypeDisplay(TranslateVM.shared.currentMode.dataType), disposeBag: disposeBag)
        }
    }

    private func bindSide(_ side: CallTranslateSideModel, to view: SimultaneousTranscriptionView) {
        side.originStreamingText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { text in
                view.showStreamingText(text)
            })
            .disposed(by: disposeBag)

        side.definiteOriginText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { text in
                view.appendOriginText(text)
            })
            .disposed(by: disposeBag)

        side.definiteTranslatedText
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { text in
                view.appendTranslatedText(text)
            })
            .disposed(by: disposeBag)
    }

    private func setupScrollSync() {
        var syncing = false
        let earbudTV = earbudView.textView
        let phoneTV = phoneView.textView

        earbudTV.rx.observe(CGPoint.self, "contentOffset")
            .filter { _ in !syncing }
            .subscribe(onNext: { offset in
                guard let offset = offset, phoneTV.contentOffset != offset else { return }
                syncing = true
                phoneTV.contentOffset = offset
                syncing = false
            })
            .disposed(by: disposeBag)

        phoneTV.rx.observe(CGPoint.self, "contentOffset")
            .filter { _ in !syncing }
            .subscribe(onNext: { offset in
                guard let offset = offset, earbudTV.contentOffset != offset else { return }
                syncing = true
                earbudTV.contentOffset = offset
                syncing = false
            })
            .disposed(by: disposeBag)
    }

    // MARK: - 刷新

    private func refreshStatusCard() {
        let mode = TranslateVM.shared.currentMode
        let phoneLang = TranslateVM.shared.translateLanguage
        modeLab.text = "模式: 面对面翻译（手机+耳机）"
        audioTypeLab.text = "\(R.localStr.audioType()): \(dataTypeDisplay(mode.dataType))"
        phoneLangLab.text = "\(R.localStr.phoneSide()): \(langDisplay(phoneLang.0)) → \(langDisplay(phoneLang.1.first ?? .en))"
        earbudLangLab.text = "\(R.localStr.earbudSide()): \(langDisplay(phoneLang.1.first ?? .en)) → \(langDisplay(phoneLang.0))"
    }

    private func refreshPhoneButton(state: FaceRecordSideState) {
        let recording = (state == .recording)
        phoneStartBtn.isEnabled = !recording
        phoneStopBtn.isEnabled = recording
    }

    private func refreshEarbudButton(state: FaceRecordSideState) {
        let recording = (state == .recording)
        earbudStartBtn.isEnabled = !recording
        earbudStopBtn.isEnabled = recording
    }

    private func sourceDisplay(_ source: FaceToFaceRecordSource) -> String {
        switch source {
        case .user: return R.localStr.recordSourceUser()
        case .device: return R.localStr.recordSourceDevice()
        case .none: return ""
        }
    }

    // MARK: - 展示辅助

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

    private func langDisplay(_ lang: TranslateLanguage) -> String {
        switch lang {
        case .zh: return "中文"
        case .en: return "English"
        case .ja: return "日文"
        }
    }
}
