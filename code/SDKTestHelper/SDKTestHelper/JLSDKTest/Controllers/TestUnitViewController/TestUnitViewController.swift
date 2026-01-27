//
//  TestUnitViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/11.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JPEGTurbo

class TestUnitViewController: BaseViewController {

    private let subTable = UITableView()
    private let subItemArray: BehaviorRelay<[String]> = BehaviorRelay(value: [])
    private var trJlav2:TranslateAV2Helper?
    override func initUI() {
        super.initUI()
        navigationView.title = "TestUnit"
        navigationView.rightBtn.isHidden = true
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        subTable.register(FuncSelectCell.self, forCellReuseIdentifier: "FUNCCell")
        subTable.rowHeight = 60
        subTable.separatorStyle = .none
        view.addSubview(subTable)
        subTable.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
        subItemArray.bind(to: subTable.rx.items(cellIdentifier: "FUNCCell", cellType: FuncSelectCell.self)) { _, element, cell in
            cell.titleLab.text = element
        }.disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trJlav2 = TranslateAV2Helper({ pcmData in
            
            JLAudioPlayer.shared.enqueuePCMData(pcmData)
            
        }, { [weak self] jlavData in
            guard let self = self else { return }
            trJlav2?.decodeDataToPcm(jlavData)
        })
        
    }
    override func initData() {
        super.initData()
        subItemArray.accept(["AudioSession Test Unit","DialInfoExtent","Network Extension Test","Jpeg convert to jpg"])
        subTable.rx.modelSelected(String.self).subscribe(onNext: { [weak self] model in
            guard let self = self else { return }
            if model == "AudioSession Test Unit" {
                let vc = AudioSessionUnitViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if model == "DialInfoExtent" {
                guard let manager = BleManager.shared.currentCmdMgr else {return}
                JLDialInfoExtentManager.share().getDialInfoExtented(manager) {  status, model in
                    let str = model?.logProperties() ?? ""
                    let alert = UIAlertController(title: "DialInfoExtent", message: str, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: R.localStr.confirm(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            }
            if model == "Network Extension Test" {
                let vc = TestNetworkExtensionVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
            if model == "Jpeg convert to jpg" {
                guard let path = R.file.convert_1Jpg.url(), let img = UIImage(contentsOfFile: path.path) else { return }
                let size = img.size
                let newImg = JpegProcessor.compressImage(img, targetSize: size, quality: 1, maxFileSize: 0)
                let savePath = NSHomeDirectory() + "/Documents/test.jpg"
                try?FileManager.default.removeItem(atPath: savePath)
                FileManager.default.createFile(atPath: savePath, contents: newImg, attributes: nil)
            }
            subTable.reloadData()
        }).disposed(by: disposeBag)
    }

}
