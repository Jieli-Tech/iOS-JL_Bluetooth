//
//  SettingViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/10/30.
//

import UIKit

class SettingViewController: BaseViewController {
    let subtable = UITableView()
    var itemArray: [String] = [R.localStr.customizeBLEConnection(), R.localStr.authenticationPairing(), R.localStr.customizeTransportPath(), R.localStr.usingATTCommunication()]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.setting()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        subtable.backgroundColor = UIColor.eHex("#F5F5F5")
        subtable.register(SettingViewCell.self, forCellReuseIdentifier: "SettingViewCell")
        subtable.delegate = self
        subtable.dataSource = self
        subtable.tableFooterView = UIView()
        view.addSubview(subtable)
        subtable.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        itemArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingViewCell", for: indexPath) as! SettingViewCell
        cell.label.text = itemArray[indexPath.row]
        cell.useInterfaceEnable(enable: true)
        cell.setDetailText(str: "")
        cell.switchBtn.tag = indexPath.row
        if indexPath.row == 0 {
            cell.switchBtn.isOn = SettingInfo.getCustomerBleConnect()
            if let entity = BleManager.shared.currentEntity {
                BleManager.shared.connectEntity(entity)
            }
            if SettingInfo.getATTComunication() {
                cell.useInterfaceEnable(enable: false)
            } else {
                cell.useInterfaceEnable(enable: true)
            }
        }
        if indexPath.row == 1 {
            cell.switchBtn.isOn = SettingInfo.getPairEnable()
        }
        if indexPath.row == 2 {
            cell.switchBtn.isOn = SettingInfo.getCustomTransportSupport()
        }
        if indexPath.row == 3 {
            cell.switchBtn.isOn = SettingInfo.getATTComunication()
            if SettingInfo.getATTComunication() {
                cell.setDetailText(str: "UUID：" + (SettingInfo.getAttDevUUID() ?? "unknow"))
            } else {
                cell.setDetailText(str: "")
            }
        }
        cell.handler = { [weak self] btn in
            self?.handleBtn(switchBtn: btn)
        }
        return cell
    }

    func handleBtn(switchBtn: UISwitch) {
        switch switchBtn.tag {
        case 0:
            SettingInfo.saveCustomerBleConnect(switchBtn.isOn)
        case 1:
            SettingInfo.savePairEnable(switchBtn.isOn)
        case 2:
            SettingInfo.saveCustomTransportSupport(switchBtn.isOn)
        case 3:
            if switchBtn.isOn {
                showInputEditView()
            } else {
                SettingInfo.saveATTComunication(false)
            }
            subtable.reloadData()
        default:
            break
        }
    }

    func showInputEditView() {
        let alertView = UIAlertController(title: R.localStr.tips(), message: R.localStr.enterTheUUIDOfTheConnectedPeripheral(), preferredStyle: .alert)
        alertView.addTextField { textField in
            textField.text = SettingInfo.getAttDevUUID()
        }
        alertView.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel))
        alertView.addAction(UIAlertAction(title: R.localStr.confirm(), style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            if let text = alertView.textFields?.first?.text, text.count > 0 {
                SettingInfo.saveAttDevUUID(text)
                SettingInfo.saveATTComunication(true)
                self.subtable.reloadData()
            }
        }))
        present(alertView, animated: true, completion: nil)
    }
}

class SettingViewCell: UITableViewCell {
    let label = UILabel()
    let switchBtn = UISwitch()
    let detailBtn = UIButton()
    let detailLab = UILabel()
    private let maskingView = UIView()
    var handler: ((UISwitch) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(detailLab)
        contentView.addSubview(switchBtn)
        contentView.addSubview(maskingView)

        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.black
        detailLab.font = UIFont.systemFont(ofSize: 12)
        detailLab.textColor = UIColor.gray
        switchBtn.addTarget(self, action: #selector(switchBtnClick), for: .valueChanged)
        maskingView.isHidden = true
        maskingView.backgroundColor = UIColor.black
        maskingView.alpha = 0.1

        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }

        detailLab.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-5)
        }

        switchBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        maskingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func useInterfaceEnable(enable: Bool) {
        maskingView.isHidden = enable
    }

    func setDetailText(str: String) {
        detailLab.text = str
        if str.count > 0 {
            label.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(20)
                make.top.equalToSuperview().offset(5)
            }
            detailLab.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(20)
                make.bottom.equalToSuperview().offset(-5)
            }
        } else {
            label.snp.remakeConstraints { make in
                make.left.equalToSuperview().offset(20)
                make.centerY.equalToSuperview()
            }
        }
    }

    @objc func switchBtnClick() {
        handler?(switchBtn)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
