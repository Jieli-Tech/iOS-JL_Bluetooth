//
//  StreamTransferViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/4/14.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import JL_BLEKit

class StreamTransferViewController: BaseViewController {

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    
    private let previewView = StreamPreviewView()
    private let peripheralListView = PeripheralListContainerView()
    private let configPanelView = StreamConfigPanelView()
    private let controlPanelView = StreamControlPanelView()
    
    private var viewModel: StreamTransferViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationView.title = "流媒体传输 (Stream)"
        navigationView.leftBtn.setTitle("返回", for: .normal)
        
        
        
        if let manager = BleManager.shared.currentCmdMgr {
            viewModel = StreamTransferViewModel(bleManager: manager)
        }else{
            JLLogManager.logLevel(.ERROR, content: "当前设备未连接，无法进行流媒体传输")
        }
        
        setupUI()
        bindViewModel()
        
        // 页面加载后自动获取一次设备信息
        viewModel?.fetchDeviceInfoCommand.accept(())
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        scrollView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.width.equalToSuperview().offset(-32)
        }
        
        // 添加各个拆分的面板组件
        stackView.addArrangedSubview(previewView)
        stackView.addArrangedSubview(peripheralListView)
        stackView.addArrangedSubview(configPanelView)
        stackView.addArrangedSubview(controlPanelView)
        
        // 设置预览画面的固定比例或高度
        previewView.snp.makeConstraints { make in
            make.height.equalTo(240)
        }
    }
    
    private func bindViewModel() {
        navigationView.leftBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        // --- 绑定输入 (Inputs) ---
        guard let viewModel = viewModel else { return }
        // 刷新外设列表
        peripheralListView.refreshButton.rx.tap
            .bind(to: viewModel.fetchDeviceInfoCommand)
            .disposed(by: disposeBag)
        
        // 发起传输
        configPanelView.startButton.rx.tap
            .withLatestFrom(configPanelView.currentConfig)
            .compactMap { $0 }
            .bind(to: viewModel.startStreamCommand)
            .disposed(by: disposeBag)
        
        // 停止传输
        controlPanelView.stopButton.rx.tap
            .bind(to: viewModel.stopStreamCommand)
            .disposed(by: disposeBag)
        
        // --- 绑定输出 (Outputs) ---
        
        // 绑定外设列表数据
        peripheralListView.bind(peripheralsDriver: viewModel.peripherals)
        configPanelView.bind(peripheralsDriver: viewModel.peripherals)
        
        // 绑定预览画面
        previewView.bind(imageDriver: viewModel.currentFrameImage)
        
        // 绑定流媒体状态 (用于控制 UI 显示)
        controlPanelView.bind(statusDriver: viewModel.streamStatus)
        
        // 绑定弹窗提示信息
        viewModel.alertMessage
            .drive(onNext: { [weak self] message in
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

