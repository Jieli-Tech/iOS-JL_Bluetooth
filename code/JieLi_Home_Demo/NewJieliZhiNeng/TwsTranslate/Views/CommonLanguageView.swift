//
//  CommonLanguageView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class CommonLanguageView: BasicView {
    private let titleLab = UILabel()
    private let subTable = UITableView()
    private let itemsArray = BehaviorRelay<[TranslationLanguageType]>(value: [])
    var currentLanguage = BehaviorRelay<TranslationLanguageType>(value: .zh)

    override func initUI() {
        super.initUI()
        backgroundColor = .clear

        subTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        subTable.rowHeight = 36
        subTable.separatorStyle = .none
        subTable.backgroundColor = .white
        subTable.layer.cornerRadius = 6
        subTable.layer.masksToBounds = true
        subTable.isScrollEnabled = false

        titleLab.text = LanguageCls.localizableTxt("All")
        titleLab.textColor = .eHex("#000000", alpha: 0.6)
        titleLab.font = R.Font.regular(10)

        addSubview(titleLab)
        addSubview(subTable)

        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(titleLab.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(6)
        }

        titleLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(4)
        }

        itemsArray.bind(to: subTable.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { _, model, cell in
            cell.textLabel?.text = model.title()
            cell.textLabel?.font = R.Font.medium(14)
            if model == self.currentLanguage.value {
                cell.textLabel?.textColor = .eHex("#7657EC")
            } else {
                cell.textLabel?.textColor = .eHex("#000000", alpha: 0.9)
            }
            // 设置左边距为 16
            cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            cell.textLabel?.preservesSuperviewLayoutMargins = true
        }.disposed(by: disposeBag)
    }

    override func initData() {
        super.initData()
        itemsArray.accept(TranslationLanguageType.allLanguages())
        subTable.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            currentLanguage.accept(self.itemsArray.value[index.row])
            subTable.reloadData()
        }).disposed(by: disposeBag)
        currentLanguage.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.subTable.reloadData()
        }).disposed(by: disposeBag)
    }
}
