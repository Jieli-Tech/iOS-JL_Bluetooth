//
//  FileListView.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/27.
//

import UIKit

class FileListView: BaseView {
    let fileListTableView = UITableView()
    let refreshBtn = UIButton()
    let titleLab = UILabel()
    let itemList = BehaviorRelay<[JLModel_File]>(value: [])
    var handleDownloadFile: ((JLModel_File) -> Void)?

    private var nowModels: [JLModel_File] = []

    override func initUI() {
        super.initUI()
        backgroundColor = .white

        let model = BleManager.shared.currentCmdMgr?.mFileManager.getCurrentFileHandleType() ?? .FLASH

        titleLab.text = model.beString() + R.localStr.sFileList()
        titleLab.textColor = UIColor.black
        titleLab.font = UIFont.boldSystemFont(ofSize: 15)
        titleLab.backgroundColor = UIColor.eHex("#ababab")
        titleLab.textAlignment = .center
        addSubview(titleLab)

        refreshBtn.setTitle(R.localStr.refresh(), for: .normal)
        refreshBtn.setTitleColor(.white, for: .normal)
        refreshBtn.backgroundColor = UIColor.eHex("F5F5F5")
        addSubview(refreshBtn)

        fileListTableView.rowHeight = 40
        fileListTableView.tableFooterView = UIView()
        fileListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "fileListCell")
        addSubview(fileListTableView)

        titleLab.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(6)
            make.height.equalTo(40)
        }

        refreshBtn.snp.makeConstraints { make in
            make.right.left.equalToSuperview()
            make.height.equalTo(35)
            make.top.equalTo(titleLab.snp.bottom).offset(6)
        }

        fileListTableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(refreshBtn.snp.bottom)
            make.bottom.equalToSuperview().inset(6)
        }
    }

    override func initData() {
        super.initData()

        itemList.bind(to: fileListTableView.rx.items(cellIdentifier: "fileListCell", cellType: UITableViewCell.self)) {
            _, item, cell in
            cell.textLabel?.text = item.fileName
        }.disposed(by: disposeBag)

        fileListTableView.rx.modelSelected(JLModel_File.self).subscribe { [weak self] item in
            if let model = item.element {
                if self?.handleDownloadFile == nil {
                    return
                }
                if model.fileType == .file {
                    let alert = UIAlertController(title: nil, message: R.localStr.doYouWantToReadBackThisFileFromTheDeviceTheRetrievedFileCanBeViewedInSelectFile(model.fileName), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: R.localStr.confirm(), style: .default, handler: { _ in
                        self?.handleDownloadFile?(model)
                    }))

                    alert.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel, handler: nil))
                    self?.contextView?.present(alert, animated: true)
                } else {}
            }
        }.disposed(by: disposeBag)

        refreshBtn.rx.tap.bind { [weak self] in
            let fm = BleManager.shared.currentCmdMgr?.mFileManager
            let raw = (fm?.getCurrentFileHandleType() ?? .FLASH).rawValue
            fm?.cmdCleanCacheType(JL_CardType(rawValue: raw)!)

            self?.createData()
        }.disposed(by: disposeBag)

        createData()
    }

    private func createData() {
        guard let fmanager = BleManager.shared.currentCmdMgr else {
            return
        }
        nowModels.removeAll()
        fmanager.mFileManager.cmdBrowseMonitorResult { [weak self] arr, _ in
            guard let arr = arr else { return }
            var targetArray: [JLModel_File] = []
            for item in arr {
                if let i = item as? JLModel_File {
                    targetArray.append(i)
                }
            }
            self?.itemList.accept(targetArray)
            self?.fileListTableView.reloadData()
        }

        let model = fmanager.getDeviceModel()
        let fileModel = JLModel_File()

        fileModel.fileType = JL_BrowseType(rawValue: 0)!
        fileModel.fileClus = 0
        switch fmanager.mFileManager.getCurrentFileHandleType() {
        case .USB:
            fileModel.cardType = .USB
            fileModel.fileName = "USB"
            fileModel.folderName = "USB"
            fileModel.fileHandle = model.cardInfo.usbHandle.eHex
        case .SD_0:
            fileModel.cardType = .SD_0
            fileModel.fileName = "SD Card"
            fileModel.folderName = "SD Card"
            fileModel.fileHandle = model.cardInfo.sd0Handle.eHex
        case .SD_1:
            fileModel.cardType = .SD_1
            fileModel.fileName = "SD Card 1"
            fileModel.folderName = "SD Card 1"
            fileModel.fileHandle = model.cardInfo.sd1Handle.eHex
        case .FLASH:
            fileModel.cardType = .FLASH
            fileModel.fileName = "FLASH"
            fileModel.folderName = "FLASH"
            fileModel.fileHandle = model.cardInfo.flashHandle.eHex
        case .FLASH2:
            fileModel.cardType = .FLASH2
            fileModel.fileName = "FLASH2"
            fileModel.folderName = "FLASH2"
            fileModel.fileHandle = model.cardInfo.flash2Handle.eHex
        case .lineIn:
            break
        case .FLASH3:
            fileModel.cardType = .FLASH3
            fileModel.fileName = "FLASH3"
            fileModel.folderName = "FLASH3"
            fileModel.fileHandle = model.cardInfo.flash3Handle.eHex
        case .reservedArea:
            fileModel.cardType = .reservedArea
            fileModel.fileName = "reservedArea"
            fileModel.folderName = "reservedArea"
            fileModel.fileHandle = model.cardInfo.reservedAreaHandle.eHex
        @unknown default:
            break
        }

        nowModels.append(fileModel)
        fmanager.mFileManager.cmdBrowseModel(fileModel, number: 100, result: nil)
    }
}
