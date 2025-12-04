//
//  Mp3ToUmp3VC.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2025/11/28.
//

import UIKit

/// Mp3ToUmp3VC
/// 单声道 MP3 → UMP3 转换示例页面
class Mp3ToUmp3VC: BaseViewController {
    private let fileListView = FileListView()
    private let reloadFileBtn = UIButton()
    private let startBtn = UIButton()

    override func initUI() {
        super.initUI()
        navigationView.title = "MP3 To UMP3"
        view.addSubview(fileListView)
        view.addSubview(reloadFileBtn)
        view.addSubview(startBtn)

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
        super.initData()
        fileListView.loadFoldFile(Tools.mp3Path)

        reloadFileBtn.rx.tap.bind { [weak self] in
            self?.fileListView.loadFoldFile(Tools.mp3Path)
        }.disposed(by: disposeBag)

        startBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            if self.fileListView.fileDidSelect.count == 0 {
                return
            }
            let mp3Path = Tools.mp3Path + "/" + self.fileListView.fileDidSelect
            let outPath: String
            if mp3Path.hasSuffix(".mp3") {
                outPath = (mp3Path as NSString).deletingPathExtension + ".ump3"
            } else {
                outPath = mp3Path + ".ump3"
            }
            JLAudioConverter.convertMP3(toUmp3: mp3Path, ump3Path: outPath) { success in
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.fileListView.loadFoldFile(Tools.mp3Path)
                    var fsOk = false
                    let fm = FileManager.default
                    if fm.fileExists(atPath: outPath) {
                        if let attrs = try? fm.attributesOfItem(atPath: outPath),
                           let size = attrs[.size] as? NSNumber,
                           size.intValue > 0 {
                            fsOk = true
                        }
                    }
                    if success && fsOk {
                        self.view.makeToast("Convert Success")
                    } else {
                        self.view.makeToast("Convert Failed")
                    }
                }
            }
        }).disposed(by: disposeBag)
    }
}
