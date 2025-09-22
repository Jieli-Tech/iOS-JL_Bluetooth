//
//  MainViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/18.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class MainViewController: BaseViewController {
    let historyBtn = UIButton()
    let subFuncTable = UITableView()
    let itemsArray: [String] = [R.localStr.fileTransport(), R.localStr.defaultSet(), R.localStr.customerCommand(), R.localStr.update()]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.jlsdkTestHelper()
        navigationView.rightBtn.isHidden = false
        navigationView.leftBtn.setTitle(R.localStr.search(), for: .normal)
        navigationView.rightBtn.setTitle(R.localStr.setting(), for: .normal)

        historyBtn.setTitle(R.localStr.deviceHistory(), for: .normal)
        historyBtn.setTitleColor(.white, for: .normal)
        historyBtn.backgroundColor = UIColor.random()
        historyBtn.layer.cornerRadius = 10
        historyBtn.layer.masksToBounds = true
        view.addSubview(historyBtn)

        subFuncTable.register(FuncSelectCell.self, forCellReuseIdentifier: "FUNCCell")
        subFuncTable.delegate = self
        subFuncTable.dataSource = self
        subFuncTable.tableFooterView = UIView()
        subFuncTable.rowHeight = 60
        subFuncTable.separatorStyle = .none
        view.addSubview(subFuncTable)

        historyBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }

        subFuncTable.snp.makeConstraints { make in
            make.top.equalTo(historyBtn.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }

    override func initData() {
        super.initData()
        NotificationCenter.default.addObserver(self, selector: #selector(connectStatusChange(_:)), name: NSNotification.Name(kJL_BLE_M_ENTITY_CONNECTED), object: nil)
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            let SearchView = SearchBleViewController()
            self?.navigationController?.pushViewController(SearchView, animated: true)
        }).disposed(by: disposeBag)

        navigationView.rightBtn.rx.tap.subscribe(onNext: { [weak self] in
            let SettingView = SettingViewController()
            self?.navigationController?.pushViewController(SettingView, animated: true)
        }).disposed(by: disposeBag)

        historyBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.pushViewController(DevHistoryViewController(), animated: true)
        }.disposed(by: disposeBag)
    }

    @objc override func disconnectStatusChange(_ notification: Notification) {
        connectStatusChange(notification)
    }

    @objc func connectStatusChange(_: Notification) {
        if (BleManager.shared.currentEntity) != nil {
            navigationView.leftBtn.setTitle(R.localStr.connected(), for: .normal)
            view.makeToast(R.localStr.initializing(), duration: 5, position: .center)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: DispatchWorkItem(block: {
                DialManager.openDialFileSystem(withCmdManager: BleManager.shared.currentCmdMgr!) { _, _ in
                    self.view.hideToast()
                }
            }))
            subFuncTable.reloadData()
        } else {
            navigationView.leftBtn.setTitle(R.localStr.search(), for: .normal)
        }
        subFuncTable.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        if BleManager.shared.currentEntity != nil {
            return 2
        } else {
            return 1
        }
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        if BleManager.shared.currentEntity != nil {
            if section == 0 {
                return (BleManager.shared.currentEntity?.mPeripheral.name ?? "") + R.localStr.deviceInfo()
            } else {
                return R.localStr.functions()
            }
        }
        return R.localStr.unconnected()
    }

    func tableView(_: UITableView, estimatedHeightForHeaderInSection _: Int) -> CGFloat {
        return 40
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 40
        } else {
            return 40
        }
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if BleManager.shared.currentEntity != nil {
            if section == 0 {
                return 1
            } else {
                return itemsArray.count
            }
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "FUNCCell", for: indexPath) as? FuncSelectCell
        if cell == nil {
            cell = FuncSelectCell(style: .default, reuseIdentifier: "FUNCCell")
        }
        if indexPath.section == 0, BleManager.shared.currentEntity != nil {
            if indexPath.row == 0 {
                cell?.titleLab.text = R.localStr.disconnect()
            }
        } else {
            cell?.titleLab.text = itemsArray[indexPath.row]
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0, BleManager.shared.currentEntity != nil {
            if indexPath.row == 0 {
                BleManager.shared.disconnectEntity()
            }
        } else if indexPath.section == 1, BleManager.shared.currentEntity != nil {
            switch indexPath.row {
            case 0:
                navigationController?.pushViewController(FileTransportViewController(), animated: true)
            case 1:
                navigationController?.pushViewController(DefaultSetViewController(), animated: true)
            case 2:
                navigationController?.pushViewController(CustomCmdVC(), animated: true)
            case 3:
                navigationController?.pushViewController(UpdatesViewController(), animated: true)
            case 4:
                navigationController?.pushViewController(OthersProtocolVC(), animated: true)
            default:
                break
            }
        }
    }
    
    
}
