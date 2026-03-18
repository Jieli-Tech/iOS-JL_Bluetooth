//
//  AIInfoHelperViewController.swift
//  WatchTest
//
//  Created by EzioChan on 2023/11/30.
//

import UIKit

class AIInfoHelperViewController: BaseViewController, JLAIManagerDelegate {
    let aiHelper = JLAiManager()
    let readAiInfoBtn = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        aiHelper.delegate = self
    }

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.aiInfoHelper()
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        view.addSubview(readAiInfoBtn)
        readAiInfoBtn.setTitle(R.localStr.readAIPlatformInformation(), for: .normal)
        readAiInfoBtn.backgroundColor = UIColor.random()
        readAiInfoBtn.setTitleColor(UIColor.white, for: .normal)
        readAiInfoBtn.layer.cornerRadius = 10
        readAiInfoBtn.clipsToBounds = true
        readAiInfoBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.height.equalTo(35)
        }
    }

    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)

        readAiInfoBtn.rx.tap.subscribe { [weak self] _ in
            guard let manager = BleManager.shared.currentCmdMgr else { return }
            self?.aiHelper.getOpenPlatformInfo(manager, result: { message, _ in
                message.logProperties()
            })
        }.disposed(by: disposeBag)
    }

    func jlaiUpdateStatus(_: JLAiManager) {}

    func jlaiUpdateDevAiOpenPlatforms(_: JLAiManager, info: JLOpenPlatformMessage) {
        info.logProperties()
    }
}
