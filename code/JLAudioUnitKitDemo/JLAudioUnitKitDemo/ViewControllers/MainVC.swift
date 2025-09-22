//
//  MainVC.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import AVFoundation

class MainVC: BaseViewController {

    let speexDecodeBtn = UIButton()
    let opusDecodeBtn = UIButton()
    let opusEncodeBtn = UIButton()
    
    private var audioFormat = AVAudioFormat(standardFormatWithSampleRate: 16000.0, channels: 1)
       private var audioPlayer = AVAudioPlayerNode()
       private lazy var audioEngine: AVAudioEngine = {
           let engine = AVAudioEngine()
           // Must happen only once.
           engine.attach(self.audioPlayer)
           return engine
       }()
    
    override func initUI() {
        super.initUI()
        navigationView.title = "JLAudioUnitKitDemo"
        navigationView.leftBtn.isHidden = true
        navigationView.rightBtn.setTitle("Setting", for: .normal)
        navigationView.rightBtn.isHidden = false
        
        view.addSubview(speexDecodeBtn)
        view.addSubview(opusDecodeBtn)
        view.addSubview(opusEncodeBtn)
    
        
        speexDecodeBtn.setTitle("Speex Decode", for: .normal)
        speexDecodeBtn.setTitleColor(.white, for: .normal)
        speexDecodeBtn.backgroundColor = UIColor.random()
        speexDecodeBtn.layer.cornerRadius = 8
        speexDecodeBtn.layer.masksToBounds = true
        
        opusDecodeBtn.setTitle("Opus Decode", for: .normal)
        opusDecodeBtn.setTitleColor(.white, for: .normal)
        opusDecodeBtn.backgroundColor = UIColor.random()
        opusDecodeBtn.layer.cornerRadius = 8
        opusDecodeBtn.layer.masksToBounds = true
        
        opusEncodeBtn.setTitle("Opus Encode", for: .normal)
        opusEncodeBtn.setTitleColor(.white, for: .normal)
        opusEncodeBtn.backgroundColor = UIColor.random()
        opusEncodeBtn.layer.cornerRadius = 8
        opusEncodeBtn.layer.masksToBounds = true
        

        
        speexDecodeBtn.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
        }
        
        opusDecodeBtn.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(speexDecodeBtn.snp.bottom).offset(10)
        }
        
        opusEncodeBtn.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(opusDecodeBtn.snp.bottom).offset(10)
        }
        
        
    }
    
    override func initData() {
        super.initData()
        speexDecodeBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.pushViewController(SpeexDecodeVC(), animated: true)
        }).disposed(by: disposeBag)
        
        opusDecodeBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.pushViewController(OpusDecodeVC(), animated: true)
        }).disposed(by: disposeBag)
        
        opusEncodeBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.pushViewController(OpusEncodeVC(), animated: true)
        }).disposed(by: disposeBag)
        
        navigationView.rightBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.pushViewController(SettingViewController(), animated: true)
        }).disposed(by: disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
    }

}
