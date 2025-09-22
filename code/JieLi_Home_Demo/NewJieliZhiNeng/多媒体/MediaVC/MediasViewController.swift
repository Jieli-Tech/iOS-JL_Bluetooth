//
//  MediasViewController.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/11/29.
//  Copyright © 2023 杰理科技. All rights reserved.
//

import UIKit

class MediasViewController: UIViewController {

    let funcsView = MediasFuncsView()
    let existBtn = UIButton()
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(existBtn)
        existBtn.setImage(R.Image.img("Theme.bundle/icon_return"), for: .normal)
        existBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).inset(10)
            make.width.equalTo(60)
            make.height.equalTo(35)
        }
        
        view.addSubview(funcsView)
        funcsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(400)
            make.bottom.equalToSuperview()
        }
        
        existBtn.rx.tap.subscribe { [weak self](_) in
            self?.dismiss(animated: true, completion: nil)
        }.disposed(by: disposeBag)
    }
    
    

}



