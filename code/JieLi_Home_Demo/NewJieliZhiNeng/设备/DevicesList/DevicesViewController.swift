//
//  DevicesViewController.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class DevicesViewController: BasicViewController,LanguagePtl {
    func languageChange() {
        
    }
    var isDeleteMode = false
    let subTable = UITableView()
    var uitap: UITapGestureRecognizer?
    private let headerView = DevicesHeaderView()
    private let noDeviceView = DevicesNoDeviceView()
    private let searchingView = SearchView()
    private let disposeBag = DisposeBag()
    
    override func initUI() {
        super.initUI()
        view.backgroundColor = .eHex("#F8FAFE")
        LanguageCls.share().add(self)
        naviView.isHidden = true
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(40 + view.safeAreaInsets.top + 44)
        }
        view.addSubview(noDeviceView)
        noDeviceView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40 -  view.safeAreaInsets.top - 44)
        }
        
        subTable.separatorStyle = .none
        subTable.rowHeight = UITableView.automaticDimension
        subTable.estimatedRowHeight = 80
        subTable.keyboardDismissMode = .interactive
        subTable.backgroundColor = .clear
        subTable.register(
            DevicesInfoCell.self,
            forCellReuseIdentifier: "cell"
        )
        view.addSubview(subTable)
        self.searchingView.frame = CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
        
        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
    
    override func initData() {
        super.initData()
        DevicesViewModel.share.subArray.bind(to: subTable.rx.items(cellIdentifier: "cell", cellType: DevicesInfoCell.self)) { [weak self] index, model, cell in
            guard let self = self else { return }
            cell.config(model, isDeleteMode, self)
        }.disposed(by: disposeBag)
        headerView.addDeviceBtn.rx.tap.subscribe(
            onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                guard JL_RunSDK.sharedMe().mBleMultiple.bleManagerState == .poweredOn else {
                    DispatchQueue.main
                        .async {
                            self.view
                                .makeToast(
                                    LanguageCls.localizableTxt(
                                        "bluetooth_not_enable"
                                    ),
                                    position: .center
                                )
                    }
                    return
                }
                let windows = UIApplication.shared.windows.first
                windows?.addSubview(self.searchingView)
                self.searchingView.startSearch()
        }).disposed(by: disposeBag)
        
        headerView.settingBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            let vc = AppSettingVC()
            self.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
        
        DevicesViewModel.share.subArray.subscribe(onNext: { [weak self] list in
            guard let self = self else { return }
            if list.count > 0 {
                self.noDeviceView.isHidden = true
                self.subTable.isHidden = false
            } else {
                self.noDeviceView.isHidden = false
                self.subTable.isHidden = true
            }
        }).disposed(by: disposeBag)
        
        subTable.rx.modelSelected(DevicesInfoModel.self).subscribe(onNext: { [weak self] model in
            guard let self = self else { return }
            DevicesViewModel.share.connectDevice(model, viewController: self)
        }).disposed(by: disposeBag)
        
        uitap = UITapGestureRecognizer(target: self, action: #selector(exitDeleteMode))
        addNote()
    }
    
    private func addNote() {
        JL_Tools.add(kUI_TURN_TO_DEVICEVC, action: #selector(enterDeviceList), own: self)
    }
    
    @objc private func enterDeviceList(_ note: Notification) {
        guard let entity = JL_RunSDK.sharedMe().mBleEntityM else { return }
        entity.mCmdManager.mTwsManager.cmdHeadsetGetAdvFlag(.all) { [weak self] dict in
            guard let self = self else { return }
            let vc = DeviceInfoVC()
            vc.headsetDict = dict ?? [:]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    @objc private func exitDeleteMode() {
        isDeleteMode = false
        subTable.reloadData()
        view.removeGestureRecognizer(uitap!)
    }
    
    func setDeleteMode() {
        isDeleteMode = true
        view.addGestureRecognizer(uitap!)
        subTable.reloadData()
    }
    
    deinit {
        JL_Tools.remove(kUI_TURN_TO_DEVICEVC, own: self)
        LanguageCls.share().remove(self)
    }
    
}
