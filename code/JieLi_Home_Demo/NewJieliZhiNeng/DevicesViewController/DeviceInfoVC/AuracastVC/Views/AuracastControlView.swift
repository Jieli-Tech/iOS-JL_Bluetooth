//
//  AuracastControlView.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/12.
//

import UIKit
import JL_BLEKit

class AuracastControlView: BasicView {
    private weak var _deviceVM: DeviceInfoViewModel?
    private let onOffBtn = UISwitch()
    private let imgv = UIImageView()
    private var timeID: String = ""
    var deviceVm: DeviceInfoViewModel? {
        get {
            return _deviceVM
        }
        set {
            _deviceVM = newValue
            _deviceVM?.isScaningSubject.subscribe { [weak self] element in
                guard let self = self else {
                    return
                }
                if element {
                    self.onOffBtn.isOn = true
                } else {
                    self.onOffBtn.isOn = false
                }
            }.disposed(by: disposeBag)
        }
    }

    override func initUI() {
        super.initUI()
        addSubview(imgv)
        addSubview(onOffBtn)
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.masksToBounds = true

        imgv.image = RResources.image.logo_new()!
        onOffBtn.isOn = false
        onOffBtn.onTintColor = RResources.color.switchColor()!

        imgv.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        onOffBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        onOffBtn.rx.controlEvent(.valueChanged).subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.onOffBtn.isOn {
                self.deviceVm?.onScan()
            }else{
                self.deviceVm?.onStopScan()
            }
            if self.onOffBtn.isOn {
                JLEcTimerHelper.stopTimer(self.timeID)
                self.timeID = JLEcTimerHelper.startTimer(withTimeout: 60) { _ in
                    self.deviceVm?.onStopScan()
                }
            }
        }).disposed(by: disposeBag)
    }
}
