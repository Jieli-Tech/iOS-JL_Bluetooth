//
//  OpusDecodeVC.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import JLAudioUnitKit
import Toast_Swift
import AVFoundation
import AudioToolbox
import JLLogHelper

class OpusDecodeVC: BaseViewController {
    private let fileListView = FileListView()
    private let startBtn = UIButton()
    private var opusDecoder:JLOpusDecoder!
    private let channelLab = UILabel()
    private let switchBtn = UISwitch()
    private let sampleRateLab = UILabel()
    private let packerView = UIPickerView()
    private let drawView = SpectrogramView()
    private var isJLHeaderLab = UILabel()
    private var headerSwitch = UISwitch()
    private var format = JLOpusFormat.defaultFormats()
    private let pickerData = BehaviorRelay<[String]>(value: ["8000", "16000", "24000", "32000", "44100", "48000", "96000"])
    private var audioFormat = AudioStreamBasicDescription(
                                                            mSampleRate: 16000, // 采样率
                                                            mFormatID: kAudioFormatLinearPCM,
                                                            mFormatFlags: kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked,
                                                            mBytesPerPacket: 2, // 每个数据包的字节数
                                                            mFramesPerPacket: 1,
                                                            mBytesPerFrame: 2,
                                                            mChannelsPerFrame: 1, // 单声道
                                                            mBitsPerChannel: 16,
                                                            mReserved: 0
                                                        )
    
    override func initUI() {
        super.initUI()
        navigationView.title = "Opus Decode"
        view.addSubview(fileListView)
        view.addSubview(startBtn)
        view.addSubview(channelLab)
        view.addSubview(switchBtn)
        view.addSubview(packerView)
        view.addSubview(isJLHeaderLab)
        view.addSubview(headerSwitch)
        view.addSubview(sampleRateLab)
        view.addSubview(drawView)
        
        
        startBtn.setTitle("Start", for: .normal)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.backgroundColor = UIColor.random()
        startBtn.layer.cornerRadius = 8
        startBtn.layer.masksToBounds = true
        
        channelLab.text = "Channels:"
        channelLab.textColor = R.color.fontBackText_90()
        
        switchBtn.isOn = false
        
        isJLHeaderLab.text = "JL Header:"
        isJLHeaderLab.textColor = R.color.fontBackText_90()
        
        headerSwitch.isOn = true
        
        sampleRateLab.text = "Sample Rate:"
        sampleRateLab.textColor = R.color.fontBackText_90()
        
        drawView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 200)
        
        fileListView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.height.equalTo(160)
        }
        startBtn.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(fileListView.snp.bottom).offset(10)
        }
        
        channelLab.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(startBtn.snp.bottom).offset(10)
        }
        
        switchBtn.snp.makeConstraints { make in
            make.left.equalTo(channelLab.snp.right).offset(10)
            make.centerY.equalTo(channelLab.snp.centerY)
        }
        
        sampleRateLab.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(channelLab.snp.bottom).offset(5)
        }
        
        packerView.snp.makeConstraints { make in
            make.left.equalTo(sampleRateLab.snp.right).offset(10)
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.centerY.equalTo(sampleRateLab.snp.centerY)
        }
        
        isJLHeaderLab.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(sampleRateLab.snp.bottom).offset(5)
        }
        
        headerSwitch.snp.makeConstraints { make in
            make.left.equalTo(isJLHeaderLab.snp.right).offset(10)
            make.centerY.equalTo(isJLHeaderLab.snp.centerY)
        }
        
        drawView.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.top.equalTo(isJLHeaderLab.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(20)
        }
        
        
    }
    
    override func initData() {
        super.initData()
        self.opusDecoder = JLOpusDecoder(decoder: format, delegate: self)
        fileListView.loadFoldFile(Tools.opusPath)
        
        JLAudioPlayer.shared.start()
        JLAudioPlayer.shared.callBack = { [weak self] data in
            guard let self = self else { return }
            self.drawView.setPcmData(data)
        }
        startBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if let data = NSData(contentsOfFile: Tools.opusPath + "/" + self.fileListView.fileDidSelect) as? Data {
                self.opusDecoder.opusDecoderInputData(data)
                let path = Tools.opusPath + "/" + self.fileListView.fileDidSelect
                let pcmPath = path.replacingOccurrences(of: ".opus", with: ".pcm")
                try?FileManager.default.removeItem(atPath: pcmPath)
                FileManager.default.createFile(atPath: pcmPath, contents: data)
            } else {
                self.view.makeToast("File not found",position: .center)
            }
//            self.opusDecoder.opusDecodeFile(path, outPut: pcmPath) {  pcmPath,err in
//                JLLogManager.logLevel(.DEBUG, content: "pcmPath:\(pcmPath ?? "")")
//            }
            
        }).disposed(by: disposeBag)
        
        pickerData.bind(to: packerView.rx.itemTitles) { _, item in
            return item
        }.disposed(by: disposeBag)
        
        packerView.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            let value = self.pickerData.value[index.row]
            self.format.sampleRate = Int32(value) ?? 16000
            self.opusDecoder.resetOpusFramet(self.format)
            self.audioFormat.mSampleRate = Float64(self.format.sampleRate)
            JLAudioPlayer.shared.changeFormat(audioFormat)
        }).disposed(by: disposeBag)
        
        switchBtn.rx.value.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            self.format.channels = value ? 2 : 1
            self.format.dataSize = value ? 80 : 40
            self.channelLab.text = "Channels: \(self.format.channels)"
            self.opusDecoder.resetOpusFramet(self.format)
            self.audioFormat.mChannelsPerFrame = value ? 2 : 1
            self.audioFormat.mBytesPerFrame = value ? 4 : 2
            self.audioFormat.mBytesPerPacket = value ? 4 : 2
            JLAudioPlayer.shared.changeFormat(audioFormat)
        }).disposed(by: disposeBag)
        
        headerSwitch.rx.value.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            self.format.hasDataHeader = value
            self.isJLHeaderLab.text = "JL Header: \(self.format.hasDataHeader)"
            self.opusDecoder.resetOpusFramet(self.format)
        }).disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        packerView.selectRow(1, inComponent: 0, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        JLAudioPlayer.shared.stop()
        opusDecoder.opusOnRelease()
    }
}

/// MARK: JLOpusDecoderDelegate
extension OpusDecodeVC: JLOpusDecoderDelegate {
    func opusDecoder(_ decoder: JLOpusDecoder, data: Data?, error: (any Error)?) {
        if let data = data {
            JLAudioPlayer.shared.enqueuePCMData(data)
        }
    }
}
