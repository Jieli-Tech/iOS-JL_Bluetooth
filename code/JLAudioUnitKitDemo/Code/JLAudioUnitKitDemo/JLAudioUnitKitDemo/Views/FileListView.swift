//
//  FileListView.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/25.
//

import UIKit
import RxSwift
import RxCocoa

class FileListView: BaseView {
    
    private let titleLab = UILabel()
    private let subTableView = UITableView()
    private let itemArray = BehaviorRelay<[String]>(value: [])
    private let noFileLab = UILabel()
    private var currentPath:String = ""
    var fileDidSelect:String = ""
    
    override func initUI() {
        super.initUI()
        
        addSubview(titleLab)
        addSubview(subTableView)
        addSubview(noFileLab)
        
        self.backgroundColor = .random()
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        
        titleLab.text = "File List"
        titleLab.textColor = .white
        titleLab.font = .systemFont(ofSize: 18)
        
        subTableView.backgroundColor = .clear
        subTableView.rowHeight = 40
        subTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FileListCell")

        noFileLab.text = "No File,Please add file to Document by itunes tools"
        noFileLab.textColor = .black
        noFileLab.numberOfLines = 0
        noFileLab.textAlignment = .center
        noFileLab.adjustsFontSizeToFitWidth = true
        noFileLab.font = .systemFont(ofSize: 18)

        
        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(5)
        }
        
        noFileLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        subTableView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }

    }
    override func initData() {
        super.initData()
        itemArray.bind(to: subTableView.rx.items(cellIdentifier: "FileListCell", cellType: UITableViewCell.self)) { row, element, cell in
            cell.backgroundColor = .random()
            cell.textLabel?.textColor = .white
            let sizeText = self.fileSizeText(for: element)
            if sizeText.isEmpty {
                cell.textLabel?.text = element
            } else {
                cell.textLabel?.text = "\(element) (\(sizeText))"
            }
            if element == self.fileDidSelect {
                cell.accessoryType = .checkmark
            }else{
                cell.accessoryType = .none
            }
        }.disposed(by: disposeBag)
        subTableView.rx.modelSelected(String.self).subscribe(onNext: { [weak self] element in
            guard let self = self else { return }
            self.fileDidSelect = element
            self.subTableView.reloadData()
        }).disposed(by: disposeBag)
        itemArray.subscribe(onNext: { [weak self] element in
            guard let self = self else { return }
            if element.count == 0 {
                self.noFileLab.isHidden = false
            }else{
                self.noFileLab.isHidden = true
            }
        }).disposed(by: disposeBag)
        
        subTableView.rx.modelDeleted(String.self).subscribe { [weak self] element in
            guard let self = self else { return }
            let path = self.currentPath + "/" + element
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: path)
            } catch {
                print(error)
            }
            self.loadFoldFile(self.currentPath)
        }.disposed(by: disposeBag)
        
    }
    
    func loadFoldFile(_ path:String){
        currentPath = path
        let fileManager = FileManager.default
        let fileArray = fileManager.subpaths(atPath: path)
        itemArray.accept(fileArray ?? [])
    }
    
    private func readableFileSize(_ size: Int64) -> String {
        if size < 1024 { return "\(size) B" }
        let kb = Double(size) / 1024.0
        if kb < 1024 { return String(format: "%.1f KB", kb) }
        let mb = kb / 1024.0
        if mb < 1024 { return String(format: "%.1f MB", mb) }
        let gb = mb / 1024.0
        return String(format: "%.2f GB", gb)
    }
    
    private func fileSizeText(for element: String) -> String {
        let path = currentPath + "/" + element
        var isDir: ObjCBool = false
        let fm = FileManager.default
        guard fm.fileExists(atPath: path, isDirectory: &isDir), !isDir.boolValue else { return "" }
        if let attrs = try? fm.attributesOfItem(atPath: path), let n = attrs[.size] as? NSNumber {
            return readableFileSize(n.int64Value)
        }
        return ""
    }
    

}
