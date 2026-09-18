//
//  VolumeSetViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/1.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JL_BLEKit
import AVFoundation
import MediaPlayer
import RxSwift
import RxCocoa
import SnapKit

class VolumeSetViewController: BaseViewController {
    
    // MARK: - UI Components
    private lazy var volumeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        slider.tintColor = .systemBlue
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        return slider
    }()
    
    private lazy var volumeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "50%"
        return label
    }()
    
    private lazy var modeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var deviceInfoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Properties
    private var volumeObserver: NSKeyValueObservation?
    private var currentDeviceVolume: UInt8 = 0
    private var maxDeviceVolume: UInt8 = 100
    private var isSyncVoiceMode: Bool = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - UI Setup
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.volumeSet()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        
        view.addSubview(volumeLabel)
        view.addSubview(volumeSlider)
        view.addSubview(modeLabel)
        view.addSubview(deviceInfoLabel)
        
        volumeLabel.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
        }
        
        volumeSlider.snp.makeConstraints { make in
            make.top.equalTo(volumeLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        modeLabel.snp.makeConstraints { make in
            make.top.equalTo(volumeSlider.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        deviceInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(modeLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
    }
    
    // MARK: - Data Initialization
    override func initData() {
        super.initData()
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        refreshVolumeDisplay()
    }
    
    // MARK: - Volume Control
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let volume = Int(sender.value)
        updateVolumeUI(volume)
        
        if isSyncVoiceMode {
            setPhoneSystemVolume(volume)
        } else {
            let deviceVolume = Int(volume * Int(maxDeviceVolume) / 100)
            setDeviceVolume(UInt8(deviceVolume))
        }
    }
    
    private func setPhoneSystemVolume(_ volume: Int) {
        let volumeView = MPVolumeView()
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                slider.value = Float(volume) / 100.0
                JLLogManager.logLevel(.DEBUG, content: "[Volume] 手机系统音量设置: \(volume)%")
            }
        }
    }
    
    private func setDeviceVolume(_ volume: UInt8) {
        guard let manager = BleManager.shared.currentCmdMgr else {
            ECPrintError("current cmd manager is nil, please connect first!", self, "\(#function)", #line)
            return
        }
        
        let clampedVolume = min(volume, maxDeviceVolume)
        currentDeviceVolume = clampedVolume
        
        JLLogManager.logLevel(.DEBUG, content: "[Volume] 设置设备音量: \(clampedVolume)/\(maxDeviceVolume)")
        
        manager.mSystemVolume.cmdSetSystemVolume(clampedVolume) { [weak self] status, _, _ in
            DispatchQueue.main.async {
                if status == .success {
                    JLLogManager.logLevel(.DEBUG, content: "[Volume] 设备音量设置成功: \(clampedVolume)")
                    self?.currentDeviceVolume = clampedVolume
                } else {
                    JLLogManager.logLevel(.ERROR, content: "[Volume] 设备音量设置失败: \(status)")
                }
            }
        }
    }
    
    // MARK: - Volume Display
    private func refreshVolumeDisplay() {
        guard let manager = BleManager.shared.currentCmdMgr else {
            volumeSlider.value = 50
            updateVolumeUI(50)
            modeLabel.text = R.localStr.deviceNotConnected()
            deviceInfoLabel.text = ""
            removeVolumeObserver()
            return
        }
        
        let deviceModel = manager.outputDeviceModel()
        isSyncVoiceMode = deviceModel.isSyncVoice
        maxDeviceVolume = UInt8(deviceModel.maxVol)
        currentDeviceVolume = UInt8(deviceModel.currentVol)
        
        if isSyncVoiceMode {
            // 音量同步模式
            let systemVolume = getPhoneSystemVolume()
            volumeSlider.value = Float(systemVolume)
            updateVolumeUI(systemVolume)
            modeLabel.text = R.localStr.volumeSyncMode()
            deviceInfoLabel.text = "\(R.localStr.maxVolume()): 100 | \(R.localStr.currentVolume()): \(systemVolume)"
            setupVolumeObserver()
        } else {
            // 独立音量模式
            let displayVolume = Int(currentDeviceVolume) * 100 / max(Int(maxDeviceVolume), 1)
            volumeSlider.value = Float(displayVolume)
            updateVolumeUI(displayVolume)
            modeLabel.text = R.localStr.volumeIndependentMode()
            deviceInfoLabel.text = "\(R.localStr.maxVolume()): \(maxDeviceVolume) | \(R.localStr.currentVolume()): \(currentDeviceVolume)"
            removeVolumeObserver()
        }
    }
    
    private func getPhoneSystemVolume() -> Int {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(true)
            let volume = audioSession.outputVolume
            return Int(volume * 100)
        } catch {
            JLLogManager.logLevel(.ERROR, content: "[Volume] 获取系统音量失败: \(error)")
            return 50
        }
    }
    
    private func updateVolumeUI(_ volume: Int) {
        volumeLabel.text = "\(volume)%"
    }
    
    // MARK: - System Volume Observer
    private func setupVolumeObserver() {
        removeVolumeObserver()
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setActive(true)
            
            volumeObserver = audioSession.observe(\.outputVolume, options: [.new]) { [weak self] _, change in
                guard let newValue = change.newValue else { return }
                let volumePercent = Int(newValue * 100)
                
                DispatchQueue.main.async {
                    if self?.isSyncVoiceMode == true {
                        self?.volumeSlider.value = Float(volumePercent)
                        self?.updateVolumeUI(volumePercent)
                        JLLogManager.logLevel(.DEBUG, content: "[Volume] 系统音量变化: \(volumePercent)%")
                    }
                }
            }
            
            JLLogManager.logLevel(.DEBUG, content: "[Volume] 已设置系统音量监听")
        } catch {
            JLLogManager.logLevel(.ERROR, content: "[Volume] 设置音量监听失败: \(error)")
        }
    }
    
    private func removeVolumeObserver() {
        volumeObserver?.invalidate()
        volumeObserver = nil
    }
    
    // MARK: - Cleanup
    private func cleanup() {
        removeVolumeObserver()
    }
}
