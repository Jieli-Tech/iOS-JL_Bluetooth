//
//  TraSelectRecordView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/28.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class TraSelectRecordView: BasicView {

    let allRecordBtn = UIButton()
    let dateSelectBtn = UIButton()
    
    override func initUI() {
        super.initUI()
        backgroundColor = .white
        
        allRecordBtn.setTitle(LanguageCls.localizableTxt("All records"), for: .normal)
        allRecordBtn.setTitleColor(.eHex("#000000", alpha: 0.6), for: .normal)
        allRecordBtn.titleLabel?.font = R.Font.medium(14)
        allRecordBtn.setImage(R.Image.img("record_icon_down"), for: .normal)
        allRecordBtn.layoutLeftTitleRightImage()
        
        dateSelectBtn.setTitle("2025-06-01", for: .normal)
        dateSelectBtn.setTitleColor(.eHex("#000000", alpha: 0.6), for: .normal)
        dateSelectBtn.titleLabel?.font = R.Font.medium(14)
        dateSelectBtn.setImage(R.Image.img("record_icon_down"), for: .normal)
        dateSelectBtn.layoutLeftTitleRightImage()
        
        addSubview(allRecordBtn)
        addSubview(dateSelectBtn)
        
        allRecordBtn.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(dateSelectBtn.snp.left)
            make.width.equalTo(dateSelectBtn)
        }
        dateSelectBtn.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(allRecordBtn.snp.right)
            make.width.equalTo(allRecordBtn)
        }
        
    }

}
