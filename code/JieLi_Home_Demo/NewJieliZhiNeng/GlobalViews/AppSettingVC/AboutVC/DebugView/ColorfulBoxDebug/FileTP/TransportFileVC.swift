//
//  TransportFileVC.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/26.
//

import UIKit

class TransportFileVC: DebugBasicViewController {

    let seleteFileBtn = UIButton()
    let transpFileLab = UILabel()
    let progress = UIProgressView()
    let progressLab = UILabel()
    let cancelBtn = UIButton()
    let startBtn = UIButton()
    let transpView = FileLoadView()
    let deviceFileListView = FileListView()
    private let disposeBag = DisposeBag()
    
    var filePath:String = ""
    
    /// 读回来的存放路径
    var readSavePath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        super.initUI()
        naviView.titleLab.text = "传输文件"
        
        seleteFileBtn.setTitle("选择文件", for: .normal)
        seleteFileBtn.backgroundColor = UIColor.eHex("#F5F5F5")
        seleteFileBtn.setTitleColor(UIColor.black, for: .normal)
        
        transpFileLab.text = "未选择文件"
        transpFileLab.textColor = UIColor.black
        transpFileLab.font = UIFont.boldSystemFont(ofSize: 15)
        transpFileLab.textAlignment = .center
     
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.backgroundColor = UIColor.eHex("#F5F5F5")
        cancelBtn.setTitleColor(UIColor.black, for: .normal)
    
        startBtn.setTitle("开始", for: .normal)
        startBtn.backgroundColor = UIColor.eHex("#F5F5F5")
        startBtn.setTitleColor(UIColor.black, for: .normal)
  
        progress.progressTintColor = UIColor.red
        progress.trackTintColor = UIColor.lightGray
        progress.progress = 0
        
        progressLab.text = "0%"
        progressLab.textColor = UIColor.black
        progressLab.font = R.Font.medium(15)
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
            make.top.equalTo(self.naviView.snp.bottom).offset(10)
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
        
        transpView.handleBlock = { [weak self] path in
            self?.transpView.isHidden = true
            self?.filePath = path
            self?.transpFileLab.text = (path as NSString).lastPathComponent
        }
        
        
        seleteFileBtn.rx.tap.subscribe { [weak self]_ in
            
            self?.transpView.isHidden = false
            self?.transpView.showFiles(R.path.transportFilePath)
            
        }.disposed(by: disposeBag)
        
        
        
        startBtn.rx.tap.subscribe { [weak self]_ in
            if let path = self?.filePath,path != "" {
                //准备环境
                JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.cmdPreEnvironment(.bigFileTransmission){status,_,_ in
                    if status == .success {
                        self?.startBtn.setTitleColor(UIColor.gray, for: .normal)
                        self?.startBtn.isUserInteractionEnabled = false
                        
                        //开始传输
                        JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.cmdBigFileData(path, withFileName: (path as NSString).lastPathComponent, result: { result, progress in
                            switch result {
                            case .transferStart,.transferDownload:
                                DispatchQueue.main.async {
                                    self?.progress.progress = Float(progress)
                                    self?.progressLab.text = String(format: "%.0f%%", progress * 100)
                                }
                                break
                            case .transferEnd:
                                self?.view.makeToast("传输结束",position: .center)
                                self?.startBtn.setTitleColor(UIColor.black, for: .normal)
                                self?.startBtn.isUserInteractionEnabled = true
                            default:
                                self?.startBtn.setTitleColor(UIColor.black, for: .normal)
                                self?.startBtn.isUserInteractionEnabled = true
                                self?.view.makeToast("传输异常：\(result)",position: .center)
                            }
                        })
                    }
                }
            }
        }.disposed(by: disposeBag)
        
        cancelBtn.rx.tap.subscribe { [weak self]_ in
            JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.cmdStopBigFileData()
            self?.startBtn.setTitleColor(UIColor.black, for: .normal)
            self?.startBtn.isUserInteractionEnabled = true
        }.disposed(by: disposeBag)
        
        deviceFileListView.handleDownloadFile = { [weak self] model in
            
            let alert = UIAlertController(title: "选择读回的方式", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "文件名", style: .default, handler: { _ in
                JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.cmdFileReadContent(withName: model.fileName, result: { result, sn, data, progressValue in
                    self?.handleReadBack(result: result, size: sn, data: data, progressValue: progressValue,model: model)
                })
            }))
            
            alert.addAction(UIAlertAction(title: "文件簇号", style: .default, handler: { _ in
                JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager.mFileManager.cmdFileReadContent(withFileClus: model.fileClus, result: { result, sn, data, progressValue in
                    self?.handleReadBack(result: result, size: sn, data: data, progressValue: progressValue,model: model)
                })
            }))
            self?.present(alert, animated: true)
            
        }
        

    }
    
    private func handleReadBack(result:JL_FileContentResult,size:UInt32,data:Data?,progressValue:Float,model:JLModel_File){
        
        switch result {
        case .reading:
            DispatchQueue.main.async {
                self.progress.progress = progressValue
                self.progressLab.text = String(format: "%.2f%", progressValue*100)
            }
            JL_Tools.write(data ?? Data(), endFile: readSavePath)
        case .end:
            self.view.makeToast("读回已完成:\(result)")
        case .start:
            self.view.makeToast("读回开始:\(result)")
            let dtfm = DateFormatter()
            dtfm.dateFormat = "yyyy-MM-dd_HH:mm:ss"
            readSavePath = R.path.transportFilePath+"/"+model.fileName
            try?FileManager.default.removeItem(atPath: readSavePath)
            FileManager.default.createFile(atPath: readSavePath, contents: data)
        default:
            self.view.makeToast("读回错误:\(result)")
        }
    }

}
