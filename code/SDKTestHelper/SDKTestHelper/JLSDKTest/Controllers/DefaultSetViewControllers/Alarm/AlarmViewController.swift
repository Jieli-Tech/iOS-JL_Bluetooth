//
//  AlarmViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/22.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class AlarmViewController: BaseViewController {
    let addButton = UIButton()
    let subTable = UITableView()
    let itemsArray = BehaviorRelay<[JLModel_RTC]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentMgr = BleManager.shared.currentCmdMgr else {
            ECPrintError("current cmd manager is nil，please connect device", self, "\(#function)", #line)
            return
        }

        currentMgr.mAlarmClockManager.cmdRtcGetAlarms { [weak self] rtcs, err in
            if err == nil, let rtcs = rtcs {
                self?.itemsArray.accept(rtcs)
            } else {
                ECPrintError("get alarm error", "error", "\(#function)", #line)
                self?.view.makeToast("get alarm error,\(String(describing: err?.localizedDescription))", position: .center)
            }
        }
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.alarm()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(addButton)
        addButton.setTitle(R.localStr.addAlarm(), for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor.random()
        addButton.layer.cornerRadius = 10
        addButton.layer.masksToBounds = true
        addButton.titleLabel?.adjustsFontSizeToFitWidth = true

        subTable.tableFooterView = UIView()
        subTable.rowHeight = 55
        subTable.register(AlarmCell.self, forCellReuseIdentifier: "AlarmCell")
        subTable.backgroundColor = UIColor.clear
        subTable.separatorStyle = .none
        view.addSubview(subTable)

        addButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
        }

        subTable.snp.makeConstraints { make in
            make.top.equalTo(addButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(6)
            make.bottom.equalToSuperview().inset(16)
        }
        itemsArray.bind(to: subTable.rx.items(cellIdentifier: "AlarmCell", cellType: AlarmCell.self)) { [weak self] _, element, cell in
            guard let `self` = self else { return }
            cell.bind(element)
            cell.isOnBlock = {
                BleManager.shared.currentCmdMgr?.mAlarmClockManager.cmdRtcSetArray([cell.alarmModel!], result: { status, _, _ in
                    if status == .success {
                        self.view.makeToast("set alarm success!")
                    } else {
                        self.view.makeToast("set alarm fali:\(status)")
                    }
                    self.subTable.reloadData()
                })
            }
        }.disposed(by: disposeBag)
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        addButton.rx.tap.subscribe { [weak self] _ in
            guard let manager = BleManager.shared.currentCmdMgr,
                  var rtcModels = manager.mAlarmClockManager.rtcAlarms as? [JLModel_RTC] else { return }

            rtcModels = rtcModels.sorted(by: { $0.rtcIndex < $1.rtcIndex })

            let rtc = JLModel_RTC()
            rtc.rtcHour = UInt8(Calendar.current.component(.hour, from: Date()))
            rtc.rtcMin = UInt8(Calendar.current.component(.minute, from: Date()))
            rtc.rtcName = "Alarm"

            let vc = AlarmDetailViewController()
            if rtcModels.count > 0 {
                rtc.rtcIndex = rtcModels.last!.rtcIndex + 1
            } else {
                rtc.rtcIndex = 0
            }

            if let ring = manager.mAlarmClockManager.rtcDfRings.firstObject as? JLModel_Ring {
                // 设置默认闹钟铃声
                rtc.ringInfo = RTC_RingInfo()
                rtc.ringInfo.type = 0
                rtc.ringInfo.dev = 0
                rtc.ringInfo.clust = 0
                rtc.ringInfo.data = ring.name.data(using: .utf8) ?? Data()
                rtc.ringInfo.len = UInt8(rtc.ringInfo.data.count)
            }
            vc.alarmModel = rtc
            self?.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)

        subTable.rx.modelDeleted(JLModel_RTC.self).subscribe { [weak self] item in
            guard let `self` = self else { return }
            BleManager.shared.currentCmdMgr?.mAlarmClockManager.cmdRtcDeleteIndexArray([NSNumber(value: item.rtcIndex)], result: { status, _, _ in
                if status == .success {
                    self.view.makeToast("delete alarm success!")
                }
                var arr = self.itemsArray.value
                arr.removeAll(where: { $0.rtcIndex == item.rtcIndex })
                self.itemsArray.accept(arr)
            })
        }.disposed(by: disposeBag)

        subTable.rx.modelSelected(JLModel_RTC.self).subscribe { [weak self] item in
            guard let `self` = self else { return }
            let vc = AlarmDetailViewController()
            vc.alarmModel = item
            navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
}
