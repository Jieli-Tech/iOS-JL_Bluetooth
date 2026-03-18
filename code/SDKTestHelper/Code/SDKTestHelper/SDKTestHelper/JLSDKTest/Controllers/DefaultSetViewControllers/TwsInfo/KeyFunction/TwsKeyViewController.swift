//
//  TwsKeyViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/6.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class TwsKeyViewController: BaseViewController{
    
    
    private let importConfigBtn = UIButton()
    private let tableView = UITableView()
    private var itemsArray = [Dictionary<String, Any>]()
    private var twsMgr = BleManager.shared.currentCmdMgr?.mTwsManager
    private var observation1: NSKeyValueObservation?
    private var observation2: NSKeyValueObservation?
    
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.headphoneButtonFunctions()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        
        importConfigBtn.setTitle(R.localStr.importConfiguration(), for: .normal)
        importConfigBtn.setTitleColor(.white, for: .normal)
        importConfigBtn.backgroundColor = UIColor.random()
        importConfigBtn.layer.cornerRadius = 10
        importConfigBtn.layer.masksToBounds = true
        importConfigBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        
        view.addSubview(importConfigBtn)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(DetailDefaultCell.self, forCellReuseIdentifier: "cell")
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 54
        
        
        importConfigBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(importConfigBtn.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
    }
    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        importConfigBtn.rx.tap.subscribe { [weak self] _ in
            self?.importConfigAction()
        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animation: Bool) {
        super.viewWillAppear(animation)
        let json = SettingInfo.getKeyConfig()
        if let dict = json.jsonStrBeDict() {
            configKeyFunction(dict)
        }
        
        JLLogManager.logLevel(.DEBUG, content: "twsMgr.workMode:\(self.twsMgr?.workMode ?? 0) micMode:\(self.twsMgr?.micMode ?? 0)")
        twsMgr?.cmdHeadsetGetAdvFlag(.all, result: { dict in
            JLLogManager.logLevel(.DEBUG, content: "\(String(describing: dict))")
        })
        
        observation1 = twsMgr?.observe(\.workMode, options: [.new], changeHandler: { object, change in
            JLLogManager.logLevel(.DEBUG, content: "twsMgr.workMode:\(self.twsMgr?.workMode ?? 0)")
            self.tableView.reloadData()
        })
        
        observation2 = twsMgr?.observe(
            \.micMode,
             options: [.new]
        ) { object, change in
            JLLogManager.logLevel(.DEBUG, content: "twsMgr.micMode:\(self.twsMgr?.micMode ?? 0)")
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillDisappear(_ animation: Bool) {
        super.viewWillDisappear(animation)
        observation1?.invalidate()
        observation2?.invalidate()
    }
    
    private func importConfigAction() {
        let defaultJson = SettingInfo.getKeyConfig()
        AlertInputView.showSingleInput(title: R.localStr.importConfiguration(), message: R.localStr.pleaseEnterTheJsonContentOfTheButtonConfiguration(), inputText: defaultJson, in: self) { [weak self] json in
            guard let self = self else { return }
            if let dict = json?.jsonStrBeDict() {
                configKeyFunction(dict)
                SettingInfo.saveKeyConfig(json!)
            } else {
                view.makeToast(R.localStr.jsonFormatError(), position: .center)
            }
        }
    }
    
    private func configKeyFunction(_ dict: Dictionary<String, Any>) {
        itemsArray = []
        
        guard let device = dict["device"] as? Dictionary<String, Any>,
              let keysettings = device["key_settings"] as? Dictionary<String, Any> else {
            view.makeToast(R.localStr.jsonFormatError(), position: .center)
            tableView.reloadData()
            return
        }
        itemsArray.append(keysettings)
        
        guard let ledSetting = device["led_settings"] as? Dictionary<String, Any> else {
            view.makeToast(R.localStr.jsonFormatError(), position: .center)
            tableView.reloadData()
            return
        }
        itemsArray.append(ledSetting)
        
        guard let workModel = device["work_mode"] as? [Dictionary<String, Any>] else {
            view.makeToast(R.localStr.jsonFormatError(), position: .center)
            tableView.reloadData()
            return
        }
        if twsMgr?.workMode != 0 {
            itemsArray.append(["workModel":workModel])
        }
        
        guard let micChannel = device["mic_channel"] as? [Dictionary<String, Any>] else {
            view.makeToast(R.localStr.jsonFormatError(), position: .center)
            tableView.reloadData()
            return
        }
        if twsMgr?.micMode != 0 {
            itemsArray.append(["micChannel":micChannel])
        }
        tableView.reloadData()
    }
    
}


extension TwsKeyViewController: UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 || section == 1 {
            return 1
        }
        let dict = itemsArray[section]
        if let workModel = dict["workModel"] as? [Dictionary<String, Any>] {
            return workModel.count
        }
        if let micChannel = dict["micChannel"] as? [Dictionary<String, Any>] {
            return micChannel.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLab = UILabel()
        headerLab.font = .systemFont(ofSize: 16, weight: .medium)
        headerLab.textColor = .darkText
        if section == 0 {
            headerLab.text = R.localStr.headphoneButtonFunctions()
        }
        if section == 1 {
            headerLab.text = R.localStr.lightingSettings()
        }
        if section == 2 {
            headerLab.text = R.localStr.modeSettings()
        }
        if section == 3 {
            headerLab.text = R.localStr.microphoneSettings()
        }
        return headerLab
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? DetailDefaultCell
        if cell == nil {
            cell = DetailDefaultCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell?.accessoryType = .none
        if indexPath.section == 0 {
            cell?.setData(title: R.localStr.headphoneButtonFunctions(), detail: R.localStr.configureTheFunctionOfClickingTheHeadset())
            cell?.accessoryType = .disclosureIndicator
        }
        if indexPath.section == 1 {
            cell?.setData(title: R.localStr.lightingSettings(), detail: R.localStr.configureTheStatusLightsOfTheHeadset())
            cell?.accessoryType = .disclosureIndicator
        }
        if indexPath.section == 2 {
            let list = itemsArray[2]["workModel"] as! [Dictionary<String, Any>]
            let dict = list[indexPath.row]
            let value = dict["value"] as! Int
            let titleDict = dict["title"] as! Dictionary<String, String>
            let title = R.isZh ? titleDict["zh"] : titleDict["en"]
            cell?.setData(title: title ?? "" , detail: "value\(value)")
            if self.twsMgr?.workMode == Int32(value) {
                cell?.accessoryType = .checkmark
            }
        }
        if indexPath.section == 3 {
            let list = itemsArray[3]["micChannel"] as! [Dictionary<String, Any>]
            let dict = list[indexPath.row]
            let value = dict["value"] as! Int
            let titleDict = dict["title"] as! Dictionary<String, String>
            let title = R.isZh ? titleDict["zh"] : titleDict["en"]
            cell?.setData(title: title ?? "" , detail: "value\(value)")
            if self.twsMgr?.micMode == Int32(value) {
                cell?.accessoryType = .checkmark
            }
        }
        return cell ?? DetailDefaultCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let vc = TwsKeySelectVC()
            vc.currentKeyDict = self.twsMgr?.headSetInfoDict?["KEY_SETTING"] as? [Dictionary<String, Any>] ?? []
            vc.presetDict = itemsArray[0]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 1 {
            let vc = LightFuncSetVC()
            vc.currentKeyDict = self.twsMgr?.headSetInfoDict?["LED_SETTING"] as? [Dictionary<String, Any>] ?? []
            if vc.currentKeyDict.count == 0 {
                view.makeToast(R.localStr.theDeviceDoesNotSupportLEDSettings(), position: .center)
                return
            }
            vc.presetDict = itemsArray[1]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        if indexPath.section == 2 {
            let list = itemsArray[2]["workModel"] as! [Dictionary<String, Any>]
            let dict = list[indexPath.row]
            let value = dict["value"] as! Int
            self.twsMgr?.cmdHeadsetWorkSettingMode(UInt8(value))
        }
        if indexPath.section == 3 {
            let list = itemsArray[3]["micChannel"] as! [Dictionary<String, Any>]
            let dict = list[indexPath.row]
            let value = dict["value"] as! Int
            self.twsMgr?.cmdHeadsetMicSettingMode(JL_HeadsetMicSettingMode(rawValue: UInt8(value))!)
        }
    }
}
