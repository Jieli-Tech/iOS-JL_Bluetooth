//
//  PcmToWtgVC.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2025/1/21.
//

import UIKit

class PcmToWtgVC: BaseViewController {

    private let fileListView = FileListView()
    private let reloadFileBtn = UIButton()
    private let startBtn = UIButton()
    private let recordBtn = UIButton()
    private let stopRecordBtn = UIButton()
    
    private lazy var pcmToWtg:JLPcmToWtg = {
        JLPcmToWtg(delegate: self)
    }()
    
    override func initUI() {
        super.initUI()
        navigationView.title = "PCM To WTG"
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
        fileListView.loadFoldFile(Tools.wtgPath)
        
        reloadFileBtn.rx.tap.bind { [weak self] in
            self?.fileListView.loadFoldFile(Tools.wtgPath)
        }.disposed(by: disposeBag)
        
        startBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.fileListView.fileDidSelect.count == 0 {
                return
            }
            let path = Tools.wtgPath + "/" + self.fileListView.fileDidSelect
            let obj = JLPcm2WtgModel()
            obj.pcmPath = path
            obj.wtgPath = path.replacingOccurrences(of: ".pcm", with: ".wtg")
            self.pcmToWtg.convert(obj)
        }).disposed(by: disposeBag)
        
        recordBtn.rx.tap.subscribe(onNext: {  _ in
            let path = Tools.wtgPath + "/record.pcm"
            JLAudioRecoder.shared.start(path, 8000)
        }).disposed(by: disposeBag)
        
        stopRecordBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            JLAudioRecoder.shared.stop()
            self.fileListView.loadFoldFile(Tools.wtgPath)
        }).disposed(by: disposeBag)
        
    }

}

extension PcmToWtgVC:JLPcmToWtgDelegate {
    func convertPcm(toWtgDone model: JLPcm2WtgModel) {
        print(model)
    }
}
