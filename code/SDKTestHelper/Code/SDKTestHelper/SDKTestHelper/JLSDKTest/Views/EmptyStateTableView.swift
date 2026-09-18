//
//  EmptyStateTableView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/17.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import MobileCoreServices

class EmptyStateTableView: UITableView {
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private let emptyStateLabel = UILabel()
    private let importButton = UIButton(type: .system)
    
    /// 空状态视图（可自定义）
    var emptyBackgroundView: UIView? {
        didSet {
            emptyBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
            reloadEmptyState()
        }
    }
    
    /// 空状态文本
    var emptyStateLabelText: String? {
        get { emptyStateLabel.text }
        set { emptyStateLabel.text = newValue }
    }
    
    /// 绑定数据源是否为空
    var isEmpty: Binder<Bool> {
        return Binder(self) { tableView, isEmpty in
            isEmpty ? tableView.showEmptyView() : tableView.hideEmptyView()
        }
    }
    
    // MARK: - File Import Properties
    
    /// 是否显示导入按钮（默认 true）
    var showImportButton: Bool = true {
        didSet {
            importButton.isHidden = !showImportButton
        }
    }
    
    /// 导入按钮标题
    var importButtonTitle: String = "从文件导入" {
        didSet {
            importButton.setTitle(importButtonTitle, for: .normal)
        }
    }
    
    /// 允许选择的文件 UTType 类型（默认 public.item，即所有文件）
    var importFileTypes: [String] = [kUTTypeItem as String] {
        didSet {
            updateImportButtonState()
        }
    }
    
    /// 文件导入目标路径（Documents 下的子目录路径），为 nil 则不复制文件
    var importDestinationPath: String?
    
    /// 是否允许文件多选（默认 true）
    var allowsImportMultipleSelection: Bool = true
    
    /// 文件导入成功事件，发出目标文件 URL 数组
    let fileImported = PublishSubject<[URL]>()
    
    /// 文件导入失败事件
    let fileImportError = PublishSubject<Error>()
    
    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        tableFooterView = UIView() // 去除多余分割线
        
        setupImportButton()
    }
    
    private func setupImportButton() {
        importButton.setTitle(importButtonTitle, for: .normal)
        importButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        importButton.layer.cornerRadius = 8
        importButton.layer.masksToBounds = true
        importButton.isHidden = !showImportButton
        
        importButton.rx.tap
            .bind { [weak self] in
                self?.presentFileImporter()
            }
            .disposed(by: disposeBag)
    }
    
    private func updateImportButtonState() {
        importButton.isHidden = !showImportButton
    }
    
    // MARK: - Empty State Management
    private func showEmptyView() {
        if backgroundView == nil {
            backgroundView = emptyBackgroundView ?? createDefaultEmptyView()
            layoutEmptyView()
        }
    }
    
    private func hideEmptyView() {
        backgroundView = nil
    }
    
    private func reloadEmptyState() {
        // 留给外部手动触发使用
        showEmptyView()
    }
    
    private func layoutEmptyView() {
        guard let backgroundView = backgroundView else { return }
        
        backgroundView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
            make.width.equalToSuperview().inset(20)
            make.height.greaterThanOrEqualTo(200)
        }
    }
    
    // MARK: - Default Empty View
    private func createDefaultEmptyView() -> UIView {
        let container = UIView()
        
        let imageView = UIImageView()
        if #available(iOS 13.0, *) {
            imageView.image = UIImage(systemName: "list.bullet")
        }
        imageView.tintColor = .random()
        imageView.contentMode = .scaleAspectFit
    
        emptyStateLabel.text = "暂无数据"
        emptyStateLabel.font = .systemFont(ofSize: 14)
        emptyStateLabel.textColor = UIColor.compatibleSystemGray
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.adjustsFontSizeToFitWidth = true
        
        importButton.backgroundColor = UIColor.eHex("#cc4a1c")
        importButton.setTitleColor(.white, for: .normal)
        
        // 使用SnapKit布局
        container.addSubview(imageView)
        container.addSubview(emptyStateLabel)
        container.addSubview(importButton)
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
            make.width.height.equalTo(70)
        }
        
        emptyStateLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(12)
        }
        
        importButton.snp.makeConstraints { make in
            make.top.equalTo(emptyStateLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(36)
            make.bottom.equalToSuperview().inset(12)
        }
        
        return container
    }
    
    // MARK: - File Import
    
    /// 手动触发文件导入选择器
    func presentFileImporter() {
        guard let viewController = findViewController() else { return }
        
        // 使用 .open 模式直接访问原始文件，避免 .import 模式产生 Inbox 中间副本
        // 从而规避 QLThumbnailError 缩略图关联失败的问题
        let documentPicker = UIDocumentPickerViewController(
            documentTypes: importFileTypes,
            in: .open
        )
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = allowsImportMultipleSelection
        viewController.present(documentPicker, animated: true)
    }
    
    /// 将选中的文件复制到目标目录
    private func copyImportedFiles(from urls: [URL]) {
        guard let destinationPath = importDestinationPath else {
            // 没有设置目标路径，直接发出原始 URL
            fileImported.onNext(urls)
            return
        }
        
        // 确保目标目录存在
        let fm = FileManager.default
        try? fm.createDirectory(atPath: destinationPath, withIntermediateDirectories: true, attributes: nil)
        
        var destinationURLs: [URL] = []
        
        for sourceURL in urls {
            // .open 模式下必须通过安全作用域访问资源
            let accessing = sourceURL.startAccessingSecurityScopedResource()
            
            let fileName = sourceURL.lastPathComponent
            let destURL = URL(fileURLWithPath: destinationPath).appendingPathComponent(fileName)
            
            do {
                // 如果目标已存在同名文件，先删除
                if fm.fileExists(atPath: destURL.path) {
                    try fm.removeItem(at: destURL)
                }
                // 使用 FileCoordinator 协调读取，确保安全作用域资源可正确读取
                var coordinationError: NSError?
                var copyError: Error?
                let coordinator = NSFileCoordinator(filePresenter: nil)
                coordinator.coordinate(readingItemAt: sourceURL, options: .forUploading, error: &coordinationError) { coordinatedURL in
                    do {
                        try fm.copyItem(at: coordinatedURL, to: destURL)
                    } catch {
                        copyError = error
                    }
                }
                
                if let coordError = coordinationError {
                    throw coordError
                }
                if let copyErr = copyError {
                    throw copyErr
                }
                
                destinationURLs.append(destURL)
            } catch {
                fileImportError.onNext(error)
            }
            
            if accessing {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        
        if !destinationURLs.isEmpty {
            fileImported.onNext(destinationURLs)
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutEmptyView()
    }
}

// MARK: - UIDocumentPickerDelegate
extension EmptyStateTableView: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        copyImportedFiles(from: urls)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // 用户取消选择，不做处理
    }
}
