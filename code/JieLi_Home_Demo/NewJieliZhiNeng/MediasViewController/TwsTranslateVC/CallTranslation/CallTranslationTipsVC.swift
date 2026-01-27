//
//  CallTranslationTipsVC.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/18.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class CallTranslationTipsVC: BasicViewController {
    static let statusIdentifier = "CallTranslationTipsVC"
    private let headerView = TimeHeaderView()
    private let centerView = CallTransTipsView()
    private let disposeBag = DisposeBag()
    
    override func initUI() {
        super.initUI()
        naviView.isHidden = true
        view.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalTo(naviView.snp.bottom)
        }
        
        view.addSubview(centerView)
        centerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func initData() {
        super.initData()
        let languages = TranslateTools.getLanguages(.call)
        headerView.configText(languages.0.title(), languages.1.title())
        centerView.confirmBtn.rx.tap.subscribe(onNext: { [weak self]  in
            guard let self = self else { return }
            TranslateVM.shared.setMode(type: .call) { _, err in
                if err != nil {
                    self.view.makeToast(err?.localizedDescription ?? "")
                    return
                }
                let vc = CallTranslationVC()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }).disposed(by: disposeBag)
    }
    
    static func shouldShowTips() ->Bool {
        return !UserDefaults.standard.bool(forKey: CallTranslationTipsVC.statusIdentifier)
    }

}
