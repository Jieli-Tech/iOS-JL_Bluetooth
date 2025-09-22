//
//  SyncTranslationVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/27.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

struct SyncTranslationMode {
    let original: String
    let translate: String
    let translateColor: UIColor
}

class SyncTranslationVC: BasicViewController {
    private let headerView = TimeHeaderView()
    private let speakBtn = UIButton()
    private let spectrogramView = SpectrogramView()
    private let subTable = UITableView()
    private let bottomView = SyncTraBottomView()
    private let lanSelectView = LanguageSelect()
    private let disposeBag = DisposeBag()
    private let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    private let syncSpeakArray = BehaviorRelay<[SyncTranslationMode]>(value: [])

    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(speakBtn)
        view.addSubview(spectrogramView)
        view.addSubview(subTable)
        view.addSubview(bottomView)
        view.addSubview(lanSelectView)

        speakBtn.setImage(R.Image.img("icon_mute_sync_open"), for: .normal)
        headerView.configSwitch(R.Image.img("arrow_left"))
        headerView.configImage(R.Image.img("translation_icon_our"), R.Image.img("translation_icon_phone"))

        spectrogramView.layer.cornerRadius = 4
        spectrogramView.layer.masksToBounds = true

        subTable.register(TranslateSyncSpeakCell.self, forCellReuseIdentifier: "cell")
        subTable.separatorStyle = .none
        subTable.rowHeight = UITableView.automaticDimension
        subTable.estimatedRowHeight = 60
        subTable.keyboardDismissMode = .interactive
        subTable.allowsSelection = false
        subTable.backgroundColor = .clear

        headerView.snp.makeConstraints { make in
            make.top.equalTo(naviView.titleLab).offset(-10)
            make.centerX.equalTo(naviView.snp.centerX)
        }

        speakBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(32)
            make.centerY.equalTo(headerView.snp.centerY)
        }

        spectrogramView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(headerView.snp.bottom).offset(4)
            make.height.equalTo(40)
        }

        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(spectrogramView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top).offset(-4)
        }

        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(48 + bottomInset)
        }

        lanSelectView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        syncSpeakArray.bind(to: subTable.rx.items(cellIdentifier: "cell", cellType: TranslateSyncSpeakCell.self)) { _, element, cell in
            cell.configContent(original: element.original, translate: element.translate)
        }.disposed(by: disposeBag)
        syncSpeakArray
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let tv = self?.subTable else { return }
                let count = tv.numberOfRows(inSection: 0)
                if count > 0 {
                    let index = IndexPath(row: count - 1, section: 0)
                    tv.scrollToRow(at: index, at: .bottom, animated: true)
                }
            })
            .disposed(by: disposeBag)
        bottomView.languageBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.lanSelectView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }).disposed(by: disposeBag)

        lanSelectView.confirmBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.lanSelectView.snp.remakeConstraints { make in
                make.top.equalTo(self.view.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalToSuperview()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            var list = syncSpeakArray.value
            list.append(testData())
            syncSpeakArray.accept(list)
        }).disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        syncSpeakArray.accept([testData()])
    }
}

extension SyncTranslationVC {
    func testData() -> SyncTranslationMode {
        let md = SyncTranslationMode(original: "我有一个梦想，有一天这个国家会站立起来，真正实现其信条的真谛：“我们认为这些真理是不言而喻的—人人生而平等。”我有一个梦想，有一天，在佐治亚的红土山上，昔日奴隶的儿子将能够和昔日奴隶主的儿子坐在一起，共叙兄弟情谊。我有一个梦想，有一天，甚至连密西西比州这个正义匿迹，压迫成风，如同沙漠般的地方，也将变成自由和正义的绿洲。我有一个梦想，我的四个孩子将在一个不是以他们的肤色，而是以他们的品格来评价他们的国度里生活。我今天有一个梦想。", translate: "I have a dream that one day this nation will rise up and live out the true meaning of its creed: \"We hold these truths to be self-evident - that all men are created equal.\" I have a dream that one day on the red hills of Georgia the sons of former slaves will be able to sit down together with the sons of former slave owners and speak of brotherhood. I have a dream that one day even the state of Mississippi, a state sweltering with the heat of oppression, will be transformed into an oasis of freedom and justice. I have a dream that my four little children will live in a nation where they will not be judged by the color of their skin but by the content of their character. I have a dream today.", translateColor: .eHex("#000000", alpha: 0.6))
        return md
    }
}
