//
//  ToolViewPCView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2024/10/16.
//  Copyright © 2024 杰理科技. All rights reserved.
//

import UIKit

class ToolViewPCView: SwBasicView {
    private let nextBtn = UIButton()
    private let previousBtn = UIButton()
    private let ppBtn = UIButton()
    override func initUI() {
        super.initUI()
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        self.addSubview(nextBtn)
        self.addSubview(previousBtn)
        self.addSubview(ppBtn)
        
        nextBtn.setImage(UIImage(named: "mul_icon_last_02"), for: .normal)
        previousBtn.setImage(UIImage(named: "mul_icon_previous_02"), for: .normal)
        ppBtn.setImage(UIImage(named: "pc_icon_play"), for: .normal)
        
        nextBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(60)
            make.width.height.equalTo(40)
        }
        previousBtn.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(60)
        }
        
        ppBtn.snp.makeConstraints { make in
            make.width.height.equalTo(56)
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    override func initData() {
        super.initData()
        nextBtn.rx.tap.subscribe { [weak self] _ in
            guard self != nil else {return}
            SpdifPcViewModel.share.pcNextOrPrivious(.next)
        }.disposed(by: disposeBag)
        
        previousBtn.rx.tap.subscribe { [weak self] _ in
            guard self != nil else {return}
            SpdifPcViewModel.share.pcNextOrPrivious(.previous)
        }.disposed(by: disposeBag)
        
        ppBtn.rx.tap.subscribe { [weak self] _ in
            guard self != nil else {return}
            SpdifPcViewModel.share.setPCPlayStatus()
        }.disposed(by: disposeBag)
        
        SpdifPcViewModel.share.pcServerModelListen.subscribe() { [weak self] model in
            guard let `self` = self else {return}
            if model.playStatus {
                self.ppBtn.setImage(UIImage(named: "pc_icon_pause"), for: .normal)
            }else{
                self.ppBtn.setImage(UIImage(named: "pc_icon_play"), for: .normal)
            }
        }.disposed(by: disposeBag)
    }
}
