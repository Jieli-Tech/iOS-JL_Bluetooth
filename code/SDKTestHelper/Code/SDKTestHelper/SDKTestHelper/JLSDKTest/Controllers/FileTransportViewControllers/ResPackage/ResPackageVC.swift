//
//  ResPackageVC.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/3/18.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import JL_BLEKit
import JLPackageResKit
import JLBmpConvertKit
import RxSwift
import RxCocoa

class ResPackageVC: BaseViewController {
    
    let subTable = EmptyStateTableView()
    
    var modeSelectView: DropdownView<String> = DropdownView<String>()
    var modePackageTypeView: DropdownView<String> = DropdownView<String>()
    var packetFormatView: DropdownView<String> = DropdownView<String>()
    var nameInputView: InputView = InputView()
    
    let confirmBtn = UIButton()
    let clearCacheBtn = UIButton()
    let retryBtn = UIButton()
    
    let statusLab = UILabel()
    let progressView = UIProgressView()
    
    private let viewModel = ResPackageViewModel()
    
    // For file selection
    private let availableFiles = BehaviorRelay<[URL]>(value: [])
    
    override func initUI() {
        super.initUI()
        
        navigationView.title = "Res Package Transfer"
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        
        view.addSubview(subTable)
        view.addSubview(modeSelectView)
        view.addSubview(modePackageTypeView)
        view.addSubview(packetFormatView)
        view.addSubview(nameInputView)
        view.addSubview(confirmBtn)
        view.addSubview(clearCacheBtn)
        view.addSubview(retryBtn)
        view.addSubview(statusLab)
        view.addSubview(progressView)
        
        setupViews()
        setupConstraints()
        
        loadAvailableFiles()
    }
    
    private func setupViews() {
        subTable.backgroundColor = UIColor.clear
        subTable.rowHeight = 60
        subTable.tableFooterView = UIView()
        subTable.register(UITableViewCell.self, forCellReuseIdentifier: "imageCell")
        subTable.emptyStateLabelText = "No PNG files in image2bin folder"
        subTable.allowsMultipleSelection = true
        subTable.tintColor = .systemBlue // 设置鲜明的系统蓝色，让选中状态的✅更加明显
        
        modeSelectViewInit()
        modePackageTypeViewInit()
        packetFormatViewInit()
        
        nameInputView.configure(title: R.localStr.fileName(), placeholder: "input file name")
        nameInputView.textField.text = "PKG_001"
        
        confirmBtn.setTitle("Start Convert & Pack", for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        confirmBtn.backgroundColor = UIColor.random()
        confirmBtn.layer.cornerRadius = 10
        confirmBtn.layer.masksToBounds = true
        
        clearCacheBtn.setTitle("Clear Caches", for: .normal)
        clearCacheBtn.setTitleColor(.white, for: .normal)
        clearCacheBtn.backgroundColor = .gray
        clearCacheBtn.layer.cornerRadius = 10
        clearCacheBtn.layer.masksToBounds = true
        
        retryBtn.setTitle("Retry Transfer", for: .normal)
        retryBtn.setTitleColor(.white, for: .normal)
        retryBtn.backgroundColor = .orange
        retryBtn.layer.cornerRadius = 10
        retryBtn.layer.masksToBounds = true
        retryBtn.isHidden = true
        
        statusLab.textColor = .darkText
        statusLab.textAlignment = .center
        statusLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        statusLab.adjustsFontSizeToFitWidth = true
        statusLab.numberOfLines = 0
        
        progressView.progress = 0.0
        progressView.progressTintColor = UIColor.eHex("#cc4a1c")
        progressView.trackTintColor = UIColor.eHex("d8d8d8")
    }
    
    private func setupConstraints() {
        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(navigationView.snp.bottom).offset(12)
            make.height.equalTo(250)
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
            make.left.equalToSuperview().inset(12)
            make.top.equalTo(packetFormatView.snp.bottom).offset(12)
            make.height.equalTo(40)
            make.width.equalTo(160)
        }
        
        clearCacheBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.top.equalTo(packetFormatView.snp.bottom).offset(12)
            make.height.equalTo(40)
            make.width.equalTo(160)
        }
        
        statusLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(confirmBtn.snp.bottom).offset(12)
            make.height.greaterThanOrEqualTo(35)
        }
        
        progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(statusLab.snp.bottom).offset(12)
        }
        
        retryBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(progressView.snp.bottom).offset(12)
            make.height.equalTo(40)
        }
    }
    
    private func loadAvailableFiles() {
        if let list = _R.path.image2Bin.listFile() {
            let pngUrls = list.filter { $0.lowercased().hasSuffix(".png") }
                              .map { URL(fileURLWithPath: $0) }
            availableFiles.accept(pngUrls)
        }
    }
    
    override func initData() {
        super.initData()
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        availableFiles.map { $0.isEmpty }.bind(to: subTable.isEmpty).disposed(by: disposeBag)
        
        availableFiles.bind(to: subTable.rx.items(cellIdentifier: "imageCell")) { [weak self] row, url, cell in
            let size = _R.sizeForFilePath(url.path)
            let sizeStr = _R.covertToFileString(size)
            cell.textLabel?.text = "\(url.lastPathComponent) (\(sizeStr))"
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            cell.imageView?.image = UIImage(contentsOfFile: url.path)
            
            if let items = self?.viewModel.selectedImages.value, items.contains(where: { $0.url == url }) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }.disposed(by: disposeBag)
        
        subTable.rx.modelSelected(URL.self).subscribe(onNext: { [weak self] url in
            guard let self = self else { return }
            let size = _R.sizeForFilePath(url.path)
            if size > 2 * 1024 * 1024 {
                self.view.makeToast("Image exceeds 2MB limit", duration: 2, position: .center)
                return
            }
            
            let items = self.viewModel.selectedImages.value
            if let index = items.firstIndex(where: { $0.url == url }) {
                self.viewModel.removeImage(at: index)
            } else {
                if items.count >= 10 {
                    self.view.makeToast("Max 10 images allowed", duration: 2, position: .center)
                } else {
                    self.viewModel.selectImages(urls: [url])
                }
            }
            self.subTable.reloadData()
        }).disposed(by: disposeBag)
        
        subTable.rx.modelDeselected(URL.self).subscribe(onNext: { [weak self] url in
            guard let self = self else { return }
            if let index = self.viewModel.selectedImages.value.firstIndex(where: { $0.url == url }) {
                self.viewModel.removeImage(at: index)
                self.subTable.reloadData()
            }
        }).disposed(by: disposeBag)
        
        nameInputView.textField.rx.text.orEmpty.subscribe(onNext: { [weak self] text in
            self?.viewModel.targetFileName = text
        }).disposed(by: disposeBag)
        
        confirmBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.startProcess()
        }).disposed(by: disposeBag)
        
        clearCacheBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.clearCaches()
            self?.subTable.reloadData()
            self?.view.makeToast("Caches cleared", duration: 2, position: .center)
        }).disposed(by: disposeBag)
        
        retryBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.viewModel.retryTransfer()
        }).disposed(by: disposeBag)
        
        viewModel.state.subscribe(onNext: { [weak self] state in
            self?.handleState(state)
        }).disposed(by: disposeBag)
    }
    
    private func handleState(_ state: ResPackageState) {
        switch state {
        case .idle:
            statusLab.text = "Idle"
            progressView.progress = 0
            retryBtn.isHidden = true
            confirmBtn.isEnabled = true
            
        case .converting(let progress, let current, let total):
            statusLab.text = "Converting \(current)/\(total)..."
            progressView.progress = progress
            retryBtn.isHidden = true
            confirmBtn.isEnabled = false
            
        case .packing:
            statusLab.text = "Packing resources..."
            progressView.progress = 0
            retryBtn.isHidden = true
            confirmBtn.isEnabled = false
            
        case .transferring(let progress):
            statusLab.text = "Transferring to device: \(Int(progress * 100))%"
            progressView.progress = progress
            retryBtn.isHidden = true
            confirmBtn.isEnabled = false
            
        case .success(let message):
            statusLab.text = message
            progressView.progress = 1.0
            retryBtn.isHidden = true
            confirmBtn.isEnabled = true
            view.makeToast("Success", duration: 2, position: .center)
            
        case .failed(let step, let error):
            statusLab.text = "Failed at [\(step)]: \(error)"
            progressView.progress = 0
            retryBtn.isHidden = (step != "Transfer" && step != "Retry")
            confirmBtn.isEnabled = true
            view.makeToast("Failed: \(error)", duration: 3, position: .center)
        }
    }
    
    // MARK: - Dropdown Inits
    
    private func modeSelectViewInit() {
        modeSelectView.title = "Chip Type"
        let items = [
            "695N_RBG", "701N_RBG", "701N_ARBG", "701N_RBG_NO_PACK",
            "701N_ARGB_NO_PACK", "707N_RBG", "707N_ARGB",
            "707N_RBG_NO_PACK", "707N_ARGB_NO_PACK", "701N_JPEG"
        ]
        modeSelectView.updateItems(items)
        modeSelectView.scrollToItem("701N_ARBG")
        modeSelectView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "695N_RBG": self.viewModel.mode = .type695N_RBG
            case "701N_RBG": self.viewModel.mode = .type701N_RBG
            case "701N_ARBG": self.viewModel.mode = .type701N_ARBG
            case "701N_RBG_NO_PACK": self.viewModel.mode = .type701N_RBG_NO_PACK
            case "701N_ARGB_NO_PACK": self.viewModel.mode = .type701N_ARGB_NO_PACK
            case "707N_RBG": self.viewModel.mode = .type707N_RBG
            case "707N_ARGB": self.viewModel.mode = .type707N_ARGB
            case "707N_RBG_NO_PACK": self.viewModel.mode = .type707N_RBG_NO_PACK
            case "707N_ARGB_NO_PACK": self.viewModel.mode = .type707N_ARGB_NO_PACK
            case "701N_JPEG": self.viewModel.mode = .type701N_JPEG
            default: break
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
            case "ARBG8888/RBG888": self.viewModel.packageType = ._888
            case "ARBG8565/RBG565": self.viewModel.packageType = ._565
            case "Auto": self.viewModel.packageType = ._Auto
            default: break
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
            case "None": self.viewModel.packetFormat = .none
            case "JLUI": self.viewModel.packetFormat = .JLUI
            case "LVGL": self.viewModel.packetFormat = .LVGL
            default: break
            }
        }
    }
}
