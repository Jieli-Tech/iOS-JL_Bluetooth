//
//  CreateVoicesViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2024/1/24.
//

import JL_BLEKit
import JLUsefulTools
import JLPackageResKit
import UIKit

class CreateVoicesViewController: BaseViewController {
    let getInfoBtn = UIButton()
    let infoLab = UILabel()
    let subTable = UITableView()
    let makePcmBtn = UIButton()
    let pcm2wtsBtn = UIButton()
    let drawView = PlotView(frame: CGRectMake(0, 0, UIScreen.main.bounds.size.width, 90))
    let makePackageBtn = UIButton()
    let makeBundlePcmPkgBtn = UIButton()
    let tipsView = CreateVoiceView()

    private var isRecording = false
    private let voiceReplace = JLTipsSoundReplaceMgr.share()
    private var voiceInfo: JLVoiceReplaceInfo?
    private let items = BehaviorRelay<[JLTipsVoiceInfo]>(value: [])
    private var finishIndex = 0
    private let audioHelper = JLAudioRecoder()
    private var audioPlayer: AVAudioPlayer?
    private let audioFm = DFAudioFormat()
    private var tipsVoiceInfos: [TipsVoiceModel] = []
    var ecTask = EasyStack<String>()

    override func viewDidLoad() {
        super.viewDidLoad()

        var testItems: [JLTipsVoiceInfo] = []
        for i in 0 ..< 1 {
            let v = JLTipsVoiceInfo()
            v.fileName = String(i) + ".wts"
            v.index = UInt8(i)
            v.length = 65535
            v.nickName = R.localStr.nickName() + String(i)
            v.offset = 0x00
            testItems.append(v)
        }
        items.accept(testItems)
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.promptTonePacking()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(getInfoBtn)
        view.addSubview(infoLab)
        view.addSubview(subTable)
        view.addSubview(drawView)
        view.addSubview(makePcmBtn)
        view.addSubview(pcm2wtsBtn)
        view.addSubview(makePackageBtn)
        view.addSubview(makeBundlePcmPkgBtn)
        view.addSubview(tipsView)

        getInfoBtn.setTitle(R.localStr.getDevicePromptInfo(), for: .normal)
        getInfoBtn.setTitleColor(.white, for: .normal)
        getInfoBtn.backgroundColor = UIColor.random()
        getInfoBtn.layer.cornerRadius = 10
        getInfoBtn.layer.masksToBounds = true
        getInfoBtn.titleLabel?.adjustsFontSizeToFitWidth = true

        infoLab.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        infoLab.adjustsFontSizeToFitWidth = true
        infoLab.textColor = .darkText
        infoLab.numberOfLines = 0

        drawView.backgroundColor = UIColor.white

        makePcmBtn.setTitle(R.localStr.recordPCM(), for: .normal)
        makePcmBtn.setTitleColor(.white, for: .normal)
        makePcmBtn.backgroundColor = UIColor.random()
        makePcmBtn.layer.cornerRadius = 10
        makePcmBtn.layer.masksToBounds = true

        pcm2wtsBtn.setTitle(R.localStr.pcmToWTS(), for: .normal)
        pcm2wtsBtn.setTitleColor(.white, for: .normal)
        pcm2wtsBtn.backgroundColor = UIColor.random()
        pcm2wtsBtn.layer.cornerRadius = 10
        pcm2wtsBtn.layer.masksToBounds = true

        makePackageBtn.setTitle(R.localStr.byRecordCustomVoices(), for: .normal)
        makePackageBtn.setTitleColor(.white, for: .normal)
        makePackageBtn.backgroundColor = UIColor.random()
        makePackageBtn.layer.cornerRadius = 10
        makePackageBtn.layer.masksToBounds = true

        makeBundlePcmPkgBtn.setTitle(R.localStr.bySandBoxVoices(), for: .normal)
        makeBundlePcmPkgBtn.setTitleColor(.white, for: .normal)
        makeBundlePcmPkgBtn.backgroundColor = UIColor.random()
        makeBundlePcmPkgBtn.layer.cornerRadius = 10
        makeBundlePcmPkgBtn.layer.masksToBounds = true

        tipsView.isHidden = true

        subTable.backgroundColor = UIColor.clear
        subTable.rowHeight = 60
        subTable.tableFooterView = UIView()
        subTable.register(VoiceInfoCell.self, forCellReuseIdentifier: "tagCell")
        subTable.separatorStyle = .none

        items.bind(to: subTable.rx.items(cellIdentifier: "tagCell", cellType: VoiceInfoCell.self)) { [weak self] index, item, cell in
            guard let `self` = self else { return }
            cell.makeModel(item)
            if index <= self.finishIndex {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }.disposed(by: disposeBag)

        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(getInfoBtn.snp.bottom).offset(12)
            make.height.equalTo(200)
        }

        infoLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(12)
            make.height.equalTo(60)
        }

        getInfoBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(infoLab.snp.bottom).offset(12)
            make.height.equalTo(35)
        }
        drawView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(subTable.snp.bottom).offset(12)
            make.height.equalTo(90)
        }

        makePcmBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.height.equalTo(35)
            make.right.equalTo(pcm2wtsBtn.snp.left).offset(-12)
            make.width.equalTo(pcm2wtsBtn.snp.width)
            make.top.equalTo(drawView.snp.bottom).offset(12)
        }

        pcm2wtsBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.left.equalTo(makePcmBtn.snp.right).offset(12)
            make.width.equalTo(makePcmBtn.snp.width)
            make.top.equalTo(drawView.snp.bottom).offset(12)
            make.height.equalTo(35)
        }

        tipsView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        makePackageBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(pcm2wtsBtn.snp.bottom).offset(12)
            make.height.equalTo(35)
        }

        makeBundlePcmPkgBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(makePackageBtn.snp.bottom).offset(12)
            make.height.equalTo(35)
        }
    }

    override func initData() {
        super.initData()

        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        audioFm.mSampleRate = 16000
        audioFm.mChannelsPerFrame = 1
        audioFm.mBitsPerChannel = 16
        audioFm.mFormatID = kAudioFormatLinearPCM

//        audioHelper.setRecorderFormat(audioFm)
        
        drawView.fm = audioFm
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, options: .defaultToSpeaker)
        session.requestRecordPermission { [weak self] granted in
            guard let `self` = self else { return }
            if !granted {
                self.view.makeToast(R.localStr.pleaseAllowMicrophoneAccess())
            }
        }


        getInfoBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            guard let cmdMgr = BleManager.shared.currentCmdMgr else { return }
            voiceReplace.voicesReplaceGetVoiceInfo(cmdMgr) { cmdStatus, data in
                if cmdStatus != .success {
                    self.view.makeToast(R.localStr.errorRequestingDeviceInformation())
                    return
                }
                if data == nil {
                    return
                }
                self.voiceInfo = JLVoiceReplaceInfo(data!)
                guard let info = self.voiceInfo else {
                    return
                }
                self.infoLab.text = R.localStr.numberOfFiles() + String(info.maxNum) + "\n" + R.localStr.fileName() + info.fileName + "\n" + R.localStr.reservedAreaSize() + String(info.blockSize)
                self.items.accept(info.infoArray)
            }
        }.disposed(by: disposeBag)

        pcm2wtsBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }

            let model = self.items.value[self.finishIndex]
            let wtsPath = _R.path.tipsVoice + "/" + model.fileName
            try? FileManager.default.removeItem(atPath: wtsPath)
            self.tipsView.isHidden = false
            JLPcmToWts.share().pcm(toWts: _R.path.library + "/temp.pcm", bitOutFileName: wtsPath, targetRate: 20000, sr_in: 16000, vadthr: 0, usesavemodef: 0) { status, _, _ in
                if status {
                    ECPrintDebug("pcm2wts success", self, "\(#function)", #line)
                    self.view.makeToast(R.localStr.pcm2wtsSuccess())
                    self.finishIndex += 1
                    let md = TipsVoiceModel(name: model.nickName, file: model.fileName, path: wtsPath, type: false)
                    self.tipsVoiceInfos.append(md)
                    self.subTable.reloadData()
                    self.tipsView.isHidden = true
                }
            }
        }.disposed(by: disposeBag)

        makePcmBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            if self.isRecording {
                self.audioHelper.stop()
                self.makePcmBtn.setTitle(R.localStr.start(), for: .normal)
                let tmpPath = _R.path.library + "/temp.pcm"
                let recPathData = try! Data(contentsOf: URL(fileURLWithPath: tmpPath))
                self.drawView.points = recPathData
                DDOpenALAudioPlayer.sharePalyer().openAudio(fromQueue: recPathData, samplerate: Int32(audioFm.mSampleRate), channels: Int32(audioFm.mChannelsPerFrame), bit: Int32(audioFm.mBitsPerChannel))
            } else {
                DDOpenALAudioPlayer.sharePalyer().stopSound()
                let tmpPath = _R.path.library + "/temp.pcm"
                try? FileManager.default.removeItem(atPath: tmpPath)
                try?self.audioHelper.startRecording(toFile: tmpPath)
                self.makePcmBtn.setTitle(R.localStr.cancel(), for: .normal)
            }
            self.isRecording.toggle()
        }.disposed(by: disposeBag)

        makePackageBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
//            if self.finishIndex == items.value.count-1{
            if let info = self.voiceInfo {
                let vc = PackageResViewController()
                vc.canNotPushBack = true
                vc.info = info
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.view.makeToast(R.localStr.pleaseObtainTheDevicePromptInformationFirst(), position: .center)
            }
//            }else{
//                self.view.makeToast("请先生成所有文件",position: .center)
//            }
        }.disposed(by: disposeBag)

        makeBundlePcmPkgBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            guard let pcms = _R.path.pcmPath.listFile(), pcms.count > 0 else {
                self.view.makeToast(R.localStr.pleaseImportThePcmFileIntoTheDocumentPcmDataFolderFirst(), position: .center)
                return
            }

            tipsView.isHidden = false
            for item in pcms {
                self.ecTask.push(item)
            }
            self.changeToWts()
        }.disposed(by: disposeBag)
    }

    private func changeToWts() {
        if let str = ecTask.pop() {
            let name = (str as NSString).lastPathComponent.replacingOccurrences(of: ".pcm", with: ".wts")
            let wtsPath = _R.path.tipsVoice + "/" + name
            try? FileManager.default.removeItem(atPath: wtsPath)
            JLPcmToWts.share().pcm(toWts: str, bitOutFileName: wtsPath, targetRate: 20000, sr_in: 16000, vadthr: 0, usesavemodef: 0) { [weak self] _, _, _ in
                self?.changeToWts()
            }
        } else {
            tipsView.isHidden = true
            if let info = voiceInfo {
                let vc = PackageResViewController()
                vc.info = info
                navigationController?.pushViewController(vc, animated: true)
            } else {
                view.makeToast(R.localStr.pleaseObtainTheDevicePromptInformationFirst(), position: .center)
            }
        }
    }
}

private extension Data {
    mutating func add(_ num: UInt16) {
        let byte1 = UInt8(num >> 8)
        let byte2 = UInt8(num & 0xFF)
        let dt = Data([byte1, byte2])
        append(dt)
    }

    mutating func add(_ num: UInt32) {
        let byte1 = UInt16(num >> 16)
        let byte2: uint16 = UInt16(num & 0xFFFF)
        add(byte1)
        add(byte2)
    }
}

private class VoiceInfoCell: UITableViewCell {
    let mainLab = UILabel()
    let subLab = UILabel()

    private var model: JLTipsVoiceInfo?
    private let disposeBag = DisposeBag()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mainLab)
        contentView.addSubview(subLab)

        mainLab.font = UIFont.systemFont(ofSize: 14)
        mainLab.textColor = UIColor.darkText
        subLab.font = UIFont.systemFont(ofSize: 12)
        subLab.textColor = UIColor.darkText

        mainLab.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.height.equalTo(20)
            make.left.equalToSuperview().inset(8)
        }

        subLab.snp.makeConstraints { make in
            make.top.equalTo(mainLab.snp.bottom)
            make.height.equalTo(20)
            make.left.equalToSuperview().inset(8)
        }
    }

    func makeModel(_ md: JLTipsVoiceInfo) {
        mainLab.text = R.localStr.fileName() + ":" + md.fileName
        subLab.text = "NickName:" + md.nickName + " index：" + String(md.index) + " size:" + String(md.length)
        model = md
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
