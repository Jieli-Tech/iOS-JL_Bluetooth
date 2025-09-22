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
    var fileDidSelect:String = ""
    
    override func initUI() {
        super.initUI()
        
        addSubview(titleLab)
        addSubview(subTableView)
        addSubview(noFileLab)
        
        
        titleLab.text = "File List"
        titleLab.textColor = .black
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
            cell.textLabel?.text = element
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
    }
    
    func loadFoldFile(_ path:String){
        let fileManager = FileManager.default
        let fileArray = fileManager.subpaths(atPath: path)
        itemArray.accept(fileArray ?? [])
    }
    

}
