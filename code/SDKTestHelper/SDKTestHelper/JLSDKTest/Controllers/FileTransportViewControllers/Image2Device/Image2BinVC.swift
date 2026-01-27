//
//  Image2BinVC.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/18.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JLBmpConvertKit
import UIKit

class Image2BinVC: BaseViewController {
    
    let subTable = EmptyStateTableView()
    let confirmBtn = UIButton()
    let statusLab = UILabel()
    let progressView = UIProgressView()
    var modeSelectView: DropdownView<String> = DropdownView<String>()
    var modePackageTypeView: DropdownView<String> = DropdownView<String>()
    var packetFormatView: DropdownView<String> = DropdownView<String>()
    var nameInputView: InputView = InputView()
    let sendBtn = UIButton()
    
    private var mode: JLBmpConvertType = .type701N_ARBG
    private let convertOption = JLBmpConvertOption()
    private var packageType: JLBmpPixelformat = ._Auto
    private var packetFormat: JLBmpPacketFormat = .JLUI
    private var imageBin:Data?
    private let items = BehaviorRelay<[String]>(value: [])
    private var targetFile = ""
    private var dialMgr: JLDialUnitMgr?
    
    override func initUI() {
        super.initUI()
        
        navigationView.title = R.localStr.imageToDevice()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(subTable)
        view.addSubview(modeSelectView)
        view.addSubview(modePackageTypeView)
        view.addSubview(packetFormatView)
        view.addSubview(nameInputView)
        view.addSubview(confirmBtn)
        view.addSubview(statusLab)
        view.addSubview(progressView)
        view.addSubview(sendBtn)
        
        if let list = _R.path.image2Bin.listFile() {
            items.accept(list)
        }
        if items.value.count == 0 {
            view.makeToast(R.localStr.theFileNeedsToBeImportedIntoDocumentImage2binFolder(), duration: 3, position: .center)
        }
        
        subTable.backgroundColor = UIColor.clear
        subTable.rowHeight = 35
        subTable.tableFooterView = UIView()
        subTable.register(UITableViewCell.self, forCellReuseIdentifier: "tagCell")
        
        modeSelectViewInit()
        modePackageTypeViewInit()
        packetFormatViewInit()
        
        nameInputView.configure(title: R.localStr.fileName(), placeholder: "input file name")
        nameInputView.textField.text = "BGP_W111"
        
        subTable.tintColor = .random()
        
        items.bind(to: subTable.rx.items(cellIdentifier: "tagCell")) { _, item, cell in
            cell.textLabel?.text = (item as NSString).lastPathComponent
            if self.targetFile == item {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }.disposed(by: disposeBag)
        
        items.map { $0.isEmpty }.bind(to: subTable.isEmpty).disposed(by: disposeBag)
        
        subTable.emptyStateLabelText = R.localStr.theFileNeedsToBeImportedIntoDocumentImage2binFolder()
        
        subTable.rx.modelSelected(String.self).subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }
            let str = model as String
            if !str.hasSuffix(".bin") {
                targetFile = model
                self.subTable.reloadData()
            }
        }).disposed(by: disposeBag)
        
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
        
        modePackageTypeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(modeSelectView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }
        
        packetFormatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(modePackageTypeView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(packetFormatView.snp.bottom).offset(4)
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
                    convertOption.convertType = mode
                    convertOption.pixelformat = packageType
                    convertOption.packetFormat = packetFormat
                    let res = JLBmpConvert.convert(convertOption, imageData: dt)
                    self.imageBin = res.outFileData
                    if self.imageBin != nil {
                        self.statusLab.text = R.localStr.createSuccess()
                    }
                    self.saveData()
                }
            }
        }.disposed(by: disposeBag)
        
        sendBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            if let dt = self.imageBin, let dialMgr = dialMgr{
                let namePath = "/" + (self.nameInputView.textField.text ?? "BGP_W111")
                dialMgr.updateFile(toDevice: .FLASH, data: dt, filePath: namePath) { [weak self] status, progress, err in
                    if err != nil {
                        self?.view.makeToast(err?.localizedDescription ?? "send failed")
                    }
                    if status == 0 {
                        self?.progressView.progress = 1.0
                        self?.statusLab.text = R.localStr.successfullyModified()
                        self?.activeBgImgBin()
                    } else if status == 1 {
                        self?.progressView.progress = Float(progress)
                    }
                }
            }
        }.disposed(by: disposeBag)
    }
    private func activeBgImgBin() {
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
        let items = [
            "695N_RBG",
            "701N_RBG",
            "701N_ARBG",
            "701N_RBG_NO_PACK",
            "701N_ARGB_NO_PACK",
            "707N_RBG",
            "707N_ARGB",
            "707N_RBG_NO_PACK",
            "707N_ARGB_NO_PACK",
            "701N_JPEG"
        ]
        modeSelectView.updateItems(items)
        modeSelectView.scrollToItem("701N_ARBG")
        modeSelectView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "695N_RBG":
                mode = .type695N_RBG
            case "701N_RBG":
                mode = .type701N_RBG
            case "701N_ARBG":
                mode = .type701N_ARBG
            case "701N_RBG_NO_PACK":
                mode = .type701N_RBG_NO_PACK
            case "701N_ARGB_NO_PACK":
                mode = .type701N_ARGB_NO_PACK
            case "707N_RBG":
                mode = .type707N_RBG
            case "707N_ARGB":
                mode = .type707N_ARGB
            case "707N_RBG_NO_PACK":
                mode = .type707N_RBG_NO_PACK
            case "707N_ARGB_NO_PACK":
                mode = .type707N_ARGB_NO_PACK
            case "701N_JPEG":
                mode = .type701N_JPEG
            default:
                break
            }
        }
    }
    private func modePackageTypeViewInit() {
        modePackageTypeView.title = "format"
        let items = ["ARBG8888/RBG888","ARBG8565/RBG565","Auto"]
        modePackageTypeView.updateItems(items)
        modePackageTypeView.scrollToItem("Auto")
        modePackageTypeView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "ARBG8888/RBG888":
                packageType = ._565
            case "ARBG8565/RBG565":
                packageType = ._888
            case "Auto":
                packageType = ._Auto
            default:
                break
            }
        }
    }
    private func packetFormatViewInit() {
        packetFormatView.title = "packet Type"
        let items = ["None","JLUI","LVGL"]
        packetFormatView.updateItems(items)
        packetFormatView.scrollToItem("JLUI")
        packetFormatView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "None":
                packetFormat = .none
            case "JLUI":
                packetFormat = .JLUI
            case "LVGL":
                packetFormat = .LVGL
            default:
                break
            }
        }
    }
    
    private func namePath()->String {
        let chipName = getChipName()
        let type = getImageFormat()
        let name = chipName + "_" + "_" + type
        let path = _R.path.image2Bin + "/" + name + ".bin"
        return path
    }
    private func saveData(){
        guard let data = self.imageBin else { return }
        let path = namePath()
        try? FileManager.default.removeItem(atPath: path)
        FileManager.default.createFile(atPath: path, contents: data)
        if let list = _R.path.image2Bin.listFile() {
            items.accept(list)
        }
    }
    
    private func getChipName()->String {
        switch mode {
        case .type701N_RBG:
            return "701N_RBG"
        case .type701N_ARBG:
            return "701N_ARBG"
        case .type701N_RBG_NO_PACK:
            return "701N_RBG_NO_PACK"
        case .type701N_ARGB_NO_PACK:
            return "701N_ARGB_NO_PACK"
        case .type707N_RBG:
            return "707N_RBG"
        case .type707N_ARGB:
            return "707N_ARGB"
        case .type707N_RBG_NO_PACK:
            return "707N_RBG_NO_PACK"
        case .type707N_ARGB_NO_PACK:
            return "707N_ARGB_NO_PACK"
        case .type701N_JPEG:
            return "701N_JPEG"
        case .type695N_RBG:
            return "695N_RBG"
        @unknown default:
            return ""
        }
    }
    
    private func getImageFormat()->String {
        switch packageType {
        case ._565:
            return "ARBG8565|RBG565"
        case ._888:
            return "ARBG8888|RBG888"
        case ._Auto:
            return "Auto"
        @unknown default:
            return ""
        }
    }
    
}




