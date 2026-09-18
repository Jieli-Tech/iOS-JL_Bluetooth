//
//  Image2JLJpegVC.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import JLBmpConvertKit
import UIKit

/// JLJPEGConvert 测试界面
/// 用于测试 JPEG 编码/解码功能及资源类型配置
class Image2JLJpegVC: BaseViewController {

    // ScrollView
    let scrollView = UIScrollView()
    let contentView = UIView()

    let subTable = EmptyStateTableView()
    let confirmBtn = UIButton()
    let statusLab = UILabel()
    let progressView = UIProgressView()

    // 配置选项控件
    var pixelFormatView: DropdownView<String> = DropdownView<String>()
    var blockModeView: DropdownView<String> = DropdownView<String>()
    var yuvSampleView: DropdownView<String> = DropdownView<String>()
    var btModeView: DropdownView<String> = DropdownView<String>()
    var resourceTypeView: DropdownView<String> = DropdownView<String>()
    var imageFormatView: DropdownView<String> = DropdownView<String>()
    var blockSizeView: DropdownView<String> = DropdownView<String>()
    var lvglVersionView: DropdownView<String> = DropdownView<String>()
    var waferTypeView: DropdownView<String> = DropdownView<String>()
    var clutFormatView: DropdownView<String> = DropdownView<String>()
    var yuvFormatView: DropdownView<String> = DropdownView<String>()

    var rgbQualityInput: InputView = InputView()
    var alphaQualityInput: InputView = InputView()
    var widthInput: InputView = InputView()
    var heightInput: InputView = InputView()
    var nameInputView: InputView = InputView()

    let decodeBtn = UIButton()
    let constraintLab = UILabel()
    let jsonPreviewBtn = UIButton()
    
    // 数据源
    private let items = BehaviorRelay<[String]>(value: [])
    private var targetFile = ""
    private var jpegData: Data?
    private var decodedImage: UIImage?
    
    // 配置状态
    private var pixelFormat: JLJPEGPixelFormat = .BGRA8888
    private var blockMode: JLJPEGBlockMode = .mode32x32
    private var yuvSample: JLJPEGYUVSample = .sample420
    private var btMode: JLJPEGBTMode = .BT601
    private var resourceType: JLResourceType = .BIN
    private var imageFormat: JLImageFormat = .ARGB8888
    private var blockSize: JLBlockSize = .size64x1
    private var lvglVersion: JLLVGLVersion = .version8
    private var waferType: JLWaferType = .ALL
    private var clutFormat: JLCLUTFormat = .ARGB8888
    private var yuvFormat: JLYUVFormat = .YUYV
    
    /// 当前是否为 RLE 类型
    private var isRLEMode: Bool {
        return resourceType == .RLE
    }
    
    /// 当前是否为 ETC2 类型
    private var isETC2Mode: Bool {
        return resourceType == .ETC2
    }
    
    override func initUI() {
        super.initUI()

        navigationView.title = R.string.localizable.imageToJLJPEG()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        // 添加 ScrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // 添加所有控件到 contentView
        contentView.addSubview(subTable)
        contentView.addSubview(nameInputView)
        contentView.addSubview(pixelFormatView)
        contentView.addSubview(blockModeView)
        contentView.addSubview(yuvSampleView)
        contentView.addSubview(btModeView)
        contentView.addSubview(resourceTypeView)
        contentView.addSubview(imageFormatView)
        contentView.addSubview(blockSizeView)
        contentView.addSubview(lvglVersionView)
        contentView.addSubview(waferTypeView)
        contentView.addSubview(clutFormatView)
        contentView.addSubview(yuvFormatView)
        contentView.addSubview(rgbQualityInput)
        contentView.addSubview(alphaQualityInput)
        contentView.addSubview(widthInput)
        contentView.addSubview(heightInput)
        contentView.addSubview(constraintLab)
        contentView.addSubview(confirmBtn)
        contentView.addSubview(decodeBtn)
        contentView.addSubview(jsonPreviewBtn)
        contentView.addSubview(statusLab)
        view.addSubview(progressView)

        // 加载文件列表
        let list = _R.path.image2JLJpeg.listFile() ?? []
        items.accept(list)
        if items.value.count == 0 {
            view.makeToast(R.string.localizable.pleaseImportImageFilesToDocumentsImage2JLJpegFolder(), duration: 3, position: .center)
        }
        
        setupTableView()
        setupDropdownViews()
        setupInputViews()
        setupButtons()
        setupConstraints()
        
        updateConstraintHint()
        updateRLEControlsVisibility()
        updateETC2ControlsVisibility()
    }
    
    private func setupTableView() {
        subTable.backgroundColor = UIColor.clear
        subTable.rowHeight = 35
        subTable.tableFooterView = UIView()
        subTable.register(UITableViewCell.self, forCellReuseIdentifier: "tagCell")
        subTable.tintColor = .random()
        subTable.emptyStateLabelText = R.string.localizable.pleaseImportImageFilesToDocumentsImage2JLJpegFolder()
        subTable.importDestinationPath = _R.path.image2JLJpeg
        
        items.bind(to: subTable.rx.items(cellIdentifier: "tagCell")) { [weak self] _, item, cell in
            cell.textLabel?.text = (item as NSString).lastPathComponent
            if self?.targetFile == item {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }.disposed(by: disposeBag)
        
        items.map { $0.isEmpty }.bind(to: subTable.isEmpty).disposed(by: disposeBag)
        
        subTable.rx.modelSelected(String.self).subscribe(onNext: { [weak self] model in
            guard let self = self else { return }
            self.targetFile = model
            self.subTable.reloadData()
            // 自动获取图片尺寸
            self.autoFillImageDimensions()
        }).disposed(by: disposeBag)
    }
    
    private func setupDropdownViews() {
        // 像素格式
        pixelFormatView.title = "Pixel Format"
        pixelFormatView.updateItems(["BGRA8888", "BGR888", "A8"])
        pixelFormatView.scrollToItem("BGRA8888")
        pixelFormatView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "BGRA8888": self.pixelFormat = .BGRA8888
            case "BGR888": self.pixelFormat = .BGR888
            case "A8": self.pixelFormat = .A8
            default: break
            }
        }
        
        // 分块方式
        blockModeView.title = "Block Mode"
        blockModeView.updateItems(["32x16", "32x32"])
        blockModeView.scrollToItem("32x32")
        blockModeView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "32x16": self.blockMode = .mode32x16
            case "32x32": self.blockMode = .mode32x32
            default: break
            }
        }
        
        // YUV 采样
        yuvSampleView.title = "YUV Sample"
        yuvSampleView.updateItems(["444", "422", "420"])
        yuvSampleView.scrollToItem("420")
        yuvSampleView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "444": self.yuvSample = .sample444
            case "422": self.yuvSample = .sample422
            case "420": self.yuvSample = .sample420
            default: break
            }
        }
        
        // BT 模式
        btModeView.title = "BT Mode"
        btModeView.updateItems(["BT709", "BT601"])
        btModeView.scrollToItem("BT601")
        btModeView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "BT709": self.btMode = .BT709
            case "BT601": self.btMode = .BT601
            default: break
            }
        }
        
        // 资源类型
        resourceTypeView.title = "Resource Type"
        resourceTypeView.updateItems(["BIN", "RLE", "ETC2"])
        resourceTypeView.scrollToItem("BIN")
        resourceTypeView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "BIN": self.resourceType = .BIN
            case "RLE": self.resourceType = .RLE
            case "ETC2": self.resourceType = .ETC2
            default: break
            }
            self.onResourceTypeChanged()
        }
        
        // 图像格式
        imageFormatView.title = "Image Format"
        updateImageFormatItems()
        imageFormatView.scrollToItem("ARGB8888")
        imageFormatView.onSelect = { [weak self] item in
            guard let self = self else { return }
            self.imageFormat = self.imageFormatFromItem(item)
        }
        
        // 块大小
        blockSizeView.title = "Block Size"
        blockSizeView.updateItems(["64x1", "8x8", "256x1", "16x16"])
        blockSizeView.scrollToItem("64x1")
        blockSizeView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "64x1": self.blockSize = .size64x1
            case "8x8": self.blockSize = .size8x8
            case "256x1": self.blockSize = .size256x1
            case "16x16": self.blockSize = .size16x16
            default: break
            }
        }
        
        // LVGL 版本
        lvglVersionView.title = "LVGL Version"
        lvglVersionView.updateItems(["LVGL8", "LVGL9"])
        lvglVersionView.scrollToItem("LVGL8")
        lvglVersionView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "LVGL8": self.lvglVersion = .version8
            case "LVGL9": self.lvglVersion = .version9
            default: break
            }
        }
        
        // 晶圆类型
        waferTypeView.title = "Wafer Type"
        waferTypeView.updateItems(["BR33", "WL83", "ALL"])
        waferTypeView.scrollToItem("ALL")
        waferTypeView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "BR33": self.waferType = .BR33
            case "WL83": self.waferType = .WL83
            case "ALL": self.waferType = .ALL
            default: break
            }
        }
        
        // CLUT 格式
        clutFormatView.title = "CLUT Format"
        clutFormatView.updateItems(["ARGB8888", "ARGB8565", "RGB888", "RGB565"])
        clutFormatView.scrollToItem("ARGB8888")
        clutFormatView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "ARGB8888": self.clutFormat = .ARGB8888
            case "ARGB8565": self.clutFormat = .ARGB8565
            case "RGB888": self.clutFormat = .RGB888
            case "RGB565": self.clutFormat = .RGB565
            default: break
            }
        }
        
        // YUV 格式
        yuvFormatView.title = "YUV Format"
        yuvFormatView.updateItems(["YUYV", "UYVY"])
        yuvFormatView.scrollToItem("YUYV")
        yuvFormatView.onSelect = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case "YUYV": self.yuvFormat = .YUYV
            case "UYVY": self.yuvFormat = .UYVY
            default: break
            }
        }
    }
    
    private func setupInputViews() {
        nameInputView.configure(title: R.localStr.fileName(), placeholder: "input file name")
        nameInputView.textField.text = "test_jpeg"
        
        rgbQualityInput.configure(title: "RGB Q", placeholder: "1-100", "90")
        rgbQualityInput.textField.keyboardType = .numberPad
        
        alphaQualityInput.configure(title: "Alpha Q", placeholder: "1-100", "90")
        alphaQualityInput.textField.keyboardType = .numberPad
        
        widthInput.configure(title: "Width", placeholder: "auto")
        widthInput.textField.keyboardType = .numberPad
        
        heightInput.configure(title: "Height", placeholder: "auto")
        heightInput.textField.keyboardType = .numberPad
    }

    private func setupButtons() {
        confirmBtn.setTitle(R.string.localizable.encodeToJLJPEG(), for: .normal)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.backgroundColor = UIColor.random()
        confirmBtn.layer.cornerRadius = 10
        confirmBtn.layer.masksToBounds = true

        decodeBtn.setTitle(R.string.localizable.decodeJLJPEG(), for: .normal)
        decodeBtn.setTitleColor(.white, for: .normal)
        decodeBtn.backgroundColor = UIColor.random()
        decodeBtn.layer.cornerRadius = 10
        decodeBtn.layer.masksToBounds = true

        jsonPreviewBtn.setTitle(R.string.localizable.previewJSONConfig(), for: .normal)
        jsonPreviewBtn.setTitleColor(.white, for: .normal)
        jsonPreviewBtn.backgroundColor = UIColor.random()
        jsonPreviewBtn.layer.cornerRadius = 10
        jsonPreviewBtn.layer.masksToBounds = true

        statusLab.textColor = .darkText
        statusLab.textAlignment = .center
        statusLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        statusLab.adjustsFontSizeToFitWidth = true
        statusLab.text = R.string.localizable.ready()
        
        progressView.progress = 0.0
        progressView.progressTintColor = UIColor.eHex("#cc4a1c")
        progressView.trackTintColor = UIColor.eHex("d8d8d8")
        
        constraintLab.font = .systemFont(ofSize: 11)
        constraintLab.textColor = .eHex("#cc4a1c")
        constraintLab.numberOfLines = 0
        constraintLab.textAlignment = .left
    }
    
    private func setupConstraints() {
        // ScrollView 约束
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-50)
        }

        // ContentView 约束
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalToSuperview().offset(12)
            make.height.equalTo(120)
        }

        nameInputView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(subTable.snp.bottom).offset(5)
            make.height.equalTo(35)
        }

        pixelFormatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(nameInputView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        blockModeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(pixelFormatView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        yuvSampleView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(blockModeView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        btModeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(yuvSampleView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        resourceTypeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(btModeView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        imageFormatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(resourceTypeView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        blockSizeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(imageFormatView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        lvglVersionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(blockSizeView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        waferTypeView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(lvglVersionView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        clutFormatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(waferTypeView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        yuvFormatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(clutFormatView.snp.bottom).offset(4)
            make.height.equalTo(35)
        }

        rgbQualityInput.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.top.equalTo(yuvFormatView.snp.bottom).offset(4)
            make.width.equalToSuperview().multipliedBy(0.48)
            make.height.equalTo(35)
        }

        alphaQualityInput.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.top.equalTo(yuvFormatView.snp.bottom).offset(4)
            make.width.equalToSuperview().multipliedBy(0.48)
            make.height.equalTo(35)
        }

        widthInput.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.top.equalTo(rgbQualityInput.snp.bottom).offset(4)
            make.width.equalToSuperview().multipliedBy(0.48)
            make.height.equalTo(35)
        }

        heightInput.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.top.equalTo(alphaQualityInput.snp.bottom).offset(4)
            make.width.equalToSuperview().multipliedBy(0.48)
            make.height.equalTo(35)
        }

        constraintLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(widthInput.snp.bottom).offset(4)
        }

        confirmBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(12)
            make.top.equalTo(constraintLab.snp.bottom).offset(8)
            make.right.equalTo(decodeBtn.snp.left).offset(-10)
            make.width.equalTo(decodeBtn.snp.width)
            make.height.equalTo(40)
        }

        decodeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.top.equalTo(constraintLab.snp.bottom).offset(8)
            make.left.equalTo(confirmBtn.snp.right).offset(10)
            make.width.equalTo(confirmBtn.snp.width)
            make.height.equalTo(40)
        }

        jsonPreviewBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(confirmBtn.snp.bottom).offset(8)
            make.height.equalTo(35)
        }

        statusLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(jsonPreviewBtn.snp.bottom).offset(8)
            make.height.equalTo(30)
            make.bottom.equalToSuperview().offset(-12)
        }

        progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    override func initData() {
        super.initData()
        
        // 文件导入后刷新列表
        subTable.fileImported
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let list = _R.path.image2JLJpeg.listFile() ?? []
                self.items.accept(list)
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
        
        // 编码按钮
        confirmBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.encodeImage()
        }.disposed(by: disposeBag)
        
        // 解码按钮
        decodeBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.decodeImage()
        }.disposed(by: disposeBag)
        
        // JSON 预览按钮
        jsonPreviewBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.previewJSONConfig()
        }.disposed(by: disposeBag)
    }
    
    // MARK: - 编码逻辑
    
    private func encodeImage() {
        guard targetFile.count > 0 else {
            view.makeToast(R.string.localizable.pleaseSelectAnImageFileFirst())
            return
        }

        statusLab.text = R.string.localizable.encoding()
        progressView.progress = 0.3
        
        // 在主线程提前收集 UI 值，避免后台线程访问 UI
        let option = createOption()
        let filePath = targetFile
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                let imageData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                
                // 验证参数
                let warnings = option.validationWarnings()
                if !warnings.isEmpty {
                    DispatchQueue.main.async {
                        self.statusLab.text = "Warn: \(warnings.joined(separator: ", "))"
                    }
                    option.autoCorrectParameters()
                }

                // 执行编码
                let result: JLJPEGConvertResult
                if let image = UIImage(data: imageData) {
                    result = JLJPEGConvert.encode(option, image: image)
                } else {
                    result = JLJPEGConvert.encodeImageData(option, imageData: imageData)
                }

                DispatchQueue.main.async {
                    self.progressView.progress = 1.0
                    if result.result > 0, let data = result.outData {
                        self.jpegData = data
                        self.statusLab.text = "\(R.string.localizable.encodeSuccess()): \(data.count) bytes"
                        self.saveData(data, suffix: "jljpeg")
                    } else {
                        self.statusLab.text = "\(R.string.localizable.encodeFailed()): \(result.error?.localizedDescription ?? "Unknown")"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.statusLab.text = "\(R.string.localizable.readFileFailed()): \(error.localizedDescription)"
                    self.progressView.progress = 0.0
                }
            }
        }
    }

    // MARK: - 解码逻辑

    private func decodeImage() {
        guard let jpegData = jpegData else {
            view.makeToast(R.string.localizable.pleaseEncodeToGenerateJLJPEGDataFirst())
            return
        }

        statusLab.text = R.string.localizable.decoding()
        progressView.progress = 0.5

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }

            if let image = JLJPEGConvert.decode(toImage: jpegData) {
                DispatchQueue.main.async {
                    self.decodedImage = image
                    self.progressView.progress = 1.0
                    self.statusLab.text = "\(R.string.localizable.decodeSuccess()): \(Int(image.size.width))x\(Int(image.size.height))"
                    self.showDecodedImage(image)
                }
            } else {
                DispatchQueue.main.async {
                    self.statusLab.text = R.string.localizable.decodeFailed()
                    self.progressView.progress = 0.0
                }
            }
        }
    }
    
    // MARK: - JSON 配置预览
    
    private func previewJSONConfig() {
        let option = createOption()
        let json = option.generateJSONConfig()

        let alert = UIAlertController(title: R.string.localizable.jsonConfig(), message: json, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.copy(), style: .default) { _ in
            UIPasteboard.general.string = json
        })
        alert.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - 辅助方法
    
    private func createOption() -> JLJPEGConvertOption {
        let option = JLJPEGConvertOption()
        option.pixelFormat = pixelFormat
        option.blockMode = blockMode
        option.yuvSample = yuvSample
        option.btMode = btMode
        option.resourceType = resourceType
        option.imageFormat = imageFormat
        option.blockSize = blockSize
        option.lvglVersion = lvglVersion
        option.waferType = waferType
        option.clutFormat = clutFormat
        option.yuvFormat = yuvFormat
        
        if let rgbStr = rgbQualityInput.textField.text, let rgb = UInt8(rgbStr), rgb >= 1 && rgb <= 100 {
            option.rgbQuality = rgb
        } else {
            option.rgbQuality = 90
        }
        
        if let alphaStr = alphaQualityInput.textField.text, let alpha = UInt8(alphaStr), alpha >= 1 && alpha <= 100 {
            option.alphaQuality = alpha
        } else {
            option.alphaQuality = 90
        }
        
        if let wStr = widthInput.textField.text, let w = UInt16(wStr), w > 0 {
            option.width = w
        }
        
        if let hStr = heightInput.textField.text, let h = UInt16(hStr), h > 0 {
            option.height = h
        }
        
        return option
    }
    
    private func autoFillImageDimensions() {
        guard targetFile.count > 0 else { return }
        
        if let image = UIImage(contentsOfFile: targetFile) {
            widthInput.textField.text = "\(Int(image.size.width))"
            heightInput.textField.text = "\(Int(image.size.height))"
        }
    }
    
    private func saveData(_ data: Data, suffix: String) {
        let fileName = (nameInputView.textField.text ?? "test") + "." + suffix
        let path = _R.path.image2JLJpeg + "/" + fileName
        try? FileManager.default.removeItem(atPath: path)
        FileManager.default.createFile(atPath: path, contents: data)

        // 刷新列表
        let list = _R.path.image2JLJpeg.listFile() ?? []
        items.accept(list)
    }
    
    private func showDecodedImage(_ image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        
        let container = UIView(frame: UIScreen.main.bounds)
        container.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        container.addSubview(imageView)
        imageView.frame = CGRect(x: 20, y: 100, width: container.bounds.width - 40, height: container.bounds.height - 200)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissImageView(_:)))
        container.addGestureRecognizer(tapGesture)
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(container)
            container.tag = 9999
        }
    }
    
    @objc private func dismissImageView(_ gesture: UITapGestureRecognizer) {
        gesture.view?.removeFromSuperview()
    }
    
    // MARK: - 资源类型变化处理
    
    private func onResourceTypeChanged() {
        updateImageFormatItems()
        updateRLEControlsVisibility()
        updateETC2ControlsVisibility()
        updateConstraintHint()
    }
    
    private func updateImageFormatItems() {
        var items: [String]
        switch resourceType {
        case .BIN:
            items = ["ARGB8888", "ARGB8565", "RGB888", "RGB565",
                     "Indexed1Bit", "Indexed2Bit", "Indexed4Bit", "Indexed8Bit",
                     "Alpha1Bit", "Alpha2Bit", "Alpha4Bit", "Alpha8Bit"]
        case .RLE:
            items = ["ARGB8888", "ARGB8565", "RGB888", "RGB565", "Indexed8Bit", "Alpha8Bit"]
        case .ETC2:
            items = ["ARGB8888", "RGB888", "Alpha8Bit"]
        default:
            items = ["ARGB8888"]
        }
        imageFormatView.updateItems(items)
        imageFormatView.scrollToItem(items[0])
        imageFormat = imageFormatFromItem(items[0])
    }
    
    private func imageFormatFromItem(_ item: String) -> JLImageFormat {
        switch item {
        case "ARGB8888": return .ARGB8888
        case "ARGB8565": return .ARGB8565
        case "RGB888": return .RGB888
        case "RGB565": return .RGB565
        case "Indexed1Bit": return .indexed1Bit
        case "Indexed2Bit": return .indexed2Bit
        case "Indexed4Bit": return .indexed4Bit
        case "Indexed8Bit": return .indexed8Bit
        case "Alpha1Bit": return .alpha1Bit
        case "Alpha2Bit": return .alpha2Bit
        case "Alpha4Bit": return .alpha4Bit
        case "Alpha8Bit": return .alpha8Bit
        default: return .ARGB8888
        }
    }
    
    private func updateRLEControlsVisibility() {
        let show = isRLEMode
        clutFormatView.isHidden = !show
        yuvFormatView.isHidden = !show
    }
    
    private func updateETC2ControlsVisibility() {
        // ETC2 需要 waferType 不为 WL83
        if isETC2Mode && waferType == .WL83 {
            waferType = .ALL
            waferTypeView.scrollToItem("ALL")
        }
    }
    
    private func updateConstraintHint() {
        var hints: [String] = []
        
        switch resourceType {
        case .BIN:
            hints = ["BIN: 支持所有图像格式，无需额外参数"]
        case .RLE:
            hints = ["RLE: 必需设置 CLUT Format 和 YUV Format"]
            hints.append("支持的格式: ARGB8888/8565, RGB888/565, Indexed8Bit, Alpha8Bit")
        case .ETC2:
            hints = ["ETC2: 不支持 WL83 晶圆类型"]
            hints.append("支持的格式: ARGB8888, RGB888, Alpha8Bit")
        default:
            break
        }
        
        // 块大小兼容性提示
        let blockCompat: String
        switch imageFormat {
        case .ARGB8888, .ARGB8565, .RGB565:
            blockCompat = "64x1, 8x8"
        case .indexed1Bit, .indexed2Bit, .indexed4Bit, .indexed8Bit,
                .alpha1Bit, .alpha2Bit, .alpha4Bit, .alpha8Bit:
            blockCompat = "256x1, 16x16"
        default:
            blockCompat = "64x1, 8x8, 256x1, 16x16"
        }
        hints.append("当前格式支持的块大小: \(blockCompat)")
        
        constraintLab.text = hints.joined(separator: "\n")
    }
}
