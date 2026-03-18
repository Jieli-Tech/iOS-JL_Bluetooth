//
//  OTA4GViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2024/1/3.
//

import UIKit

class OTA4GViewController: BaseViewController {
    let selectFileBtn = UIButton()
    let initializeBtn = UIButton()
    let startOtaBtn = UIButton()
    let stopOtaBtn = UIButton()
    let fileLab = UILabel()
    let statusLab = UILabel()
    let progressView = UIProgressView()
    let progressLab = UILabel()
    let fileListView = FileLoadView()

    var otaFilePath = ""
    var manager4G = JL4GUpgradeManager.share()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let cmdMgr = BleManager.shared.currentCmdMgr {
            JLDeviceConfig.share().deviceGet(cmdMgr) { _, _, model in
                model?.exportFunc.logProperties()
            }
        }
    }

    override func initUI() {
        super.initUI()
        navigationView.title = "4G OTA"
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        view.addSubview(selectFileBtn)
        view.addSubview(initializeBtn)
        view.addSubview(startOtaBtn)
        view.addSubview(stopOtaBtn)
        view.addSubview(fileLab)
        view.addSubview(statusLab)
        view.addSubview(progressView)
        view.addSubview(progressLab)
        view.addSubview(fileListView)

        selectFileBtn.setTitle(R.localStr.select4GOTAFile(), for: .normal)
        selectFileBtn.setTitleColor(UIColor.black, for: .normal)
        selectFileBtn.backgroundColor = UIColor.random()
        selectFileBtn.setTitleColor(UIColor.white, for: .normal)
        selectFileBtn.layer.cornerRadius = 8
        selectFileBtn.clipsToBounds = true

        initializeBtn.setTitle(R.localStr.initialize(), for: .normal)
        initializeBtn.setTitleColor(UIColor.black, for: .normal)
        initializeBtn.backgroundColor = UIColor.random()
        initializeBtn.setTitleColor(UIColor.white, for: .normal)
        initializeBtn.layer.cornerRadius = 8
        initializeBtn.clipsToBounds = true

        startOtaBtn.setTitle(R.localStr.start(), for: .normal)
        startOtaBtn.setTitleColor(UIColor.black, for: .normal)
        startOtaBtn.backgroundColor = UIColor.eHex("00ffcd")
        startOtaBtn.setTitleColor(UIColor.white, for: .normal)
        startOtaBtn.layer.cornerRadius = 8
        startOtaBtn.clipsToBounds = true

        stopOtaBtn.setTitle(R.localStr.cancel(), for: .normal)
        stopOtaBtn.setTitleColor(UIColor.black, for: .normal)
        stopOtaBtn.backgroundColor = UIColor.eHex("00ffcd")
        stopOtaBtn.setTitleColor(UIColor.white, for: .normal)
        stopOtaBtn.layer.cornerRadius = 8
        stopOtaBtn.clipsToBounds = true

        fileLab.text = R.localStr.noFileSelected()
        fileLab.textAlignment = .center
        fileLab.textColor = UIColor.eHex("002200")
        fileLab.font = UIFont.boldSystemFont(ofSize: 16)

        statusLab.text = R.localStr.otaNotStartedYet()
        statusLab.textAlignment = .left
        statusLab.textColor = UIColor.eHex("002200")
        statusLab.font = UIFont.boldSystemFont(ofSize: 16)

        progressView.progress = 0.0
        progressView.progressTintColor = UIColor.eHex("#cc4a1c")
        progressView.trackTintColor = UIColor.eHex("d8d8d8")

        progressLab.text = "0%"
        progressLab.textAlignment = .center
        progressLab.textColor = UIColor.eHex("#002200")
        progressLab.font = UIFont.boldSystemFont(ofSize: 16)

        fileListView.isHidden = true

        stopOtaBtn.isHidden = true

        selectFileBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        fileLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(selectFileBtn.snp.bottom).offset(10)
            make.height.equalTo(20)
        }
        initializeBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(fileLab.snp.bottom).offset(10)
            make.height.equalTo(40)
        }

        statusLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(initializeBtn.snp.bottom).offset(10)
            make.height.equalTo(20)
        }

        progressView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(progressLab.snp.left)
            make.top.equalTo(statusLab.snp.bottom).offset(10)
        }
        progressLab.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.width.equalTo(70)
            make.centerY.equalTo(progressView.snp.centerY)
        }

        startOtaBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(progressView.snp.bottom).offset(30)
            make.height.equalTo(40)
        }

        stopOtaBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(startOtaBtn.snp.bottom).offset(10)
            make.height.equalTo(40)
        }

        fileListView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        }
    }

    override func initData() {
        super.initData()

        manager4G.delegate = self

        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        selectFileBtn.rx.tap.subscribe { [weak self] _ in
            self?.fileListView.isHidden = false
            self?.fileListView.showFiles(_R.path.ota4gfile)
        }.disposed(by: disposeBag)

        fileListView.handleBlock = { [weak self] file in
            self?.fileLab.text = (file as NSString).lastPathComponent
            self?.otaFilePath = file
        }

        initializeBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            guard let cmdMgr = BleManager.shared.currentCmdMgr else { return }
            self.manager4G.cmdGetDevice4GInfo(cmdMgr) { _, model in
                guard let model = model else { return }
                model.logProperties()
            }
        }.disposed(by: disposeBag)

        startOtaBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            guard let dt = try? Data(contentsOf: URL(fileURLWithPath: self.otaFilePath)) else { return }
            guard let cmdMgr = BleManager.shared.currentCmdMgr else { return }
            self.manager4G.cmdStartUpgrade4G(cmdMgr, data: dt)
            self.startOtaBtn.isUserInteractionEnabled = false
            self.startOtaBtn.alpha = 0.6
        }.disposed(by: disposeBag)

        stopOtaBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            guard let cmdMgr = BleManager.shared.currentCmdMgr else { return }
            self.manager4G.cmdCancel4GUpgrade(cmdMgr)
        }.disposed(by: disposeBag)
    }
}

extension OTA4GViewController: JL4GUpgradeDelegate {
    func jl4GGetDeviceInfo(_: JLPublic4GModel) {}

    func jl4GUpgradeResult(_: JL4GUpgradeManager, status: JL4GUpgradeStatus, progress: Float, code: UInt8, error: Error?) {
        switch status {
        case .finish:
            if code != 0x00 {
                statusLab.text = R.localStr.otaFail()
                view.makeToast("\(String(describing: error?.localizedDescription))", position: .center)
            } else {
                statusLab.text = R.localStr.otaSuccess()
            }
            startOtaBtn.isUserInteractionEnabled = true
            startOtaBtn.alpha = 1
        case .start:
            statusLab.text = R.localStr.startOTA()
        case .transporting:
            statusLab.text = R.localStr.upgrading()
            progressView.progress = progress
            progressLab.text = "\(Int(progress * 100))%"
        case .deviceProcessing:
            statusLab.text = R.localStr.theUpgradeDataHasBeenSentAndTheDeviceIsBeingProcessed()
        @unknown default:
            break
        }
    }
}
