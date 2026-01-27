//
//  AuracastViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/5/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JL_BLEKit

/// Auracast 列表与搜索控制器
/// 负责绑定 `broadcastModelList` 到 `tableView`，并管理搜索按钮与扫描指示状态
class AuracastViewController: BaseViewController {
    private var assistViewModel: DeviceInfoViewModel?

    private let contentContainer = UIView()
    private let receiverContainer = UIView()
    private let lancerContainer = UIView()

    private let emptyStateLabel = UILabel()

    private let statusStack = UIStackView()
    private let connectionLabel = UILabel()
    private let batteryLabel = UILabel()
    private let chargingLabel = UILabel()
    private let volumeLabel = UILabel()
    private let loginStateLabel = UILabel()

    private let searchButton = UIButton(type: .system)
    private let searchActivity = UIActivityIndicatorView(style: .medium)

    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private var allBroadcasts: [JLBroadcastDataModel] = []
    private var currentPage = 1
    private let pageSize = 20
    private var visibleBroadcasts: [JLBroadcastDataModel] = []
    private var scanningState: Bool = false
    private var currentSource: JLBroadcastDataModel?
    private var pendingAddress: String?
    private var pendingIDHex: String?
    private var pendingCode: Data?

    private let loginStack = UIStackView()
    private let passwordField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let loginLoading = UIActivityIndicatorView(style: .medium)
    private let loginStatusLabel = UILabel()

    private let changePwdStack = UIStackView()
    private let oldPwdField = UITextField()
    private let newPwdField = UITextField()
    private let changePwdButton = UIButton(type: .system)
    private let changePwdStatusLabel = UILabel()

    private let settingStack = UIStackView()
    private let nameField = UITextField()
    private let formatField = UITextField()
    private let encryptSwitch = UISwitch()
    private let codeField = UITextField()
    private let powerSlider = UISlider()
    private let applyAllButton = UIButton(type: .system)
    private var timerID = ""

    override func initData() {
        super.initData()
        assistViewModel = DeviceInfoViewModel()
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.auracastAssistant()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

        view.addSubview(contentContainer)
        contentContainer.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        contentContainer.addSubview(receiverContainer)
        contentContainer.addSubview(lancerContainer)
        contentContainer.addSubview(emptyStateLabel)

        receiverContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        lancerContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        emptyStateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        emptyStateLabel.textAlignment = .center
        emptyStateLabel.textColor = .secondaryLabel
        emptyStateLabel.text = R.localStr.deviceNotSupport()

        setupReceiverUI()
        setupLancerUI()
        bindViewModel()
    }

    private func setupReceiverUI() {
        receiverContainer.isHidden = true
        statusStack.axis = .vertical
        statusStack.spacing = 8
        receiverContainer.addSubview(statusStack)
        statusStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(16)
        }

        [connectionLabel, batteryLabel, chargingLabel, volumeLabel, loginStateLabel].forEach { lbl in
            lbl.font = .systemFont(ofSize: 15)
            statusStack.addArrangedSubview(lbl)
        }

        let searchStack = UIStackView()
        searchStack.axis = .horizontal
        searchStack.spacing = 8
        receiverContainer.addSubview(searchStack)
        searchStack.snp.makeConstraints { make in
            make.top.equalTo(statusStack.snp.bottom).offset(12)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        searchButton.setTitle(R.localStr.search(), for: .normal)
        searchButton.backgroundColor = .random()
        searchButton.layer.cornerRadius = 8
        searchButton.layer.masksToBounds = true
        searchStack.addArrangedSubview(searchButton)
        searchActivity.hidesWhenStopped = true
        searchStack.addArrangedSubview(searchActivity)

        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        // 使用 .subtitle 风格以显示加密状态
        // 不注册类，使用按需创建以选择 cell 风格
        tableView.dataSource = self
        tableView.delegate = self
        receiverContainer.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchStack.snp.bottom).offset(12)
            make.left.right.bottom.equalToSuperview()
        }
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
    }

    private func setupLancerUI() {
        lancerContainer.isHidden = true
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        lancerContainer.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(16)
        }

        loginStack.axis = .horizontal
        loginStack.spacing = 8
        passwordField.isSecureTextEntry = true
        passwordField.borderStyle = .roundedRect
        passwordField.placeholder = R.localStr.inputPassword()
        loginButton.setTitle(R.localStr.login(), for: .normal)
        loginLoading.hidesWhenStopped = true
        loginStatusLabel.textColor = .secondaryLabel
        loginStack.addArrangedSubview(passwordField)
        loginStack.addArrangedSubview(loginButton)
        loginStack.addArrangedSubview(loginLoading)
        stack.addArrangedSubview(loginStack)
        stack.addArrangedSubview(loginStatusLabel)

        changePwdStack.axis = .horizontal
        changePwdStack.spacing = 8
        oldPwdField.isSecureTextEntry = true
        oldPwdField.borderStyle = .roundedRect
        oldPwdField.placeholder = R.localStr.oldPassword()
        newPwdField.isSecureTextEntry = true
        newPwdField.borderStyle = .roundedRect
        newPwdField.placeholder = R.localStr.newPassword()
        changePwdButton.setTitle(R.localStr.changePassword(), for: .normal)
        changePwdStatusLabel.textColor = .secondaryLabel
        changePwdStack.addArrangedSubview(oldPwdField)
        changePwdStack.addArrangedSubview(newPwdField)
        changePwdStack.addArrangedSubview(changePwdButton)
        stack.addArrangedSubview(changePwdStack)
        stack.addArrangedSubview(changePwdStatusLabel)

        settingStack.axis = .vertical
        settingStack.spacing = 8
        nameField.borderStyle = .roundedRect
        nameField.placeholder = R.localStr.broadcastName()
        formatField.borderStyle = .roundedRect
        formatField.placeholder = R.localStr.audioFormat()
        codeField.borderStyle = .roundedRect
        codeField.placeholder = R.localStr.broadcastCode()
        codeField.isSecureTextEntry = true
        powerSlider.minimumValue = 1
        powerSlider.maximumValue = 10
        applyAllButton.setTitle(R.localStr.accept(), for: .normal)
        settingStack.addArrangedSubview(nameField)
        settingStack.addArrangedSubview(formatField)
        settingStack.addArrangedSubview(encryptSwitch)
        settingStack.addArrangedSubview(codeField)
        settingStack.addArrangedSubview(powerSlider)
        settingStack.addArrangedSubview(applyAllButton)
        stack.addArrangedSubview(settingStack)
    }

    private func bindViewModel() {
        guard let vm = assistViewModel else { return }

        vm.isAuracastDeviceSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] support in
                guard let self = self else { return }
                self.emptyStateLabel.isHidden = support
                if !support {
                    self.receiverContainer.isHidden = true
                    self.lancerContainer.isHidden = true
                }
            }).disposed(by: disposeBag)

        vm.deviceTypeSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] t in
                guard let self = self else { return }
                switch t {
                case .receiver:
                    self.transitionContainers(showReceiver: true)
                    navigationView.title = R.localStr.auracastAssistant() + "(Receiver)"
                case .lancer:
                    self.transitionContainers(showReceiver: false)
                    navigationView.title = R.localStr.auracastAssistant() + "(Lancer)"
                case .none:
                    self.receiverContainer.isHidden = true
                    self.lancerContainer.isHidden = true
                }
            }).disposed(by: disposeBag)

        vm.deviceStateModel
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] state in
                guard let self = self else { return }
                let connected = state != nil
                self.connectionLabel.text = connected ? R.localStr.connected() : R.localStr.disconnect()
                if let s = state, let model = BleManager.shared.currentCmdMgr?.getDeviceModel() {
                    
                    self.batteryLabel.text = "\(model.battery)%"
                    self.chargingLabel.text =  "unKnow"
                    self.volumeLabel.text = "\(model.currentVol)"
                    self.loginStateLabel.text = (s.loginState == .login) ? R.localStr.logined() : R.localStr.notLogin()
                } else {
                    self.batteryLabel.text = "-"
                    self.chargingLabel.text = "-"
                    self.volumeLabel.text = "-"
                    self.loginStateLabel.text = "-"
                }
            }).disposed(by: disposeBag)

        vm.currentSourceModel
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] src in
                guard let self = self else { return }
                self.currentSource = src
                if let src = src, let addr = self.pendingAddress, let pid = self.pendingIDHex, let code = self.pendingCode {
                    let idHex = self.dataToHex(src.broadcastID as Data)
                    if src.advertiserAddressString == addr && idHex == pid {
                        _ = self.keychainSave(service: "auracast.broadcast.code", account: "\(addr)|\(pid)", data: code)
                        self.pendingAddress = nil
                        self.pendingIDHex = nil
                        self.pendingCode = nil
                    }
                }
                if let src = src {
                    self.mergeCurrentSourceIntoList(src)
                } else {
                    self.tableView.reloadData()
                }
            }).disposed(by: disposeBag)

        vm.broadcastModelList
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] list in
                guard let self = self else { return }
                print("[AuracastVC] broadcast list updated, count=\(list.count)")
                self.allBroadcasts = list
                if let src = self.currentSource {
                    self.mergeCurrentSourceIntoList(src)
                } else {
                    self.applyPagination(reset: true)
                }
            }).disposed(by: disposeBag)

        vm.isScaningSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] scanning in
                guard let self = self else { return }
                print("[AuracastVC] scanning state=\(scanning)")
                self.updateScanningUI(scanning)
                if scanning {
                    self.allBroadcasts.removeAll()
                    if let src = self.currentSource, src.syncState == .success {
                        self.allBroadcasts.append(src)
                    }
                    self.applyPagination(reset: true)
                }
            }).disposed(by: disposeBag)

        searchButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let next = !self.scanningState
                print("[AuracastVC] search tapped, toggle scanning -> \(next)")
                self.updateScanningUI(next)
                if self.assistViewModel?.auracastManager?.isScanning == true {
                    self.assistViewModel?.auracastManager?.auracastScanBroadcast(.stop)
                } else {
                    self.assistViewModel?.auracastManager?.auracastScanBroadcast(.start)
                }
            }).disposed(by: disposeBag)

        tableView.rx.itemSelected
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                tableView.deselectRow(at: indexPath, animated: true)
                let model = self.visibleBroadcasts[indexPath.row]
                if let current = self.currentSource, current.broadcastID == model.broadcastID {
                    self.showToast(R.localStr.alreadyPlaying())
                } else {
                    if model.encrypted {
                        let alert = UIAlertController(title: R.localStr.inputPassword(), message: nil, preferredStyle: .alert)
                        alert.addTextField { tf in
                            tf.isSecureTextEntry = true
                            tf.placeholder = R.localStr.inputPassword()
                        }
                        alert.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel, handler: nil))
                        alert.addAction(UIAlertAction(title: R.localStr.confirm(), style: .default, handler: { [weak self] _ in
                            guard let self = self else { return }
                            guard let text = alert.textFields?.first?.text, !text.isEmpty else { self.showToast(R.localStr.inputTextCannotBeEmpty()); return }
                            let cleaned = text.replacingOccurrences(of: " ", with: "").lowercased()
                            let codeData = Data(cleaned.utf8)
                            if !codeData.isEmpty {
                                model.broadcastKey = codeData
                                self.pendingAddress = model.advertiserAddressString
                                self.pendingIDHex = self.dataToHex(model.broadcastID as Data)
                                self.pendingCode = codeData
                                self.assistViewModel?.auracastManager?.addSource(toDev: model)
                                self.showToast(R.localStr.switchSource())
                            } else {
                                self.showToast(R.localStr.inputTextCannotBeEmpty())
                            }
                        }))
                        self.present(alert, animated: true)
                    } else {
                        self.assistViewModel?.auracastManager?.addSource(toDev: model)
                        self.showToast(R.localStr.switchSource())
                    }
                }
            }).disposed(by: disposeBag)

        loginButton.rx.tap
            .withLatestFrom(passwordField.rx.text.orEmpty)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] pwd in
                guard let self = self else { return }
                if pwd.isEmpty { return }
                self.loginLoading.startAnimating()
                self.assistViewModel?.auracastLancerManager?.loginVerify(pwd, result: { [weak self] status in
                    guard let self = self else { return }
                    self.loginLoading.stopAnimating()
                    if status == .lancerLoginVerifyTypeSuccess {
                        self.loginStatusLabel.text = R.localStr.loginSuccess()
                    } else {
                        self.loginStatusLabel.text = R.localStr.loginFailed()
                    }
                })
            }).disposed(by: disposeBag)

        changePwdButton.rx.tap
            .withLatestFrom(Observable.combineLatest(oldPwdField.rx.text.orEmpty, newPwdField.rx.text.orEmpty))
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] oldPwd, newPwd in
                guard let self = self else { return }
                if !self.validatePasswordStrength(newPwd) { self.changePwdStatusLabel.text = R.localStr.weakPassword(); return }
                self.assistViewModel?.auracastLancerManager?.changePassword(oldPwd, newPassword: newPwd, result: { [weak self] result in
                    guard let self = self else { return }
                    if result == .success {
                        self.changePwdStatusLabel.text = R.localStr.changeSuccess()
                    } else {
                        self.changePwdStatusLabel.text = R.localStr.changeFailed()
                    }
                })
            }).disposed(by: disposeBag)

        applyAllButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let mode = JLAuracastLancerSettingMode()
                mode.broadcastName = self.nameField.text ?? ""
                if let idx = UInt8(self.formatField.text ?? "") {
                    mode.audioFormatIndex = JLBroadcastSetAudioFormat(rawValue: idx) ?? .format16_1_1
                }
                mode.encryptEnabled = self.encryptSwitch.isOn
                if let codeText = self.codeField.text, let codeData = codeText.data(using: .utf8), codeData.count == 16 { mode.broadcastCode = codeData }
                mode.powerLevel = UInt8(self.powerSlider.value)
                self.assistViewModel?.auracastLancerManager?.setBroadcastLancerSetting(mode)

                let ud = UserDefaults.standard
                ud.setValue(mode.broadcastName, forKey: "auracast.setting.name")
                ud.setValue(mode.audioFormatIndex, forKey: "auracast.setting.format")
                ud.setValue(mode.encryptEnabled, forKey: "auracast.setting.encrypt")
                ud.setValue(Int(mode.powerLevel), forKey: "auracast.setting.power")
            }).disposed(by: disposeBag)
    }

    private func transitionContainers(showReceiver: Bool) {
        UIView.transition(with: contentContainer, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.receiverContainer.isHidden = !showReceiver
            self.lancerContainer.isHidden = showReceiver
        }, completion: nil)
    }

    @objc private func onRefresh() {
        print("[AuracastVC] pull-to-refresh -> start scanning")
        updateScanningUI(true)
        assistViewModel?.auracastManager?.auracastScanBroadcast(.start)
    }

    private func applyPagination(reset: Bool) {
        if reset { currentPage = 1 }
        var base = uniqueBroadcasts(allBroadcasts)
        if let src = currentSource, src.syncState == .success {
            let idHex = dataToHex(src.broadcastID as Data)
            base.removeAll { dataToHex(($0.broadcastID as Data)) == idHex }
            base.insert(src, at: 0)
        }
        let end = min(currentPage * pageSize, base.count)
        visibleBroadcasts = Array(base.prefix(end))
        tableView.reloadData()
        if refreshControl.isRefreshing { refreshControl.endRefreshing() }
    }

    private func uniqueBroadcasts(_ list: [JLBroadcastDataModel]) -> [JLBroadcastDataModel] {
        var seen = Set<String>()
        var result: [JLBroadcastDataModel] = []
        for m in list {
            let idHex = dataToHex(m.broadcastID as Data)
            if !seen.contains(idHex) {
                seen.insert(idHex)
                result.append(m)
            }
        }
        return result
    }

    private func updateScanningUI(_ scanning: Bool) {
        scanningState = scanning
        searchButton.setTitle(scanning ? R.localStr.stopSearch() : R.localStr.search(), for: .normal)
        if scanning {
            searchActivity.startAnimating()
        } else {
            searchActivity.stopAnimating()
            refreshControl.endRefreshing()
        }
    }

    private func mergeCurrentSourceIntoList(_ src: JLBroadcastDataModel) {
        let id = src.broadcastID as Data
        if let idx = allBroadcasts.firstIndex(where: { $0.broadcastID == id }) {
            allBroadcasts[idx].syncState = src.syncState
        } else if src.syncState == .success {
            allBroadcasts.append(src)
        }
        applyPagination(reset: true)
    }

    private func showToast(_ text: String) {
        self.view.makeToast(text, duration: 2, position: .center)
    }

    private func validatePasswordStrength(_ pwd: String) -> Bool {
        if pwd.count < 6 { return false }
        let hasLower = pwd.range(of: "[a-z]", options: .regularExpression) != nil
        let hasUpper = pwd.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasDigit = pwd.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpec = pwd.range(of: "[!@#$%^&*()_+=\\-{}|\\[\\]:;\"'<>,.?/`~]", options: .regularExpression) != nil
        let score = [hasLower, hasUpper, hasDigit, hasSpec].filter { $0 }.count
        return score >= 2
    }

    private func keychainSave(service: String, account: String, data: Data) -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: service,
                                    kSecAttrAccount as String: account,
                                    kSecValueData as String: data]
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    private func hexStringToData(_ hex: String) -> Data? {
        var data = Data(capacity: hex.count / 2)
        var index = hex.startIndex
        while index < hex.endIndex {
            let nextIndex = hex.index(index, offsetBy: 2)
            if nextIndex > hex.endIndex { return nil }
            let byteString = hex[index..<nextIndex]
            if let num = UInt8(byteString, radix: 16) {
                data.append(num)
            } else {
                return nil
            }
            index = nextIndex
        }
        return data
    }

    private func dataToHex(_ data: Data) -> String {
        return data.map { String(format: "%02x", $0) }.joined()
    }
}

extension AuracastViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleBroadcasts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let m = visibleBroadcasts[indexPath.row]
        cell.textLabel?.text = m.broadcastName
        let isListening = ((currentSource?.broadcastID as Data?) == (m.broadcastID as Data)) || (m.syncState == .success)
        let listenText = isListening ? R.localStr.playing() : R.localStr.notPlaying()
        cell.detailTextLabel?.text = "\(m.advertiserAddressString) • " + (m.encrypted ? R.localStr.encrypt() : R.localStr.unencrypted()) + " • " + listenText
        cell.accessoryView = buildAccessoryView(for: m, at: indexPath.row, isListening: isListening)
        return cell
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentH = scrollView.contentSize.height
        let frameH = scrollView.frame.size.height
        if offsetY > contentH - frameH - 60 {
            let totalPages = Int(ceil(Double(allBroadcasts.count) / Double(pageSize)))
            if currentPage < totalPages {
                currentPage += 1
                applyPagination(reset: false)
            }
        }
    }

    @objc private func onRemoveTapped(_ sender: UIButton) {
        let idx = sender.tag
        guard idx >= 0 && idx < visibleBroadcasts.count else { return }
        let m = visibleBroadcasts[idx]
        print("[AuracastVC] remove tapped for broadcast=\(m.broadcastName)")
        // 先本地更新 UI，防止设备回执延迟导致 UI 不刷新
        if let cur = currentSource, (cur.broadcastID as Data) == (m.broadcastID as Data) {
            currentSource = nil
        }
        // 将对应项置为未收听
        if let ai = allBroadcasts.firstIndex(where: { $0.broadcastID == (m.broadcastID as Data) }) {
            allBroadcasts[ai].syncState = .idle
        }
        if let vi = visibleBroadcasts.firstIndex(where: { $0.broadcastID == (m.broadcastID as Data) }) {
            visibleBroadcasts[vi].syncState = .idle
        }
        tableView.reloadData()
        // 发送移除命令并主动查询当前播放源以同步状态
        assistViewModel?.auracastManager?.removeDevCurrentSource()
        assistViewModel?.auracastManager?.getCurrentOperationSource({ [weak self] model in
            guard let self = self else { return }
            self.currentSource = model
            self.mergeCurrentSourceIntoList(model)
        })
    }

    private func buildAccessoryView(for model: JLBroadcastDataModel, at row: Int, isListening: Bool) -> UIView? {
        let showLock = model.encrypted
        let showRemove = isListening
        if !showLock && !showRemove { return nil }
        let lockWidth: CGFloat = showLock ? 24 : 0
        let btnWidth: CGFloat = showRemove ? 64 : 0
        let width = lockWidth + (showRemove ? (btnWidth + (showLock ? 6 : 0)) : 0)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 24))
        var x: CGFloat = 0
        if showLock {
            let iv = UIImageView(image: UIImage(systemName: "lock.fill"))
            iv.tintColor = .systemRed
            iv.contentMode = .scaleAspectFit
            iv.frame = CGRect(x: x, y: 2, width: 20, height: 20)
            container.addSubview(iv)
            x += 26
        }
        if showRemove {
            let btn = UIButton(type: .system)
            btn.setTitle(R.localStr.remove(), for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 13)
            btn.setTitleColor(.systemRed, for: .normal)
            btn.frame = CGRect(x: x, y: 0, width: 64, height: 24)
            btn.layer.cornerRadius = 4
            btn.layer.borderColor = UIColor.systemRed.cgColor
            btn.layer.borderWidth = 1
            btn.tag = row
            btn.addTarget(self, action: #selector(onRemoveTapped(_:)), for: .touchUpInside)
            container.addSubview(btn)
        }
        return container
    }
}
