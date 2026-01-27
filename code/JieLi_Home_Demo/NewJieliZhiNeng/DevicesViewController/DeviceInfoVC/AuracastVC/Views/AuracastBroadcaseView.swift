//
//  AuracastBroadcaseView.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/12.
//

import UIKit
import JL_BLEKit

class AuracastBroadcaseView: BasicView {
    private let subTable = UITableView()
    private let titleLabel = UILabel()
    private let loadingView = UIActivityIndicatorView()
    private weak var _deviceVM: DeviceInfoViewModel?
    var deviceVM: DeviceInfoViewModel? {
        get {
            return _deviceVM
        }
        set {
            _deviceVM = newValue
            addWatcher()
        }
    }

    override func initUI() {
        super.initUI()
        addSubview(titleLabel)
        addSubview(loadingView)
        addSubview(subTable)
        backgroundColor = .clear

        titleLabel.text = LanguageCls.localizableTxt("Auracast broadcasts available nearby")
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = RResources.color.fontGrayText838383()

        loadingView.hidesWhenStopped = true

        subTable.backgroundColor = UIColor.clear
        subTable.separatorStyle = .none
        subTable.separatorColor = .clear
        subTable.layer.cornerRadius = 10
        subTable.layer.masksToBounds = true
        subTable.register(AuracastTableViewCell.self, forCellReuseIdentifier: "AuracastTableViewCell")
        subTable.rowHeight = 60

        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.height.equalTo(22)
        }
        loadingView.snp.makeConstraints { make in
            make.left.equalTo(titleLabel.snp.right).offset(10)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(30)
        }

        subTable.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()

        subTable.rx.modelSelected(JLBroadcastDataModel.self).subscribe(onNext: { [weak self] model in
            guard let self = self else { return }
            subTable.deselectRow(at: subTable.indexPathForSelectedRow!, animated: true)
            if model.encrypted {
                AlertManager.showInputPasswordView(contextView: self.contextView) { broadcastCode in
                    let codeData = Data(broadcastCode.utf8)
                    model.broadcastKey = codeData
                    AlertManager.hiddenInputPasswordView()
                    self.deviceVM?.addBroadcast(model: model) { status ,err in
                        if status == .success {
                            self.deviceVM?.keyPassword = DeviceInfoViewModel.BroadcastIDPassword(id: model.broadcastID, password: model.broadcastKey)
                        }
                    }
                }
            } else {
                self.deviceVM?.addBroadcast(model: model)
            }
        }).disposed(by: disposeBag)
    }

    private func addWatcher() {
        deviceVM?.broadcastModelShowList
            .bind(to: subTable.rx.items(cellIdentifier: "AuracastTableViewCell",
                                        cellType: AuracastTableViewCell.self)) { _, model, cell in
            cell.configCell(model)
        }.disposed(by: disposeBag)

        deviceVM?.isScaningSubject.subscribe { [weak self] element in
            guard let self = self else {
                return
            }
            self.isScaning(element)
        }.disposed(by: disposeBag)
    }

    private func isScaning(_ isOn: Bool) {
        if isOn {
            loadingView.startAnimating()
        } else {
            loadingView.stopAnimating()
        }
    }
}
