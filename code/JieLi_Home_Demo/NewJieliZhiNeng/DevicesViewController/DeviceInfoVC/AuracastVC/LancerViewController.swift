//
//  LancerViewController.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/30.
//

import UIKit

@objcMembers class LancerViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var deviceVM:DeviceInfoViewModel? = DeviceInfoViewModel.shared
    private let scrollView = UIScrollView()
    private let subTable = UITableView()
    private let createQRcodeBtn = UIButton()
    private let disconnectBtn = UIButton()
    private let renameView = AlertRenameView()
    private let alertQRcodeShow = AlertQRcodeShow()

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.configureAuracastBroadcast()
        scrollView.showsVerticalScrollIndicator = false
        view.backgroundColor = .eHex("#F7F7F7")
        view.addSubview(scrollView)
        scrollView.addSubview(subTable)
        scrollView.addSubview(createQRcodeBtn)
        scrollView.addSubview(disconnectBtn)
        alertQRcodeShow.contextView = self

        subTable.backgroundColor = .clear
        subTable.separatorStyle = .none
        subTable.separatorColor = .clear
        subTable.register(LancerDeviceSetTableViewCell.self, forCellReuseIdentifier: "LancerDeviceSetTableViewCell")
        subTable.rowHeight = 56
        subTable.isScrollEnabled = false
        subTable.dataSource = self
        subTable.delegate = self

        createQRcodeBtn.layer.cornerRadius = 8
        createQRcodeBtn.layer.masksToBounds = true
        createQRcodeBtn.backgroundColor = .white
        createQRcodeBtn.setTitle(R.localStr.generateQRCode(), for: .normal)
        createQRcodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        createQRcodeBtn.setTitleColor(R.color.btnBlueText(), for: .normal)

        disconnectBtn.layer.cornerRadius = 8
        disconnectBtn.layer.masksToBounds = true
        disconnectBtn.backgroundColor = .white
        disconnectBtn.setTitle(R.localStr.disconnect_device(), for: .normal)
        disconnectBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        disconnectBtn.setTitleColor(.eHex("#F12C2C"), for: .normal)

        let width = UIScreen.main.bounds.size.width

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalToSuperview()
            make.width.equalTo(width - 24)
            make.height.equalTo(10 * 56 + 45 * 2)
        }

        createQRcodeBtn.snp.makeConstraints { make in
            make.top.equalTo(subTable.snp.bottom).offset(32)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(48)
        }

        disconnectBtn.snp.makeConstraints { make in
            make.top.equalTo(createQRcodeBtn.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(12)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(24)
        }
    }

    override func initData() {
        super.initData()
        deviceVM?.deviceInfoList.subscribe { [weak self] _ in
            guard let self = self else {
                return
            }
            self.subTable.reloadData()
        }.disposed(by: disposeBag)

        createQRcodeBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self, let deviceVM = self.deviceVM else {
                return
            }
            self.alertQRcodeShow.show(deviceVM)
        }.disposed(by: disposeBag)

        disconnectBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else {
                return
            }
            guard let entity = JL_RunSDK.sharedMe().mBleEntityM else { return }
            JL_RunSDK.sharedMe().mBleMultiple.disconnectEntity(entity) { _ in
            }
        }.disposed(by: disposeBag)

        renameView.callback = { [weak self] name in
            guard let self = self else {
                return
            }
            self.deviceVM?.auracastLancerManager?.setBroadcastName(name)
        }
    }

    func numberOfSections(in _: UITableView) -> Int {
        return deviceVM?.deviceInfoList.value.count ?? 0
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let list = deviceVM?.deviceInfoList.value[section] else {
            return 1
        }
        return list.count
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LancerDeviceSetTableViewCell",
                                                 for: indexPath) as? LancerDeviceSetTableViewCell
        if cell == nil {
            cell = LancerDeviceSetTableViewCell(style: .default, reuseIdentifier: "LancerDeviceSetTableViewCell")
        }
        cell?.callBackSlider = { [weak self] value, _ in
            guard let self = self else {
                return
            }
            if indexPath.section == 0 && indexPath.row == 1 {
                self.view.makeToast("Not support", duration: 2, position: .center)
            }
            if indexPath.section == 0 && indexPath.row == 2 {
                self.deviceVM?.auracastLancerManager?.setPowerLevel(UInt8(value))
            }
        }
        cell?.callBackSwitch = { [weak self] value, model in
            guard let self = self else {
                return
            }
            if model.name == R.localStr.encryptionSettings() {
                guard let codeData = deviceVM?.auracastLancerManager?.settingMode?.broadcastCode else {
                    return
                }
                self.deviceVM?.auracastLancerManager?.setEncryptEnabled(value, code: codeData)
            }
        }
        guard let list = deviceVM?.deviceInfoList.value[indexPath.section] else { return cell! }
        let model = list[indexPath.row]
        cell?.configCell(model)
        if list.count == 1 {
            cell?.layer.cornerRadius = 12
            cell?.layer.maskedCorners = [.layerMinXMinYCorner,
                                         .layerMaxXMinYCorner,
                                         .layerMinXMaxYCorner,
                                         .layerMaxXMaxYCorner]
        } else if indexPath.row == 0 {
            cell?.layer.cornerRadius = 12
            cell?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if indexPath.row == list.count - 1 {
            cell?.layer.cornerRadius = 12
            cell?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            cell?.layer.cornerRadius = 0
        }
        return cell!
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lab = UILabel()
        lab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        lab.textColor = R.color.fontBackText_50()
        lab.adjustsFontSizeToFitWidth = true
        switch section {
        case 0:
            lab.text = R.localStr.deviceSettings()
        case 1:
            lab.text = R.localStr.basicSettings()
        case 2:
            lab.text = R.localStr.securitySettings()
        default:
            break
        }
        return lab
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            handleDeviceSettingsSelection(at: indexPath.row)
        case 1:
            handleBasicSettingsSelection(at: indexPath.row)
        case 2:
            handleSecuritySettingsSelection(at: indexPath.row)
        default:
            break
        }
    }

    private func handleDeviceSettingsSelection(at row: Int) {
        guard let list = deviceVM?.deviceInfoList.value[0] else { return }
        switch row {
        case 0:
            showRenameView(list[row].detailContext ?? "")
        default:
            break
        }
    }

    private func handleBasicSettingsSelection(at row: Int) {
        switch row {
        case 0:
            // 广播配置
            break
        case 2:
            handleKeySettings()
        case 3:
            handleAudioFormatSettings()
        case 4:
            // 更多设置
            break
        default:
            break
        }
    }

    private func handleSecuritySettingsSelection(at row: Int) {
        switch row {
        case 0:
            let viewController = LancerPswSafeVC()
            viewController.deviceVM = deviceVM
            navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }

    private func handleKeySettings() {
        guard let model = deviceVM?.deviceInfoList.value[1][2] else { return }
        if model.isEnable {
            let viewController = LancerEncryptSetVC()
            viewController.deviceVM = deviceVM
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func handleAudioFormatSettings() {
        let viewController = LancerAudioFormatVC()
        guard let deviceVM = deviceVM else { return }
        viewController.makeInit(deviceVM)
        navigationController?.pushViewController(viewController, animated: true)
    }

    // MARK: - Rename

    func showRenameView(_ name: String) {
        guard let window = AlertManager.windows() else { return }
        window.addSubview(renameView)
        renameView.setName(name)
        renameView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
        renameView.isHidden = false
    }

    func hiddenRenameView() {
        renameView.removeFromSuperview()
        renameView.isHidden = true
    }
}
