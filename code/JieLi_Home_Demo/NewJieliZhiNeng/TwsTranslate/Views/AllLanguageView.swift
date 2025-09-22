//
//  AllLanguageView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

struct LanguageWrapper {
    let language: TranslationLanguageType
    let displayName: String
}

class AllLanguageView: BasicView {
    private let titleLab = UILabel()
    private let subTable = UITableView()
    private var allLanguages = TranslationLanguageType.allLanguages()
    private var sectionTitles = [String]()
    private var sectionedLanguages: [[TranslationLanguageType]] = []
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
        subTable.delegate = self
        subTable.dataSource = self

        titleLab.text = LanguageCls.localizableTxt("Common languages")
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
    }

    override func initData() {
        super.initData()
        subTable.rx.itemSelected.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            subTable.reloadData()
        }).disposed(by: disposeBag)
        currentLanguage.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.subTable.reloadData()
        }).disposed(by: disposeBag)
    }

    private func sortAndGroupLanguages() {
        let locale = Locale.current
        let collator = locale.collator

        let wrapped = allLanguages.map { LanguageWrapper(language: $0, displayName: $0.title()) }
        let sorted = wrapped.sorted {
            $0.displayName.compare($1.displayName, locale: locale) == .orderedAscending
        }

        var grouped: [String: [TranslationLanguageType]] = [:]

        for item in sorted {
            guard let firstChar = item.displayName.first else { continue }
            let sectionKey = String(firstChar).uppercased()
            grouped[sectionKey, default: []].append(item.language)
        }

        sectionTitles = grouped.keys.sorted()
        sectionedLanguages = sectionTitles.map { grouped[$0] ?? [] }
    }
}

extension Locale {
    var collator: (String, String) -> ComparisonResult {
        return { str1, str2 in
            str1.compare(str2, locale: self)
        }
    }
}

extension AllLanguageView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return sectionedLanguages.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionedLanguages[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let model = sectionedLanguages[indexPath.section][indexPath.row]
        cell.textLabel?.text = model.title()
        cell.textLabel?.font = R.Font.medium(14)
        if model == currentLanguage.value {
            cell.textLabel?.textColor = .eHex("#7657EC")
        } else {
            cell.textLabel?.textColor = .eHex("#000000", alpha: 0.9)
        }
        // 设置左边距为 16
        cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        cell.textLabel?.preservesSuperviewLayoutMargins = true
        return cell
    }
}
