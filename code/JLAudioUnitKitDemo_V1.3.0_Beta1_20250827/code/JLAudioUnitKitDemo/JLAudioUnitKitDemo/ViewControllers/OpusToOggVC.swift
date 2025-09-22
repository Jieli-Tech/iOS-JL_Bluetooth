//
//  OpusToOggVC.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2025/5/16.
//

import UIKit

class OpusToOggVC: BaseViewController {
    private let fileListView = FileListView()
    private let reloadFileBtn = UIButton()
    private let startBtn = UIButton()
    private let oggConvertMgr = JLOpusToOgg(frameLength: 40)
    
    
    override func initUI() {
        super.initUI()
        navigationView.title = "PCM To WAV"
        view.addSubview(fileListView)
        view.addSubview(reloadFileBtn)
        view.addSubview(startBtn)
        
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
        
        
    }
    
    override func initData() {
        fileListView.loadFoldFile(Tools.opusPath)
        
        reloadFileBtn.rx.tap.bind { [weak self] in
            self?.fileListView.loadFoldFile(Tools.opusPath)
        }.disposed(by: disposeBag)
        
        startBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.fileListView.fileDidSelect.count == 0 {
                return
            }
            makeConvert()
            
        }).disposed(by: disposeBag)
        
    }
    private func convertFile(){
        let path = Tools.opusPath + "/" + self.fileListView.fileDidSelect
        guard let data = NSData(contentsOfFile: path) as? Data else {
            return
        }
        let path1 = path.replacingOccurrences(of: ".opus", with: ".ogg")
        try? FileManager.default.removeItem(atPath: path1)
        var oggData: Data?
        var duartion: Double = 0
        do {
            oggData = try JLOpusToOgg.convertOpusData(toOgg: data, frameLen: 40, duration: &duartion)
        } catch {
            self.view.makeToast("err:\(error.localizedDescription)", position: .center)
        }
        FileManager.default.createFile(atPath: path1, contents: oggData)
        fileListView.loadFoldFile(Tools.opusPath)
    }
    
    private func makeConvert() {
        let path = Tools.opusPath + "/" + self.fileListView.fileDidSelect
        guard let opusData = NSData(contentsOfFile: path) as? Data else {
            return
        }
        var oggData: Data = Data()
        oggConvertMgr.convertBlock = { [weak self] data,isEnd,err in
            guard let _ = self,
                  let data = data else {return}
            oggData.append(data)
            if isEnd {
                self?.view.makeToast("Convert Success", position: .center)
            }
        }
        
        oggConvertMgr.startStream()
        
        var offset = 0
        while offset < opusData.count {
            let end = min(offset + 40, opusData.count)
            let chunk = opusData.subdata(in: offset..<end)
            offset += 40
            oggConvertMgr.appendOpusData(chunk)
        }
        oggConvertMgr.closeStream()

        let path1 = path.replacingOccurrences(of: ".opus", with: ".ogg")
        try? FileManager.default.removeItem(atPath: path1)
        FileManager.default.createFile(atPath: path1, contents: oggData)
        fileListView.loadFoldFile(Tools.opusPath)
    }
}
