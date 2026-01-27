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
    private let recordTypeView = SelectRecordView()
    private let recordTable = UITableView()
    private let deleteBottomView = TraBottomDeleteView()
    private let noRecordView = ProductsEmptyView()
    private let records = BehaviorRelay<[MessageModel]>(value: [])
    private let disposeBag = DisposeBag()
    private var currentDate = Date()
    private var currentType = TranslateDBType.all
    private var editStatus = false
    private let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 20
    private var deleteTapges = UITapGestureRecognizer()
    

    override func initUI() {
        super.initUI()
        editBtn.setImage(R.Image.img("Theme.bundle/bay_icon_edit"), for: .normal)
        editBtn.titleLabel?.font = R.Font.medium(14)
        naviView.titleLab.text = R.Language.lan("Record")
        naviView.rightView.addSubview(editBtn)
        naviView.rightView.isHidden = false
        datePickerView.isHidden = true
        recordTypeView.isHidden = true

        recordTable.register(TraRecordCell.self, forCellReuseIdentifier: "TraRecordCell")
        recordTable.separatorStyle = .none
        recordTable.rowHeight = UITableView.automaticDimension
        recordTable.estimatedRowHeight = 88
        recordTable.backgroundColor = .clear
        recordTable.keyboardDismissMode = .interactive
        deleteBottomView.addGestureRecognizer(deleteTapges)
        deleteBottomView.isHidden = true
        
        noRecordView.noneLab.text = R.Language.lan("No records yet")
        noRecordView.noneLab.textColor = .eHex("#000000", alpha: 0.4)

        view.addSubview(selecterView)
        view.addSubview(recordTable)
        view.addSubview(noRecordView)
        view.addSubview(datePickerView)
        view.addSubview(recordTypeView)
        view.addSubview(deleteBottomView)

        editBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

        recordTypeView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        deleteBottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(50 + bottomInset)
            make.bottom.equalToSuperview()
        }
        noRecordView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-150)
            make.centerX.equalToSuperview()
        }
        
        noRecordView.noneLab.snp.updateConstraints { make in
            make.top.equalTo(noRecordView.noneImgv.snp.bottom).offset(40)
        }
        
    }

    override func initData() {
        super.initData()
        selecterView.currentDate(date: Date())

        records.bind(to: recordTable.rx.items(cellIdentifier: "TraRecordCell", cellType: TraRecordCell.self)) { _, model, cell in
            cell.configure(mode: model, isSelecting: self.editStatus)
        }.disposed(by: disposeBag)
        
        records.subscribe(onNext: { [weak self] value in
            guard let self = self else { return }
            if value.count > 0 {
                self.noRecordView.isHidden = true
            }else{
                self.noRecordView.isHidden = false
            }
        }).disposed(by: disposeBag)

        selecterView.allRecordBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.recordTypeView.isHidden = false
            self.recordTypeView.didShow()
        }).disposed(by: disposeBag)

        selecterView.dateSelectBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.datePickerView.isHidden = false
        }).disposed(by: disposeBag)

        recordTypeView.currentType.subscribe(onNext: { [weak self] type in
            guard let self = self else { return }
            self.currentType = type
            selecterView.allRecordBtn.setTitle(type.title, for: .normal)
            selecterView.allRecordBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            updateData()
        }).disposed(by: disposeBag)

        datePickerView.calendar.selectedDate
            .subscribe(onNext: { [weak self] date in
                self?.selecterView.currentDate(date: date)
                self?.currentDate = date
                self?.updateData()
                self?.datePickerView.didClose()
            })
            .disposed(by: disposeBag)

        recordTable.rx.modelSelected(MessageModel.self).subscribe(onNext: { [weak self] model in
            guard let self = self else { return }
            if self.editStatus {
                model.isSelect = !model.isSelect
                _ = self.isAllSelected()
                recordTable.reloadData()
            } else {
                if model.type == .sync {
                    let syncVC = SyncRecordVC()
                    syncVC.groupId = model.date.getDateStr
                    navigationController?.pushViewController(syncVC, animated: true)
                }
                if model.type == .call {
                    let callVC = CallRecordVC()
                    callVC.callVM = CallRecordViewModel(groupId: model.date)
                    navigationController?.pushViewController(callVC, animated: true)
                }
                if model.type == .face {
                    let faceToFaceVC = FaceToFaceRecordVC()
                    faceToFaceVC.dataVM = FaceToFaceRecordViewModel(groupId: model.date)
                    navigationController?.pushViewController(faceToFaceVC, animated: true)
                }
            }
        }).disposed(by: disposeBag)

        editBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if editStatus {
                if isAllSelected() {
                    for item in records.value {
                        item.isSelect = false
                    }
                    self.editBtn.setTitle(R.Language.lan("Select All"), for: .normal)
                } else {
                    for item in records.value {
                        item.isSelect = true
                    }
                    self.editBtn.setTitle(R.Language.lan("Deselect All"), for: .normal)
                }
                self.recordTable.reloadData()
            } else {
                self.editStatus = true
                self.editBtn.setImage(UIImage(), for: .normal)
                self.editBtn.setTitle(R.Language.lan("Select All"), for: .normal)
                self.editBtn.setTitleColor(.eHex("#242424"), for: .normal)
                self.editBtn.titleLabel?.adjustsFontSizeToFitWidth = true
                self.recordTable.reloadData()
                self.naviView.existBtn.setImage(UIImage(), for: .normal)
                self.naviView.existBtn.setTitle(R.Language.lan("Cancel"), for: .normal)
                recordTable.snp.remakeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(self.selecterView.snp.bottom)
                    make.bottom.equalTo(self.deleteBottomView.snp.top)
                }
                deleteBottomView.isHidden = false
            }
        }).disposed(by: disposeBag)

        deleteTapges.rx.event.bind { [weak self] _ in
            guard let self = self else { return }
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let confirmAction = UIAlertAction(title: R.Language.lan("confirm"), style: .destructive) { _ in
                let values = self.records.value.filter { $0.isSelect }
                TranslateDBManager.shared.deleteByModel(values)
                self.updateData()
                self.backBtnAction()
            }
            let cancelAction = UIAlertAction(title: R.Language.lan("Cancel"), style: .cancel, handler: nil)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }.disposed(by: disposeBag)
        
        
    }

    override func backBtnAction() {
        if editStatus {
            editStatus = false
            editBtn.setImage(R.Image.img("Theme.bundle/bay_icon_edit"), for: .normal)
            editBtn.setTitle("", for: .normal)
            for item in records.value {
                item.isSelect = false
            }
            recordTable.reloadData()
            naviView.existBtn.setImage(R.Image.img("Theme.bundle/icon_return"), for: .normal)
            naviView.existBtn.setTitle("", for: .normal)
            recordTable.snp.remakeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(selecterView.snp.bottom)
                make.bottom.equalToSuperview()
            }
            deleteBottomView.isHidden = true
        } else {
            super.backBtnAction()
        }
    }

    private func isAllSelected() -> Bool {
        for item in records.value {
            if !item.isSelect {
                return false
            }
        }
        editBtn.setTitle(R.Language.lan("Deselect All"), for: .normal)
        return true
    }

    private func updateData() {
        records.accept(TranslateDBManager.shared.queryAll(currentType, currentDate))
        datePickerView.calendar.hasDataDates = TranslateDBManager.shared.queryDataWithDate(currentType)
    }
}

private extension TranslateDBType {
    var title: String {
        switch self {
        case .all:
            return R.Language.lan("All records")
        case .sync:
            return R.Language.lan("Simultaneous interpretation")
        case .call:
            return R.Language.lan("Call translation")
        case .face:
            return R.Language.lan("Face-to-face translation")
        }
    }
}
