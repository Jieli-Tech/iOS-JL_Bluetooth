//
//  FileTransportViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/18.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

import UIKit

class FileTransportViewController: BaseViewController {
    let subFuncTable = UITableView()
    let itemsArray = BehaviorRelay<[String]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.fileTransport()
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
        itemsArray.accept([R.localStr.file(),
                           R.localStr.syncContacts(),
                           R.localStr.watchDial(),
                           R.localStr.smallFile(),
                           R.localStr.fileBrowser(),
                           R.localStr.gifToDevice()])
        subFuncTable.rx.itemSelected.subscribe { [weak self] index in
            guard let self = self else { return }
            switch index.element?.row {
            case 0:
                FileTransportViewController.makeSelectHandle(self) { [weak self] in
                    let vc = TransportFileViewController()
                    vc.canNotPushBack = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case 1:
                self.navigationController?.pushViewController(ContactViewController(), animated: true)
            case 2:
                FileTransportViewController.makeSelectHandle(self) { [weak self] in
                    let vc = DialTpViewController()
                    vc.canNotPushBack = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case 3:
                self.navigationController?.pushViewController(SmallFileViewController(), animated: true)
            case 4:
                FileTransportViewController.makeSelectHandle(self) { [weak self] in
                    let vc = FilesBrowseViewController()
                    vc.canNotPushBack = true
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            case 5:
                let vc = Gif2DeviceViewController()
                vc.canNotPushBack = true
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                break
            }
            self.subFuncTable.reloadData()
        }.disposed(by: disposeBag)
    }

    class func makeSelectHandle(_ vc: UIViewController, _ block: @escaping () -> Void) {
        BleManager.shared.currentCmdMgr?.cmdGetSystemInfo(.COMMON) { _, _, _ in
            if let dev = BleManager.shared.currentCmdMgr?.getDeviceModel() {
                let alert = UIAlertController(title: R.localStr.selectFileHandle(),
                                              message: nil,
                                              preferredStyle: .actionSheet)
                for it in dev.cardInfo.cardArray {
                    if let value = it as? Int {
                        let title = JL_CardType(rawValue: UInt8(value))!.beString()
                        JLLogManager.logLevel(.DEBUG, content: title)
                        let action = UIAlertAction(title: title, style: .default) { ac in
                            switch ac.title {
                            case "SD_0":
                                BleManager.shared.currentCmdMgr?.mFileManager.setCurrentFileHandleType(.SD_0)
                            case "SD_1":
                                BleManager.shared.currentCmdMgr?.mFileManager.setCurrentFileHandleType(.SD_1)
                            case "USB":
                                BleManager.shared.currentCmdMgr?.mFileManager.setCurrentFileHandleType(.USB)
                            case "lineIn":
                                BleManager.shared.currentCmdMgr?.mFileManager.setCurrentFileHandleType(.lineIn)
                            case "FLASH":
                                BleManager.shared.currentCmdMgr?.mFileManager.setCurrentFileHandleType(.FLASH)
                            case "FLASH2":
                                BleManager.shared.currentCmdMgr?.mFileManager.setCurrentFileHandleType(.FLASH2)
                            case "FLASH3":
                                BleManager.shared.currentCmdMgr?.mFileManager.setCurrentFileHandleType(.FLASH3)
                            case "reservedArea":
                                BleManager.shared.currentCmdMgr?.mFileManager.setCurrentFileHandleType(.reservedArea)
                            default:
                                break
                            }
                            block()
                        }
                        alert.addAction(action)
                    }
                }
                alert.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel, handler: nil))
                vc.present(alert, animated: true, completion: nil)
            }
        }
    }
}
