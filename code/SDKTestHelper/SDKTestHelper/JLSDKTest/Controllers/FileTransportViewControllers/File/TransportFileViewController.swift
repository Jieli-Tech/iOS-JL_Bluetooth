//
//  TransportFileViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/26.
//

import UIKit

private enum TransportFileVCType {
    case send
    case receive
}

class TransportFileViewController: BaseViewController {
    let seleteFileBtn = UIButton()
    let transpFileLab = UILabel()
    let progress = UIProgressView()
    let progressLab = UILabel()
    let cancelBtn = UIButton()
    let startBtn = UIButton()
    let transpView = FileLoadView()
    let deviceFileListView = FileListView()
    var tmpMiddlePath = ""

    var filePath: String = ""

    /// 读回来的存放路径
    var readSavePath = ""
    private var transportType: TransportFileVCType = .send
    private var isTransporting = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.fileTransport()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        seleteFileBtn.setTitle(R.localStr.selectFile(), for: .normal)
        seleteFileBtn.backgroundColor = UIColor.random()
        seleteFileBtn.layer.cornerRadius = 8
        seleteFileBtn.layer.masksToBounds = true
        seleteFileBtn.setTitleColor(UIColor.white, for: .normal)

        transpFileLab.text = R.localStr.noFileSelected() // "No file selected"
        transpFileLab.textColor = UIColor.black
        transpFileLab.font = UIFont.boldSystemFont(ofSize: 15)
        transpFileLab.textAlignment = .center

        cancelBtn.setTitle(R.localStr.cancel(), for: .normal)
        cancelBtn.backgroundColor = UIColor.random()
        cancelBtn.setTitleColor(UIColor.white, for: .normal)

        startBtn.setTitle(R.localStr.start(), for: .normal)
        startBtn.backgroundColor = UIColor.random()
        startBtn.setTitleColor(UIColor.white, for: .normal)

        progress.progressTintColor = UIColor.red
        progress.trackTintColor = UIColor.lightGray
        progress.progress = 0

        progressLab.text = "0%"
        progressLab.textColor = UIColor.black
        progressLab.font = UIFont.systemFont(ofSize: 15)
        progressLab.textAlignment = .center

        deviceFileListView.contextView = self

        view.addSubview(seleteFileBtn)
        view.addSubview(transpFileLab)
        view.addSubview(progress)
        view.addSubview(progressLab)
        view.addSubview(cancelBtn)
        view.addSubview(startBtn)
        view.addSubview(deviceFileListView)
        view.addSubview(transpView)

        seleteFileBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(50)
        }

        transpFileLab.snp.makeConstraints { make in
            make.top.equalTo(seleteFileBtn.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(25)
        }

        progress.snp.makeConstraints { make in
            make.top.equalTo(transpFileLab.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(4)
        }
        progressLab.snp.makeConstraints { make in
            make.top.equalTo(progress.snp.bottom).offset(5)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(25)
        }

        startBtn.snp.makeConstraints { make in
            make.top.equalTo(progressLab.snp.bottom).offset(20)
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(cancelBtn.snp.left).offset(-16)
            make.width.equalTo(cancelBtn.snp.width)
            make.height.equalTo(50)
        }
        cancelBtn.snp.makeConstraints { make in
            make.top.equalTo(progressLab.snp.bottom).offset(20)
            make.right.equalToSuperview().inset(16)
            make.left.equalTo(startBtn.snp.right).offset(16)
            make.width.equalTo(startBtn.snp.width)
            make.height.equalTo(50)
        }

        deviceFileListView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(startBtn.snp.bottom).offset(20)
        }

        transpView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        transpView.isHidden = true
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            if self.isTransporting {
                let alert = UIAlertController(title: R.localStr.tips(), message: R.localStr.transferringConfirmToExit(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel))
                alert.addAction(UIAlertAction(title: R.localStr.confirm(), style: .default, handler: { _ in
                    self.cancelTransport()
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }.disposed(by: disposeBag)

        transpView.handleBlock = { [weak self] path in
            self?.transpView.isHidden = true
            self?.filePath = path
            self?.transpFileLab.text = (path as NSString).lastPathComponent
            if SettingInfo.getCustomTransportSupport() {
                let alert = UIAlertController(title: R.localStr.tips(), message: R.localStr.enterTheSpecifiedFolderSuchAsDocumentABCOrDownload(), preferredStyle: .alert)
                alert.addTextField { txfd in
                    txfd.text = "Download/"
                    txfd.clearButtonMode = .whileEditing
                    txfd.placeholder = "Download/"
                    txfd.keyboardType = .default
                    txfd.borderStyle = .roundedRect
                }
                alert.addAction(UIAlertAction(title: R.localStr.confirm(), style: .cancel, handler: { [weak self] _ in
                    guard let self = self else { return }
                    let text = alert.textFields?.first?.text ?? ""
                    self.tmpMiddlePath = text
                }))
                self?.present(alert, animated: true)
            }
        }

        seleteFileBtn.rx.tap.subscribe { [weak self] _ in

            self?.transpView.isHidden = false
            self?.transpView.showFiles(_R.path.transportFilePath)

        }.disposed(by: disposeBag)

        startBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            if self.filePath != "" {
                // 准备环境
                BleManager.shared.currentCmdMgr?.mFileManager.cmdPreEnvironment(.bigFileTransmission) { status, _, _ in
                    if status == .success {
                        self.startBtn.setTitleColor(UIColor.gray, for: .normal)
                        self.startBtn.isUserInteractionEnabled = false

                        // 开始传输
                        let tmpFileName = self.tmpMiddlePath + (self.filePath as NSString).lastPathComponent
                        BleManager.shared.currentCmdMgr?.mFileManager.cmdBigFileData(self.filePath, withFileName: tmpFileName, result: { result, progress in
                            switch result {
                            case .transferStart, .transferDownload:
                                DispatchQueue.main.async {
                                    self.progress.progress = Float(progress)
                                    self.progressLab.text = String(format: "%.0f%%", progress * 100)
                                    self.deviceFileListView.isUserInteractionEnabled = false
                                    self.transportType = .send
                                }
                                self.isTransporting = true
                            case .transferEnd:
                                self.view.makeToast(R.localStr.transportSuccessful(), position: .center)
                                self.startBtn.setTitleColor(UIColor.black, for: .normal)
                                self.startBtn.isUserInteractionEnabled = true
                                self.deviceFileListView.isUserInteractionEnabled = true
                                self.isTransporting = false
                            default:
                                self.startBtn.setTitleColor(UIColor.black, for: .normal)
                                self.startBtn.isUserInteractionEnabled = true
                                self.view.makeToast("\(R.localStr.transportError())\(result)", position: .center)
                                self.deviceFileListView.isUserInteractionEnabled = true
                                self.isTransporting = false
                            }
                        })
                    }
                }
            }
        }.disposed(by: disposeBag)

        cancelBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            self.cancelTransport()
        }.disposed(by: disposeBag)

        deviceFileListView.handleDownloadFile = { [weak self] model in

            guard let `self` = self else { return }
            if self.isTransporting {
                self.view.makeToast(R.localStr.theTransmissionIsInProgressRepeatedInitiationIsNotAllowed(), position: .center)
                return
            }
            let alert = UIAlertController(title: R.localStr.selectTheWayToReadBack(), message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: R.localStr.fileName(), style: .default, handler: { _ in
                BleManager.shared.currentCmdMgr?.mFileManager.cmdFileReadContent(withName: model.fileName, result: { result, sn, data, progressValue in
                    self.handleReadBack(result: result, size: sn, data: data, progressValue: progressValue, model: model)
                })
            }))

            alert.addAction(UIAlertAction(title: R.localStr.fileCluster(), style: .default, handler: { _ in
                BleManager.shared.currentCmdMgr?.mFileManager.cmdFileReadContent(withFileClus: model.fileClus, result: { result, sn, data, progressValue in
                    self.handleReadBack(result: result, size: sn, data: data, progressValue: progressValue, model: model)
                })
            }))
            self.present(alert, animated: true)
        }
    }

    private func cancelTransport() {
        if transportType == .send {
            BleManager.shared.currentCmdMgr?.mFileManager.cmdStopBigFileData()
            startBtn.setTitleColor(UIColor.black, for: .normal)
            startBtn.isUserInteractionEnabled = true
        } else {
            BleManager.shared.currentCmdMgr?.mFileManager.cmdFileReadContentCancel()
            startBtn.setTitleColor(UIColor.black, for: .normal)
            startBtn.isUserInteractionEnabled = true
        }
    }

    private func handleReadBack(result: JL_FileContentResult, size _: UInt32, data: Data?, progressValue: Float, model: JLModel_File) {
        switch result {
        case .reading:
            DispatchQueue.main.async {
                self.progress.progress = progressValue
                self.progressLab.text = String(format: "%.2f%", progressValue * 100)
            }
            JL_Tools.write(data ?? Data(), endFile: readSavePath)
            startBtn.setTitleColor(UIColor.gray, for: .normal)
            startBtn.isUserInteractionEnabled = false
            transportType = .receive
            isTransporting = true
        case .end:
            view.makeToast("\(R.localStr.readBackCompleted())\(result)")
            startBtn.setTitleColor(UIColor.black, for: .normal)
            startBtn.isUserInteractionEnabled = true
            isTransporting = false
        case .start:
            view.makeToast("\(R.localStr.readingBackStart())\(result)")
            let dtfm = DateFormatter()
            dtfm.dateFormat = "yyyy-MM-dd_HH:mm:ss"
            readSavePath = _R.path.transportFilePath + "/" + model.fileName
            try? FileManager.default.removeItem(atPath: readSavePath)
            FileManager.default.createFile(atPath: readSavePath, contents: data)
        default:
            view.makeToast("\(R.localStr.readingError)\(result)")
            startBtn.setTitleColor(UIColor.black, for: .normal)
            startBtn.isUserInteractionEnabled = true
            isTransporting = false
        }
    }
}
