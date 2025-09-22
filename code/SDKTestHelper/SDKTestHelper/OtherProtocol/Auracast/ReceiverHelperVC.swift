//
//  ReceiverHelperVC.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class ReceiverHelperVC: BaseViewController {
    
    private let isScaningTipLab = UILabel()
    private let isScanSwitchBtn = UISwitch()
    private let devDiscoverListLab = UILabel()
    private let devDiscoverListTable = UITableView()
    private let removeCurrentBtn = UIButton()
    var vm: DeviceInfoViewModel!
    
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.auracastAssistant()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        
        isScaningTipLab.text = R.localStr.searchingOnTheDevice()
        isScaningTipLab.textColor = .black
        isScaningTipLab.font = UIFont.boldSystemFont(ofSize: 15)
        view.addSubview(isScaningTipLab)
        
        isScanSwitchBtn.isOn = false
        view.addSubview(isScanSwitchBtn)
        
        devDiscoverListLab.text = R.localStr.auracastBroadcastResources()
        devDiscoverListLab.textColor = .black
        devDiscoverListLab.font = UIFont.boldSystemFont(ofSize: 15)
        view.addSubview(devDiscoverListLab)
        
        devDiscoverListTable.register(UITableViewCell.self, forCellReuseIdentifier: "DeviceInfoCell")
        view.addSubview(devDiscoverListTable)
        
        removeCurrentBtn.setTitle(R.localStr.removeSources(), for: .normal)
        removeCurrentBtn.setTitleColor(.white, for: .normal)
        removeCurrentBtn.backgroundColor = .eHex("#7657EC")
        removeCurrentBtn.layer.cornerRadius = 10
        removeCurrentBtn.layer.masksToBounds = true
        view.addSubview(removeCurrentBtn)
        
        isScaningTipLab.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(isScanSwitchBtn.snp.left).offset(-16)
        }
        
        isScanSwitchBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-16)
        }
        
        devDiscoverListLab.snp.makeConstraints { make in
            make.top.equalTo(isScaningTipLab.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(16)
        }
        
        devDiscoverListTable.snp.makeConstraints { make in
            make.top.equalTo(devDiscoverListLab.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
        
        removeCurrentBtn.snp.makeConstraints { make in
            make.top.equalTo(devDiscoverListTable.snp.bottom).offset(10)
            make.left.right.equalTo(devDiscoverListTable)
            make.height.equalTo(40)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vm.onRelease()
    }
    
    override func initData() {
        super.initData()
        vm.devBroadcastModelList.bind(to: devDiscoverListTable.rx.items(cellIdentifier: "DeviceInfoCell", cellType: UITableViewCell.self)) { index, model, cell in
            cell.textLabel?.text = model.name
            cell.textLabel?.textColor = .eHex("#000000", alpha: 0.9)
            cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            if model.broadcastID == self.vm.currentBroadcastID {
                cell.textLabel?.textColor = .eHex("#7657EC")
            }
        }.disposed(by: disposeBag)
        
        
        devDiscoverListTable.rx.itemSelected.subscribe(
            onNext: { [weak self] index in
            guard let self = self else { return }
            let model = vm.devBroadcastModelList.value[index.row]
            vm.addSource(model: model) { _ in
                self.devDiscoverListTable.reloadData()
            }
        }).disposed(by: disposeBag)
        
        vm.receiveStatusSubject.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            devDiscoverListTable.reloadData()
        }).disposed(by: disposeBag)
        
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        
        isScanSwitchBtn.rx.value.subscribe(onNext: { [weak self] isOn in
            guard let self = self else { return }
            self.vm.makeDevScanLancer(isOn)
        }).disposed(by: disposeBag)
        
        removeCurrentBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.vm.removeSource { _ in
                self.devDiscoverListTable.reloadData()
            }
        }).disposed(by: disposeBag)
        
    }
}
