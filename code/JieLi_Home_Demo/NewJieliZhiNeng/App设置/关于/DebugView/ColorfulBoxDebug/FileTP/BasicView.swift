//
//  BasicView.swift
//  IPCLink
//
//  Created by EzioChan on 2023/4/4.
//  Copyright © 2023 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift



protocol BasicViewLiveAble{
    func viewWillLoad()
    func viewWillClose()
}


@objcMembers class BasicView: UIView {

    public let disposeBag = DisposeBag()
    let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    
    open weak var contextView:UIViewController?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initData()
        initUI()
    }
    
    public init() {
        super.init(frame: CGRectZero)
        initData()
        initUI()
    }
    
    open func initUI(){
        
    }
    
    open func initData(){
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}


@objcMembers class NaviView:BasicView{
    public let bgView = UIView()
    public let leftBtn = UIButton()
    public let rightBtn = UIButton()
    public let titleLab = UILabel()
    open var bgColor = UIColor.eHex("#FFFFFF")
    
    var title:String {
        get{
            titleLab.text ?? ""
        }
        set{
            titleLab.text = newValue
        }
    }
    
    override func initUI() {
    
        self.addSubview(bgView)
        self.addSubview(leftBtn)
        self.addSubview(titleLab)
        self.addSubview(rightBtn)
        bgView.backgroundColor = bgColor
        
        rightBtn.titleLabel?.font = R.Font.medium(15)
        rightBtn.setTitleColor(UIColor.eHex("#242424"), for: .normal)
        rightBtn.isHidden = true
        
        
        leftBtn.titleLabel?.font = R.Font.medium(15)
        leftBtn.setImage(UIImage(named: "Theme.bundle/icon_return"), for: .normal)
        leftBtn.setTitleColor(UIColor.eHex("#242424"), for: .normal)
        
        titleLab.font = UIFont.boldSystemFont(ofSize: 18)
        titleLab.textColor = UIColor.black
        titleLab.textAlignment = .center
        titleLab.adjustsFontSizeToFitWidth = true
        
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        leftBtn.snp.makeConstraints { make in
            make.left.bottom.equalTo(self).inset(6)
            make.height.equalTo(35)
            make.width.equalTo(45)
        }
        titleLab.snp.makeConstraints { make in
            make.centerY.equalTo(leftBtn.snp.centerY)
            make.height.equalTo(35)
            make.centerX.equalTo(self)
        }
        
        rightBtn.snp.makeConstraints { make in
            make.bottom.equalTo(self).inset(6)
            make.right.equalToSuperview().inset(10)
            make.height.width.equalTo(35)
        }
        
    }
}

