//
//  TestUnitViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/11.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit


// 定义音频配置枚举
enum AudioConfiguration: String, CaseIterable {
    case playbackOnly
    case recordOnly
    case playAndRecord
    case voiceChat
    case ambient
    case multiRoute
    
    var category: AVAudioSession.Category {
        switch self {
        case .playbackOnly: return .playback
        case .recordOnly: return .record
        case .playAndRecord, .voiceChat: return .playAndRecord
        case .ambient: return .ambient
        case .multiRoute: return .multiRoute
        }
    }
    
    var options: AVAudioSession.CategoryOptions {
        switch self {
        case .recordOnly:
            return [.allowBluetooth]
        case .voiceChat:
            return [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker]
        case .playAndRecord:
            return [.allowBluetooth, .mixWithOthers]
        case .ambient:
            return [.mixWithOthers]
        case .multiRoute:
            return [.allowBluetooth, .allowAirPlay]
        default:
            return []
        }
    }
    
    var mode: AVAudioSession.Mode {
        switch self {
        case .voiceChat: return .voiceChat
        default: return .default
        }
    }
}


class AudioSessionUnitViewController: BaseViewController {
    private let subTable = UITableView()
    private let subItemArray: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    private let subTextView = UITextView()
    private let playAudioBtn = UIButton()
    private var contextText = ""
    
    override func initUI() {
        super.initUI()
        navigationView.title = "AudioSession"
        navigationView.rightBtn.isHidden = false
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        subTable.register(FuncSelectCell.self, forCellReuseIdentifier: "FUNCCell")
        subTable.rowHeight = 60
        subTable.separatorStyle = .none
        
        subTextView.backgroundColor = .white
        subTextView.font = UIFont.systemFont(ofSize: 14)
        subTextView.textColor = .darkText
        subTextView.isEditable = false
        
        playAudioBtn.setTitle("Play Audio", for: .normal)
        playAudioBtn.setTitleColor(.white, for: .normal)
        playAudioBtn.layer.cornerRadius = 10
        playAudioBtn.layer.masksToBounds = true
        playAudioBtn.backgroundColor = .random()
        
        view.addSubview(playAudioBtn)
        view.addSubview(subTextView)
        view.addSubview(subTable)
        
        playAudioBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        subTextView.snp.makeConstraints { make in
            make.top.equalTo(playAudioBtn.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
        
        subTable.snp.makeConstraints { make in
            make.top.equalTo(subTextView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        subItemArray.bind(to: subTable.rx.items(cellIdentifier: "FUNCCell", cellType: FuncSelectCell.self)) { _, element, cell in
            cell.titleLab.text = element
        }.disposed(by: disposeBag)
    }
    
    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        subItemArray.accept(AudioConfiguration.allCases.map({ $0.rawValue }))
        
        subTable.rx.modelSelected(String.self).subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }
            guard let config = AudioConfiguration(rawValue: model) else {
                print("未知的音频配置: \(model)")
                return
            }
            
            do {
                let audioSession = AVAudioSession.sharedInstance()
                
                // 先停用当前会话
                try audioSession.setActive(false)
                
                // 应用新配置
                try audioSession.setCategory(
                    config.category,
                    mode: config.mode,
                    options: config.options
                )
                
                // 重新激活会话
                try audioSession.setActive(true)
                contextText += "✅ 已切换到音频模式: \(model) \n"
                subTextView.text = contextText
                
                // 打印当前配置信息
                self.logCurrentAudioConfiguration()
                
            } catch {
                contextText += "❌ 切换音频配置失败: \(error) \n"
                subTextView.text = contextText
            }
        }).disposed(by: disposeBag)
        playAudioBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.playAudio()
        }).disposed(by: disposeBag)
        
    }
    
    private func playAudio() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
            contextText += "✅ 已激活音频会话\n"
            subTextView.text = contextText
        } catch {
            contextText += "❌ 激活音频会话失败: \(error)\n"
            subTextView.text = contextText
        }
        guard let pcmPath = R.file.convertedPcm.url(), let pcmData = try? Data(contentsOf: pcmPath) else { return }
        
        JLAudioPlayer.shared.enqueuePCMData(pcmData)
    }
    
    private func logCurrentAudioConfiguration() {
        let session = AVAudioSession.sharedInstance()
        contextText += """
        \n--- 当前音频配置 ---
        类别: \(session.category.rawValue)
        模式: \(session.mode.rawValue)
        选项: \(session.categoryOptions)
        输入: \(session.currentRoute.inputs)
        输出: \(session.currentRoute.outputs)
        ----------------------\n
        """
        subTextView.text = contextText
    }
    
    
}
