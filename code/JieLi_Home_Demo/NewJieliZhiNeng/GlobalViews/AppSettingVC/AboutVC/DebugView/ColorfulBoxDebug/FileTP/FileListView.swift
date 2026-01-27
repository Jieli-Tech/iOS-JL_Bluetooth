//
//  FileListView.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/27.
//

import UIKit

class FileListView: BasicView {

    let fileListTableView = UITableView()
    let refreshBtn = UIButton()
    let titleLab = UILabel()
    let itemList = BehaviorRelay<[JLModel_File]>(value: [])
    var handleDownloadFile:((JLModel_File)->Void)?
    
    private var nowModels:[JLModel_File] = []
    
    override func initUI() {
        super.initUI()
        self.backgroundColor = .white
        
        let model = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.getCurrentFileHandleType() ?? .FLASH
        
        titleLab.text = model.beString()+"的文件列表"
        titleLab.textColor = UIColor.black
        titleLab.font = UIFont.boldSystemFont(ofSize: 15)
        titleLab.backgroundColor = UIColor.eHex("#ababab")
        titleLab.textAlignment = .center
        self.addSubview(titleLab)
        
        refreshBtn.setTitle("刷新", for: .normal)
        refreshBtn.setTitleColor(.white, for: .normal)
        refreshBtn.backgroundColor = UIColor.eHex("F5F5F5")
        self.addSubview(refreshBtn)
        
        fileListTableView.rowHeight = 40
        fileListTableView.tableFooterView = UIView()
        fileListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "fileListCell")
        self.addSubview(fileListTableView)
        
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
        
        itemList.bind(to: fileListTableView.rx.items(cellIdentifier: "fileListCell",cellType: UITableViewCell.self)){
            index, item, cell in
            cell.textLabel?.text = item.fileName
        }.disposed(by: disposeBag)
        
        fileListTableView.rx.modelSelected(JLModel_File.self).subscribe { [weak self] item in
            if let model = item.element{
                if self?.handleDownloadFile == nil{
                    return
                }
                if model.fileType == .file{
                    let alert = UIAlertController(title: nil, message: "是否从设备读回此文件？\n\(model.fileName)\n读回的文件可在【选择文件】中查看", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
                        self?.handleDownloadFile?(model)
                    }))
                    
                    alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
                    self?.contextView?.present(alert, animated: true)
                }else{
                    
                }
            }
        }.disposed(by: disposeBag)
  
        
        refreshBtn.rx.tap.bind { [weak self] in
            let fm = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager
            let raw = (fm?.getCurrentFileHandleType() ?? .FLASH).rawValue
            fm?.cmdCleanCacheType(JL_CardType(rawValue: raw)!)
            
            self?.createData()
        }.disposed(by: disposeBag)
        
        
        
        createData()
    }
    
    private func createData(){
        
        guard let fmanager = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else{
            return
        }
        nowModels.removeAll()
        fmanager.mFileManager.cmdBrowseMonitorResult { [weak self](arr, response) in
            guard let arr = arr else{ return}
            var targetArray:[JLModel_File] = []
            for item in arr{
                if let i = item as? JLModel_File{
                    targetArray.append(i)
                }
            }
            self?.itemList.accept(targetArray)
            self?.fileListTableView.reloadData()
        }
        
        let model = fmanager.outputDeviceModel()
        let fileModel = JLModel_File()
        
        fileModel.fileType = JL_BrowseType.init(rawValue: 0)!
        fileModel.fileClus = 0
        switch fmanager.mFileManager.getCurrentFileHandleType() {
        case .USB:
            fileModel.cardType = .USB
            fileModel.fileName = "USB"
            fileModel.folderName = "USB"
            fileModel.fileHandle = model.handleUSB
        case .SD_0:
            fileModel.cardType = .SD_0
            fileModel.fileName = "SD Card"
            fileModel.folderName = "SD Card"
            fileModel.fileHandle = model.handleSD_0
        case .SD_1:
            fileModel.cardType = .SD_1
            fileModel.fileName = "SD Card 1"
            fileModel.folderName = "SD Card 1"
            fileModel.fileHandle = model.handleSD_1
        case .FLASH:
            fileModel.cardType = .FLASH
            fileModel.fileName = "FLASH"
            fileModel.folderName = "FLASH"
            fileModel.fileHandle = model.handleFlash
        case .FLASH2:
            fileModel.cardType = .FLASH2
            fileModel.fileName = "FLASH2"
            fileModel.folderName = "FLASH2"
            fileModel.fileHandle = model.handleFlash2
        case .lineIn:
            break
        @unknown default:
            break
        }
        
        nowModels.append(fileModel)
        fmanager.mFileManager.cmdBrowseModel(fileModel, number: 100, result: nil)
    }

}


fileprivate extension JL_FileHandleType{
    func beString()->String{
        switch self {
        case .FLASH:
            return "FLASH"
        case .SD_0:
            return "SD_0"
        case .USB:
            return "USB"
        case .SD_1:
            return "SD_1"
        case .lineIn:
            return "lineIn"
        case .FLASH2:
            return "FLASH2"
        @unknown default:
            return "未知"
        }
    }
}
