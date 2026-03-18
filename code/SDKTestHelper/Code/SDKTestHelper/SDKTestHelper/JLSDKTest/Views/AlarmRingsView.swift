//
//  AlarmRingsView.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/27.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class AlarmRingsView: BaseView {
    private let bgCenterView = UIView()
    private let dfSubTable = UITableView()
    let itemsArray = BehaviorRelay<[JLModel_Ring]>(value: [])
    var currentModel: ((JLModel_Ring) -> Void)?
    override func initUI() {
        super.initUI()
        backgroundColor = .clear
        addSubview(bgCenterView)
        addSubview(dfSubTable)

        bgCenterView.backgroundColor = .black
        bgCenterView.alpha = 0.65
        bgCenterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        dfSubTable.tableFooterView = UIView()
        dfSubTable.rowHeight = 55
        dfSubTable.register(FuncSelectCell.self, forCellReuseIdentifier: "FuncSelectCell")
        dfSubTable.backgroundColor = UIColor.clear

        itemsArray.bind(to: dfSubTable.rx.items(cellIdentifier: "FuncSelectCell", cellType: FuncSelectCell.self)) { _, element, cell in
            cell.titleLab.text = element.name
        }.disposed(by: disposeBag)

        dfSubTable.rx.modelSelected(JLModel_Ring.self).subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }
            currentModel?(model)
            self.isHidden = true
        }).disposed(by: disposeBag)

        dfSubTable.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(300)
        }

        bgCenterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissSelf)))
    }

    @objc private func dismissSelf() {
        isHidden = true
    }
}
