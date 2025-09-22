//
//  DevicesCell.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/9.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class DevicesInfoCell: UITableViewCell {
    private let itemView = CellItemView()
    private let bgView = UIView()
    private let deleteBtn = UIButton()
    private let headStatus = CellItemStatusView()
    private let tableView = UITableView()
    private let locationGoBtn = UIButton()
    private let disposeBag = DisposeBag()
    private weak var viewController: UIViewController?
    private var cellModel: DevicesInfoModel?
    private let itemsArray = BehaviorRelay(value: [CellItemSubMode]())
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        stepUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func stepUI() {
        contentView.addSubview(bgView)
        backgroundColor = .clear
        bgView.backgroundColor = .white
        bgView.layer.cornerRadius = 12
        bgView.layer.masksToBounds = true
        bgView.layer.shadowColor = UIColor.eHex("#CDE6FB", alpha: 0.2).cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: -2)
        bgView.layer.shadowOpacity = 1
        bgView.layer.shadowRadius = 16
        bgView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(6)
        }
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.isUserInteractionEnabled = false
        tableView.register(CellItemView.self, forCellReuseIdentifier: "CellItemView")
        tableView.rowHeight = 60
        bgView.addSubview(tableView)
        bgView.addSubview(headStatus)
        bgView.addSubview(locationGoBtn)
        
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(locationGoBtn.snp.left)
            make.top.bottom.equalToSuperview().inset(10)
        }
        itemView.productImgv.image = R.Image.img("Theme.bundle/device")
        headStatus.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(26)
            make.width.greaterThanOrEqualTo(90)
            make.centerX.equalToSuperview()
        }
        locationGoBtn.setImage(R.Image.img("Theme.bundle/product_icon_local"), for: .normal)
        locationGoBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(6)
            make.width.equalTo(30)
            make.height.equalTo(60)
            make.centerY.equalToSuperview()
        }
        itemsArray.bind(to: tableView.rx.items(cellIdentifier: "CellItemView", cellType: CellItemView.self)) { row, element, cell in
            cell.config(element)
        }.disposed(by: disposeBag)
        
        contentView.addSubview(deleteBtn)
        deleteBtn.setImage(R.Image.img("Theme.bundle/product_btn_delete"), for: .normal)
        deleteBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(40)
        }
        deleteBtn.isHidden = true
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.addGestureRecognizer(tap)
        deleteBtn.rx.tap.subscribe(onNext: { _ in
            DevicesViewModel.share.deleteDevice(dev: self.cellModel!)
        }).disposed(by: disposeBag)
        locationGoBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            guard let cellModel = self.cellModel else { return }
            guard let viewController = self.viewController as? DevicesViewController else { return }
            let mapVC = MapViewController()
            mapVC.deviceObjc = cellModel.dev
            mapVC.energy = cellModel.power
            viewController.navigationController?.pushViewController(mapVC, animated: true)
        }).disposed(by: disposeBag)
    }
    

    func config(_ mode: DevicesInfoModel, _ isDeleteMode: Bool,_ viewController: UIViewController) {
        cellModel = mode
        if mode.status == .configing || mode.status == .using {
            headStatus.setStatus(mode.status)
            headStatus.isHidden = false
        }else{
            headStatus.isHidden = true
        }
        self.viewController = viewController
        let modeList = DevicesViewModel.share.createCellInfo(mode, viewController)
        itemsArray.accept(modeList)
        tableView.snp.remakeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalTo(locationGoBtn.snp.left)
            make.height.equalTo(modeList.count * 60)
            make.top.bottom.equalToSuperview().inset(10)
        }
        if mode.dev.findDevice == "1" {
            locationGoBtn.isHidden = false
            locationGoBtn.snp.updateConstraints { make in
                make.width.equalTo(30)
            }
        } else {
            locationGoBtn.isHidden = true
            locationGoBtn.snp.updateConstraints { make in
                make.width.equalTo(0)
            }
        }
        if mode.status == .offline {
            deleteBtn.isHidden = !isDeleteMode
        }else{
            deleteBtn.isHidden = true
        }
    }
    
    @objc private func handleLongPress() {
        guard let vc = viewController as? DevicesViewController else { return }
        vc.setDeleteMode()
    }
    

}



fileprivate class CellItemView: UITableViewCell {
    let productImgv = UIImageView()
    let nameLab = UILabel()
    let typeImgv = UIImageView()
    let powerImgv = UIImageView()
    let powerLab = UILabel()
    let statusView = CellItemStatusView()
    private var disposeBag = DisposeBag()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        addSubview(productImgv)
        addSubview(nameLab)
        addSubview(typeImgv)
        addSubview(powerImgv)
        addSubview(powerLab)
        addSubview(statusView)
        productImgv.contentMode = .scaleAspectFit
        
        productImgv.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        nameLab.font = R.Font.regular(14)
        nameLab.textColor = .eHex("#000000", alpha: 0.9)
        nameLab.adjustsFontSizeToFitWidth = true
        nameLab.snp.makeConstraints { make in
            make.left.equalTo(productImgv.snp.right).offset(8)
            make.centerY.equalTo(productImgv)
        }
        typeImgv.snp.makeConstraints { make in
            make.left.equalTo(nameLab.snp.right).offset(6)
            make.width.height.equalTo(10)
            make.centerY.equalToSuperview()
        }
        powerLab.font = R.Font.medium(13)
        powerLab.textColor = .eHex("#000000", alpha: 0.5)
        powerLab.textAlignment = .center
        powerLab.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(6)
            make.width.equalTo(44)
            make.centerY.equalToSuperview()
        }
        powerImgv.snp.makeConstraints { make in
            make.right.equalTo(powerLab.snp.left).offset(-4)
            make.centerY.equalToSuperview()
        }
        statusView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-4)
            make.height.equalTo(26)
            make.centerY.equalToSuperview()
        }
    
    }
    
    func config(_ mode: CellItemSubMode) {
        productImgv.image = mode.productImg
        nameLab.text = mode.name
        if mode.showTypeImg {
            typeImgv.image = mode.typeImg
            typeImgv.isHidden = false
        }else{
            typeImgv.isHidden = true
        }
        if mode.status == .offline {
            statusView.setStatus(.offline)
            statusView.isHidden = false
            powerLab.isHidden = true
            powerImgv.isHidden = true
        }else{
            statusView.isHidden = true
            powerLab.isHidden = false
            powerImgv.isHidden = false
            let powerInfo = DevicesViewModel.share.powerImageInfo(
                mode.power,
                mode.isCharge
            )
            powerImgv.image = powerInfo.0
            powerLab.text = powerInfo.1
        }
    }
}

enum CellItemStatus {
    case using
    case configing
    case upgrade
    case connected
    case offline
    var weight: Int {
        switch self {
        case .using: return 1
        case .configing: return 2
        case .upgrade: return 3
        case .connected: return 4
        case .offline: return 5
        }
    }
}

fileprivate class CellItemStatusView: BasicView {
    private let statusLab = UILabel()
    private let bgImgv = UIImageView()
    override func initUI() {
        super.initUI()
        layer.cornerRadius = 4
        layer.masksToBounds = true
        bgImgv.image = R.Image.img("Theme.bundle/product_tag_use")
        addSubview(bgImgv)
        bgImgv.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        statusLab.textColor = .eHex("#F4F7FF")
        statusLab.font = R.Font.medium(12)
        statusLab.textAlignment = .center
        statusLab.adjustsFontSizeToFitWidth = true
        addSubview(statusLab)
        statusLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    func setStatus(_ status: CellItemStatus) {
        switch status {
        case .using:
            statusLab.text = "• " + R.Language.lan("device_status_using")
            statusLab.textColor = .eHex("#448EFF")
            backgroundColor = .white
            layer.cornerRadius = 0
            layer.masksToBounds = true
            bgImgv.isHidden = false
            bgImgv.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        case .offline:
            statusLab.text = "• " + R.Language.lan("device_status_unconnected")
            statusLab.textColor = .eHex("#5F5F5F")
            backgroundColor = .eHex("#F4F7FF")
            layer.cornerRadius = 4
            layer.masksToBounds = true
            bgImgv.isHidden = true
            bgImgv.snp.remakeConstraints { make in
                make.edges.equalTo(statusLab)
            }
        case .upgrade:
            statusLab.text = "• " + R.Language.lan("need_upgrade_second")
            statusLab.textColor = .eHex("#E51C23")
            backgroundColor = .eHex("#F4F7FF")
            layer.cornerRadius = 4
            layer.masksToBounds = true
            bgImgv.isHidden = true
            bgImgv.snp.remakeConstraints { make in
                make.edges.equalTo(statusLab)
            }
        case .configing:
            statusLab.text = "• "  + R.Language.lan("configing")
            statusLab.textColor = .eHex("#448EFF")
            backgroundColor = .white
            layer.cornerRadius = 0
            layer.masksToBounds = true
            bgImgv.isHidden = false
            bgImgv.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        case .connected:
            backgroundColor = .white
            layer.cornerRadius = 0
            layer.masksToBounds = true
            bgImgv.isHidden = true
            bgImgv.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
}


