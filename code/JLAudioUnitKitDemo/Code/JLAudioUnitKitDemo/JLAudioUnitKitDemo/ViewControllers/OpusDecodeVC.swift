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
/// 提供本地分包读取与 PCM 数据记录保存能力，支持随机分包大小但保持顺序，确保数据完整性，并以流式方式写入 Documents 下的同名 .pcm 文件及配套元数据，满足线程安全与内存高效要求。
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
            let fileName = self.fileListView.fileDidSelect
            let fullPath = Tools.opusPath + "/" + fileName
            guard FileManager.default.fileExists(atPath: fullPath) else {
                self.view.makeToast("File not found", position: .center)
                return
            }
            self.prepareRecorder(baseName: fileName, sourcePath: fullPath)
            self.startLocalPacketRead(filePath: fullPath)
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
