//
//  ToolViewSpdifView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2024/10/16.
//  Copyright © 2024 杰理科技. All rights reserved.
//

import UIKit

class ToolViewSpdifView: SwBasicView{
    private let ppBtn = UIButton()
    private let hdmiBtn = UIButton()
    private let foBtn = UIButton()
    private let coaxialBtn = UIButton()
    private let hdmiLabel  = UILabel()
    private let fiberLabel = UILabel()
    private let coaxialLabel = UILabel()
    
    override func initUI() {
        super.initUI()
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        
        addSubview(ppBtn)
        addSubview(hdmiBtn)
        addSubview(foBtn)
        addSubview(coaxialBtn)
        addSubview(hdmiLabel)
        addSubview(fiberLabel)
        addSubview(coaxialLabel)
        
        ppBtn.setImage(UIImage(named: "spdif_icon_play"), for: .normal)
        hdmiBtn.setImage(UIImage(named: "spdif_icon_hdmi_nor"), for: .normal)
        foBtn.setImage(UIImage(named: "spdif_icon_guangxian_nor"), for: .normal)
        coaxialBtn.setImage(UIImage(named: "spdif_icon_tongzhou_nor"), for: .normal)
        
        hdmiLabel.text = R.Language.lan("hdmi")
        hdmiLabel.textColor = UIColor.eHex("#E6000000")
        hdmiLabel.font = R.Font.medium(13)
        hdmiLabel.textAlignment = .center
        
        fiberLabel.text = R.Language.lan("optical_fiber")
        fiberLabel.textColor = UIColor.eHex("#E6000000")
        fiberLabel.font =  R.Font.medium(13)
        fiberLabel.textAlignment = .center
        
        coaxialLabel.text = R.Language.lan("coaxial")
        coaxialLabel.textColor = UIColor.eHex("#E6000000")
        coaxialLabel.font =  R.Font.medium(13)
        coaxialLabel.textAlignment = .center
        
        ppBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(40)
            make.width.equalTo(96)
        }
        hdmiBtn.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalTo(foBtn)
            make.left.equalToSuperview().inset(38)
        }
        
        foBtn.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(30)
        }
        
        coaxialBtn.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalTo(foBtn)
            make.right.equalToSuperview().inset(38)
        }
        
        hdmiLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(41)
            make.centerY.equalTo(fiberLabel)
        }
        
        fiberLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(76)
        }
        
        coaxialLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(45)
            make.centerY.equalTo(fiberLabel)
        }
    }
    
    override func initData() {
        super.initData()
        LanguageCls.share().add(self)

        ppBtn.rx.tap.subscribe { _ in
            SpdifPcViewModel.share.setSpdifPlayStatus()
        }.disposed(by: disposeBag)
        
        hdmiBtn.rx.tap.subscribe { _ in
            SpdifPcViewModel.share.setSpdifAudioType(.HDMI)
        }.disposed(by: disposeBag)
        
        foBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else {return}
            SpdifPcViewModel.share.setSpdifAudioType(.FO)
        }.disposed(by: disposeBag)
        
        coaxialBtn.rx.tap.subscribe { [weak self] _ in
            guard let `self` = self else {return}
            SpdifPcViewModel.share.setSpdifAudioType(.coaxial)
        }.disposed(by: disposeBag)
        
        SpdifPcViewModel.share.spdifModelListen.subscribe() { [weak self] model in
            guard let `self` = self else {return}
            self.coaxialBtn.setImage(UIImage(named: "spdif_icon_tongzhou_nor"), for: .normal)
            self.foBtn.setImage(UIImage(named: "spdif_icon_guangxian_nor"), for: .normal)
            self.hdmiBtn.setImage(UIImage(named: "spdif_icon_hdmi_nor"), for: .normal)
            
            if model.playStatus {
                self.ppBtn.setImage(UIImage(named: "spdif_icon_pause"), for: .normal)
            }else{
                self.ppBtn.setImage(UIImage(named: "spdif_icon_play"), for: .normal)
            }
            switch model.audioType {
            case .HDMI:
                self.hdmiBtn.setImage(UIImage(named: "spdif_icon_hdmi_sel"), for: .normal)
            case .FO:
                self.foBtn.setImage(UIImage(named: "spdif_icon_guangxian_sel"), for: .normal)
            case .coaxial:
                self.coaxialBtn.setImage(UIImage(named: "spdif_icon_tongzhou_sel"), for: .normal)
            default:
                break
            }
        }.disposed(by: disposeBag)
    }
}

extension ToolViewSpdifView:LanguagePtl{
    func languageChange() {
        initUI()
    }
}
