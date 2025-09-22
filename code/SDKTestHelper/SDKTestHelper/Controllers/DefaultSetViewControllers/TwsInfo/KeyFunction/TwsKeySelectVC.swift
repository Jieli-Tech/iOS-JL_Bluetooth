//
//  TwsKeySelectVC.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/6.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class TwsKeySelectVC: BaseViewController, HorizontalMultiPickerViewDelegate {
    
    var currentKeyDict = [Dictionary<String, Any>]()
    var presetDict: Dictionary<String, Any> = [:]
    private let currentLab = UILabel()
    private let titleLab = UILabel()
    private let pickerView = PickerView()

    private var keyNums:[Dictionary<String, Any>] = []
    private var keyActions:[Dictionary<String, Any>] = []
    private var keyFunctions:[Dictionary<String, Any>] = []
    
    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        var keyNumsStr: [String] = []
        var keyActionsStr: [String] = []
        var keyFunctionsStr: [String] = []
        for key in presetDict {
            if key.key.contains("key_num") {
                keyNums = key.value as! [Dictionary<String, Any>]
                for num in keyNums {
                    let titleDict = num["title"] as! Dictionary<String, String>
                    let title = titleDict[R.isZh ? "zh" : "en"] ?? ""
                    keyNumsStr.append(title)
                }
            }
            
            if key.key.contains("key_action") {
                keyActions = key.value as! [Dictionary<String, Any>]
                for num in keyActions {
                    let titleDict = num["title"] as! Dictionary<String, String>
                    let title = titleDict[R.isZh ? "zh" : "en"] ?? ""
                    keyActionsStr.append(title)
                }
            }
            if key.key.contains("key_function") {
                keyFunctions = key.value as! [Dictionary<String, Any>]
                for num in keyFunctions {
                    let titleDict = num["title"] as! Dictionary<String, String>
                    let title = titleDict[R.isZh ? "zh" : "en"] ?? ""
                    keyFunctionsStr.append(title)
                }
            }
        }
        JLLogManager.logLevel(.DEBUG, content: "keyNumsStr:\(keyNumsStr) keyActionsStr:\(keyActionsStr) keyFunctionsStr:\(keyFunctionsStr)")
        pickerView.dataSources = [
            keyFunctionsStr,
            keyActionsStr,
            keyNumsStr
        ]
        pickerView.setSelectedIndexes([0, 0, 0], animated: true)
        pickerView.delegate = self
        pickerView.configuration = PickerView.Configuration(
            showsMagnifier: true,      // 是否显示放大镜效果
            showsScrollIndicator: true, // 是否显示滚动指示器
            autoAdjustFontSize: true,   // 是否自动调整字体大小
            baseFontSize: 16,           // 基础字体大小
            baseRowHeight: 70           // 基础行高
        )
        pickerView.configuration.showsMagnifier = true
        
        currentKeyConfig()
        
    }
    
    private func currentKeyConfig() {
        var targetStr = ""
        for dict in currentKeyDict {
            let keyType = dict["KEY_LR"] as! Int
            let keyAction = dict["KEY_ACTION"] as! Int
            let keyFunc = dict["KEY_FUNCTION"] as! Int
            let numDict = keyNums.first(where: { $0["value"] as! Int == keyType })!
            let numTitleDict = numDict["title"] as! Dictionary<String, String>
            let numTitle = numTitleDict[R.isZh ? "zh" : "en"]!
            targetStr = targetStr + "Key:" + numTitle + " "
            
            let actionDict = keyActions.first(where: { $0["value"] as! Int == keyAction })!
            let actionTitleDict = actionDict["title"] as! Dictionary<String, String>
            let actionTitle = actionTitleDict[R.isZh ? "zh" : "en"]!
            targetStr = targetStr + "Action:" + actionTitle + " "
            
            let funcDict = keyFunctions.first(where: { $0["value"] as! Int == keyFunc })!
            let funcTitleDict = funcDict["title"] as! Dictionary<String, String>
            let funcTitle = funcTitleDict[R.isZh ? "zh" : "en"]!
            targetStr = targetStr + "Func:" + funcTitle + " \n"
        }
        currentLab.text = targetStr
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        JL_Tools.add(kJL_MANAGER_HEADSET_SET_ERR, action: #selector(refreshView), own: self)
    }
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.headphoneButtonFunctions()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(currentLab)
        view.addSubview(titleLab)
        view.addSubview(pickerView)
        
        currentLab.textColor = .darkText
        currentLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        currentLab.numberOfLines = 0
        currentLab.adjustsFontSizeToFitWidth = true
        
        titleLab.text = R.localStr.selectButtonConfiguration()
        titleLab.textColor = .darkText
        titleLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLab.numberOfLines = 0
        titleLab.adjustsFontSizeToFitWidth = true
        
        currentLab.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }
        
        titleLab.snp.makeConstraints { make in
            make.top.equalTo(currentLab.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }
        
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(8)
            make.left.equalToSuperview().inset(6)
            make.right.equalToSuperview().inset(6)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc private func refreshView() {
        BleManager.shared.currentCmdMgr?.mTwsManager.cmdHeadsetGetAdvFlag(.buttonFunction) { _ in 
            self.currentKeyDict = BleManager.shared.currentCmdMgr?.mTwsManager
                .headSetInfoDict?["KEY_SETTING"] as? [Dictionary<String, Any>] ?? []
            self.currentKeyConfig()
        }
    }
    
    func multiPickerView(_ pickerView: PickerView, didConfirmSelection selections: [Int]) {
        JLLogManager.logLevel(.DEBUG, content: "didConfirmSelection selections:\(selections)")
        guard let twsManager = BleManager.shared.currentCmdMgr?.mTwsManager else { return }
        let function = keyFunctions[selections[0]]["value"] as! Int
        let action = keyActions[selections[1]]["value"] as! Int
        let key = keyNums[selections[2]]["value"] as! Int
        twsManager.cmdHeadsetKeySettingKey(UInt8(key), action:UInt8(action), function: UInt8(function))
    }
    
    func multiPickerView(_ pickerView: PickerView, didChangeSelection selections: [Int]) {
        JLLogManager.logLevel(.DEBUG, content: "selections:\(selections)")
    }
    
    

}
