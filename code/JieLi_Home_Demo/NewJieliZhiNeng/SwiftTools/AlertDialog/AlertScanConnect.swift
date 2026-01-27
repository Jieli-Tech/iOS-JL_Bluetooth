//
//  AlertScanConnect.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/11/4.
//

import UIKit

class AlertScanConnect: BasicView {
    private let titleLab = UILabel()
    private let centerView = UIView()
    private let bgView = UIView()
    private let loadingView = UIActivityIndicatorView()
    private var timer: Timer?
    private var maxCount: TimeInterval = 10
    private var currentCount = 0
    private var deviceName = ""

    override func initUI() {
        super.initUI()
        addSubview(bgView)
        addSubview(centerView)
        centerView.addSubview(titleLab)
        centerView.addSubview(loadingView)

        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 16
        centerView.layer.masksToBounds = true

        titleLab.text = R.localStr.device_connecting()
        titleLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLab.textColor = R.color.fontBackText242424()
        titleLab.textAlignment = .center
        titleLab.numberOfLines = 0
        titleLab.adjustsFontSizeToFitWidth = true

        loadingView.color = .gray
        if #available(iOS 13.0, *) {
            loadingView.style = .large
        }
        loadingView.startAnimating()

        bgView.backgroundColor = .black
        bgView.alpha = 0.1

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        centerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(50)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        loadingView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
        }

        titleLab.snp.makeConstraints { make in
            make.top.equalTo(loadingView.snp.bottom).offset(24)
            make.left.right.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(20)
        }
    }

    func show(_ title: String, _ deviceName: String, _: TimeInterval) {
        titleLab.text = title
        AlertManager.windows()?.addSubview(self)
        isHidden = false
        startTimeOut()
        self.deviceName = deviceName
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func hidden() {
        currentCount = 0
        removeFromSuperview()
        isHidden = true
    }

    private func startTimeOut() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            self.currentCount += 1
            if self.currentCount == Int(self.maxCount) {
                self.timer?.invalidate()
                self.timer = nil
                self.hidden()
                AlertManager.showReceiveBroadcastFailed(self.deviceName)
            }
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
}
