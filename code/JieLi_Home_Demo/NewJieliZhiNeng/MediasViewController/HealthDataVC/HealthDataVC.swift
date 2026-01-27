//
//  HealthDataVC.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/13.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class HealthDataVC: BasicViewController {
    
    private let subTable = UITableView()
    private var itemsArray = BehaviorRelay<[HealthDataCellMode]>(value: [])
    private var disposeBag = DisposeBag()
    
    override func initData() {
        super.initData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    override func initUI() {
        super.initUI()
        naviView.titleLab.text = LanguageCls.localizableTxt("Health")
        subTable.separatorStyle = .none
        subTable.backgroundColor = .clear
        subTable.rowHeight = UITableView.automaticDimension
        subTable.estimatedRowHeight = 90
        subTable.register(HealthDataTableCell.self, forCellReuseIdentifier: HealthDataTableCell.identifier)
        view.addSubview(subTable)
        subTable.snp.makeConstraints { make in
            make.top.equalTo(naviView.snp.bottom).offset(7)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }
        bindAction()
    }

    private func updateData() {
        // 查询数据库，获取今日的步数累计、心率与血氧最新记录的平均值
        let today = Date()
        // 1) 步数：查询今天的所有记录并计算累计值
        let stepsEntries = HealthDataBase.shared.querySteps(onDay: today)
        let totalStepsDouble = stepsEntries.reduce(0.0) { partial, entry in
            partial + entry.steps
        }
        let totalSteps = Int(totalStepsDouble)

        // 2) 心率：获取今天最后一条记录的平均值
        let heartEntries = HealthDataBase.shared.queryHeartRate(onDay: today)
        let lastHeartAvg: Int = {
            guard let last = heartEntries.last else { return 0 }
            return Int(last.averageBpm)
        }()

        // 3) 血氧：获取今天最后一条记录的平均值
        let spoEntries = HealthDataBase.shared.querySpO2(onDay: today)
        let lastSpoAvg: Int = {
            guard let last = spoEntries.last else { return 0 }
            return Int(last.averagePercent)
        }()

        // 更新展示数据
        itemsArray.accept([
            HealthDataCellMode(icon: R.Image.img("health_icon_record"), type: .step, value: String(totalSteps)),
            HealthDataCellMode(icon: R.Image.img("health_icon_heart"), type: .heart, value: String(lastHeartAvg)),
            HealthDataCellMode(icon: R.Image.img("health_icon_spo"), type: .blood, value: String(lastSpoAvg)),
        ])
    }
    
    private func bindAction() {
        itemsArray.bind(to: subTable.rx.items(cellIdentifier: HealthDataTableCell.identifier, cellType: HealthDataTableCell.self)) { _, model, cell in
            cell.setCell(model)
        }.disposed(by: disposeBag)
        
        subTable.rx.modelSelected(HealthDataCellMode.self).subscribe(onNext: { [weak self] model in
            switch model.type {
            case .step:
                let vc = HealthStepsVC()
                self?.navigationController?.pushViewController(vc, animated: true)
            case .heart:
                let vc = HeartRateVC()
                self?.navigationController?.pushViewController(vc, animated: true)
            case .blood:
                let vc = SpO2ViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            self?.subTable.reloadData()
        }).disposed(by: disposeBag)
    }

}
