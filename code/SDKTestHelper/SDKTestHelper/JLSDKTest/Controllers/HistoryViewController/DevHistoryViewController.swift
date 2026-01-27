//
//  DevHistoryViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/7.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import CoreBluetooth
import UIKit

class DevHistoryViewController: BaseViewController {
    private let dbTitleLab = UILabel()
    private let dbTableView = UITableView()
    private let connectTitleLab = UILabel()
    private let hidConnectTableView = UITableView()
    private let systemHistoryTitleLab = UILabel()
    private let systemHistoryTableView = UITableView()

    private let devHistoryArray = BehaviorRelay<[DevHistoryModel]>(value: [])
    private let connectedArray = BehaviorRelay<[CBPeripheral]>(value: [])
    private let systemHistoryArray = BehaviorRelay<[CBPeripheral]>(value: [])

    override func initUI() {
        super.initUI()
        setupUI()
        setupLayout()
        setupBindData()
        setupActions()
    }
    
    override func viewWillAppear(_ animate : Bool) {
        super.viewWillAppear(animate)
        BleManager.shared.startSearchBle()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BleManager.shared.stopSearchBle()
    }

    override func initData() {
        super.initData()
        Task {
            let list = await DevHistory.share.queryAll()
            devHistoryArray.accept(list)
            var historyUUIDs: [UUID] = []
            for item in list {
                if let udid = UUID(uuidString: item.uuidStr) {
                    historyUUIDs.append(udid)
                }
            }
            let sysHistory = BleManager.shared.centerManager.retrievePeripherals(withIdentifiers: historyUUIDs)
            systemHistoryArray.accept(sysHistory)
        }
        if BleManager.shared.bleStatus.value == .poweredOn {
            let connected = BleManager.shared.centerManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: "AE00")])
            connectedArray.accept(connected)
        }
    }

    func setupUI() {
        navigationView.title = R.localStr.deviceHistory()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(dbTitleLab)
        view.addSubview(dbTableView)
        view.addSubview(connectTitleLab)
        view.addSubview(hidConnectTableView)
        view.addSubview(systemHistoryTitleLab)
        view.addSubview(systemHistoryTableView)

        dbTitleLab.text = R.localStr.deviceHistory()
        dbTitleLab.textColor = UIColor.white
        dbTitleLab.backgroundColor = .random()
        dbTitleLab.layer.masksToBounds = true
        dbTitleLab.layer.cornerRadius = 3
        dbTitleLab.font = UIFont.systemFont(ofSize: 15)
        dbTitleLab.textAlignment = .left

        connectTitleLab.text = R.localStr.connected()
        connectTitleLab.textColor = UIColor.white
        connectTitleLab.backgroundColor = .random()
        connectTitleLab.layer.masksToBounds = true
        connectTitleLab.layer.cornerRadius = 3
        connectTitleLab.font = UIFont.systemFont(ofSize: 15)
        connectTitleLab.textAlignment = .left

        systemHistoryTitleLab.text = R.localStr.systemScanHistory()
        systemHistoryTitleLab.textColor = UIColor.white
        systemHistoryTitleLab.backgroundColor = .random()
        systemHistoryTitleLab.layer.masksToBounds = true
        systemHistoryTitleLab.layer.cornerRadius = 3
        systemHistoryTitleLab.font = UIFont.systemFont(ofSize: 15)
        systemHistoryTitleLab.textAlignment = .left

        dbTableView.register(HistoryDevCell.self, forCellReuseIdentifier: "HistoryDevCell")
        dbTableView.backgroundColor = .clear
        dbTableView.rowHeight = 50
        dbTableView.layer.cornerRadius = 10
        dbTableView.layer.masksToBounds = true

        hidConnectTableView.register(HistoryDevCell.self, forCellReuseIdentifier: "HistoryDevCell")
        hidConnectTableView.backgroundColor = .clear
        hidConnectTableView.rowHeight = 50
        hidConnectTableView.layer.cornerRadius = 10
        hidConnectTableView.layer.masksToBounds = true

        systemHistoryTableView.register(HistoryDevCell.self, forCellReuseIdentifier: "HistoryDevCell")
        systemHistoryTableView.backgroundColor = .clear
        systemHistoryTableView.rowHeight = 50
        systemHistoryTableView.layer.cornerRadius = 10
        systemHistoryTableView.layer.masksToBounds = true
    }

    func setupLayout() {
        dbTitleLab.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        dbTableView.snp.makeConstraints { make in
            make.top.equalTo(dbTitleLab.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }

        connectTitleLab.snp.makeConstraints { make in
            make.top.equalTo(dbTableView.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        hidConnectTableView.snp.makeConstraints { make in
            make.top.equalTo(connectTitleLab.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.height.equalTo(100)
        }

        systemHistoryTitleLab.snp.makeConstraints { make in
            make.top.equalTo(hidConnectTableView.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }

        systemHistoryTableView.snp.makeConstraints { make in
            make.top.equalTo(systemHistoryTitleLab.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
        }
    }

    func setupBindData() {
        devHistoryArray.bind(to: dbTableView.rx.items(cellIdentifier: "HistoryDevCell", cellType: HistoryDevCell.self)) { _, model, cell in
            cell.setupData(name: model.name, uuid: model.uuidStr, model.isAttDev)
        }.disposed(by: disposeBag)

        connectedArray.bind(to: hidConnectTableView.rx.items(cellIdentifier: "HistoryDevCell", cellType: HistoryDevCell.self)) { _, model, cell in
            cell.setupData(name: model.name ?? "unKnow", uuid: model.identifier.uuidString)
        }.disposed(by: disposeBag)

        systemHistoryArray.bind(to: systemHistoryTableView.rx.items(cellIdentifier: "HistoryDevCell", cellType: HistoryDevCell.self)) { _, model, cell in
            cell.setupData(name: model.name ?? "unKnow", uuid: model.identifier.uuidString)
        }.disposed(by: disposeBag)
    }

    func setupActions() {
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

        dbTableView.rx.modelSelected(DevHistoryModel.self).subscribe(onNext: { [weak self] item in
            self?.connect(uuid: item.uuidStr)
        }).disposed(by: disposeBag)

        dbTableView.rx.modelDeleted(DevHistoryModel.self).subscribe(onNext: { [weak self] item in
            guard let self = self else { return }
            if BleManager.shared.currentEntity?.mUUID == item.uuidStr {
                BleManager.shared.disconnectEntity()
            }
            var list = self.devHistoryArray.value
            list.removeAll(where: { $0.uuidStr == item.uuidStr })
            devHistoryArray.accept(list)
            DevHistory.share.delete(item.uuidStr)

        }).disposed(by: disposeBag)

        hidConnectTableView.rx.modelSelected(CBPeripheral.self).subscribe(onNext: { [weak self] item in
            self?.connect(uuid: item.identifier.uuidString, item)
        }).disposed(by: disposeBag)

        systemHistoryTableView.rx.modelSelected(CBPeripheral.self).subscribe(onNext: { [weak self] item in
            self?.connect(uuid: item.identifier.uuidString, item)
        }).disposed(by: disposeBag)
    }

    private func connect(uuid: String, _ peripheral: CBPeripheral? = nil) {
        if BleManager.shared.currentEntity?.mUUID == uuid {
            view.makeToast(R.localStr.connected())
            return
        }
        if SettingInfo.getATTComunication() {
            let alert = UIAlertController(title: R.localStr.tips(), message: R.localStr.makeSureYouAreConnectedToTheEDROfTheCorrespondingDevice(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: R.localStr.confirm(), style: .default, handler: { _ in
                BleManager.shared.connectByUUID(uuid, completion: { [weak self] status in
                    self?.connectStatusUpdate(status)
                })
            }))
            present(alert, animated: true)
        } else {
            if let peripheral = peripheral {
                BleManager.shared.connectByUUID(uuid, peripheral, completion: { [weak self] status in
                    self?.connectStatusUpdate(status)
                })
            } else {
                BleManager.shared.connectByUUID(uuid) { [weak self] status in
                    self?.connectStatusUpdate(status)
                }
            }
        }
    }

    private func connectStatusUpdate(_ status: Bool) {
        if !status {
            view.makeToast(R.localStr.connectFailed())
            return
        }
        view.makeToast(R.localStr.connected())
        initData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: DispatchWorkItem(block: {
            self.navigationController?.popViewController(animated: true)
        }))
    }
}

private class HistoryDevCell: UITableViewCell {
    let nameLab = UILabel()
    let uuidLab = UILabel()
    let isAttLab = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLab)
        contentView.addSubview(uuidLab)
        contentView.addSubview(isAttLab)

        nameLab.textColor = .black
        nameLab.font = UIFont.systemFont(ofSize: 15)
        nameLab.adjustsFontSizeToFitWidth = true
        uuidLab.textColor = .black.withAlphaComponent(0.5)
        uuidLab.font = UIFont.systemFont(ofSize: 14)
        uuidLab.adjustsFontSizeToFitWidth = true

        isAttLab.textColor = .purple
        isAttLab.font = UIFont.systemFont(ofSize: 18)
        isAttLab.adjustsFontSizeToFitWidth = true

        nameLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(isAttLab.snp.left)
            make.top.equalToSuperview()
        }

        uuidLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(isAttLab.snp.left)
            make.top.equalTo(nameLab.snp.bottom)
            make.bottom.equalToSuperview()
        }

        isAttLab.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }

    func setupData(name: String, uuid: String, _ isAtt: Bool = false) {
        nameLab.text = "name:" + name
        uuidLab.text = "uuid:" + uuid
        if BleManager.shared.currentEntity?.mUUID == uuid {
            nameLab.textColor = .systemBlue
            uuidLab.textColor = .systemBlue
        } else {
            nameLab.textColor = .black
            uuidLab.textColor = .black.withAlphaComponent(0.5)
        }
        if isAtt {
            isAttLab.text = "ATT"
        } else {
            isAttLab.text = ""
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
