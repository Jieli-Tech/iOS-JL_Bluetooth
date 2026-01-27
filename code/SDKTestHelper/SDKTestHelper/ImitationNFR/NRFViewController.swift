//
//  NRFViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/11.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

/// NFR 扫描页面
class NRFViewController: BaseViewController {
    private let filterBtn = UIButton()
    private let tableView = UITableView()
    private let viewModel = NRFViewModel()
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindVM()
        viewModel.startScan()
    }
    
    override func initUI() {
        super.initUI()
        navigationView.title = "NFR Scan"
        navigationView.rightBtn.isHidden = true
        
        filterBtn.setTitle("Filter", for: .normal)
        filterBtn.setTitleColor(.white, for: .normal)
        filterBtn.backgroundColor = .systemTeal
        filterBtn.layer.cornerRadius = 8
        view.addSubview(filterBtn)
        
        tableView.register(iNrfScanCell.self, forCellReuseIdentifier: "nrfcell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .none
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.viewModel.startScan()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: DispatchWorkItem(block: {
                self?.viewModel.stopScan()
                self?.tableView.mj_header?.endRefreshing()
            }))
        })
        view.addSubview(tableView)
        
        filterBtn.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(8)
            make.right.equalToSuperview().inset(16)
            make.height.equalTo(36)
            make.width.equalTo(88)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterBtn.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-8)
        }
    }
    
    private func bindVM() {
        viewModel.devicesDriver
            .drive(tableView.rx.items(cellIdentifier: "nrfcell", cellType: iNrfScanCell.self)) { [weak self] _, item, cell in
                cell.configure(with: item)
                cell.onConnect = { [weak self] in 
                    self?.viewModel.connect(item)
                    self?.viewModel.stopScan()
                }
                cell.onHeightChanged = { [weak self] in
                    self?.tableView.performBatchUpdates(nil, completion: nil)
                }
            }
            .disposed(by: bag)
        
        tableView.rx.modelSelected(DiscoveredDevice.self)
            .subscribe(onNext: { [weak self] device in
                guard let self = self else { return }
                if device.peripheral.state == .connected {
                    let vc = NrfDetailsViewController()
                    // 传递外设引用
                    if let nav = self.navigationController {
                        vc.hidesBottomBarWhenPushed = true
                        // NrfDetailsViewController 将通过 InrfBleManager 使用该外设继续发现服务/特征
                        vc.setPeripheral(device.peripheral)
                        nav.pushViewController(vc, animated: true)
                    }
                }
            })
            .disposed(by: bag)
        
        filterBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let popup = NRFFilterPopupView()
                popup.onConfirm = { [weak self] name, opt in
                    self?.viewModel.filterNameRelay.accept(name)
                    let mapped: NRFViewModel.SortOption = (opt == .rssiDesc) ? .rssiDesc : .nameAsc
                    self?.viewModel.sortRelay.accept(mapped)
                    self?.viewModel.startScan()
                }
                popup.onCancel = { }
                self.view.addSubview(popup)
                popup.snp.makeConstraints { make in make.edges.equalToSuperview() }
            })
            .disposed(by: bag)
        
        viewModel.scanTimeoutDriver
            .drive(onNext: { [weak self] in
                self?.viewModel.stopScan()
            })
            .disposed(by: bag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopScan()
    }
}
