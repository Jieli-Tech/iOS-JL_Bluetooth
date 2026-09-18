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
    var compressStrategyView: DropdownView<String> = DropdownView<String>()
    var paletteFormatView: DropdownView<String> = DropdownView<String>()
    var nameInputView: InputView = InputView()
    let sendBtn = UIButton()
    let constraintLab = UILabel()
    
    private var mode: JLBmpConvertType = .type701N_ARBG
    private let convertOption = JLBmpConvertOption()
    private var packageType: JLBmpPixelformat = ._Auto
    private var packetFormat: JLBmpPacketFormat = .JLUI
    private var compressStrategy: JLBmpCompressStrategy = .bestQuality
    private var paletteFormat: JLBmpPaletteFormat = .auto
    private var imageBin:Data?
    private let items = BehaviorRelay<[String]>(value: [])
    private var targetFile = ""
    private var dialMgr: JLDialUnitMgr?
    
    /// 当前是否为 380N 模式
    private var is380NMode: Bool {
        return mode == .type380N_IMAGE
    }
    
    /// 当前是否为 707N 模式
    private var is707NMode: Bool {
        return [.type707N_RBG, .type707N_ARGB, .type707N_ARGB_NO_PACK, .type707N_RBG_NO_PACK].contains(mode)
    }
    
    override func initUI() {
        super.initUI()
        
        navigationView.title = R.localStr.imageToDevice()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(subTable)
        view.addSubview(modeSelectView)
        view.addSubview(modePackageTypeView)
        view.addSubview(packetFormatView)
        view.addSubview(compressStrategyView)
        view.addSubview(paletteFormatView)
        view.addSubview(nameInputView)
        view.addSubview(constraintLab)
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
        compressStrategyViewInit()
        paletteFormatViewInit()
        
        nameInputView.configure(title: R.localStr.fileName(), placeholder: "input file name")
        nameInputView.textField.text = "BGP_W111"
        
        subTable.tintColor = .random()
        
        constraintLab.font = .systemFont(ofSize: 11)
        constraintLab.textColor = .eHex("#cc4a1c")
        constraintLab.numberOfLines = 0
        constraintLab.textAlignment = .left
        updateConstraintHint()
        
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
        subTable.importDestinationPath = _R.path.image2Bin
        
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
            make.height.equalTo(150)
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
        
        compressStrategyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(packetFormatView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }
        
        paletteFormatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(compressStrategyView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        constraintLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(paletteFormatView.snp.bottom).offset(4)
        }
        
        confirmBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(constraintLab.snp.bottom).offset(4)
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
        
        update380NControlsVisibility()
    }
    
    override func initData() {
        super.initData()
        
        initDialMgr()
        
        // 文件导入后刷新列表
        subTable.fileImported
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let list = _R.path.image2Bin.listFile() {
                    self.items.accept(list)
                }
            })
            .disposed(by: disposeBag)
        
        subTable.fileImportError
            .subscribe(onNext: { [weak self] error in
                self?.view.makeToast(error.localizedDescription, duration: 2, position: .center)
            })
            .disposed(by: disposeBag)
        
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
                    convertOption.compressStrategy = compressStrategy
                    convertOption.paletteFormat = paletteFormat
                    // 转换前自动修正不兼容参数
                    convertOption.autoCorrectParameters()
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
    
    // MARK: - Chip Type
    
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
            "701N_JPEG",
            "380N_IMAGE"
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
            case "380N_IMAGE":
                mode = .type380N_IMAGE
            default:
                break
            }
            self.onChipTypeChanged()
        }
    }
    
    // MARK: - Pixel Format
    
    private func modePackageTypeViewInit() {
        modePackageTypeView.title = "format"
        updatePixelFormatItems()
        modePackageTypeView.scrollToItem("Auto")
        modePackageTypeView.onSelect = { [weak self] item in
            guard let self = self else { return }
            packageType = self.pixelformatFromItem(item)
        }
    }
    
    // MARK: - Packet Format
    
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
    
    // MARK: - Compress Strategy (380N only)
    
    private func compressStrategyViewInit() {
        compressStrategyView.title = "Compress"
        let items = ["None", "BestPerformance", "BestSpaceSize", "BestQuality"]
        compressStrategyView.updateItems(items)
        compressStrategyView.scrollToItem("BestQuality")
        compressStrategyView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "None":
                compressStrategy = .none
            case "BestPerformance":
                compressStrategy = .bestPerformance
            case "BestSpaceSize":
                compressStrategy = .bestSpaceSize
            case "BestQuality":
                compressStrategy = .bestQuality
            default:
                break
            }
        }
    }
    
    // MARK: - Palette Format (380N only)
    
    private func paletteFormatViewInit() {
        paletteFormatView.title = "Palette"
        let items = ["ARGB8888", "ARGB8565", "RGB888", "RGB565", "Auto"]
        paletteFormatView.updateItems(items)
        paletteFormatView.scrollToItem("Auto")
        paletteFormatView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "ARGB8888":
                paletteFormat = .ARGB8888
            case "ARGB8565":
                paletteFormat = .ARGB8565
            case "RGB888":
                paletteFormat = .RGB888
            case "RGB565":
                paletteFormat = .RGB565
            case "Auto":
                paletteFormat = .auto
            default:
                break
            }
        }
    }
    
    // MARK: - Chip Type Changed
    
    private func onChipTypeChanged() {
        updatePixelFormatItems()
        updatePacketFormatAvailability()
        update380NControlsVisibility()
        updateConstraintHint()
    }
    
    /// 更新像素格式可选项（根据芯片类型）
    private func updatePixelFormatItems() {
        if is380NMode {
            let items = [
                "888(ARGB8888/RGB888)",
                "565(ARGB8565/RGB565)",
                "Auto",
                "ARGB4444",
                "ARGB1555",
                "AL88",
                "AL44",
                "AL22",
                "L8",
                "L4",
                "L2",
                "L1",
                "A8",
                "A4",
                "A2",
                "A1"
            ]
            modePackageTypeView.updateItems(items)
            modePackageTypeView.scrollToItem("Auto")
            packageType = ._Auto
        } else if is707NMode {
            let items = ["ARGB8888/RGB888", "ARGB8565/RGB565", "Auto"]
            modePackageTypeView.updateItems(items)
            modePackageTypeView.scrollToItem("Auto")
            packageType = ._Auto
        } else {
            // 695N/701N 不支持自定义像素格式，显示固定值
            let items = ["Auto(Fixed)"]
            modePackageTypeView.updateItems(items)
            modePackageTypeView.scrollToItem("Auto(Fixed)")
            packageType = ._Auto
        }
    }
    
    /// 根据显示项获取像素格式枚举值
    private func pixelformatFromItem(_ item: String) -> JLBmpPixelformat {
        switch item {
        case "888(ARGB8888/RGB888)", "ARGB8888/RGB888":
            return ._888
        case "565(ARGB8565/RGB565)", "ARGB8565/RGB565":
            return ._565
        case "Auto", "Auto(Fixed)":
            return ._Auto
        case "ARGB4444":
            return ._ARGB4444
        case "ARGB1555":
            return ._ARGB1555
        case "AL88":
            return ._AL88
        case "AL44":
            return ._AL44
        case "AL22":
            return ._AL22
        case "L8":
            return ._L8
        case "L4":
            return ._L4
        case "L2":
            return ._L2
        case "L1":
            return ._L1
        case "A8":
            return ._A8
        case "A4":
            return ._A4
        case "A2":
            return ._A2
        case "A1":
            return ._A1
        default:
            return ._Auto
        }
    }
    
    /// 更新打包格式可用性
    /// 707N 系列芯片支持 None/JLUI/LVGL
    /// 380N 芯片支持 None/JLUI/LVGL
    /// 695N/701N 有固定打包格式
    private func updatePacketFormatAvailability() {
        if is380NMode || is707NMode {
            // 707N 和 380N 支持选择 None/JLUI/LVGL
            let items = ["None", "JLUI", "LVGL"]
            packetFormatView.updateItems(items)
            packetFormatView.show(true)
        } else {
            // 695N/701N 有固定打包格式
            let isNoPack = [.type701N_RBG_NO_PACK, .type701N_ARGB_NO_PACK].contains(mode)
            let items = isNoPack ? ["None(Fixed)"] : ["JLUI(Fixed)"]
            packetFormatView.updateItems(items)
            packetFormatView.scrollToItem(items[0])
            packetFormat = isNoPack ? .none : .JLUI
            packetFormatView.show(true)
        }
    }
    
    /// 更新 380N 专属控件的可见性
    private func update380NControlsVisibility() {
        let show = is380NMode
        compressStrategyView.isHidden = !show
        paletteFormatView.isHidden = !show

        // 非380N时，压缩策略和调色板格式重置为默认值
        if !show {
            compressStrategy = .none
            paletteFormat = .auto
        }
    }
    
    /// 更新参数约束提示
    private func updateConstraintHint() {
        var hints: [String] = []
        
        switch mode {
        case .type695N_RBG:
            hints = ["695N: 固定RGB565+JLUI打包，不支持自定义参数"]
        case .type701N_RBG:
            hints = ["701N_RBG: 固定RGB565+JLUI打包"]
        case .type701N_ARBG:
            hints = ["701N_ARBG: 固定ARGB8565+JLUI打包"]
        case .type701N_RBG_NO_PACK:
            hints = ["701N_RBG_NO_PACK: 固定RGB565，不打包"]
        case .type701N_ARGB_NO_PACK:
            hints = ["701N_ARGB_NO_PACK: 固定ARGB8565，不打包"]
        case .type701N_JPEG:
            hints = ["701N_JPEG: JPEG直通，所有格式参数无效"]
        case .type707N_RBG, .type707N_ARGB:
            hints = ["707N: 支持888/565/Auto像素格式，支持JLUI/LVGL/None打包"]
        case .type707N_RBG_NO_PACK, .type707N_ARGB_NO_PACK:
            hints = ["707N_NO_PACK: 支持888/565/Auto像素格式，强制不打包"]
        case .type380N_IMAGE:
            hints = ["380N: 支持全部16种像素格式、4种压缩策略、5种调色板格式、3种打包方式"]
        @unknown default:
            break
        }
        
        constraintLab.text = hints.joined(separator: "\n")
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
        case .type380N_IMAGE:
            return "380N_IMAGE"
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
        case ._ARGB4444:
            return "ARGB4444"
        case ._ARGB1555:
            return "ARGB1555"
        case ._AL88:
            return "AL88"
        case ._AL44:
            return "AL44"
        case ._AL22:
            return "AL22"
        case ._L8:
            return "L8"
        case ._L4:
            return "L4"
        case ._L2:
            return "L2"
        case ._L1:
            return "L1"
        case ._A8:
            return "A8"
        case ._A4:
            return "A4"
        case ._A2:
            return "A2"
        case ._A1:
            return "A1"
        @unknown default:
            return ""
        }
    }
    
}
