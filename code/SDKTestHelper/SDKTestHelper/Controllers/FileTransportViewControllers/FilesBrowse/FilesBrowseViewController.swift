//
//  FilesBrowseViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/11/10.
//

import UIKit

class FilesBrowseViewController: BaseViewController {
    let progressView = UIProgressView()
    let progressLab = UILabel()
    let centerView = FileBrowseView()
    let filesItem = UIButton()
    let fileLoadView = FileLoadView()

    private var readSavePath = ""
    private var isTransporting = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.fileBrowser()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        view.addSubview(progressView)
        view.addSubview(progressLab)
        view.addSubview(centerView)

        progressView.progress = 0
        progressView.trackTintColor = UIColor.random()
        progressView.progressTintColor = UIColor.random()
        progressView.layer.cornerRadius = 2
        progressView.clipsToBounds = true

        progressLab.text = "0%"
        progressLab.textColor = UIColor.random()
        progressLab.font = UIFont.boldSystemFont(ofSize: 30)
        progressLab.textAlignment = .center

        progressView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(progressLab.snp.left)
            make.height.equalTo(4)
        }

        progressLab.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.centerY.equalTo(progressView.snp.centerY)
        }

        filesItem.setTitle(R.localStr.browseDownloaded(), for: .normal)
        filesItem.setTitleColor(UIColor.white, for: .normal)
        filesItem.backgroundColor = UIColor.random()
        filesItem.layer.cornerRadius = 8
        filesItem.layer.masksToBounds = true

        view.addSubview(filesItem)
        view.addSubview(fileLoadView)

        centerView.snp.makeConstraints { make in
            make.top.equalTo(progressView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(filesItem.snp.top).offset(-10)
        }

        filesItem.snp.makeConstraints { make in
            make.top.equalTo(centerView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }

        fileLoadView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        fileLoadView.isHidden = true
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            if self.isTransporting {
                let alert = UIAlertController(title: R.localStr.tips(),
                                              message: R.localStr.transferringConfirmToExit(),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: R.localStr.cancel(),
                                              style: .cancel))
                alert.addAction(UIAlertAction(title: R.localStr.confirm(),
                                              style: .default,
                                              handler: { _ in
                                                  BleManager.shared.currentCmdMgr?.mFileManager.cmdFileReadContentCancel()
                                                  self.navigationController?.popViewController(animated: true)
                                              }))
                self.present(alert, animated: true)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: disposeBag)

        filesItem.rx.tap.subscribe(onNext: { [weak self] in
            self?.fileLoadView.showFiles(_R.path.transportFilePath)
            self?.fileLoadView.isHidden = false
        }).disposed(by: disposeBag)

        let nowModel = JLModel_File()
        nowModel.fileName = "Root"
        nowModel.fileType = .folder
        nowModel.fileClus = 0
        nowModel.cardType = BleManager.shared.currentCmdMgr?.mFileManager
            .getCurrentFileHandleType().beCardType() ?? .FLASH
        nowModel.fileHandle = (BleManager.shared.currentCmdMgr?.mFileManager.currentDeviceHandleData().eHex)!

        centerView.loadWithModel(model: nowModel)
        centerView.handleFileSelect = { [weak self] model in
            guard let `self` = self else { return }
            if self.isTransporting {
                self.view.makeToast(R.localStr.transmitting(), position: .center)
                return
            }
            let alert = UIAlertController(title: R.localStr.selectDownloadMethod(),
                                          message: R.localStr.theDownloadedFilesAreStoredInTheTransportFilesFolderOfDocumentDirectory(),
                                          preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: R.localStr.fileName_1(),
                                          style: .destructive,
                                          handler: { _ in
                                              BleManager.shared.currentCmdMgr?.mFileManager.cmdFileReadContent(withName: model.fileName, result: { st, size, data, progress in
                                                  self.handleDownloadProgress(st, size, data, progress, model)
                                              })
                                          }))
            alert.addAction(UIAlertAction(title: R.localStr.fileCluster(),
                                          style: .destructive,
                                          handler: { _ in
                                              BleManager.shared.currentCmdMgr?.mFileManager.cmdFileReadContent(withFileClus: model.fileClus, result: { st, size, data, progress in
                                                  self.handleDownloadProgress(st, size, data, progress, model)
                                              })
                                          }))
            let cancelAction = UIAlertAction(title: R.localStr.cancel(),
                                             style: .cancel,
                                             handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func handleDownloadProgress(_ result: JL_FileContentResult, _: UInt32, _ data: Data?, _ progress: Float, _ model: JLModel_File) {
        switch result {
        case .reading:
            DispatchQueue.main.async {
                self.progressView.progress = progress
                self.progressLab.text = String(format: "%.1f%%", progress * 100)
            }
            isTransporting = true
            JL_Tools.write(data ?? Data(), endFile: readSavePath)
        case .end:
            view.makeToast("\(R.localStr.readBackCompleted)\(result)")
            isTransporting = false
        case .start:
            view.makeToast("\(R.localStr.readingBackStart)\(result)")
            readSavePath = _R.path.transportFilePath + "/" + model.fileName
            try? FileManager.default.removeItem(atPath: readSavePath)
            FileManager.default.createFile(atPath: readSavePath, contents: data)
            isTransporting = true
        default:
            isTransporting = false
            view.makeToast("\(R.localStr.readingError)\(result)")
        }
    }
}
