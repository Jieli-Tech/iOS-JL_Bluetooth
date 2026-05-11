//
//  OpusToOggVC.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2025/5/16.
//

import UIKit
import JLAudioUnitKit
import JLLogHelper
import RxSwift
import RxCocoa

class OpusToOggVC: BaseViewController {
    
    // MARK: - UI Components
    
    // 文件列表
    private let fileListView = FileListView()
    
    // 配置区域容器 - 使用普通UIView，内部用ScrollView
    private let configContainerView = UIView()
    private let configScrollView = UIScrollView()
    private let configContentView = UIView()
    
    // 预设配置选择
    private let presetLabel = UILabel()
    private let presetSegmentedControl = UISegmentedControl(items: ["标准", "短帧", "长帧", "超长", "超短", "自定义"])
    
    // 采样率选择
    private let sampleRateLabel = UILabel()
    private let sampleRateSegmentedControl = UISegmentedControl(items: ["8k", "12k", "16k", "24k", "48k"])
    private let sampleRateValues: [UInt32] = [8000, 12000, 16000, 24000, 48000]
    
    // 声道数选择
    private let channelLabel = UILabel()
    private let channelSegmentedControl = UISegmentedControl(items: ["单声道", "立体声"])
    
    // 帧时长选择
    private let frameDurationLabel = UILabel()
    private let frameDurationSegmentedControl = UISegmentedControl(items: ["2.5ms", "5ms", "10ms", "20ms", "40ms", "60ms"])
    private let frameDurationValues: [UInt8] = [2, 5, 10, 20, 40, 60] // 2.5ms用2表示
    
    // 每帧字节数
    private let frameLengthLabel = UILabel()
    private let frameLengthTextField = UITextField()
    private let frameLengthUnitLabel = UILabel()
    private let frameLengthDescLabel = UILabel()
    
    // 预跳过样本数
    private let preSkipLabel = UILabel()
    private let preSkipTextField = UITextField()
    private let preSkipUnitLabel = UILabel()
    private let autoPreSkipSwitch = UISwitch()
    private let autoPreSkipLabel = UILabel()
    
    // 当前配置信息展示
    private let currentConfigTitleLabel = UILabel()
    private let currentConfigLabel = UILabel()
    
    // 操作按钮
    private let reloadFileBtn = UIButton()
    private let startBtn = UIButton()
    private let resetConfigBtn = UIButton()
    
    // MARK: - Properties
    
    private var oggConvertMgr: JLOpusToOgg?
    private var currentConfig = JLOpusToOggConfig.standardConfiguration()
    
    // 是否正在应用预设（防止循环触发）
    private var isApplyingPreset = false
    
    // 预设配置映射
    private let presetConfigs: [(title: String, config: () -> JLOpusToOggConfig)] = [
        ("标准", { JLOpusToOggConfig.standardConfiguration() }),
        ("短帧", { JLOpusToOggConfig.shortFrameConfiguration() }),
        ("长帧", { JLOpusToOggConfig.longFrameConfiguration() }),
        ("超长", { JLOpusToOggConfig.extraLongFrameConfiguration() }),
        ("超短", { JLOpusToOggConfig.ultraShortFrameConfiguration() })
    ]
    
    // MARK: - Lifecycle
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Opus To OGG "
        
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    override func initData() {
        fileListView.loadFoldFile(Tools.opusPath)
        updateUIWithCurrentConfig()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // 配置容器
        configContainerView.backgroundColor = .systemBackground
        configContainerView.layer.cornerRadius = 8
        configContainerView.layer.borderWidth = 1
        configContainerView.layer.borderColor = UIColor.systemGray4.cgColor
        
        configScrollView.showsVerticalScrollIndicator = true
        configScrollView.alwaysBounceVertical = true
        
        // 预设配置
        presetLabel.text = "预设配置:"
        presetLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        presetLabel.textColor = R.color.fontBackText_90()
        presetSegmentedControl.selectedSegmentIndex = 0
        
        // 采样率
        sampleRateLabel.text = "采样率:"
        sampleRateLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        sampleRateLabel.textColor = R.color.fontBackText_90()
        sampleRateSegmentedControl.selectedSegmentIndex = 2 // 16k
        
        // 声道数
        channelLabel.text = "声道数:"
        channelLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        channelLabel.textColor = R.color.fontBackText_90()
        channelSegmentedControl.selectedSegmentIndex = 0 // 单声道
        
        // 帧时长
        frameDurationLabel.text = "帧时长:"
        frameDurationLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        frameDurationLabel.textColor = R.color.fontBackText_90()
        frameDurationSegmentedControl.selectedSegmentIndex = 3 // 20ms
        
        // 每帧字节数
        frameLengthLabel.text = "每帧字节数:"
        frameLengthLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        frameLengthLabel.textColor = R.color.fontBackText_90()
        frameLengthTextField.borderStyle = .roundedRect
        frameLengthTextField.keyboardType = .numberPad
        frameLengthTextField.font = UIFont.systemFont(ofSize: 14)
        frameLengthTextField.text = "40"
        frameLengthUnitLabel.text = "bytes"
        frameLengthUnitLabel.font = UIFont.systemFont(ofSize: 12)
        frameLengthUnitLabel.textColor = .systemGray
        frameLengthDescLabel.text = "✓ 推荐值"
        frameLengthDescLabel.font = UIFont.systemFont(ofSize: 11)
        frameLengthDescLabel.textColor = .systemGreen
        frameLengthDescLabel.numberOfLines = 0
        
        // 预跳过样本数
        preSkipLabel.text = "预跳过样本:"
        preSkipLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        preSkipLabel.textColor = R.color.fontBackText_90()
        preSkipTextField.borderStyle = .roundedRect
        preSkipTextField.keyboardType = .numberPad
        preSkipTextField.font = UIFont.systemFont(ofSize: 14)
        preSkipTextField.text = "320"
        preSkipUnitLabel.text = "samples"
        preSkipUnitLabel.font = UIFont.systemFont(ofSize: 12)
        preSkipUnitLabel.textColor = .systemGray
        autoPreSkipLabel.text = "自动"
        autoPreSkipLabel.font = UIFont.systemFont(ofSize: 12)
        autoPreSkipLabel.textColor = .systemGray
        autoPreSkipSwitch.isOn = true
        
        // 当前配置信息
        currentConfigTitleLabel.text = "当前配置摘要:"
        currentConfigTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        currentConfigTitleLabel.textColor = R.color.fontBackText_90()
        currentConfigLabel.numberOfLines = 0
        currentConfigLabel.font = UIFont.systemFont(ofSize: 12)
        currentConfigLabel.textColor = .systemGreen
        currentConfigLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
        currentConfigLabel.layer.cornerRadius = 6
        currentConfigLabel.layer.masksToBounds = true
        currentConfigLabel.textAlignment = .left
        currentConfigLabel.lineBreakMode = .byWordWrapping
        
        // 按钮
        reloadFileBtn.setTitle("刷新文件", for: .normal)
        reloadFileBtn.setTitleColor(.white, for: .normal)
        reloadFileBtn.backgroundColor = .systemBlue
        reloadFileBtn.layer.cornerRadius = 8
        reloadFileBtn.layer.masksToBounds = true
        reloadFileBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        resetConfigBtn.setTitle("重置", for: .normal)
        resetConfigBtn.setTitleColor(.systemOrange, for: .normal)
        resetConfigBtn.backgroundColor = .systemOrange.withAlphaComponent(0.1)
        resetConfigBtn.layer.cornerRadius = 8
        resetConfigBtn.layer.masksToBounds = true
        resetConfigBtn.layer.borderWidth = 1
        resetConfigBtn.layer.borderColor = UIColor.systemOrange.cgColor
        resetConfigBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        startBtn.setTitle("开始转换", for: .normal)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.backgroundColor = .systemGreen
        startBtn.layer.cornerRadius = 8
        startBtn.layer.masksToBounds = true
        startBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        
        // 添加子视图
        view.addSubview(fileListView)
        view.addSubview(configContainerView)
        configContainerView.addSubview(configScrollView)
        configScrollView.addSubview(configContentView)
        
        configContentView.addSubview(presetLabel)
        configContentView.addSubview(presetSegmentedControl)
        configContentView.addSubview(sampleRateLabel)
        configContentView.addSubview(sampleRateSegmentedControl)
        configContentView.addSubview(channelLabel)
        configContentView.addSubview(channelSegmentedControl)
        configContentView.addSubview(frameDurationLabel)
        configContentView.addSubview(frameDurationSegmentedControl)
        configContentView.addSubview(frameLengthLabel)
        configContentView.addSubview(frameLengthTextField)
        configContentView.addSubview(frameLengthUnitLabel)
        configContentView.addSubview(frameLengthDescLabel)
        configContentView.addSubview(preSkipLabel)
        configContentView.addSubview(preSkipTextField)
        configContentView.addSubview(preSkipUnitLabel)
        configContentView.addSubview(autoPreSkipSwitch)
        configContentView.addSubview(autoPreSkipLabel)
        configContentView.addSubview(currentConfigTitleLabel)
        configContentView.addSubview(currentConfigLabel)
        
        view.addSubview(reloadFileBtn)
        view.addSubview(resetConfigBtn)
        view.addSubview(startBtn)
    }
    
    private func setupConstraints() {
        // 文件列表 - 增加高度权重
        fileListView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(8)
            make.height.equalTo(280)
        }
        
        // 配置容器 - 固定高度，内部可滚动
        configContainerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(fileListView.snp.bottom).offset(8)
            make.bottom.equalTo(startBtn.snp.top).offset(-8)
        }
        
        configScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        
        configContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // 预设配置
        presetLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.top.equalToSuperview().inset(8)
            make.width.equalTo(70)
        }
        
        presetSegmentedControl.snp.makeConstraints { make in
            make.left.equalTo(presetLabel.snp.right).offset(4)
            make.right.equalToSuperview().inset(8)
            make.centerY.equalTo(presetLabel)
            make.height.equalTo(28)
        }
        
        // 采样率
        sampleRateLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.top.equalTo(presetLabel.snp.bottom).offset(12)
            make.width.equalTo(70)
        }
        
        sampleRateSegmentedControl.snp.makeConstraints { make in
            make.left.equalTo(sampleRateLabel.snp.right).offset(4)
            make.right.equalToSuperview().inset(8)
            make.centerY.equalTo(sampleRateLabel)
            make.height.equalTo(28)
        }
        
        // 声道数
        channelLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.top.equalTo(sampleRateLabel.snp.bottom).offset(12)
            make.width.equalTo(70)
        }
        
        channelSegmentedControl.snp.makeConstraints { make in
            make.left.equalTo(channelLabel.snp.right).offset(4)
            make.right.equalToSuperview().inset(8)
            make.centerY.equalTo(channelLabel)
            make.height.equalTo(28)
        }
        
        // 帧时长
        frameDurationLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.top.equalTo(channelLabel.snp.bottom).offset(12)
            make.width.equalTo(70)
        }
        
        frameDurationSegmentedControl.snp.makeConstraints { make in
            make.left.equalTo(frameDurationLabel.snp.right).offset(4)
            make.right.equalToSuperview().inset(8)
            make.centerY.equalTo(frameDurationLabel)
            make.height.equalTo(28)
        }
        
        // 每帧字节数
        frameLengthLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.top.equalTo(frameDurationLabel.snp.bottom).offset(12)
        }
        
        frameLengthTextField.snp.makeConstraints { make in
            make.left.equalTo(frameLengthLabel.snp.right).offset(4)
            make.width.equalTo(60)
            make.centerY.equalTo(frameLengthLabel)
            make.height.equalTo(28)
        }
        
        frameLengthUnitLabel.snp.makeConstraints { make in
            make.left.equalTo(frameLengthTextField.snp.right).offset(4)
            make.centerY.equalTo(frameLengthLabel)
        }
        
        frameLengthDescLabel.snp.makeConstraints { make in
            make.left.equalTo(frameLengthUnitLabel.snp.right).offset(8)
            make.right.equalToSuperview().inset(8)
            make.centerY.equalTo(frameLengthLabel)
        }
        
        // 预跳过样本数
        preSkipLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.top.equalTo(frameLengthLabel.snp.bottom).offset(12)
        }
        
        preSkipTextField.snp.makeConstraints { make in
            make.left.equalTo(preSkipLabel.snp.right).offset(4)
            make.width.equalTo(60)
            make.centerY.equalTo(preSkipLabel)
            make.height.equalTo(28)
        }
        
        preSkipUnitLabel.snp.makeConstraints { make in
            make.left.equalTo(preSkipTextField.snp.right).offset(4)
            make.centerY.equalTo(preSkipLabel)
        }
        
        autoPreSkipLabel.snp.makeConstraints { make in
            make.left.equalTo(preSkipUnitLabel.snp.right).offset(12)
            make.centerY.equalTo(preSkipLabel)
        }
        
        autoPreSkipSwitch.snp.makeConstraints { make in
            make.left.equalTo(autoPreSkipLabel.snp.right).offset(4)
            make.centerY.equalTo(preSkipLabel)
            make.width.equalTo(44)
            make.height.equalTo(28)
        }
        
        // 当前配置信息
        currentConfigTitleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(8)
            make.top.equalTo(preSkipLabel.snp.bottom).offset(12)
        }
        
        currentConfigLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(currentConfigTitleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(12)
        }
        
        // 底部按钮
        reloadFileBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.width.equalTo(view.snp.width).multipliedBy(0.25).offset(-12)
            make.height.equalTo(44)
            make.top.equalTo(configContainerView.snp.bottom).offset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
        }
        
        resetConfigBtn.snp.makeConstraints { make in
            make.left.equalTo(reloadFileBtn.snp.right).offset(8)
            make.width.equalTo(reloadFileBtn)
            make.height.equalTo(44)
            make.centerY.equalTo(reloadFileBtn)
        }
        
        startBtn.snp.makeConstraints { make in
            make.left.equalTo(resetConfigBtn.snp.right).offset(8)
            make.right.equalToSuperview().inset(12)
            make.height.equalTo(44)
            make.centerY.equalTo(reloadFileBtn)
        }
    }
    
    // MARK: - Actions
    
    private func setupActions() {
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        // 刷新文件列表
        reloadFileBtn.rx.tap.bind { [weak self] in
            self?.fileListView.loadFoldFile(Tools.opusPath)
            self?.view.makeToast("文件列表已刷新", position: .center)
        }.disposed(by: disposeBag)
        
        // 重置配置
        resetConfigBtn.rx.tap.bind { [weak self] in
            self?.resetToStandardConfig()
        }.disposed(by: disposeBag)
        
        // 开始转换
        startBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.fileListView.fileDidSelect.count == 0 {
                self.view.makeToast("请先选择一个文件", position: .center)
                return
            }
            self.startConvert()
        }).disposed(by: disposeBag)
        
        // 预设配置切换
        presetSegmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                if index < self.presetConfigs.count {
                    self.isApplyingPreset = true
                    self.applyPresetConfig(index: index)
                    self.isApplyingPreset = false
                }
            }).disposed(by: disposeBag)
        
        // 采样率变化
        sampleRateSegmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateConfigFromUI()
                if !self.isApplyingPreset {
                    self.checkAndUpdatePresetSelection()
                }
            }).disposed(by: disposeBag)
        
        // 声道数变化
        channelSegmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.updateConfigFromUI()
                if !self.isApplyingPreset {
                    self.checkAndUpdatePresetSelection()
                }
            }).disposed(by: disposeBag)
        
        // 帧时长变化
        frameDurationSegmentedControl.rx.selectedSegmentIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                // 自动更新推荐的帧长度
                let frameDuration = self.frameDurationValues[index]
                let recommendedFrameLength = self.calculateRecommendedFrameLength(frameDurationMs: frameDuration)
                self.frameLengthTextField.text = "\(recommendedFrameLength)"
                self.updateFrameLengthDescription(frameDurationMs: frameDuration, frameLength: recommendedFrameLength)
                self.updateConfigFromUI()
                if !self.isApplyingPreset {
                    self.checkAndUpdatePresetSelection()
                }
            }).disposed(by: disposeBag)
        
        // 帧长度编辑完成
        frameLengthTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.updateConfigFromUI()
                if !self.isApplyingPreset {
                    self.checkAndUpdatePresetSelection()
                }
            }).disposed(by: disposeBag)
        
        // 预跳过样本数编辑完成
        preSkipTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.updateConfigFromUI()
                if !self.isApplyingPreset {
                    self.checkAndUpdatePresetSelection()
                }
            }).disposed(by: disposeBag)
        
        // 自动预跳过开关
        autoPreSkipSwitch.rx.isOn
            .subscribe(onNext: { [weak self] isOn in
                guard let self = self else { return }
                self.preSkipTextField.isEnabled = !isOn
                self.updateConfigFromUI()
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Configuration Logic
    
    /// 检查当前配置是否匹配某个预设，并更新预设选择
    private func checkAndUpdatePresetSelection() {
        // 获取当前配置的值
        let sampleRateIndex = sampleRateSegmentedControl.selectedSegmentIndex
        let sampleRate = sampleRateValues[sampleRateIndex]
        let channelCount = UInt8(channelSegmentedControl.selectedSegmentIndex + 1)
        let frameDurationIndex = frameDurationSegmentedControl.selectedSegmentIndex
        let frameDurationMs = frameDurationValues[frameDurationIndex]
        let frameLength = UInt32(frameLengthTextField.text ?? "40") ?? 40
        
        // 检查是否匹配某个预设
        var matchedPresetIndex: Int?
        for (index, preset) in presetConfigs.enumerated() {
            let presetConfig = preset.config()
            if presetConfig.sampleRate == sampleRate &&
               presetConfig.channelCount == channelCount &&
               presetConfig.frameDurationMs == frameDurationMs &&
               presetConfig.frameLength == frameLength {
                matchedPresetIndex = index
                break
            }
        }
        
        // 更新预设选择
        if let matchedIndex = matchedPresetIndex {
            presetSegmentedControl.selectedSegmentIndex = matchedIndex
        } else {
            presetSegmentedControl.selectedSegmentIndex = 5 // 自定义
        }
    }
    
    /// 验证配置是否有效
    private func validateConfig() -> Bool {
        let supportedSampleRates: [UInt32] = [8000, 12000, 16000, 24000, 48000]
        guard supportedSampleRates.contains(currentConfig.sampleRate) else { return false }
        guard currentConfig.channelCount == 1 || currentConfig.channelCount == 2 else { return false }
        let supportedDurations: [UInt8] = [2, 5, 10, 20, 40, 60]
        guard supportedDurations.contains(currentConfig.frameDurationMs) else { return false }
        guard currentConfig.frameLength > 0 else { return false }
        return true
    }
    
    /// 获取配置警告
    private func getConfigWarnings() -> [String] {
        var warnings: [String] = []
        let recommended = calculateRecommendedFrameLength(frameDurationMs: currentConfig.frameDurationMs)
        let diff = abs(Int(currentConfig.frameLength) - Int(recommended))
        if diff > Int(recommended) / 4 {
            warnings.append("帧长度偏离推荐值")
        }
        return warnings
    }
    
    /// 根据帧时长计算推荐的帧长度
    private func calculateRecommendedFrameLength(frameDurationMs: UInt8) -> UInt32 {
        let baseDuration: UInt32 = 20
        let baseLength: UInt32 = 40
        return (baseLength * UInt32(frameDurationMs)) / baseDuration
    }
    
    /// 更新帧长度描述
    private func updateFrameLengthDescription(frameDurationMs: UInt8, frameLength: UInt32) {
        let recommended = calculateRecommendedFrameLength(frameDurationMs: frameDurationMs)
        if frameLength == recommended {
            frameLengthDescLabel.text = "✓ 推荐值"
            frameLengthDescLabel.textColor = .systemGreen
        } else {
            let diff = Int(frameLength) - Int(recommended)
            let diffText = diff > 0 ? "+\(diff)" : "\(diff)"
            frameLengthDescLabel.text = "⚠ 偏离 \(diffText)"
            frameLengthDescLabel.textColor = .systemOrange
        }
    }
    
    /// 应用预设配置
    private func applyPresetConfig(index: Int) {
        guard index < presetConfigs.count else { return }
        
        let config = presetConfigs[index].config()
        currentConfig = config
        updateUIWithCurrentConfig()
        
        JLLogManager.logLevel(JLLOG_LEVEL(rawValue: 2)!, 
                              content: "[OpusToOggVC] 应用预设配置: \(presetConfigs[index].title)")
    }
    
    /// 重置为标准配置
    private func resetToStandardConfig() {
        currentConfig = JLOpusToOggConfig.standardConfiguration()
        presetSegmentedControl.selectedSegmentIndex = 0
        updateUIWithCurrentConfig()
        view.makeToast("已重置为标准配置", position: .center)
        
        JLLogManager.logLevel(JLLOG_LEVEL(rawValue: 2)!, 
                              content: "[OpusToOggVC] 重置为标准配置")
    }
    
    /// 根据UI更新配置
    private func updateConfigFromUI() {
        let sampleRateIndex = sampleRateSegmentedControl.selectedSegmentIndex
        let sampleRate = sampleRateValues[sampleRateIndex]
        
        let channelCount = UInt8(channelSegmentedControl.selectedSegmentIndex + 1)
        
        let frameDurationIndex = frameDurationSegmentedControl.selectedSegmentIndex
        let frameDurationMs = frameDurationValues[frameDurationIndex]
        
        let frameLength = UInt32(frameLengthTextField.text ?? "40") ?? 40
        
        let preSkip: UInt16
        if autoPreSkipSwitch.isOn {
            preSkip = UInt16((sampleRate * UInt32(frameDurationMs)) / 1000)
        } else {
            preSkip = UInt16(preSkipTextField.text ?? "320") ?? 320
        }
        
        currentConfig = JLOpusToOggConfig()
        currentConfig.sampleRate = sampleRate
        currentConfig.channelCount = channelCount
        currentConfig.frameDurationMs = frameDurationMs
        currentConfig.frameLength = frameLength
        currentConfig.preSkip = preSkip
        
        updateConfigDisplay()
        
        JLLogManager.logLevel(JLLOG_LEVEL(rawValue: 1)!, 
                              content: "[OpusToOggVC] 配置已更新: \(sampleRate)Hz, \(channelCount)Ch, \(frameDurationMs)ms, \(frameLength)bytes")
    }
    
    /// 根据当前配置更新UI
    private func updateUIWithCurrentConfig() {
        if let sampleRateIndex = sampleRateValues.firstIndex(of: currentConfig.sampleRate) {
            sampleRateSegmentedControl.selectedSegmentIndex = sampleRateIndex
        }
        
        channelSegmentedControl.selectedSegmentIndex = Int(currentConfig.channelCount) - 1
        
        if let frameDurationIndex = frameDurationValues.firstIndex(of: currentConfig.frameDurationMs) {
            frameDurationSegmentedControl.selectedSegmentIndex = frameDurationIndex
        }
        
        frameLengthTextField.text = "\(currentConfig.frameLength)"
        updateFrameLengthDescription(frameDurationMs: currentConfig.frameDurationMs, 
                                      frameLength: currentConfig.frameLength)
        
        preSkipTextField.text = "\(currentConfig.preSkip)"
        
        updateConfigDisplay()
    }
    
    /// 更新配置信息显示
    private func updateConfigDisplay() {
        let samplesPerFrame = currentConfig.samplesPerFrame()
        let outputSampleRate = currentConfig.outputSampleRate()
        
        let isValid = validateConfig()
        
        var statusText = ""
        if isValid {
            statusText = "✓ 配置有效\n"
        } else {
            statusText = "✗ 配置无效\n"
        }
        
        let warnings = getConfigWarnings()
        if !warnings.isEmpty {
            statusText += "⚠ \(warnings.joined(separator: ", "))\n"
        }
        
        currentConfigLabel.text = """
        \(statusText)
        采样率: \(currentConfig.sampleRate) Hz
        声道数: \(currentConfig.channelCount) \(currentConfig.channelCount == 1 ? "(单声道)" : "(立体声)")
        帧时长: \(currentConfig.frameDurationMs == 2 ? "2.5" : String(currentConfig.frameDurationMs)) ms
        帧长度: \(currentConfig.frameLength) bytes
        每帧采样: \(samplesPerFrame) samples
        输出采样率: \(outputSampleRate) Hz
        预跳过: \(currentConfig.preSkip) samples
        """
        
        if isValid {
            currentConfigLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.1)
            currentConfigLabel.textColor = .systemGreen
        } else {
            currentConfigLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
            currentConfigLabel.textColor = .systemRed
        }
    }
    
    // MARK: - Conversion
    
    private func startConvert() {
        let path = Tools.opusPath + "/" + self.fileListView.fileDidSelect
        guard let opusData = NSData(contentsOfFile: path) as? Data else {
            self.view.makeToast("加载文件失败", position: .center)
            return
        }
        
        guard validateConfig() else {
            self.view.makeToast("配置无效，请检查参数", position: .center)
            return
        }
        
        oggConvertMgr = JLOpusToOgg(configuration: currentConfig)
        
        let processingQueue = DispatchQueue(label: "com.jl.opustogg.demo", qos: .userInitiated)
        oggConvertMgr?.processingQueue = processingQueue
        
        var oggData = Data()
        var totalBytesReceived = 0
        
        oggConvertMgr?.convertBlock = { [weak self] data, isEnd, err in
            guard let self = self else { return }
            
            if let error = err {
                DispatchQueue.main.async {
                    self.view.makeToast("错误: \(error.localizedDescription)", position: .center)
                }
                return
            }
            
            if let data = data {
                oggData.append(data)
                totalBytesReceived += data.count
                JLLogManager.logLevel(JLLOG_LEVEL(rawValue: 1)!, 
                                      content: "[OpusToOggVC] 接收数据块: \(data.count) bytes, 总计: \(totalBytesReceived)")
            }
            
            if isEnd {
                DispatchQueue.main.async {
                    self.saveOggFile(oggData: oggData, originalPath: path)
                }
            }
        }
        
        JLLogManager.logLevel(JLLOG_LEVEL(rawValue: 2)!, 
                              content: "[OpusToOggVC] 开始流式转换，配置: \(currentConfig.sampleRate)Hz, \(currentConfig.frameDurationMs)ms")
        oggConvertMgr?.startStream()
        
        let frameLen = Int(currentConfig.frameLength)
        var offset = 0
        let chunkSize = frameLen * 10
        
        while offset < opusData.count {
            let end = min(offset + chunkSize, opusData.count)
            let chunk = opusData.subdata(in: offset..<end)
            oggConvertMgr?.appendOpusData(chunk)
            offset += chunkSize
            usleep(1000)
        }
        
        oggConvertMgr?.closeStream()
        JLLogManager.logLevel(JLLOG_LEVEL(rawValue: 2)!, 
                              content: "[OpusToOggVC] 流式转换完成")
    }
    
    private func saveOggFile(oggData: Data, originalPath: String) {
        let oggPath = originalPath.replacingOccurrences(of: ".opus", with: ".ogg")
        
        if FileManager.default.fileExists(atPath: oggPath) {
            try? FileManager.default.removeItem(atPath: oggPath)
        }
        
        let success = FileManager.default.createFile(atPath: oggPath, contents: oggData, attributes: nil)
        
        if success {
            JLLogManager.logLevel(JLLOG_LEVEL(rawValue: 2)!, 
                                  content: "[OpusToOggVC] OGG文件已保存: \(oggPath), 大小: \(oggData.count) bytes")
            self.view.makeToast("转换成功! \(oggData.count) bytes", position: .center)
            fileListView.loadFoldFile(Tools.opusPath)
        } else {
            self.view.makeToast("保存文件失败", position: .center)
        }
    }
}
