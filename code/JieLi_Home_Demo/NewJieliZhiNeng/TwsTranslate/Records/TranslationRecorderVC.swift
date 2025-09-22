//
//  TranslationRecorderVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/28.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit


class TranslationRecorderVC: BasicViewController {
    private let datePickerView = AlertCalendarPickerView()
    private let editBtn = UIButton()
    private let selecterView = TraSelectRecordView()
    private let recordTable = UITableView()
    private let records = BehaviorRelay<[MessageModel]>(value: TraRecordCell.testData())
    private let disposeBag = DisposeBag()
    
    override func initUI() {
        super.initUI()
        editBtn.setImage(R.Image.img("icon_edit"), for: .normal)
        naviView.titleLab.text = R.Language.lan("Record")
        naviView.rightView.addSubview(editBtn)
        naviView.rightView.isHidden = false
        datePickerView.isHidden = true
        
        recordTable.register(TraRecordCell.self, forCellReuseIdentifier: "TraRecordCell")
        recordTable.separatorStyle = .none
        recordTable.rowHeight = UITableView.automaticDimension
        recordTable.estimatedRowHeight = 88
        recordTable.backgroundColor = .clear
        recordTable.keyboardDismissMode = .interactive
        
        view.addSubview(selecterView)
        view.addSubview(recordTable)
        view.addSubview(datePickerView)
        
        editBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
        }
        selecterView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(42)
            make.top.equalTo(naviView.snp.bottom)
        }
        
        recordTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(selecterView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        datePickerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
        
    }
    override func initData() {
        super.initData()
        records.bind(to: recordTable.rx.items(cellIdentifier: "TraRecordCell", cellType: TraRecordCell.self)) { row, model, cell in
            cell.configure(icon: model.icon, date: model.date, time: model.time, title: model.title, subtitle: model.subtitle)
        }.disposed(by: disposeBag)
    }
    
    
}
