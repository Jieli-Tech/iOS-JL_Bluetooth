//
//  EQSettingViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/1.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JL_BLEKit
import RxSwift
import RxCocoa
import SnapKit

class EQSettingViewController: BaseViewController {
    
    // MARK: - UI Components
    private lazy var eqSettingView: EQSettingView = {
        let view = EQSettingView()
        view.delegate = self
        return view
    }()
    
    // MARK: - Properties
    private var mManager: JL_ManagerM?
    private var mSystemEQ: JL_SystemEQ?
    private var eqFrequencies: [String] = []
    private var eqModeObservation: NSKeyValueObservation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initData()
    }
    
    // MARK: - UI Setup
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.eqSetting()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        
        view.addSubview(eqSettingView)
        eqSettingView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Data Initialization
    override func initData() {
        super.initData()
        
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
        
        // 引用EQ数据类
        mManager = BleManager.shared.currentCmdMgr
        mSystemEQ = BleManager.shared.currentCmdMgr?.mSystemEQ
        
        mSystemEQ?.cmdGet { [weak self] status, model in
            if status == .success, let model = model {
                JL_Tools.mainTask {
                    self?.setupEQUI(with: model)
                }
            }
        }
        
        // delegate 监听 EQ 数据变更（设备主动推送 / cmdSetSystemEQ 响应）
        mSystemEQ?.delegate = self
        
        // KVO 监听 eqMode 变更（演示：delegate + KVO 两种方式并存）
        eqModeObservation = mSystemEQ?.observe(\.eqMode, options: [.new]) { [weak self] _, change in
            guard let self = self, let newMode = change.newValue else { return }
            JL_Tools.mainTask {
                self.eqSettingView.updateEQName(self.updateEqName(model: newMode))
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mSystemEQ?.delegate = nil
        eqModeObservation?.invalidate()
    }
    
    // MARK: - EQ Setup
    private func setupEQUI(with systemEQ: JL_SystemEQ) {
        // 获取频率数组
        eqFrequencies = systemEQ.eqFrequencyArray.map { "\($0)" }
        let eqCount = systemEQ.eqArray.count
        
        // 动态设置 Slider 数量
        eqSettingView.setupSliders(count: eqCount, frequencies: eqFrequencies)
        
        // 更新 UI
        updateEQUI(with: systemEQ)
    }
    
    private func updateEQUI(with systemEQ: JL_SystemEQ) {
        eqSettingView.updateEQName(updateEqName(model: systemEQ.eqMode))
        
        guard systemEQ.eqArray.count > 0 else { return }
        
        let eqValues = systemEQ.eqArray.compactMap { Float(truncating: $0 as! NSNumber) }
        
        eqSettingView.updateAllSliders(with: eqValues)
        
        for i in 0..<eqValues.count {
            eqSettingView.updateSliderColor(at: i, color: .compatibleLink)
        }
        
        if systemEQ.eqMode == .CUSTOM {
            eqSettingView.setAllSlidersEnabled(true)
        }
    }
    
    private func updateEqName(model: JL_EQMode) -> String {
        switch model {
        case .NORMAL: return R.localStr.natural()
        case .ROCK: return R.localStr.rock()
        case .POP: return R.localStr.pop()
        case .CLASSIC: return R.localStr.classic()
        case .JAZZ: return R.localStr.jazz()
        case .COUNTRY: return R.localStr.country()
        case .CUSTOM: return R.localStr.custom()
        case .LATIN: return R.localStr.latin()
        case .DANCE: return R.localStr.dance()
        default: return ""
        }
    }
    
    // MARK: - EQ Actions
    private func onSelectFrq() {
        let values = eqSettingView.getSliderValues()
        let count = mSystemEQ?.eqArray.count ?? 0
        let eqArr = values.prefix(count).map { NSNumber(value: Int($0)) }
        mSystemEQ?.cmdSetSystemEQ(.CUSTOM, params: eqArr)
    }
    
    private func onSelectEQ(mode: JL_EQMode) {
        eqSettingView.updateEQName(updateEqName(model: mode))
        mSystemEQ?.cmdSetSystemEQ(mode, params: nil)
        
        JL_Tools.delay(1.0) { [weak self] in
            self?.mSystemEQ?.cmdGet { [weak self] status, model in
                if status == .success, let model = model {
                    JL_Tools.mainTask {
                        // 重新设置 Slider 数量（可能设备返回的 EQ 数量不同）
                        self?.setupEQUI(with: model)
                    }
                }
            }
        }
    }
}

// MARK: - EQSettingViewDelegate
extension EQSettingViewController: EQSettingViewDelegate {
    func eqSettingView(_ view: EQSettingView, didChangeSliderAt index: Int, value: Float) {
        onSelectFrq()
    }
    
    func eqSettingView(_ view: EQSettingView, didSelectEQModeAt index: Int) {
        let eqModes: [JL_EQMode] = [.NORMAL, .ROCK, .POP, .CLASSIC, .JAZZ, .COUNTRY, .CUSTOM, .LATIN, .DANCE]
        guard index >= 0 && index < eqModes.count else { return }
        onSelectEQ(mode: eqModes[index])
    }
}

// MARK: - JL_SystemEQDelegate
extension EQSettingViewController: JL_SystemEQDelegate {
    func jlSystemEQDidUpdate(_ systemEQ: JL_SystemEQ) {
        JL_Tools.mainTask { [weak self] in
            guard let self = self else { return }
            self.eqSettingView.updateEQName(self.updateEqName(model: systemEQ.eqMode))
            self.updateEQUI(with: systemEQ)
        }
    }
}
