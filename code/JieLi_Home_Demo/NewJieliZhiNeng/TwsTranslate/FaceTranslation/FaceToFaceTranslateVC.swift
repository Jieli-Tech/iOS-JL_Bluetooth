//
//  FaceToFaceTranslateVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/27.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class FaceToFaceTranslateVC: BasicViewController {
    private let headerView = TimeHeaderView()
    private let tipsView = FaceToFaceStartTipsView()
    private let chatView = ChatDialogView()
    private let bottomView = FaceToFaceTraBottomView()
    private let disposeBag = DisposeBag()
    private let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0

    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(tipsView)
        view.addSubview(chatView)
        view.addSubview(bottomView)

        headerView.configImage(R.Image.img("translation_icon_our"), R.Image.img("translation_icon_phone"))
        headerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(naviView.snp.centerY).offset(10)
        }

        tipsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(headerView.snp.bottom).offset(5)
        }

        chatView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom).offset(5)
            make.width.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }

        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(80 + bottomInset)
            make.bottom.equalToSuperview()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        chatView.messages.accept(ChatDialogView.sampleFaceToFaceMessages())
//        tipsView.snp.remakeConstraints { make in
//            make.height.equalTo(0)
//        }
    }
}
