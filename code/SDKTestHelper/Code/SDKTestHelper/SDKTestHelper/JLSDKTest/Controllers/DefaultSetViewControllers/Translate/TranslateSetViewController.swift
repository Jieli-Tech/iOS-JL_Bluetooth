//
//  TranslateSetViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/17.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

class TranslateSetViewController: BaseViewController {

    // MARK: - UI Elements

    private let contentScrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()

    // 授权卡片
    private let authCardView = UIView()
    private let statusIconView = UIImageView()
    private let statusTitleLabel = UILabel()
    private let statusDescLabel = UILabel()
    private let infoStackView = UIStackView()
    private let accessKeyLabel = UILabel()
    private let accessKeyValueLabel = UILabel()
    private let appIdLabel = UILabel()
    private let appIdValueLabel = UILabel()
    private let scanBtn = UIButton()

    // 传输设置卡片
    private let configCardView = UIView()
    private let configTitleLab = UILabel()
    private let configStackView = UIStackView()
    private let noResponseSwitch = UISwitch()
    private let maxMtuField = UITextField()

    // MARK: - ViewModel

    private let viewModel = TranslateSetViewModel()

    // MARK: - Lifecycle

    override func initUI() {
        super.initUI()
        navigationView.title = "Translate Set"
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        contentScrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(contentScrollView.contentLayoutGuide)
            make.width.equalTo(contentScrollView.frameLayoutGuide)
        }

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.alignment = .fill
        contentStackView.distribution = .fill
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(20)
        }

        setupAuthCard()
        setupInfoSection()
        setupConfigCard()

        contentStackView.addArrangedSubview(authCardView)
        contentStackView.addArrangedSubview(configCardView)
    }

    override func initData() {
        super.initData()

        bindViewModel()
        viewModel.checkAuthStatus()

        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

        scanBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.startScan()
        }).disposed(by: disposeBag)

        // 传输设置绑定
        noResponseSwitch.isOn = TranslateVM.shared.writeWithoutResponse
        noResponseSwitch.rx.value.subscribe(onNext: { isOn in
            TranslateVM.shared.writeWithoutResponse = isOn
        }).disposed(by: disposeBag)

        maxMtuField.placeholder = "20-500"
        maxMtuField.text = "\(TranslateVM.shared.translateHelper?.maxMtu ?? 200)"
        maxMtuField.keyboardType = .numberPad
        maxMtuField.rx.text.orEmpty.subscribe(onNext: { [weak self] value in
            self?.validateAndSaveMaxMtu(value)
        }).disposed(by: disposeBag)

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        contentView.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkAuthStatus()
        if !viewModel.hasValidAuth() {
            showNoAuthAlert()
        }
    }

    // MARK: - UI Setup

    /// 授权卡片：状态 + Access Key/TTS AppId + 扫码按钮
    private func setupAuthCard() {
        authCardView.backgroundColor = .white
        authCardView.layer.cornerRadius = 12
        authCardView.layer.shadowColor = UIColor.black.cgColor
        authCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        authCardView.layer.shadowOpacity = 0.1
        authCardView.layer.shadowRadius = 4

        statusIconView.contentMode = .scaleAspectFit

        statusTitleLabel.font = .boldSystemFont(ofSize: 18)
        statusTitleLabel.textColor = .darkText

        statusDescLabel.font = .systemFont(ofSize: 13)
        statusDescLabel.textColor = .gray
        statusDescLabel.numberOfLines = 0

        let headerRow = UIStackView(arrangedSubviews: [statusIconView, statusTitleLabel])
        headerRow.axis = .horizontal
        headerRow.spacing = 10
        headerRow.alignment = .center

        statusIconView.snp.makeConstraints { make in
            make.width.height.equalTo(28)
        }

        let authStack = UIStackView(arrangedSubviews: [headerRow, statusDescLabel, infoStackView, scanBtn])
        authStack.axis = .vertical
        authStack.spacing = 10
        authStack.alignment = .fill
        authStack.distribution = .fill

        authCardView.addSubview(authStack)
        authStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }

        scanBtn.setTitle("Scan QR Code to Authorize", for: .normal)
        scanBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        scanBtn.setTitleColor(.white, for: .normal)
        scanBtn.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
        scanBtn.layer.cornerRadius = 12
        scanBtn.layer.masksToBounds = true
        scanBtn.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }

    private func setupInfoSection() {
        infoStackView.axis = .vertical
        infoStackView.spacing = 8
        infoStackView.isHidden = true

        func makeInfoRow(label: UILabel, valueLabel: UILabel) -> UIStackView {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.alignment = .center
            label.font = .systemFont(ofSize: 13)
            label.textColor = .gray
            label.setContentHuggingPriority(.required, for: .horizontal)
            valueLabel.font = .systemFont(ofSize: 13)
            valueLabel.textColor = .darkText
            valueLabel.numberOfLines = 1
            valueLabel.lineBreakMode = .byTruncatingMiddle
            row.addArrangedSubview(label)
            row.addArrangedSubview(valueLabel)
            return row
        }

        accessKeyLabel.text = "Access Key:"
        appIdLabel.text = "TTS AppId:"

        infoStackView.addArrangedSubview(makeInfoRow(label: accessKeyLabel, valueLabel: accessKeyValueLabel))
        infoStackView.addArrangedSubview(makeInfoRow(label: appIdLabel, valueLabel: appIdValueLabel))
    }

    /// 传输设置卡片：独立于授权卡片
    private func setupConfigCard() {
        configCardView.backgroundColor = .white
        configCardView.layer.cornerRadius = 12
        configCardView.layer.shadowColor = UIColor.black.cgColor
        configCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        configCardView.layer.shadowOpacity = 0.08
        configCardView.layer.shadowRadius = 4

        configTitleLab.text = R.localStr.transferSettings()
        configTitleLab.font = .boldSystemFont(ofSize: 15)
        configTitleLab.textColor = .darkText

        configCardView.addSubview(configTitleLab)

        configStackView.axis = .vertical
        configStackView.spacing = 14
        configStackView.alignment = .fill
        configStackView.distribution = .fill

        // 文字左对齐，控件右对齐（Switch / 输入框）
        func makeRow(title: String, control: UIView) -> UIStackView {
            let label = UILabel()
            label.text = title
            label.font = .systemFont(ofSize: 14)
            label.textColor = .darkText
            label.setContentHuggingPriority(.required, for: .horizontal)
            label.snp.makeConstraints { make in
                make.width.equalTo(140)
            }

            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

            let row = UIStackView(arrangedSubviews: [label, spacer, control])
            row.axis = .horizontal
            row.spacing = 12
            row.alignment = .center
            return row
        }

        noResponseSwitch.setContentHuggingPriority(.required, for: .horizontal)

        maxMtuField.borderStyle = .roundedRect
        maxMtuField.font = .systemFont(ofSize: 14)
        maxMtuField.textColor = .darkGray
        maxMtuField.textAlignment = .right
        maxMtuField.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.equalTo(120)
        }

        configStackView.addArrangedSubview(makeRow(title: R.localStr.enableNoInteractionDelivery(), control: noResponseSwitch))
        configStackView.addArrangedSubview(makeRow(title: R.localStr.maxMTU(), control: maxMtuField))

        configCardView.addSubview(configStackView)

        configTitleLab.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(16)
        }

        configStackView.snp.makeConstraints { make in
            make.top.equalTo(configTitleLab.snp.bottom).offset(14)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        viewModel.authStatusSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                self?.updateUI(for: status)
            }).disposed(by: disposeBag)

        viewModel.currentAuthSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] auth in
                self?.updateAuthInfo(auth)
            }).disposed(by: disposeBag)

        viewModel.toastMessageSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.view.makeToast(message, position: .center)
            }).disposed(by: disposeBag)
    }

    // MARK: - UI Update

    private func updateUI(for status: AuthStatus) {
        switch status {
        case .checking:
            statusTitleLabel.text = "Checking..."
            statusDescLabel.text = "Verifying authorization status"
            if #available(iOS 13.0, *) {
                statusIconView.image = UIImage(systemName: "arrow.triangle.2.circlepath")
            }
            statusIconView.tintColor = .gray
            infoStackView.isHidden = true

        case .valid:
            statusTitleLabel.text = "Authorized"
            statusDescLabel.text = "Translation and TTS services are ready"
            if #available(iOS 13.0, *) {
                statusIconView.image = UIImage(systemName: "checkmark.shield.fill")
            }
            statusIconView.tintColor = UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
            infoStackView.isHidden = false

        case .expired:
            statusTitleLabel.text = "Authorization Expired"
            statusDescLabel.text = "Please scan a new QR code to renew authorization"
            if #available(iOS 13.0, *) {
                statusIconView.image = UIImage(systemName: "exclamationmark.shield.fill")
            }
            statusIconView.tintColor = .orange
            infoStackView.isHidden = false

        case .notFound:
            statusTitleLabel.text = "Not Configured"
            statusDescLabel.text = "Scan QR code to add authorization key"
            if #available(iOS 13.0, *) {
                statusIconView.image = UIImage(systemName: "qrcode.viewfinder")
            }
            statusIconView.tintColor = .gray
            infoStackView.isHidden = true
        }
    }

    private func updateAuthInfo(_ auth: AuthDisplayInfo?) {
        guard let auth = auth else {
            accessKeyValueLabel.text = "—"
            appIdValueLabel.text = "—"
            return
        }
        if auth.accessKeyId.count > 8 {
            let prefix = String(auth.accessKeyId.prefix(4))
            let suffix = String(auth.accessKeyId.suffix(4))
            accessKeyValueLabel.text = "\(prefix)****\(suffix)"
        } else {
            accessKeyValueLabel.text = auth.accessKeyId.isEmpty ? "—" : "****"
        }
        if auth.appid.count > 8 {
            let prefix = String(auth.appid.prefix(4))
            let suffix = String(auth.appid.suffix(4))
            appIdValueLabel.text = "\(prefix)****\(suffix)"
        } else {
            appIdValueLabel.text = auth.appid.isEmpty ? "—" : "****"
        }
    }

    // MARK: - Scan Flow

    private func showNoAuthAlert() {
        let alert = UIAlertController(
            title: "Authorization Required",
            message: "Please scan QR code to add authorization key",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Scan", style: .default, handler: { [weak self] _ in
            self?.startScan()
        }))
        alert.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    private func validateAndSaveMaxMtu(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            maxMtuField.textColor = .darkGray
            return
        }
        guard let mtu = Int(trimmed) else {
            maxMtuField.textColor = .red
            self.view.makeToast("请输入有效的整数", position: .center)
            return
        }
        guard mtu >= 20, mtu <= 500 else {
            maxMtuField.textColor = .red
            self.view.makeToast("Max MTU 取值范围: 20-500", position: .center)
            return
        }
        maxMtuField.textColor = .darkGray
        TranslateVM.shared.translateHelper?.maxMtu = mtu
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func startScan() {
        let vc = QRScanerViewController()
        vc.handleScanResult = { [weak self] result in
            guard let self = self else { return }
            self.viewModel.processScanResult(result)
            self.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}
