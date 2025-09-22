//
//  RecordDecoderVC.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/13.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JLAudioUnitKit

class RecordDecoderVC: BaseViewController {
    private let recoderStatus = UILabel()
    private let recoderBtn = UIButton()
    private let isHasHeaderLab = UILabel()
    private let switchHeader = UISwitch()
    private let waveformView = PCMWaveformView()
    private let isSaveOpusLab = UILabel()
    private let saveOpusSwitchBtn = UISwitch()
    private let isSavePcmLab = UILabel()
    private let savePcmSwitchBtn = UISwitch()
    private let documentBrowserView = DocumentBrowserView(initialPath: _R.path.document)
    
    private var recoder:JL_SpeexManager?
    private var decoder: JLOpusDecoder?
    private var recoderParams: JLRecordParams?
    private var format: JLOpusFormat = {
        let fm = JLOpusFormat.defaultFormats()
        fm.hasDataHeader = false
        return fm
    }()
    private var saveOpusFilePath = ""
    private var savePcmFilePath = ""
    
    override func initData() {
        super.initData()
        decoder = JLOpusDecoder(decoder: format, delegate: self)
        let mManager = BleManager.shared.currentCmdMgr
        recoder = JL_SpeexManager.share(self, withManager: mManager!)
        
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        switchHeader.rx.value.subscribe(onNext: { [weak self] isOn in
            guard let self = self else { return }
            format.hasDataHeader = isOn
            decoder?.opusFormat = format
        }).disposed(by: disposeBag)
        
        recoderBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self,
                  let mgr = BleManager.shared.currentCmdMgr else { return }
            if self.recoder?.cmdCheckRecordStatus() == .doing {
                self.recoder?.cmdStopRecord(mgr, reason: .normal)
                self.recoderBtn.setTitle(R.localStr.startRecorder(), for: .normal)
                self.recoderBtn.backgroundColor = .blue
            } else {
                let params = JLRecordParams()
                params.mDataType = .OPUS
                params.mSampleRate = .rate16K
                params.mVadWay = .normal
                self.recoder?.cmdStartRecord(mgr, params: params) { status, _, _ in
                    if status == .success {
                        self.recoderBtn.setTitle(R.localStr.stopRecorder(), for: .normal)
                        self.recoderBtn.backgroundColor = .red
                        if self.savePcmSwitchBtn.isOn {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyyMMddHHmmss"
                            self.savePcmFilePath = _R.path.pcmPath + "/" + dateFormatter.string(from: Date()) + "_opus.pcm"
                        }
                        if self.saveOpusSwitchBtn.isOn {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyyMMddHHmmss"
                            self.saveOpusFilePath = _R.path.opusPath + "/" + dateFormatter.string(from: Date()) + "_opus.opus"
                        }
                    }
                }
            }
        }).disposed(by: disposeBag)
        
        JLAudioPlayer.shared.callBack = { [weak self] data in
            guard let self = self else { return }
            waveformView.appendPCMData(from: data)
        }
    }
    
    
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.voiceTransmissionDecoding()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(recoderStatus)
        view.addSubview(recoderBtn)
        view.addSubview(isHasHeaderLab)
        view.addSubview(switchHeader)
        view.addSubview(isSaveOpusLab)
        view.addSubview(saveOpusSwitchBtn)
        view.addSubview(isSavePcmLab)
        view.addSubview(savePcmSwitchBtn)
        view.addSubview(waveformView)
        view.addSubview(documentBrowserView)
        
        recoderStatus.text = R.localStr.unopened()
        recoderStatus.textColor = .black
        recoderStatus.textAlignment = .center
        recoderStatus.font = UIFont.boldSystemFont(ofSize: 15)
        
        recoderBtn.setTitle(R.localStr.startRecorder(), for: .normal)
        recoderBtn.layer.cornerRadius = 10
        recoderBtn.backgroundColor = .blue
        recoderBtn.setTitleColor(.white, for: .normal)
        
        switchHeader.isOn = false
        
        isHasHeaderLab.text =  "OPUS" + R.localStr.withStandardHeaders()
        isHasHeaderLab.textColor = .black
        isHasHeaderLab.font = UIFont.boldSystemFont(ofSize: 15)
        
        isSaveOpusLab.text = R.localStr.saveOPUSData()
        isSaveOpusLab.textColor = .black
        isSaveOpusLab.font = UIFont.boldSystemFont(ofSize: 15)
        
        saveOpusSwitchBtn.isOn = false
        
        isSavePcmLab.text = R.localStr.savePCMData()
        isSavePcmLab.textColor = .black
        isSavePcmLab.font = UIFont.boldSystemFont(ofSize: 15)
        
        savePcmSwitchBtn.isOn = false
        
        waveformView.backgroundColor = .white
        waveformView.layer.cornerRadius = 8
        waveformView.layer.masksToBounds = true
        
        documentBrowserView.contextView = self
        documentBrowserView.layer.cornerRadius = 8
        documentBrowserView.layer.masksToBounds = true
        
        isHasHeaderLab.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
        }
        switchHeader.snp.makeConstraints { make in
            make.left.equalTo(isHasHeaderLab.snp.right).offset(10)
            make.centerY.equalTo(isHasHeaderLab)
        }
        
        isSaveOpusLab.snp.makeConstraints { make in
            make.top.equalTo(switchHeader.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
        }
        saveOpusSwitchBtn.snp.makeConstraints { make in
            make.left.equalTo(isSaveOpusLab.snp.right).offset(10)
            make.centerY.equalTo(isSaveOpusLab)
        }
        
        isSavePcmLab.snp.makeConstraints { make in
            make.top.equalTo(saveOpusSwitchBtn.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
        }
        savePcmSwitchBtn.snp.makeConstraints { make in
            make.left.equalTo(isSavePcmLab.snp.right).offset(10)
            make.centerY.equalTo(isSavePcmLab)
        }
        
        recoderStatus.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(savePcmSwitchBtn.snp.bottom).offset(10)
        }
        recoderBtn.snp.makeConstraints { make in
            make.top.equalTo(recoderStatus.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        waveformView.snp.makeConstraints { make in
            make.top.equalTo(recoderBtn.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        documentBrowserView.snp.makeConstraints { make in
            make.top.equalTo(waveformView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //TODO: test code
//        guard let path = R.file.test_translationOpus.url(),
//              let data = try? Data(contentsOf: path) else {
//            return
//        }
//        DispatchQueue.global().async {
//            self.decoder?.opusDecoderInputData(data)
//        }
    }
    
    
    

}
//MARK: - decoder call back
extension RecordDecoderVC: JLOpusDecoderDelegate {
    func opusDecoder(_ decoder: JLOpusDecoder, data: Data?, error: (any Error)?) {
        guard let pcm = data else { return }
        JLAudioPlayer.shared.enqueuePCMData(pcm)
        if savePcmSwitchBtn.isOn {
            JL_Tools.write(pcm, endFile: self.savePcmFilePath)
        }
    }
}

//MARK: - 录音回调
extension RecordDecoderVC: JL_SpeexManagerDelegate {
    func speexManager(_ manager: JL_SpeexManager, audio data: Data) {
        //get Opus data
        guard let recoderParams = recoderParams,
              let decoder = decoder else { return }
        if recoderParams.mDataType != .OPUS {
            return
        }
        decoder.opusDecoderInputData(data)
        if saveOpusSwitchBtn.isOn {
            JL_Tools.write(data, endFile: self.saveOpusFilePath)
        }
    }
    
    func speexManager(_ manager: JL_SpeexManager, startByDeviceWithParam param: JLRecordParams) {
        //recoder format
        recoderParams = param
    }
    
    func speexManager(_ manager: JL_SpeexManager, stopByDeviceWithParam param: JLSpeechRecognition) {
        //stop recorder format
    }
    
    func speexManager(_ manager: JL_SpeexManager, status: JL_SpeakType) {
        //recoder status
        
    }
    
    
}
