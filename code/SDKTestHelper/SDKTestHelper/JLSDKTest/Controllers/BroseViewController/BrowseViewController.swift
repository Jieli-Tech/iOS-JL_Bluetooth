//
//  BroseViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/6/19.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class BrowseViewController: BaseViewController {
    let browseView = DocumentBrowserView(initialPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first)
    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.localFileBrowsing()
        navigationView.rightBtn.isHidden = true
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        browseView.contextView = self
        view.addSubview(browseView)
        browseView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    override func initData() {
        super.initData()
        navigationView.leftBtn.rx.tap.subscribe() { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
}
