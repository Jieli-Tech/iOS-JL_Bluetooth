//
//  SelectRecordView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/28.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

private class SelectCellMode {
    let image: UIImage
    let title: String
    var isSelect: Bool
    let type: TranslateDBType

    init(image: UIImage, title: String, isSelect: Bool, type: TranslateDBType) {
        self.image = image
        self.title = title
        self.isSelect = isSelect
        self.type = type
    }
}

private class SelectRecordViewCell: UITableViewCell {
    private let imgv = UIImageView()
    private let titleLab = UILabel()
    private let markImgv = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        initUI()
    }

    func config(_ mode: SelectCellMode) {
        imgv.image = mode.image
        titleLab.text = mode.title
        markImgv.isHidden = !mode.isSelect
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initUI() {
        contentView.addSubview(imgv)
        contentView.addSubview(titleLab)
        contentView.addSubview(markImgv)
        imgv.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
            make.left.equalToSuperview().inset(20)
        }
        titleLab.textColor = .eHex("#242424")
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLab.adjustsFontSizeToFitWidth = true

        titleLab.snp.makeConstraints { make in
            make.left.equalTo(imgv.snp.right).offset(10)
            make.right.equalTo(markImgv.snp.left).offset(-10)
            make.centerY.equalTo(imgv)
        }
        markImgv.image = R.Image.img("Theme.bundle/icon_check")
        markImgv.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.width.height.equalTo(24)
            make.centerY.equalTo(imgv)
        }
        markImgv.image = R.Image.img("icon_choose")
    }
}

class SelectRecordView: BasicView {
    let currentType: BehaviorRelay<TranslateDBType> = .init(value: .all)
    private let bgView = UIView()
    private let contentView = UIView()
    private let titleLab = UILabel()
    private let subTable = UITableView()
    private let didCloseBtn = UIButton()
    private let itemsArray = BehaviorRelay<[SelectCellMode]>(value: [])

    override func initUI() {
        super.initUI()
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(titleLab)
        contentView.addSubview(didCloseBtn)
        contentView.addSubview(subTable)
        titleLab.textColor = .eHex("#242424")
        titleLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        titleLab.text = LanguageCls.localizableTxt("Record Type")
        didCloseBtn.setImage(R.Image.img("icon_close_24"), for: .normal)
        contentView.backgroundColor = .white
        contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        contentView.layer.cornerRadius = 16

        backgroundColor = .clear
        bgView.backgroundColor = .eHex("#000000", alpha: 0.3)

        subTable.register(SelectRecordViewCell.self, forCellReuseIdentifier: "cell")
        subTable.rowHeight = 50
        subTable.separatorStyle = .none
        subTable.backgroundColor = .clear
        subTable.isScrollEnabled = false

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(5 * 50 + bottomInset + 20)
            make.top.equalTo(self.snp.bottom)
        }
        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(10)
            make.height.equalTo(50)
            make.right.equalTo(didCloseBtn.snp.left).offset(-10)
        }

        didCloseBtn.snp.makeConstraints { make in
            make.centerY.equalTo(titleLab)
            make.width.height.equalTo(50)
            make.right.equalToSuperview().inset(10)
        }

        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom)
            make.height.equalTo(4 * 50)
        }

        itemsArray.bind(to: subTable.rx.items(cellIdentifier: "cell", cellType: SelectRecordViewCell.self)) { _, model, cell in
            model.isSelect = model.type == self.currentType.value
            cell.config(model)
        }.disposed(by: disposeBag)
    }

    override func initData() {
        super.initData()

        subTable.rx.itemSelected.subscribe(onNext: { [weak self] index in
            guard let self = self else { return }
            self.currentType.accept(self.itemsArray.value[index.row].type)
            self.subTable.reloadData()
            didClose()
        }).disposed(by: disposeBag)

        let allMode = SelectCellMode(
            image: R.Image.img("icon_record_all"),
            title: R.Language.lan("All records"),
            isSelect: false,
            type: .all
        )
        let callMode = SelectCellMode(
            image: R.Image.img("icon_record_call_translation"),
            title: R.Language.lan("Call translation"),
            isSelect: false,
            type: .call
        )
        let faceMode = SelectCellMode(
            image: R.Image.img("icon_facetoface"),
            title: R.Language.lan("Face-to-face translation"),
            isSelect: false,
            type: .face
        )
        let syncMode = SelectCellMode(
            image: R.Image.img("icon_chuanyi"),
            title: R.Language.lan("Simultaneous interpretation"),
            isSelect: false,
            type: .sync
        )
        itemsArray.accept([allMode, callMode, faceMode, syncMode])

        didCloseBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            didClose()
        }).disposed(by: disposeBag)

        let tapges = UITapGestureRecognizer(target: self, action: #selector(didClose))
        bgView.addGestureRecognizer(tapges)
    }

    func didClose() {
        UIView.animate(withDuration: 0.4) {
            self.isHidden = true
            self.contentView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(5 * 50 + self.bottomInset + 20)
                make.top.equalTo(self.snp.bottom)
            }
        }
    }

    func didShow() {
        isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.contentView.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.equalTo(5 * 50 + self.bottomInset + 20)
                make.bottom.equalToSuperview()
            }
        }
    }
}
