//
//  Gif2DeviceViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2024/1/18.
//

import JLBmpConvertKit
import UIKit

class Gif2DeviceViewController: BaseViewController {
    let subTable = UITableView()
    let confirmBtn = UIButton()
    let statusLab = UILabel()
    let progressView = UIProgressView()
    var modeSelectView: DropdownView<String> = DropdownView<String>()
    var modeLevelView: DropdownView<String> = DropdownView<String>()
    var nameInputView: InputView = InputView()
    let sendBtn = UIButton()
    
    private var level = 1
    private var mode: JLGIFBinChipType = .JL_701N
    private var gifBin:Data?
    private let items = BehaviorRelay<[String]>(value: [])
    private var targetFile = ""
    private var dialMgr: JLDialUnitMgr?

    override func initUI() {
        super.initUI()

        navigationView.title = R.localStr.gifToDevice()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(subTable)
        view.addSubview(modeSelectView)
        view.addSubview(modeLevelView)
        view.addSubview(nameInputView)
        view.addSubview(confirmBtn)
        view.addSubview(statusLab)
        view.addSubview(progressView)
        view.addSubview(sendBtn)

        if let list = _R.path.gif2Rgb.listFile() {
            items.accept(list)
        }
        if items.value.count == 0 {
            view.makeToast(R.localStr.needToImportTheFileIntoDocumentGif2rgbFolder(), duration: 3, position: .center)
        }

        subTable.backgroundColor = UIColor.clear
        subTable.rowHeight = 35
        subTable.tableFooterView = UIView()
        subTable.register(UITableViewCell.self, forCellReuseIdentifier: "tagCell")
        
        modeSelectViewInit()
        modeLevelViewInit()
        
        nameInputView.configure(title: R.localStr.fileName(), placeholder: "input file name")
        nameInputView.textField.text = "BGP_W111"

        items.bind(to: subTable.rx.items(cellIdentifier: "tagCell")) { _, item, cell in
            cell.textLabel?.text = (item as NSString).lastPathComponent
            if self.targetFile == item {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }.disposed(by: disposeBag)

        subTable.rx.modelSelected(String.self).subscribe { [weak self] model in
            guard let `self` = self else { return }
            targetFile = model
        }.disposed(by: disposeBag)

        confirmBtn.setTitle(R.localStr.startCreateRgb(), for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.backgroundColor = UIColor.random()
        confirmBtn.layer.cornerRadius = 10
        confirmBtn.layer.masksToBounds = true

        statusLab.textColor = .darkText
        statusLab.textAlignment = .center
        statusLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        statusLab.adjustsFontSizeToFitWidth = true

        progressView.progress = 0.0
        progressView.progressTintColor = UIColor.eHex("#cc4a1c")
        progressView.trackTintColor = UIColor.eHex("d8d8d8")

        sendBtn.setTitle(R.localStr.sendRgbBin(), for: .normal)
        sendBtn.setTitleColor(.white, for: .normal)
        sendBtn.backgroundColor = UIColor.random()
        sendBtn.layer.cornerRadius = 10
        sendBtn.layer.masksToBounds = true

        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(12)
            make.height.equalTo(200)
        }
        nameInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(subTable.snp.bottom).offset(5)
            make.height.equalTo(35)
        }
        modeSelectView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(nameInputView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }
        
        modeLevelView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(modeSelectView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        confirmBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(modeLevelView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        statusLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(confirmBtn.snp.bottom).offset(12)
            make.height.equalTo(35)
        }

        progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(statusLab.snp.bottom).offset(12)
        }

        sendBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(progressView.snp.bottom).offset(12)
            make.height.equalTo(35)
        }
    }

    override func initData() {
        super.initData()
        
        initDialMgr()
        
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        confirmBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            if targetFile.count > 0 {
                self.statusLab.text = R.localStr.creating()
                if let dt = try? Data(contentsOf: URL(fileURLWithPath: targetFile)) {
                    JLGifBin.makeData(toBin: dt, level: Int32(level), chipType: mode) { [weak self] _, data in
                        guard let `self` = self else { return }
                        DispatchQueue.main.async {
                            self.statusLab.text = R.localStr.createSuccess()
                        }
                        self.gifBin = data
                    }
                }
            }
        }.disposed(by: disposeBag)
        
        sendBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            if let dt = self.gifBin, let dialMgr = dialMgr{
                let namePath = "/" + (self.nameInputView.textField.text ?? "BGP_W111")
                dialMgr.updateFile(toDevice: .FLASH, data: dt, filePath: namePath) { [weak self] status, progress, err in
                    if err != nil {
                        self?.view.makeToast(err?.localizedDescription ?? "send failed")
                    }
                    if status == 0 {
                        self?.progressView.progress = 1.0
                        self?.statusLab.text = R.localStr.successfullyModified()
                        self?.activeGif()
                    } else if status == 1 {
                        self?.progressView.progress = Float(progress)
                    }
                }
            }
        }.disposed(by: disposeBag)
    }
    private func activeGif() {
        guard let dialMgr = dialMgr else { return }
        dialMgr.getFileList(.FLASH, count: 100) { [weak self] list, err in
            guard let self = self else { return }
            if err != nil {
                view.makeToast(err?.localizedDescription ?? "get file list failed")
            } else {
                guard let list = list else { return }
                for item in list {
                    if item.fileName.uppercased() == self.nameInputView.textField.text?.uppercased() {
                        dialMgr.dialActiveCustomBackground(item) { _, _ in
                            
                        }
                    }
                }
            }
        }
    }
    private func initDialMgr() {
        guard let mgr = BleManager.shared.currentCmdMgr else { return }
        dialMgr = JLDialUnitMgr(manager: mgr, completion: { [weak self] err in
            guard let `self` = self else { return }
            if err != nil {
                view.makeToast(err?.localizedDescription ?? "dial init failed")
            }
            mgr.mFileManager.setCurrentFileHandleType(.FLASH)
        })
    }
    private func modeSelectViewInit() {
        modeSelectView.title = "Chip Type"
        let items = ["JL701N","JL707N"]
        modeSelectView.updateItems(items)
        modeSelectView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "JL701N":
                mode = .JL_701N
                modeLevelView.updateItems(["low","middle","high"])
                modeLevelView.scrollToItem("low")
                level = 1
            case "JL707N":
                mode = .JL_707N
                modeLevelView.updateItems(["low"])
                modeLevelView.scrollToItem("low")
                level = 1
            default:
                break
            }
        }
    }
    private func modeLevelViewInit() {
        modeLevelView.title = "Level"
        let items = ["low","middle","high"]
        modeLevelView.updateItems(items)
        modeLevelView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "low":
                level = 1
            case "middle":
                level = 2
            case "high":
                level = 3
            default:
                break
            }
        }
    }
}
