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
    private let largeFileEncodeLab = UILabel()
    private let largeFileEncodeSwitch = UISwitch()
    private let chunkSizeLab = UILabel()
    private let chunkSizePicker = UIPickerView()
    private let aggThresholdLab = UILabel()
    private let aggThresholdPicker = UIPickerView()
    private let chunkSizeData = BehaviorRelay<[String]>(value: ["512KB", "1MB", "2MB"])
    private let aggSizeData = BehaviorRelay<[String]>(value: ["128KB", "256KB", "512KB"])
    private var selectedChunkBytes: Int = 1024 * 1024
    private var selectedAggBytes: Int = 256 * 1024

    override func initUI() {
        super.initUI()
        
        navigationView.title = "Opus Encode"
        
        view.addSubview(fileListView)
        view.addSubview(startRecord)
        view.addSubview(stopRecord)
        view.addSubview(playRecord)
        view.addSubview(convertBtn)
        view.addSubview(convertBackBtn)
        view.addSubview(largeFileEncodeLab)
        view.addSubview(largeFileEncodeSwitch)
        view.addSubview(chunkSizeLab)
        view.addSubview(chunkSizePicker)
        view.addSubview(aggThresholdLab)
        view.addSubview(aggThresholdPicker)
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
        largeFileEncodeLab.text = "Large File Encode:"
        largeFileEncodeLab.textColor = R.color.fontBackText_90()
        largeFileEncodeSwitch.isOn = false
        chunkSizeLab.text = "Chunk Size:"
        chunkSizeLab.textColor = R.color.fontBackText_90()
        aggThresholdLab.text = "Aggregate Threshold:"
        aggThresholdLab.textColor = R.color.fontBackText_90()
        
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

        largeFileEncodeLab.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(convertBackBtn.snp.bottom).offset(6)
        }
        largeFileEncodeSwitch.snp.makeConstraints { make in
            make.left.equalTo(largeFileEncodeLab.snp.right).offset(10)
            make.centerY.equalTo(largeFileEncodeLab.snp.centerY)
        }
        chunkSizeLab.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(largeFileEncodeLab.snp.bottom).offset(6)
        }
        chunkSizePicker.snp.makeConstraints { make in
            make.left.equalTo(chunkSizeLab.snp.right).offset(10)
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.centerY.equalTo(chunkSizeLab.snp.centerY)
        }
        aggThresholdLab.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(chunkSizeLab.snp.bottom).offset(6)
        }
        aggThresholdPicker.snp.makeConstraints { make in
            make.left.equalTo(aggThresholdLab.snp.right).offset(10)
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.centerY.equalTo(aggThresholdLab.snp.centerY)
        }
        
        playRecord.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(aggThresholdPicker.snp.bottom).offset(6)
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
                if self.largeFileEncodeSwitch.isOn {
                    let input = Tools.opusEncodePath + "/" + self.fileListView.fileDidSelect
                    let output = Tools.opusEncodePath + "/converted.opus"
                    JLLogManager.logLevel(.DEBUG, content: "Start large file encode, chunkBytes=\(self.selectedChunkBytes), agg=\(self.selectedAggBytes)")
                    self.encoder.opusEncodeFileEx(input, output: output, chunkBytes: UInt(self.selectedChunkBytes), aggregateThreshold: UInt(self.selectedAggBytes)) { path, err in
                        if let err = err {
                            self.view.makeToast(err.localizedDescription, position: .center)
                        } else {
                            self.view.makeToast("Convert Success", position: .center)
                            self.fileListView.loadFoldFile(Tools.opusEncodePath)
                        }
                    }
                } else {
                    let input = Tools.opusEncodePath + "/" + self.fileListView.fileDidSelect
                    if let pcmData = NSData(contentsOfFile: input) as? Data {
                        JLLogManager.logLevel(.DEBUG, content: "Start small encode (memory), size=\(pcmData.count) bytes")
                        self.encoder.opusEncode(pcmData)
                        self.view.makeToast("Convert Success (memory)", position: .center)
                        self.fileListView.loadFoldFile(Tools.opusEncodePath)
                    } else {
                        self.view.makeToast("File read failed", position: .center)
                    }
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

        chunkSizeData.bind(to: chunkSizePicker.rx.itemTitles) { _, item in
            return item
        }.disposed(by: disposeBag)
        aggSizeData.bind(to: aggThresholdPicker.rx.itemTitles) { _, item in
            return item
        }.disposed(by: disposeBag)

        chunkSizePicker.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            let value = self.chunkSizeData.value[index.row]
            switch value {
            case "512KB": self.selectedChunkBytes = 512 * 1024
            case "1MB": self.selectedChunkBytes = 1024 * 1024
            case "2MB": self.selectedChunkBytes = 2 * 1024 * 1024
            default: self.selectedChunkBytes = 1024 * 1024
            }
            JLLogManager.logLevel(.DEBUG, content: "Selected chunk size: \(value) -> \(self.selectedChunkBytes) bytes")
        }).disposed(by: disposeBag)

        aggThresholdPicker.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            let value = self.aggSizeData.value[index.row]
            switch value {
            case "128KB": self.selectedAggBytes = 128 * 1024
            case "256KB": self.selectedAggBytes = 256 * 1024
            case "512KB": self.selectedAggBytes = 512 * 1024
            default: self.selectedAggBytes = 256 * 1024
            }
            JLLogManager.logLevel(.DEBUG, content: "Selected aggregate threshold: \(value) -> \(self.selectedAggBytes) bytes")
        }).disposed(by: disposeBag)

        largeFileEncodeSwitch.rx.value.subscribe(onNext: { [weak self] on in
            guard let self = self else { return }
            let hidden = !on
            JLLogManager.logLevel(.DEBUG, content: "Large file encode: \(on ? "ON" : "OFF")")
            self.chunkSizeLab.isHidden = hidden
            self.chunkSizePicker.isHidden = hidden
            self.aggThresholdLab.isHidden = hidden
            self.aggThresholdPicker.isHidden = hidden
        }).disposed(by: disposeBag)

        chunkSizeLab.isHidden = !largeFileEncodeSwitch.isOn
        chunkSizePicker.isHidden = !largeFileEncodeSwitch.isOn
        aggThresholdLab.isHidden = !largeFileEncodeSwitch.isOn
        aggThresholdPicker.isHidden = !largeFileEncodeSwitch.isOn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fileListView.loadFoldFile(Tools.opusEncodePath)
        chunkSizePicker.selectRow(1, inComponent: 0, animated: true)
        aggThresholdPicker.selectRow(1, inComponent: 0, animated: true)
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
