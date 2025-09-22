//
//  OpusEncodeVC.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import JLAudioUnitKit
import JLLogHelper

class OpusEncodeVC: BaseViewController, JLOpusDecoderDelegate, JLOpusEncoderDelegate {
    
    let startRecord = UIButton()
    let stopRecord = UIButton()
    let playRecord = UIButton()
    let convertBtn = UIButton()
    let convertBackBtn = UIButton()
    private let drawView = SpectrogramView()
    private let fileListView = FileListView()
    private var decoder:JLOpusDecoder!
    private var encoder:JLOpusEncoder!
    private var format = JLOpusFormat.defaultFormats()
    private var encodeConfig = JLOpusEncodeConfig.defaultJL()

    override func initUI() {
        super.initUI()
        
        navigationView.title = "Opus Encode"
        
        view.addSubview(fileListView)
        view.addSubview(startRecord)
        view.addSubview(stopRecord)
        view.addSubview(playRecord)
        view.addSubview(convertBtn)
        view.addSubview(convertBackBtn)
        view.addSubview(drawView)
        
        startRecord.setTitle("Start Record", for: .normal)
        startRecord.setTitleColor(.white, for: .normal)
        startRecord.backgroundColor = UIColor.random()
        startRecord.layer.cornerRadius = 8
        startRecord.layer.masksToBounds = true
        
        stopRecord.setTitle("Stop Record", for: .normal)
        stopRecord.setTitleColor(.white, for: .normal)
        stopRecord.backgroundColor = UIColor.random()
        stopRecord.layer.cornerRadius = 8
        stopRecord.layer.masksToBounds = true
        
        playRecord.setTitle("Play Record", for: .normal)
        playRecord.setTitleColor(.white, for: .normal)
        playRecord.backgroundColor = UIColor.random()
        playRecord.layer.cornerRadius = 8
        playRecord.layer.masksToBounds = true
        
        convertBtn.setTitle("Convert", for: .normal)
        convertBtn.setTitleColor(.white, for: .normal)
        convertBtn.backgroundColor = UIColor.random()
        convertBtn.layer.cornerRadius = 8
        convertBtn.layer.masksToBounds = true
        
        convertBackBtn.setTitle("Convert Back", for: .normal)
        convertBackBtn.setTitleColor(.white, for: .normal)
        convertBackBtn.backgroundColor = UIColor.random()
        convertBackBtn.layer.cornerRadius = 8
        convertBackBtn.layer.masksToBounds = true
        
        fileListView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(6)
            make.height.equalTo(200)
        }
        
        startRecord.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.right.equalTo(stopRecord.snp.left).offset(-6)
            make.height.equalTo(40)
            make.width.equalTo(stopRecord.snp.width)
            make.top.equalTo(fileListView.snp.bottom).offset(6)
        }
        
        stopRecord.snp.makeConstraints { make in
            make.right.equalTo(view).inset(20)
            make.left.equalTo(startRecord.snp.right).offset(6)
            make.width.equalTo(startRecord.snp.width)
            make.height.equalTo(40)
            make.centerY.equalTo(startRecord.snp.centerY)
        }
        
        convertBtn.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.right.equalTo(convertBackBtn.snp.left).offset(-6)
            make.width.equalTo(convertBackBtn.snp.width)
            make.height.equalTo(40)
            make.top.equalTo(stopRecord.snp.bottom).offset(6)
        }
        
        convertBackBtn.snp.makeConstraints { make in
            make.right.equalTo(view).inset(20)
            make.left.equalTo(convertBtn.snp.right).offset(6)
            make.width.equalTo(convertBtn.snp.width)
            make.height.equalTo(40)
            make.centerY.equalTo(convertBtn.snp.centerY)
        }
        
        playRecord.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(convertBackBtn.snp.bottom).offset(6)
        }
        
        drawView.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.top.equalTo(playRecord.snp.bottom).offset(6)
            make.bottom.equalToSuperview().inset(20)
        }
        
    }
    
    override func initData() {
        super.initData()
        format.hasDataHeader = false
        decoder = JLOpusDecoder(decoder: format, delegate: self)
        encoder = JLOpusEncoder(format: encodeConfig, delegate: self)
        
        JLAudioPlayer.shared.callBack = { [weak self] data in
            guard let self = self else { return }
            self.drawView.setPcmData(data)
        }
        
        startRecord.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let filePath = Tools.opusEncodePath + "/record.pcm"
            self.startRecord.isEnabled = false
            self.stopRecord.isEnabled = true
            JLAudioRecoder.shared.start(filePath)
            
        }).disposed(by: disposeBag)
        
        stopRecord.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.startRecord.isEnabled = true
            self.stopRecord.isEnabled = false
            JLAudioRecoder.shared.stop()
            self.view.makeToast("Stop Record",position: .center)
            self.fileListView.loadFoldFile(Tools.opusEncodePath)
        }).disposed(by: disposeBag)
        
        playRecord.rx.tap.subscribe(onNext: {  _ in
            let filePath = Tools.opusEncodePath + "/record.pcm"
            if let data = NSData(contentsOfFile: filePath) as? Data {
                JLAudioPlayer.shared.start()
                let chunkSize = 640
                var offset = 0
                while offset < data.count {
                    let end = min(offset + chunkSize, data.count)
                    let chunk = data.subdata(in: offset..<end)
                    JLAudioPlayer.shared.enqueuePCMData(chunk) 
                    offset += chunkSize
                }
            }
        }).disposed(by: disposeBag)
        
        convertBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.fileListView.fileDidSelect.hasSuffix(".pcm") {
                if let _ = NSData(contentsOfFile: Tools.opusEncodePath + "/" + self.fileListView.fileDidSelect) as? Data {
                    self.encoder.opusEncodeFile(Tools.opusEncodePath + "/" + self.fileListView.fileDidSelect, outPut: Tools.opusEncodePath + "/converted.opus") { _, err in
                        if err == nil {
                            self.view.makeToast("Convert Success",position: .center)
                            self.fileListView.loadFoldFile(Tools.opusEncodePath)
                        }
                    }
                }else{
                    self.view.makeToast("Please select a file",position: .center)
                }
            }else{
                self.view.makeToast("Please select a pcm file",position: .center)
            }
        }).disposed(by: disposeBag)
        
        convertBackBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.fileListView.fileDidSelect.hasSuffix(".opus") {
                if let data = NSData(contentsOfFile: Tools.opusEncodePath + "/" + self.fileListView.fileDidSelect) as? Data {
                    let path = Tools.opusEncodePath + "/" + self.fileListView.fileDidSelect.replacingOccurrences(of: ".opus", with: ".pcm")
                    self.decoder.opusDecodeFile(Tools.opusEncodePath + "/" + self.fileListView.fileDidSelect, outPut: path)
                }else{
                    self.view.makeToast("Please select a file",position: .center)
                }
            }else{
                self.view.makeToast("Please select a opus file",position: .center)
            }
        }).disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fileListView.loadFoldFile(Tools.opusEncodePath)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        JLAudioPlayer.shared.stop()
    }
    
    
    // MARK: - JLOpusDelegate
    func opusEncoder(_ encoder: JLOpusEncoder, data: Data?, error: (any Error)?) {
        let str = data?.map { String(format: "%02x", $0) }.joined() ?? ""
        JLLogManager.logLevel(.DEBUG, content: "opus data:\(str)")
    }
    
    // MARK: - JLOpusDecoder
    func opusDecoder(_ decoder: JLOpusDecoder, data: Data?, error: (any Error)?) {
        if let data = data {
            JLAudioPlayer.shared.enqueuePCMData(data)
        }
    }
    
}
