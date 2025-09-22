//
//  OTAViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/11/9.
//

import UIKit

class OTAViewController: BaseViewController {
    let selectFileBtn = UIButton()
    let initializeBtn = UIButton()
    let startOtaBtn = UIButton()
    let stopOtaBtn = UIButton()
    let rebootBtn = UIButton()
    let fileLab = UILabel()
    let statusLab = UILabel()
    let progressView = UIProgressView()
    let progressLab = UILabel()
    let fileListView = FileLoadView()
    // MARK: - OTA 相关

    var otaManager: JL_OTAManager?
    var otaFilePath = ""
    private var reconnectUUID: String?

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        otaManager = BleManager.shared.currentCmdMgr?.mOTAManager
        NotificationCenter.default.addObserver(self, selector: #selector(connectStatusChange(_:)), name: NSNotification.Name(kJL_BLE_M_ENTITY_CONNECTED), object: nil)
        BaseViewController.listenDisconnect(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BaseViewController.listenDisconnect(true)
    }

    override func initUI() {
        super.initUI()
        navigationView.title = "OTA"
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        view.addSubview(selectFileBtn)
        view.addSubview(initializeBtn)
        view.addSubview(startOtaBtn)
        view.addSubview(stopOtaBtn)
        view.addSubview(rebootBtn)
        view.addSubview(fileLab)
        view.addSubview(statusLab)
        view.addSubview(progressView)
        view.addSubview(progressLab)
        view.addSubview(fileListView)

        selectFileBtn.setTitle(R.localStr.selectOTAFile(), for: .normal)
        selectFileBtn.setTitleColor(UIColor.black, for: .normal)
        selectFileBtn.backgroundColor = UIColor.eHex("ff4d00")
        selectFileBtn.setTitleColor(UIColor.white, for: .normal)
        selectFileBtn.layer.cornerRadius = 8
        selectFileBtn.clipsToBounds = true

        initializeBtn.setTitle(R.localStr.initialize(), for: .normal)
        initializeBtn.setTitleColor(UIColor.black, for: .normal)
        initializeBtn.backgroundColor = UIColor.eHex("9fcd00")
        initializeBtn.setTitleColor(UIColor.white, for: .normal)
        initializeBtn.layer.cornerRadius = 8
        initializeBtn.clipsToBounds = true

        startOtaBtn.setTitle(R.localStr.startOTA(), for: .normal)
        startOtaBtn.setTitleColor(UIColor.black, for: .normal)
        startOtaBtn.backgroundColor = UIColor.eHex("00ffcd")
        startOtaBtn.setTitleColor(UIColor.white, for: .normal)
        startOtaBtn.layer.cornerRadius = 8
        startOtaBtn.clipsToBounds = true

        stopOtaBtn.setTitle(R.localStr.stopOTA(), for: .normal)
        stopOtaBtn.setTitleColor(UIColor.black, for: .normal)
        stopOtaBtn.backgroundColor = UIColor.eHex("00ffcd")
        stopOtaBtn.setTitleColor(UIColor.white, for: .normal)
        stopOtaBtn.layer.cornerRadius = 8
        stopOtaBtn.clipsToBounds = true

        rebootBtn.setTitle(R.localStr.reboot(), for: .normal)
        rebootBtn.setTitleColor(UIColor.black, for: .normal)
        rebootBtn.backgroundColor = UIColor.eHex("00b2ff")
        rebootBtn.setTitleColor(UIColor.white, for: .normal)
        rebootBtn.layer.cornerRadius = 8
        rebootBtn.clipsToBounds = true

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

        rebootBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(stopOtaBtn.snp.bottom).offset(10)
            make.height.equalTo(40)
        }
        fileListView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationView.snp.bottom)
        }
    }

    override func disconnectStatusChange(_: Notification) {}

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        selectFileBtn.rx.tap.subscribe { [weak self] _ in
            self?.fileListView.isHidden = false
            self?.fileListView.showFiles(_R.path.otas)
        }.disposed(by: disposeBag)

        fileListView.handleBlock = { [weak self] file in
            self?.fileLab.text = (file as NSString).lastPathComponent
            self?.otaFilePath = file
        }

        initializeBtn.rx.tap.subscribe { [weak self] _ in
            self?.otaManager?.cmdTargetFeature()
        }.disposed(by: disposeBag)

        startOtaBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            guard let dt = try? Data(contentsOf: URL(fileURLWithPath: self.otaFilePath)) else { return }
            self.reconnectUUID = self.otaManager?.mBLE_UUID
            self.otaManager?.cmdUpgrade(dt, option: nil, result: { result, progress in
                self.handleOtaResult(result, progress)
            })
        }.disposed(by: disposeBag)

        stopOtaBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }

            self.otaManager?.cmdOTACancelResult()

        }.disposed(by: disposeBag)

        rebootBtn.rx.tap.subscribe { [weak self] _ in
            self?.otaManager?.cmdRebootDevice()
        }.disposed(by: disposeBag)
    }
    
 

    // MARK: - 响应升级过程中的回调内容
    func handleOtaResult(_ status: JL_OTAResult, _ progress: Float) {
        switch status {
        case .success:
            view.makeToast(R.localStr.otaSuccess(), position: .center)
            statusLab.text = R.localStr.otaSuccess()
        case .fail:
            view.makeToast("OTA fail", position: .center)
        case .dataIsNull:
            view.makeToast("OTA data nil", position: .center)
        case .commandFail:
            view.makeToast("OTA Command fail", position: .center)
        case .seekFail:
            view.makeToast("OTA addressing failed", position: .center)
        case .infoFail:
            view.makeToast("Failed to obtain information", position: .center)
        case .lowPower:
            view.makeToast("device low power", position: .center)
        case .enterFail:
            view.makeToast("Entry failed", position: .center)
        case .upgrading:
            statusLab.text = R.localStr.upgradingPhase2()
            progressLab.text = "\(Int(progress * 100))%"
            progressView.progress = progress
        case .reconnect:
            view.makeToast(R.localStr.reconnect(), position: .center)
            // TODO: 开发者需要根据设备 UUID 去回连设备
            //(双备份升级不需要管回连内容）
            reconnectAction()
        case .reboot:
            AppDelegate.getCurrentWindows()?.makeToast(R.localStr.restarting(), position: .center)
            statusLab.text = R.localStr.restarting()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem(block: { [weak self] in
                self?.statusLab.text = R.localStr.restartSuccessful()
                self?.navigationController?.popToRootViewController(animated: true)
            }))
        case .preparing:
            statusLab.text = R.localStr.upgradingPhase1()
            progressLab.text = "\(Int(progress * 100))%"
            progressView.progress = progress
        case .prepared:
            statusLab.text = R.localStr.readyToComplete()
            view.makeToast(R.localStr.readyToComplete(), position: .center)
        case .failVerification:
            view.makeToast("Verification failed", position: .center)
        case .failCompletely:
            view.makeToast("OTA fail", position: .center)
        case .failKey:
            view.makeToast("Key Verification failed", position: .center)
        case .failErrorFile:
            view.makeToast("Wrong OTA file", position: .center)
        case .failUboot:
            view.makeToast("u-boot Verification failed", position: .center)
        case .failLenght:
            view.makeToast("OTA file len error", position: .center)
        case .failFlash:
            view.makeToast("OTA write fail", position: .center)
        case .failCmdTimeout:
            view.makeToast("command timeout", position: .center)
        case .failSameVersion:
            view.makeToast("OTA fail（same file）", position: .center)
        case .failTWSDisconnect:
            view.makeToast("OTA fail（TWS not all connected）", position: .center)
        case .failNotInBin:
            view.makeToast("OTA fail（not in file bin）", position: .center)
        case .reconnectWithMacAddr:
            // TODO: 开发者需要根据设备 mac addr 去回连设备
            //(双备份升级不需要管回连内容）
            // 这里若使用 JLSDK 的蓝牙连接，则 SDK 内部处理了回连内容，开发者只需要执行 mBleMutil 类的搜索设备方法即可
            // 当开发者启用以下升级时
            //            self.otaManager?.cmdOTAData(dt, result: { result, progress in
            //                self.handleOtaResult(result, progress)
            //            })
            // 才会触发这个回调，否则一律在内部进行回连
            view.makeToast(R.localStr.reconnect(), position: .center)
            BleManager.shared.reConnectWithMac(otaManager?.bleAddr ?? "")
        case .statusIsUpdating:
            view.makeToast("statusIsUpdating", position: .center)
        case .failedConnectMore:
            view.makeToast("failedConnectMore", position: .center)
        case .failSameSN:
            view.makeToast("failSameSN", position: .center)
        case .cancel:
            view.makeToast("cancel", position: .center)
        case .disconnect:
            view.makeToast("disconnect", position: .center)
        case .reconnectUpdateSource:
            view.makeToast("reconnectUpdateSource", position: .center)
            // TODO: 开发者需要根据设备 UUID 去回连设备
            //(双备份升级不需要管回连内容）
            reconnectAction()
        case .unknown:
            view.makeToast("unknown", position: .center)
        @unknown default:
            view.makeToast("unKnow", position: .center)
        }
    }

    // MARK: - 重连
    private func reconnectAction() {
        JLLogManager.logLevel(.DEBUG, content: "断开设备....")
        let chain = JLTaskChain()
        chain.addTask { input, completion in
            BleManager.shared.disconnectCurrentDev { uuid in
                completion(uuid, nil)
            }
        }
        chain.addTask { [weak self] input, completion in
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem(block: {
                JLLogManager.logLevel(.DEBUG, content: "重新连接设备....")
                let reUUID = self?.reconnectUUID ?? ""
                JLLogManager.logLevel(.DEBUG, content: reUUID)
                BleManager.shared.connectByUUID(reUUID)
                completion(nil, nil)
            }))
        }
        chain.run(withInitialInput: "") { _, _ in
        }
    }

    @objc func connectStatusChange(_ notification: Notification) {
        if (BleManager.shared.currentEntity) != nil {
            otaManager = BleManager.shared.currentCmdMgr?.mOTAManager
            navigationView.leftBtn.setTitle(R.localStr.connected(), for: .normal)
            view.makeToast(R.localStr.initializing(), duration: 5, position: .center)
            
            let chain = JLTaskChain()
            
            chain.addTask { [weak self] _, completion in
                JLLogManager.logLevel(.DEBUG, content: "did get feature")
                guard let manager = self?.otaManager else {
                    let err = NSError(domain: "error for get manager", code: -1, userInfo: nil)
                    completion(nil, err)
                    return
                }
                if manager.otaStatus == .force, let path = self?.otaFilePath {
                    // 继续完成 OTA 升级
                    guard let dt = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                        let err = NSError(domain: "error for get data", code: -1, userInfo: nil)
                        completion(nil, err)
                        return
                    }
                    manager.cmdOTAData(dt, result: { result, progress in
                        self?.handleOtaResult(result, progress)
                    })
                }
                if manager.otaStatus == .normal,
                   manager.isSupportReuseSpaceOTA,
                   manager.otaSourceMode == .sourcesExtendModeFirmwareOnly,
                   let path = self?.otaFilePath {
                    // 继续完成 OTA 升级
                    guard let dt = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                        let err = NSError(domain: "error for get data", code: -1, userInfo: nil)
                        completion(nil, err)
                        return
                    }
                    manager.cmdOTAData(dt , result: { result, progress in
                        self?.handleOtaResult(result, progress)
                    })
                }
            }
            
            chain.run(withInitialInput: "") { output, err in
                if err != nil {
                    JLLogManager.logLevel(.DEBUG, content: "init error")
                    self.view.makeToast("init error", duration: 5, position: .center)
                } else {
                    JLLogManager.logLevel(.DEBUG, content: "init success")
                }
            }
        }
    }
}
