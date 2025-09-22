//
//  DefaultSetViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/19.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class DefaultSetViewController: BaseViewController {
    let subFuncTable = UITableView()
    let itemsArray = BehaviorRelay<[String]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.defaultSet()
        navigationView.rightBtn.isHidden = false
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        subFuncTable.register(FuncSelectCell.self, forCellReuseIdentifier: "FUNCCell")
        subFuncTable.rowHeight = 60
        subFuncTable.separatorStyle = .none
        view.addSubview(subFuncTable)

        subFuncTable.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }

        itemsArray.bind(to: subFuncTable.rx.items(cellIdentifier: "FUNCCell", cellType: FuncSelectCell.self)) { _, element, cell in
            cell.titleLab.text = element
        }.disposed(by: disposeBag)
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        itemsArray.accept([R.localStr.weatherTest(),
                           R.localStr.voiceTransmissionDecoding(),
                           R.localStr.eqSetting(),
                           R.localStr.promptTonePacking(),
                           R.localStr.aiInfoHelper(),
                           R.localStr.dialInfoExtentedGet(),
                           R.localStr.alarm(),
                           R.localStr.translateTransfer(),
                           R.localStr.headphoneTWSInformation()])
        subFuncTable.rx.itemSelected.subscribe { [weak self] index in
            guard let self = self else { return }
            switch index.element?.row {
            case 0:
                self.navigationController?.pushViewController(WeatherTestViewController(), animated: true)
            case 1:
                self.navigationController?.pushViewController(RecordDecoderVC(), animated: true)
            case 2:
                self.navigationController?.pushViewController(EQSettingViewController(), animated: true)
            case 3:
                let vc = CreateVoicesViewController()
                vc.canNotPushBack = true
                self.navigationController?.pushViewController(vc, animated: true)
            case 4:
                self.navigationController?.pushViewController(AIInfoHelperViewController(), animated: true)
            case 5:
                guard let currentCmd = BleManager.shared.currentCmdMgr else {
                    ECPrintError("current cmd manager is nil ,please connect first!", self, "\(#function)", #line)
                    return
                }
                JLDeviceConfig.share().deviceGet(currentCmd) { status, _, configModel in
                    if status == .success, let model = configModel {
                        // is support dial info extected
                        if model.exportFunc.spDialInfoExtend {
                            JLDialInfoExtentManager.share().getDialInfoExtented(currentCmd) { st, exModel in
                                if st == .success, let exModel = exModel {
                                    // Get Dial Info
                                    exModel.logProperties()
                                }
                            }
                        }
                    }
                }
            case 6:
                self.navigationController?.pushViewController(AlarmViewController(), animated: true)
            case 7:
                self.navigationController?.pushViewController(TranslateViewController(), animated: true)
            case 8:
                self.navigationController?.pushViewController(TwsInfoViewController(), animated: true)
            default:
                break
            }
            self.subFuncTable.reloadData()
        }.disposed(by: disposeBag)
    }
}
