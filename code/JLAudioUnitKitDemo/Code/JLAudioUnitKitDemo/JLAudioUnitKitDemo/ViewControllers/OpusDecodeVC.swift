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

/// 基于 JLAudioUnitKit 的 OPUS 解码演示控制器：
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
    private var decodeWithFileLab = UILabel()
    private var decodeWithFileSwitch = UISwitch()
    private var largeFileDecodeLab = UILabel()
    private var largeFileDecodeSwitch = UISwitch()
    private var chunkSizeLab = UILabel()
    private var chunkSizePicker = UIPickerView()
    private var aggThresholdLab = UILabel()
    private var aggThresholdPicker = UIPickerView()
    private var format = JLOpusFormat.defaultFormats()
    private let pickerData = BehaviorRelay<[String]>(value: ["8000", "16000", "24000", "48000"])
    private let chunkSizeData = BehaviorRelay<[String]>(value: ["512KB", "1MB", "2MB"])
    private var selectedChunkBytes: Int = 1024 * 1024
    private let aggSizeData = BehaviorRelay<[String]>(value: ["128KB", "256KB", "512KB"])
    private var selectedAggBytes: Int = 256 * 1024
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
    private let readOpusQueue = DispatchQueue(label: "com.zh-jieli.opus.read", qos: .utility)
    private let reassemblyQueue = DispatchQueue(label: "com.zh-jieli.opus.reassembly", qos: .utility)
    private var pendingPackets: [Int: Data] = [:]
    private var nextExpectedSeq: Int = 0
    private var seqCounter: Int = 0
    private var simulationRunning: Bool = false
    private var currentDecodeFileName: String?
    private var pcmRecorder: PCMRecorder?
    private var pcmRecorderLeft: PCMRecorder?
    private var pcmRecorderRight: PCMRecorder?

    struct Packet {
        let seq: Int
        let data: Data
    }
    
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
        view.addSubview(decodeWithFileLab)
        view.addSubview(decodeWithFileSwitch)
        view.addSubview(largeFileDecodeLab)
        view.addSubview(largeFileDecodeSwitch)
        view.addSubview(chunkSizeLab)
        view.addSubview(chunkSizePicker)
        view.addSubview(aggThresholdLab)
        view.addSubview(aggThresholdPicker)
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
        
        decodeWithFileLab.text = "Decode With File:"
        decodeWithFileLab.textColor = R.color.fontBackText_90()

        decodeWithFileSwitch.isOn = false

        largeFileDecodeLab.text = "Large File Decode:"
        largeFileDecodeLab.textColor = R.color.fontBackText_90()

        largeFileDecodeSwitch.isOn = false
        chunkSizeLab.text = "Chunk Size:"
        chunkSizeLab.textColor = R.color.fontBackText_90()
        aggThresholdLab.text = "Aggregate Threshold:"
        aggThresholdLab.textColor = R.color.fontBackText_90()
        
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
        
        decodeWithFileLab.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(isJLHeaderLab.snp.bottom).offset(5)
        }
        
        decodeWithFileSwitch.snp.makeConstraints { make in
            make.left.equalTo(decodeWithFileLab.snp.right).offset(10)
            make.centerY.equalTo(decodeWithFileLab.snp.centerY)
        }

        largeFileDecodeLab.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(decodeWithFileLab.snp.bottom).offset(5)
        }

        largeFileDecodeSwitch.snp.makeConstraints { make in
            make.left.equalTo(largeFileDecodeLab.snp.right).offset(10)
            make.centerY.equalTo(largeFileDecodeLab.snp.centerY)
        }

        chunkSizeLab.snp.makeConstraints { make in
            make.left.equalTo(view).inset(20)
            make.height.equalTo(40)
            make.top.equalTo(largeFileDecodeLab.snp.bottom).offset(5)
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
            make.top.equalTo(chunkSizeLab.snp.bottom).offset(5)
        }

        aggThresholdPicker.snp.makeConstraints { make in
            make.left.equalTo(aggThresholdLab.snp.right).offset(10)
            make.width.equalTo(160)
            make.height.equalTo(40)
            make.centerY.equalTo(aggThresholdLab.snp.centerY)
        }
        
        drawView.snp.makeConstraints { make in
            make.left.right.equalTo(view).inset(20)
            make.top.equalTo(aggThresholdPicker.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(20)
        }

        
    }
    
    override func initData() {
        super.initData()
        self.opusDecoder = JLOpusDecoder(decoder: format, delegate: self)
        fileListView.loadFoldFile(Tools.opusPath)
        //修改回调队列为其他队列
        self.format.callBackQueue = dispatch_queue_t(label: "test.queue");
        
        JLAudioPlayer.shared.start()
        JLAudioPlayer.shared.callBack = { [weak self] data in
            guard let self = self else { return }
            self.drawView.setPcmData(data)
        }
        startBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            let fileName = self.fileListView.fileDidSelect
            let fullPath = Tools.opusPath + "/" + fileName
            guard FileManager.default.fileExists(atPath: fullPath) else {
                self.view.makeToast("File not found", position: .center)
                return
            }
            if self.largeFileDecodeSwitch.isOn {
                let outPath = fullPath.replacingOccurrences(of: ".opus", with: ".pcm")
                JLLogManager.logLevel(.DEBUG, content: "Start large file decode, chunkBytes=\(self.selectedChunkBytes), agg=\(self.selectedAggBytes)")
                self.opusDecoder.opusDecodeLargeFileEx(fullPath, output: outPath, chunkBytes: UInt(self.selectedChunkBytes), aggregateThreshold: UInt(self.selectedAggBytes)) { result, err in
                    if let err = err {
                        self.view.makeToast(err.localizedDescription, position: .center)
                    } else if let result = result {
                        self.view.makeToast("Large Decode Success:\(result)", position: .center)
                        self.fileListView.loadFoldFile(Tools.opusPath)
                    }
                }
            } else if self.decodeWithFileSwitch.isOn == false {
                self.prepareRecorder(baseName: fileName, sourcePath: fullPath)
                self.startLocalPacketRead(filePath: fullPath)
            }else{
                guard let _ = NSData(contentsOfFile: fullPath) as? Data else {
                    self.view.makeToast("File not found", position: .center)
                    return
                }
                self.opusDecoder.opusDecodeFile(fullPath, outPut: fullPath.replacingOccurrences(of: ".opus", with: ".pcm")) { result,err  in
                    if let err = err {
                        self.view.makeToast(err.localizedDescription, position: .center)
                    }else{
                        guard let result = result else { return }
                        self.view.makeToast("Decode Success:\(result)", position: .center)
                        self.fileListView.loadFoldFile(Tools.opusPath)
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        pickerData.bind(to: packerView.rx.itemTitles) { _, item in
            return item
        }.disposed(by: disposeBag)

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

        largeFileDecodeSwitch.rx.value.subscribe(onNext: { [weak self] on in
            guard let self = self else { return }
            let hidden = !on
            JLLogManager.logLevel(.DEBUG, content: "Large file decode: \(on ? "ON" : "OFF")")
            self.chunkSizeLab.isHidden = hidden
            self.chunkSizePicker.isHidden = hidden
            self.aggThresholdLab.isHidden = hidden
            self.aggThresholdPicker.isHidden = hidden
        }).disposed(by: disposeBag)

        chunkSizeLab.isHidden = !largeFileDecodeSwitch.isOn
        chunkSizePicker.isHidden = !largeFileDecodeSwitch.isOn
        aggThresholdLab.isHidden = !largeFileDecodeSwitch.isOn
        aggThresholdPicker.isHidden = !largeFileDecodeSwitch.isOn
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        packerView.selectRow(1, inComponent: 0, animated: true)
        chunkSizePicker.selectRow(1, inComponent: 0, animated: true)
        aggThresholdPicker.selectRow(1, inComponent: 0, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        JLAudioPlayer.shared.stop()
        opusDecoder.opusOnRelease()
        simulationRunning = false
        pcmRecorder?.finish()
        pcmRecorder = nil
        pcmRecorderLeft?.finish()
        pcmRecorderRight?.finish()
        pcmRecorderLeft = nil
        pcmRecorderRight = nil
    }
}

/// MARK: JLOpusDecoderDelegate
extension OpusDecodeVC: JLOpusDecoderDelegate {
    func opusDecoder(_ decoder: JLOpusDecoder, data: Data?, error: (any Error)?) {
        if let data = data {
            JLAudioPlayer.shared.enqueuePCMData(data)
            pcmRecorder?.append(data)
        }
    }

    func opusDecoderStereo(_ decoder: JLOpusDecoder, left: Data?, right: Data?, error: (any Error)?) {
        if let l = left { pcmRecorderLeft?.append(l) }
        if let r = right { pcmRecorderRight?.append(r) }
    }
}

/// 线程安全的 PCM 流式记录器：负责创建 Documents 下的同名 .pcm 文件并维护配套元数据文件，提供追加写入与安全关闭
final class PCMRecorder {
    private let queue = DispatchQueue(label: "com.zh-jieli.pcm.recorder")
    private var handle: FileHandle?
    private let pcmURL: URL
    private let metaURL: URL

    init?(baseName: String, sampleRate: Int, channels: Int, bitsPerChannel: Int, outputDirectory: URL) {
        let pureName = (baseName as NSString).deletingPathExtension
        pcmURL = outputDirectory.appendingPathComponent(pureName).appendingPathExtension("pcm")
        metaURL = outputDirectory.appendingPathComponent(pureName).appendingPathExtension("pcm.meta.json")

        do {
            try FileManager.default.removeItem(at: pcmURL)
        } catch { /* ignore */ }
        do {
            FileManager.default.createFile(atPath: pcmURL.path, contents: nil, attributes: nil)
            handle = try FileHandle(forWritingTo: pcmURL)
        } catch {
            print("PCMRecorder open failed: \(error.localizedDescription)")
            return nil
        }

        let meta: [String: Any] = [
            "createdAt": ISO8601DateFormatter().string(from: Date()),
            "sampleRate": sampleRate,
            "channels": channels,
            "bitsPerChannel": bitsPerChannel,
            "sourceFileName": baseName
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: meta, options: [.prettyPrinted])
            try data.write(to: metaURL, options: [.atomic])
        } catch {
            print("PCMRecorder write meta failed: \(error.localizedDescription)")
        }
    }

    func append(_ data: Data) {
        queue.async { [weak self] in
            guard let self = self, let h = self.handle else { return }
            if #available(iOS 13.4, *) {
                do {
                    try h.seekToEnd()
                    try h.write(contentsOf: data)
                } catch {
                    print("PCMRecorder append failed: \(error.localizedDescription)")
                }
            } else {
                h.seekToEndOfFile()
                h.write(data)
            }
        }
    }

    func finish() {
        queue.sync { [weak self] in
            guard let self = self else { return }
            if #available(iOS 13.4, *) {
                do {
                    try self.handle?.close()
                } catch {
                    JLLogManager.logLevel(.DEBUG, content: "PCMRecorder close failed: \(error.localizedDescription)")
                }
            } else {
                self.handle?.closeFile()
            }
            self.handle = nil
        }
    }
}

private extension OpusDecodeVC {
    func prepareRecorder(baseName: String, sourcePath: String) {
        pcmRecorder?.finish()
        let dir = URL(fileURLWithPath: sourcePath).deletingLastPathComponent()
        pcmRecorder = PCMRecorder(baseName: baseName, sampleRate: Int(self.format.sampleRate), channels: Int(self.format.channels), bitsPerChannel: 16, outputDirectory: dir)
        currentDecodeFileName = baseName
        if Int(self.format.channels) == 2 {
            let pure = (baseName as NSString).deletingPathExtension
            pcmRecorderLeft?.finish()
            pcmRecorderRight?.finish()
            pcmRecorderLeft = PCMRecorder(baseName: pure + "_L.pcm", sampleRate: Int(self.format.sampleRate), channels: 1, bitsPerChannel: 16, outputDirectory: dir)
            pcmRecorderRight = PCMRecorder(baseName: pure + "_R.pcm", sampleRate: Int(self.format.sampleRate), channels: 1, bitsPerChannel: 16, outputDirectory: dir)
        } else {
            pcmRecorderLeft?.finish()
            pcmRecorderRight?.finish()
            pcmRecorderLeft = nil
            pcmRecorderRight = nil
        }
    }

    func startLocalPacketRead(filePath: String) {
        simulationRunning = true
        readOpusQueue.async { [weak self] in
            guard let self = self else { return }
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
            var len = 0
            var subLen = format.dataSize
            if format.hasDataHeader {
                subLen += 8
            }
            while len < data.count {
                let packet = data.subdata(in: len ..< len + Int(subLen))
                self.opusDecoder.opusDecoderInputData(packet)
                len += Int(subLen)
                usleep(200)
            }
        }
    }
}
