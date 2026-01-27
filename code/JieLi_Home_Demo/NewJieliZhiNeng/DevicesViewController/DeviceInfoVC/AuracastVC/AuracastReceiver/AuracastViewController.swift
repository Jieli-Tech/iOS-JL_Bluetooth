//
//  AuracastViewController.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/12.
//

import UIKit

@objcMembers class AuracastViewController: BaseViewController {
    var deviceVm:DeviceInfoViewModel = DeviceInfoViewModel.shared
    private let bgView = UIImageView()
    private let scrollView = UIScrollView()
    private let controlView = AuracastControlView()
    private var scanListView = AuracastBroadcaseView()
    private let auracastHistoryView = AuracastHistoryListView()

    override func initUI() {
        super.initUI()
        navigationView.title = LanguageCls.localizableTxt("Listen Auracast Broadcast")
        navigationView.backgroundColor = .clear
        navigationView.rightBtn.setImage(R.image.icon_scan(), for: .normal)
        navigationView.rightBtn.isHidden = false
        navigationView.leftBtn.setImage(R.image.icon_return(), for: .normal)
        view.backgroundColor = .eHex("#F8FAFE")

        view.insertSubview(bgView, at: 0)
        view.addSubview(scrollView)
        scrollView.addSubview(controlView)
        scrollView.addSubview(auracastHistoryView)
        scrollView.addSubview(scanListView)

        scanListView.contextView = self
        bgView.image = R.image.auracast_bg()!
        bgView.isHidden = true
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.backgroundColor = .clear
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        controlView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.width.equalTo(UIScreen.main.bounds.width - 24)
            make.top.equalToSuperview()
            make.height.equalTo(64)
        }

        auracastHistoryView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(controlView.snp.bottom).offset(0)
            make.height.equalTo(100)
        }

        auracastHistoryView.isHidden = true

        scanListView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(auracastHistoryView.snp.bottom).offset(12)
            make.height.equalTo(32)
            make.bottom.equalToSuperview()
        }
    }

    override func initData() {
        setupNavigationView()
        bindViewModels()
        subscribeToDeviceViewModelBroadcastList()
        subscribeToBassDbHistoryList()
        subscribeToScanningStatus()
        updateUIBasedOnScanningStatus()
    }

    private func setupNavigationView() {
        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

        navigationView.rightBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.handleRightButtonTap()
        }).disposed(by: disposeBag)
    }

    private func handleRightButtonTap() {
        let viewController = QRScanerViewController()
        viewController.handleScanResult = { [weak self] result in
            guard let `self` = self,
                  let dict = try? JSONSerialization.jsonObject(with: result.data(using: .utf8)!,
                                                               options: .mutableContainers) as? [String: String],
                  let code = dict["code"], let name = dict["name"]
            else {
                return
            }

            self.navigationController?.popViewController(animated: true)
            self.deviceVm.scanCodeAddSource(code: code, name: name) { _ in }
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func bindViewModels() {
        controlView.deviceVm = deviceVm
        scanListView.deviceVM = deviceVm
        auracastHistoryView.deviceVM = deviceVm
    }

    private func subscribeToDeviceViewModelBroadcastList() {
        deviceVm.broadcastModelShowList.subscribe { [weak self] _ in
            guard let self = self else { return }
            let list = self.deviceVm.broadcastModelShowList.value
            self.updateScanListViewHeight(to: list.count * 60 + 32)
        }.disposed(by: disposeBag)
    }

    private func subscribeToBassDbHistoryList() {
        deviceVm.broadcastDbVm.historyList.subscribe { [weak self] element in
            guard let self = self else { return }
            self.updateAuracastHistoryView(for: element)
        }.disposed(by: disposeBag)
    }

    private func updateAuracastHistoryView(for element: Observable<[Any]>.Element) {
        if element.count == 0 {
            auracastHistoryView.snp.updateConstraints { make in
                make.height.equalTo(0)
            }
            auracastHistoryView.isHidden = true
        } else {
            auracastHistoryView.isHidden = false
            auracastHistoryView.snp.updateConstraints { make in
                make.height.equalTo(element.count * 62 + 32)
            }
        }
    }

    override func disconnectStatusChange(_ note: Notification) {
        let peripheral = note.object as? CBPeripheral
        if peripheral?.identifier.uuidString == deviceVm.deviceUUID {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    private func subscribeToScanningStatus() {
        deviceVm.isScaningSubject.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.updateUIBasedOnScanningStatus()
        }.disposed(by: disposeBag)
    }

    private func updateUIBasedOnScanningStatus() {
        updateAuracastHistoryViewVisibility(isHidden: deviceVm.broadcastDbVm.historyDevices.isEmpty)
        updateScanListViewHeight(to: deviceVm.broadcastModelShowList.value.count * 60 + 32)
    }

    private func updateAuracastHistoryViewVisibility(isHidden: Bool) {
        auracastHistoryView.isHidden = isHidden
        auracastHistoryView.snp.updateConstraints { make in
            make.height.equalTo(isHidden ? 0 : (deviceVm.broadcastDbVm.historyDevices.count * 62 + 32))
        }
    }

    private func updateScanListViewHeight(to height: Int) {
        scanListView.snp.updateConstraints { make in
            make.height.equalTo(height)
        }
    }
}
