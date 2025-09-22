//
//  PcmToWavVC.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2025/4/15.
//

import UIKit
import JLAudioUnitKit

class PcmToWavVC: BaseViewController {
    private let fileListView = FileListView()
    private let reloadFileBtn = UIButton()
    private let startBtn = UIButton()
    private let recordBtn = UIButton()
    private let stopRecordBtn = UIButton()
    
    
    override func initUI() {
        super.initUI()
        navigationView.title = "PCM To WAV"
        view.addSubview(fileListView)
        view.addSubview(reloadFileBtn)
        view.addSubview(startBtn)
        view.addSubview(recordBtn)
        view.addSubview(stopRecordBtn)
        
        startBtn.setTitle("Start", for: .normal)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.backgroundColor = UIColor.random()
        startBtn.layer.cornerRadius = 8
        startBtn.layer.masksToBounds = true
        
        reloadFileBtn.setTitle("Reload File", for: .normal)
        reloadFileBtn.setTitleColor(.white, for: .normal)
        reloadFileBtn.backgroundColor = UIColor.random()
        reloadFileBtn.layer.cornerRadius = 8
        reloadFileBtn.layer.masksToBounds = true
        
        recordBtn.setTitle("Record", for: .normal)
        recordBtn.setTitleColor(.white, for: .normal)
        recordBtn.backgroundColor = UIColor.random()
        recordBtn.layer.cornerRadius = 8
        recordBtn.layer.masksToBounds = true
        
        stopRecordBtn.setTitle("Stop Record", for: .normal)
        stopRecordBtn.setTitleColor(.white, for: .normal)
        stopRecordBtn.backgroundColor = UIColor.random()
        stopRecordBtn.layer.cornerRadius = 8
        stopRecordBtn.layer.masksToBounds = true
        
        fileListView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.height.equalTo(200)
        }
        reloadFileBtn.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(fileListView.snp.bottom).offset(10)
        }
        startBtn.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(reloadFileBtn.snp.bottom).offset(10)
        }
        
        recordBtn.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(startBtn.snp.bottom).offset(10)
        }
        
        stopRecordBtn.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(recordBtn.snp.bottom).offset(10)
        }
        
    }
    
    override func initData() {
        fileListView.loadFoldFile(Tools.wavPath)
        
        reloadFileBtn.rx.tap.bind { [weak self] in
            self?.fileListView.loadFoldFile(Tools.wavPath)
        }.disposed(by: disposeBag)
        
        startBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.fileListView.fileDidSelect.count == 0 {
                return
            }
            let path = Tools.wavPath + "/" + self.fileListView.fileDidSelect
            guard let data = NSData(contentsOfFile: path) as? Data else {
                return
            }
            if let _ = try? JLPcmToWav.convertPCMData(data, toWAVFile: path.replacingOccurrences(of: ".pcm", with: ".wav"), sampleRate: 16000, numChannels: 1, bitsPerSample: 16) {
            }
            fileListView.loadFoldFile(Tools.wavPath)
            
        }).disposed(by: disposeBag)
        
        recordBtn.rx.tap.subscribe(onNext: {  _ in
            let path = Tools.wavPath + "/record.pcm"
            JLAudioRecoder.shared.start(path)
        }).disposed(by: disposeBag)
        
        stopRecordBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            JLAudioRecoder.shared.stop()
            self.fileListView.loadFoldFile(Tools.wavPath)
        }).disposed(by: disposeBag)
        
    }
}
