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

protocol BasicViewLiveAble {
    func viewWillLoad()
    func viewWillClose()
}

class BaseView: UIView {

    public let disposeBag = DisposeBag()

    open weak var contextView: UIViewController?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initData()
        initUI()
        prepareData()
    }

    public init() {
        super.init(frame: CGRect.zero)
        initData()
        initUI()
        prepareData()
    }

    open func initUI() {

    }

    open func initData() {

    }
    
    open func prepareData() {
        
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class NaviView: BaseView {
    public let bgView = UIView()
    public let leftBtn = UIButton()
    public let rightBtn = UIButton()
    public let titleLab = UILabel()
    open var bgColor = UIColor.eHex("#000000", alpha: 0.04)

    var title: String {
        get {
            titleLab.text ?? ""
        }
        set {
            titleLab.text = newValue
        }
    }

    override func initUI() {

        self.addSubview(bgView)
        self.addSubview(leftBtn)
        self.addSubview(titleLab)
        self.addSubview(rightBtn)
        bgView.backgroundColor = UIColor.random()

        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        rightBtn.setTitleColor(.white, for: .normal)
        rightBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        rightBtn.isHidden = true

        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        leftBtn.setTitleColor(.white, for: .normal)
        leftBtn.setImage(R.image.icon_return(), for: .normal)
        leftBtn.titleLabel?.adjustsFontSizeToFitWidth = true

        titleLab.font = UIFont.boldSystemFont(ofSize: 18)
        titleLab.textColor = R.color.fontBackText_90()
        titleLab.textAlignment = .center
        titleLab.adjustsFontSizeToFitWidth = true

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        leftBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(6)
            make.height.equalTo(35)
            make.centerY.equalTo(titleLab.snp.centerY)
        }
        titleLab.snp.makeConstraints { make in
            make.bottom.equalTo(self).inset(6)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
        }

        rightBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(35)
            make.centerY.equalTo(titleLab.snp.centerY)
        }

    }
}
