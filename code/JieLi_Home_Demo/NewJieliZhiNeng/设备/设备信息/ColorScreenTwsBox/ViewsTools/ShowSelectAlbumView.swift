//
//  ShowSelectAlbumView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/12/6.
//  Copyright © 2023 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class ShowSelectAlbumView: BasicView {
    var selectBlock:((_ index:Int)->())?
    private let selectsView = UIView()
    private let photosBtn = UIButton()
    private let albumBtn = UIButton()
    private let lineView = UIView()
    private let cancelBtn = UIButton()
    private let bgView = UIView()
    private let lineView2 = UIView()
    
    override func initUI() {
        super.initUI()
        addSubview(bgView)
        addSubview(selectsView)
        selectsView.addSubview(photosBtn)
        selectsView.addSubview(albumBtn)
        selectsView.addSubview(lineView)
        addSubview(lineView2)
        addSubview(cancelBtn)
        lineView2.backgroundColor = UIColor.eHex("#F5F5F5")
        
        bgView.backgroundColor = UIColor.eHex("#000000", alpha: 0.2)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectsView.backgroundColor = UIColor.white
        selectsView.layer.cornerRadius = 11
        selectsView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        selectsView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(cancelBtn.snp.top).offset(-8)
            make.height.equalTo(114)
        }
        
        photosBtn.setTitle(R.Language.lan("Take Photo"), for: .normal)
        photosBtn.setTitleColor(UIColor.eHex("#333333"), for: .normal)
        photosBtn.setTitleColor(UIColor.eHex("#333333",alpha: 0.8), for: .highlighted)
        photosBtn.titleLabel?.font = R.Font.medium(18)
        photosBtn.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(57)
        }
        
        albumBtn.setTitle(R.Language.lan("Choose From Album"), for: .normal)
        albumBtn.setTitleColor(UIColor.eHex("#333333"), for: .normal)
        albumBtn.setTitleColor(UIColor.eHex("#333333",alpha: 0.8), for: .highlighted)
        albumBtn.titleLabel?.font = R.Font.medium(18)
        albumBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(57)
            make.top.equalTo(photosBtn.snp.bottom)
        }
        
        lineView.backgroundColor = UIColor.eHex("#E5E5E5")
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.centerY.equalToSuperview()
        }
        
        lineView2.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(selectsView.snp.bottom)
            make.bottom.equalTo(cancelBtn.snp.top)
        }
        cancelBtn.setTitle(R.Language.lan("Cancel"), for: .normal)
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.setTitleColor(UIColor.eHex("#333333"), for: .normal)
        cancelBtn.setTitleColor(UIColor.eHex("#333333",alpha: 0.8), for: .highlighted)
        cancelBtn.titleLabel?.font = R.Font.medium(18)
        cancelBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(57)
            make.bottom.equalToSuperview()
        }

    }
    
    override func initData() {
        super.initData()
        LanguageCls.share().add(self)
        
        photosBtn.rx.tap.subscribe{ [weak self] _ in
            self?.selectBlock?(0)
        }.disposed(by: disposeBag)
        
        albumBtn.rx.tap.subscribe{ [weak self] _ in
            self?.selectBlock?(1)
        }.disposed(by: disposeBag)
        
        cancelBtn.rx.tap.subscribe{ [weak self] _ in
            self?.selectBlock?(2)
        }.disposed(by: disposeBag)
        
    }
    
}

extension ShowSelectAlbumView:LanguagePtl{
    func languageChange() {
        initUI()
    }
}
    
