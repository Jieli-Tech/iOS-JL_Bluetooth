//
//  OthersProtocolVC.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class OthersProtocolVC: BaseViewController {
    var subFuncTable = UITableView()
    var itemsArray = BehaviorRelay<[String]>.init(value: [])
    
    override func initData() {
        super.initData()
        if BleManager.shared.isConnectWithAtt {
            itemsArray.accept([R.localStr.auracastProtocol()])
        }
        navigationView.title = R.localStr.otherProtocol()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        subFuncTable.rx.modelSelected(String.self).subscribe(onNext: { [weak self] model in
            guard let self = self else { return }
            if model == R.localStr.auracastProtocol() {
                self.navigationController?.pushViewController(AuracastViewController(), animated: true)
            }
            subFuncTable.reloadData()
        }).disposed(by: disposeBag)
        
    }
    override func initUI() {
        super.initUI()
        
        subFuncTable.register(FuncSelectCell.self, forCellReuseIdentifier: "FUNCCell")
        subFuncTable.rowHeight = 60
        subFuncTable.separatorStyle = .none
        subFuncTable.backgroundColor = .clear
        view.addSubview(subFuncTable)
        navigationView.title = R.localStr.otherProtocol()
        
        itemsArray.bind(to: subFuncTable.rx.items(cellIdentifier: "FUNCCell", cellType: FuncSelectCell.self)) { row, element, cell in
            cell.titleLab.text = element
        }.disposed(by: disposeBag)
        
        subFuncTable.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}
