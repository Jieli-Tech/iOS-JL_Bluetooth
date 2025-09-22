//
//  SpeexDecodeVC.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import JLAudioUnitKit
import Toast_Swift

class SpeexDecodeVC: BaseViewController {
    private var speexDecoder:JLSpeexDecoder!
    private let fileListView = FileListView()
    private let startBtn = UIButton()
    private let drawView = SpectrogramView()
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Speex Decode"
        view.addSubview(fileListView)
        view.addSubview(startBtn)
        view.addSubview(drawView)
        
        startBtn.setTitle("Start", for: .normal)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.backgroundColor = UIColor.random()
        startBtn.layer.cornerRadius = 8
        startBtn.layer.masksToBounds = true
        
        fileListView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.height.equalTo(200)
        }
        startBtn.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(fileListView.snp.bottom).offset(10)
        }
        
        drawView.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.top.equalTo(startBtn.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(20)
        }
        
    }
    
    override func initData() {
        super.initData()
        
        self.speexDecoder = JLSpeexDecoder(delegate: self)
        
        JLAudioPlayer.shared.callBack = { [weak self] data in
            guard let self = self else { return }
            self.drawView.setPcmData(data)
        }
        
        fileListView.loadFoldFile(Tools.speexPath)
        
        startBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let path = Tools.speexPath + "/" + self.fileListView.fileDidSelect
            if let data = NSData(contentsOfFile: path) as? Data {
                JLAudioPlayer.shared.stop()
                var offset =  0
                let lenSize = 1000
                while offset < data.count {
                    if offset + lenSize > data.count {
                        let dt = data.subdata(in: offset ..< data.count)
                        self.speexDecoder.speexInputData(dt)
                        break
                    }
                    let dt = data.subdata(in: offset ..< offset + lenSize)
                    self.speexDecoder.speexInputData(dt)
                    offset += lenSize
                }
                JLAudioPlayer.shared.start()
            } else {
                self.view.makeToast("File not found",position: .center)
            }
        }).disposed(by: disposeBag)
        
    }
    
}

extension SpeexDecodeVC:JLSpeexDelegate {
    func speexDecoder(_ decoder: JLSpeexDecoder, data: Data?, error: (any Error)?) {
        if let dt = data {
            JLAudioPlayer.shared.enqueuePCMData(dt)
        }
    }
}
