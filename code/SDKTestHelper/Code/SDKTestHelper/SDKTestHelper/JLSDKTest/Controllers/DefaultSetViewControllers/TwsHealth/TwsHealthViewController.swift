//
//  TwsHealthViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/10.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TwsHealthViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let bag = DisposeBag()
    private let vm = TwsHealthViewModel()
    private let statusStack = UIStackView()
    private let healthInfoLabel = UILabel()
    private let sensorStatusLabel = UILabel()
    private let realTimeStepLabel = UILabel()
    private let dailyHeartLabel = UILabel()

    enum Item: CaseIterable {
        case readConfig
        case checkSensors
        case startHeart
        case cancelHeart
        case startSpO2
        case cancelSpO2
        case startStep
        case cancelStep
        case startDailyHeart
        case endDailyHeart
        case queryRealStep
        case loopRealStep
        case cancelLoopStep

        var title: String {
            switch self {
            case .readConfig: return R.localStr.readHealthCapability()
            case .checkSensors: return R.localStr.checkSensorStatus()
            case .startHeart: return R.localStr.startHeartRate()
            case .cancelHeart: return R.localStr.cancelHeartRate()
            case .startSpO2: return R.localStr.startBloodOxygen()
            case .cancelSpO2: return R.localStr.cancelBloodOxygen()
            case .startStep: return R.localStr.startStepCount()
            case .cancelStep: return R.localStr.cancelStepCount()
            case .startDailyHeart: return R.localStr.startDailyHeartSync()
            case .endDailyHeart: return R.localStr.endDailyHeartSync()
            case .queryRealStep: return R.localStr.queryRealTimeStep()
            case .loopRealStep: return R.localStr.setStepPollingInterval()
            case .cancelLoopStep: return R.localStr.cancelStepPolling()
            }
        }
    }

    private let items = Item.allCases

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.twsHealth()
        statusStack.axis = .vertical
        statusStack.spacing = 8
        view.addSubview(statusStack)
        [healthInfoLabel, sensorStatusLabel, realTimeStepLabel, dailyHeartLabel].forEach { lbl in
            lbl.numberOfLines = 0
            lbl.font = .systemFont(ofSize: 14)
            statusStack.addArrangedSubview(lbl)
        }
        statusStack.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(statusStack.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

        bindVM()
    }

    private func bindVM() {
        vm.healthConfigSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] cfg in
                guard let self = self, let cfg = cfg else { return }
                let msg =  R.localStr.deviceHealthCapability() + ": " + "\(cfg)"
                self.healthInfoLabel.text = msg
            }).disposed(by: bag)

        vm.sensorStatusSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] st in
                guard let self = self, let st = st else { return }
                let msg = "\(R.localStr.heartRate()): \(st.heart ? R.localStr.on() : R.localStr.off())\n\(R.localStr.spo2()): \(st.spO2 ? R.localStr.on() : R.localStr.off())\n\(R.localStr.stepCount()): \(st.step ? R.localStr.on() : R.localStr.off())\n\(R.localStr.inEar()): \(st.inEar ? R.localStr.insideTheEar() : R.localStr.outsideTheEar())"
                self.sensorStatusLabel.text = R.localStr.sensorStatus() + ":\n" + msg
            }).disposed(by: bag)

        vm.opFeedbackSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.showToast(text)
            }).disposed(by: bag)

        vm.stepSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] step in
                if let self = self {
                    let msg = R.localStr.realTimeStep() + ": " + R.localStr.stepCount() + "\(step)"
                    self.realTimeStepLabel.text = msg
                }
            }).disposed(by: bag)

        vm.dailyHeartSubject
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] model in
                if let self = self {
                    let msg = R.localStr.dailyHeartRate() + ": " + "\(model)"
                    self.dailyHeartLabel.text = msg
                }
            }).disposed(by: bag)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch items[indexPath.row] {
        case .readConfig: vm.readHealthConfig()
        case .checkSensors: vm.checkSensorStatus()
        case .startHeart: vm.startHeartRate()
        case .cancelHeart: vm.cancelHeartRate()
        case .startSpO2: vm.startSpO2()
        case .cancelSpO2: vm.cancelSpO2()
        case .startStep: vm.startStep()
        case .cancelStep: vm.cancelStep()
        case .startDailyHeart: vm.startDailyHeartSync()
        case .endDailyHeart: vm.endDailyHeartSync()
        case .queryRealStep: vm.queryRealStep()
        case .loopRealStep:
            promptInterval { [weak self] sec in
                self?.vm.loopQuery(intervalSec: sec)
            }
        case .cancelLoopStep: vm.cancelLoopQuery()
        }
    }

    private func promptInterval(completion: @escaping (TimeInterval) -> Void) {
        let alert = UIAlertController(title: R.localStr.setPollingInterval(), message: R.localStr.recommendedWithin300Seconds(), preferredStyle: .alert)
        alert.addTextField { tf in
            tf.keyboardType = .numberPad
            tf.placeholder = R.localStr.example240()
        }
        alert.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: R.localStr.oK(), style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text, let v = TimeInterval(text), v > 0 {
                completion(v)
            }
        }))
        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.localStr.oK(), style: .default, handler: nil))
        present(alert, animated: true)
    }

    private func showToast(_ text: String) {
        let label = UILabel()
        label.text = text
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        label.numberOfLines = 0
        label.layer.cornerRadius = 8
        label.clipsToBounds = true
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            make.width.lessThanOrEqualTo(view.snp.width).multipliedBy(0.8)
        }
        UIView.animate(withDuration: 0.25, animations: {
            label.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 1.5, options: [], animations: {
                label.alpha = 0
            }) { _ in
                label.removeFromSuperview()
            }
        }
    }
}
