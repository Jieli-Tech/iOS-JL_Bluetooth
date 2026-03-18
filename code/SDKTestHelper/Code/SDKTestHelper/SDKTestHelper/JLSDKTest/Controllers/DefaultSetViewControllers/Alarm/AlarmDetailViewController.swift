//
//  AlarmDetailViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/23.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class AlarmDetailViewController: BaseViewController {
    private let dtFm = DateFormatter()
    private var dateGroup: (UInt8, UInt8) = (0, 0)

    let datePicker = UIDatePicker()
    var subCollect: UICollectionView?
    let itemsArray = BehaviorRelay<[AlarmDateSelectModel]>(value: [])
    let ringNameButton = UIButton()
    let alarmNameButton = UIButton()
    let confirmButton = UIButton()
    let dfSelectView = AlarmRingsView()
    let devSelectView = FileBrowseView()

    var alarmModel: JLModel_RTC?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.alarmDetail()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        view.addSubview(datePicker)
        view.addSubview(ringNameButton)
        view.addSubview(alarmNameButton)
        view.addSubview(confirmButton)

        dtFm.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dtFm.locale = Locale(identifier: "en_GB")
        let year = Calendar.current.component(.year, from: Date())
        let month = Calendar.current.component(.month, from: Date())
        let day = Calendar.current.component(.day, from: Date())
        let dtStr = String(format: "%.4d-%.2d-%.2d %.2d:%.2d:00", year, month, day, alarmModel?.rtcHour ?? 0, alarmModel?.rtcMin ?? 0)
        let date = dtFm.date(from: dtStr)
        datePicker.locale = Locale(identifier: "en_GB")
        datePicker.date = date ?? Date()
        datePicker.contentMode = .center
        datePicker.datePickerMode = .time

        let ringName = String(decoding: alarmModel?.ringInfo.data ?? Data(), as: UTF8.self)
        ringNameButton.setTitle("\(R.localStr.ringName())\(ringName)", for: .normal)
        ringNameButton.setTitleColor(.white, for: .normal)
        ringNameButton.backgroundColor = UIColor.random()
        ringNameButton.layer.cornerRadius = 10
        ringNameButton.layer.masksToBounds = true
        ringNameButton.titleLabel?.adjustsFontSizeToFitWidth = true
        if BleManager.shared.currentCmdMgr?.mAlarmClockManager.rtcDfRings.count == 0 {
            ringNameButton.isHidden = true
        }

        let alarmName = alarmModel?.rtcName ?? "none"
        alarmNameButton.setTitle("\(R.localStr.alarmName())\(alarmName)", for: .normal)
        alarmNameButton.setTitleColor(.white, for: .normal)
        alarmNameButton.backgroundColor = UIColor.random()
        alarmNameButton.layer.cornerRadius = 10
        alarmNameButton.layer.masksToBounds = true
        alarmNameButton.titleLabel?.adjustsFontSizeToFitWidth = true

        confirmButton.setTitle(R.localStr.confirm(), for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = UIColor.random()
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.masksToBounds = true
        confirmButton.titleLabel?.adjustsFontSizeToFitWidth = true

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.itemSize = CGSize(width: 40, height: 40)
        subCollect = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        subCollect?.backgroundColor = UIColor.clear
        subCollect?.register(AlarmDateCollectionCell.self, forCellWithReuseIdentifier: "AlarmDateCollectionCell")
        view.addSubview(subCollect!)

        view.addSubview(dfSelectView)
        view.addSubview(devSelectView)

        dfSelectView.itemsArray
            .accept((BleManager.shared.currentCmdMgr?.mAlarmClockManager
                    .rtcDfRings ?? []) as! [JLModel_Ring])
        dfSelectView.isHidden = true
        dfSelectView.backgroundColor = .white
        devSelectView.backgroundColor = .white

        itemsArray.bind(to: subCollect!.rx.items(cellIdentifier: "AlarmDateCollectionCell", cellType: AlarmDateCollectionCell.self)) { _, element, cell in
            cell.bind(element)
        }.disposed(by: disposeBag)

        subCollect?.rx.modelSelected(AlarmDateSelectModel.self).subscribe { [weak self] model in
            guard let `self` = self else { return }
            model.isSelected.toggle()
            self.subCollect?.reloadData()
        }.disposed(by: disposeBag)

        datePicker.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(200)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
        }

        subCollect?.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(60)
            make.top.equalTo(datePicker.snp.bottom).offset(10)
        }

        ringNameButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.top.equalTo(subCollect!.snp.bottom).offset(10)
        }

        alarmNameButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.top.equalTo(ringNameButton.snp.bottom).offset(10)
        }

        confirmButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.top.equalTo(alarmNameButton.snp.bottom).offset(10)
        }

        dfSelectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        devSelectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        devSelectView.isHidden = true
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        datePicker.rx.date.asObservable().subscribe { [weak self] date in
            guard let self = self else { return }
            let hour = Calendar.current.component(.hour, from: date)
            let min = Calendar.current.component(.minute, from: date)
            self.dateGroup = (UInt8(hour), UInt8(min))
            self.alarmModel?.logProperties()
        }.disposed(by: disposeBag)

        let array = AlarmDateSelectModel.makeWeekDateModel(alarmModel?.rtcMode ?? 0)
        itemsArray.accept(array)

        alarmNameButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }

            let alertView = UIAlertController(title: R.localStr.alarmName(), message: nil, preferredStyle: .alert)
            alertView.addTextField { textField in
                textField.text = self.alarmModel?.rtcName
            }
            alertView.addAction(UIAlertAction(title: R.localStr.confirm(), style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                let text = alertView.textFields?.first?.text
                self.alarmModel?.rtcName = text ?? "none"
                let alarmName = alarmModel?.rtcName ?? "none"
                self.alarmNameButton.setTitle("\(R.localStr.alarmName())\(alarmName)", for: .normal)
            }))
            self.present(alertView, animated: true, completion: nil)
        }.disposed(by: disposeBag)

        ringNameButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }

            let alertSheel = UIAlertController(title: R.localStr.ringName(), message: nil, preferredStyle: .actionSheet)
            alertSheel.addAction(UIAlertAction(title: R.localStr.defaultRings(), style: .default, handler: { _ in
                self.dfSelectView.isHidden = false
            }))
            alertSheel.addAction(UIAlertAction(title: R.localStr.deviceRings(), style: .default, handler: { _ in

                FileTransportViewController.makeSelectHandle(self) {
                    let nowModel = JLModel_File()
                    nowModel.fileName = "Root"
                    nowModel.fileType = .folder
                    nowModel.fileClus = 0
                    nowModel.cardType = BleManager.shared.currentCmdMgr?.mFileManager
                        .getCurrentFileHandleType().beCardType() ?? .FLASH
                    nowModel.fileHandle = (BleManager.shared.currentCmdMgr?.mFileManager.currentDeviceHandleData().eHex)!
                    self.devSelectView.loadWithModel(model: nowModel)
                    self.devSelectView.isHidden = false
                }

            }))
            alertSheel.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel, handler: { _ in
            }))
            self.present(alertSheel, animated: true, completion: nil)
        }.disposed(by: disposeBag)

        confirmButton.rx.tap.subscribe { [weak self] _ in
            guard let self = self else { return }
            guard let model = self.alarmModel else { return }
            model.rtcEnable = true
            var rtcMode: uint8 = 0
            for i in 0 ..< self.itemsArray.value.count {
                let item = self.itemsArray.value[i]
                let value = item.isSelected ? 0x01 : 0x00
                rtcMode |= uint8(value << (i + 1))
            }
            if rtcMode == 0xFE { // 当全选时，变为每天
                rtcMode = 0x01
            }
            model.rtcMode = rtcMode
            model.rtcHour = dateGroup.0
            model.rtcMin = dateGroup.1
            BleManager.shared.currentCmdMgr?.mAlarmClockManager.cmdRtcSetArray([model], result: { status, _, _ in
                if status == .success {
                    self.view.makeToast("set alarm success!")
                } else {
                    self.view.makeToast("set alarm fali:\(status)")
                }
            })
        }.disposed(by: disposeBag)

        dfSelectView.currentModel = { [weak self] model in
            guard let self = self else { return }
            self.alarmModel?.ringInfo.type = 0
            self.alarmModel?.ringInfo.dev = 0
            self.alarmModel?.ringInfo.clust = UInt32(model.index)
            self.alarmModel?.ringInfo.data = model.name.data(using: .utf8) ?? Data()
            self.alarmModel?.ringInfo.len = UInt8(self.alarmModel!.ringInfo.data.count)
            let ringName = String(decoding: alarmModel?.ringInfo.data ?? Data(), as: UTF8.self)
            ringNameButton.setTitle("\(R.localStr.ringName()):\(ringName)", for: .normal)
        }
        devSelectView.handleFileSelect = { [weak self] model in
            guard let self = self else { return }
            self.alarmModel?.ringInfo.type = 0x01
            self.alarmModel?.ringInfo.dev = model.cardType.rawValue
            self.alarmModel?.ringInfo.clust = model.fileClus
            let group = sortByName(model.fileName)
            self.alarmModel?.ringInfo.data = group.0
            self.alarmModel?.ringInfo.len = group.1
            let ringName = String(decoding: alarmModel?.ringInfo.data ?? Data(), as: UTF8.self)
            ringNameButton.setTitle("\(R.localStr.ringName()):\(ringName)", for: .normal)
            devSelectView.isHidden = true
        }
    }

    private func sortByName(_ fileName: String) -> (Data, UInt8) {
        let data = fileName.data(using: .utf8) ?? Data()
        return (data, UInt8(data.count))
    }
}
