//
//  CustomProtectView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/12/7.
//  Copyright © 2023 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class CustomProtectView: BasicView {
    let titleLab = UILabel()
    var type: UInt8 = PublicSettingViewModel.screenSaver
    var handleChoose:((_ list:[String])->Void)?
    var collectView: UICollectionView!
    var isChooseType: Bool = false
    private var viewModel: PublicSettingViewModel?
    var publicSetting: PublicSettingViewModel? {
        set {
            viewModel = newValue
            viewModel?.currentScreenSaver.subscribe(onNext: { [weak self] model in
                guard let `self` = self else { return }
                self.reloadData(model)
            }).disposed(by: disposeBag)
        }
        get {
            return viewModel
        }
    }
    var viewController: UIViewController?
    

    private let itemsArray = BehaviorRelay<[CustomPtModel]>(value: [])

    override func initUI() {
        super.initUI()
        backgroundColor = UIColor.white
        addSubview(titleLab)
        titleLab.font = R.Font.medium(15)
        titleLab.textColor = UIColor.eHex("#000000", alpha: 0.9)
        titleLab.text = R.Language.lan("Select Previous Image")
        
        let fw = UICollectionViewFlowLayout()
        let w = (UIScreen.main.bounds.size.width - 22 * 2) / 2
        fw.itemSize = CGSizeMake(w, 86)
        fw.minimumLineSpacing = 11
        fw.minimumInteritemSpacing = 11
        collectView = UICollectionView(frame: .zero, collectionViewLayout: fw)
        collectView.backgroundColor = UIColor.clear
        collectView.register(CustomPtCell.self, forCellWithReuseIdentifier: "CustomPtCell")
        addSubview(collectView)

        itemsArray.bind(to: collectView.rx.items(cellIdentifier: "CustomPtCell", cellType: CustomPtCell.self)) { [weak self] _, model, cell in
            guard let `self` = self else { return }
            cell.makeCell(model)
            cell.editImgv.isHidden = !self.isChooseType
            if self.isChooseType {
                if !model.isSel {
                    cell.selImgv.isHidden = true
                } else {
                    cell.editImgv.isHidden = true
                }
            }
        }.disposed(by: disposeBag)

        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(14)
            make.height.equalTo(20)
        }

        collectView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(14)
            make.top.equalTo(titleLab.snp.bottom).offset(14)
            make.bottom.equalToSuperview()
        }

        bindDataChange()
    }

    override func initData() {
        super.initData()

        LanguageCls.share().add(self)
    }
    
    func bindDataChange() {
        collectView.rx.modelSelected(CustomPtModel.self).subscribe(onNext: { [weak self] model in
            guard let `self` = self else { return }
            if self.isChooseType {
                if !model.isSel {
                    model.isChoosed.toggle()
                    self.itemsArray.accept(self.itemsArray.value)
                    self.handleChoose?(self.getSelected())
                }
            } else {
                self.handleSelect(model)
            }
        }).disposed(by: disposeBag)
        
    }
    

    func reloadData(_ model: ScreenSaverModel?) {
        
        let uuid = JL_RunSDK.sharedMe().mBleEntityM?.mUUID ?? "unKnow"
        var items = [CustomPtModel]()
        if type == PublicSettingViewModel.screenSaver {
            let localCus = SwiftHelper.listFiles(R.path.protectCustom + "/" + uuid)
            if localCus.count == 0 {
                itemsArray.accept([])
                return
            }
            for i in 0 ..< localCus.count {
                let model = CustomPtModel(img: localCus[i].beImage(), isSel: false, tag: i)
                model.imagePath = localCus[i]
                items.append(model)
            }
            guard let model = model else {
                itemsArray.accept(items)
                return
            }
            var fmType = (model.fileName as NSString).lastPathComponent.components(separatedBy: ".").first ?? ""
            fmType = fmType.replacingOccurrences(of: "/", with: "")
            if fmType == "VIE_CST" {
                for item in items {
                    if let f = (item.imagePath as NSString).lastPathComponent.components(separatedBy: ".").first {
                        guard let crc = f.components(separatedBy: "-").last else { return }
                        item.isSel = false
                        if crc == String(format:"%04X",model.crc) {
                            item.isSel = true
                            break
                        }
                    }
                }
            }
        } else {
            let localCus = SwiftHelper.listFiles(R.path.wallPaperCustom + "/" + uuid)
            if localCus.count == 0 {
                itemsArray.accept([])
                return
            }
            for i in 0 ..< localCus.count {
                let model = CustomPtModel(img: localCus[i].beImage(), isSel: false, tag: i)
                model.imagePath = localCus[i]
                items.append(model)
            }
            guard let model = model else {
                itemsArray.accept(items)
                return
            }
            var fmType = (model.fileName as NSString).lastPathComponent.components(separatedBy: ".").first ?? ""
            fmType = fmType.replacingOccurrences(of: "/", with: "")
            if fmType == "csbg_x" {
                for item in items {
                    if let f = (item.imagePath as NSString).lastPathComponent.components(separatedBy: ".").first {
                        guard let crc = f.components(separatedBy: "-").last else { return }
                        item.isSel = false
                        if crc == String(model.crc) {
                            item.isSel = true
                            break
                        }
                    }
                }
            }
        }
        itemsArray.accept(items)
    }

    func isSelectedAll() -> Bool {
        var result = 0
        for item in itemsArray.value {
            if item.isChoosed || item.isSel {
                result += 1
            }
        }
        if result == itemsArray.value.count {
            return true
        }
        return false
    }

    func selectAll(isSelect: Bool) {
        for item in itemsArray.value {
            if !item.isSel {
                item.isChoosed = isSelect
            } else {
                item.isChoosed = false
            }
        }
        itemsArray.accept(itemsArray.value)
    }

    func getSelected() -> [String] {
        var list: [String] = []
        for item in itemsArray.value {
            if item.isChoosed {
                list.append(item.imagePath)
            }
        }
        return list
    }
    
    private func handleSelect(_ model: CustomPtModel) {
        if publicSetting?.chipType == .AC707N {
            let fileName = model.imagePath.lastComponent()
            let crc = fileName.components(separatedBy: "-").last ?? ""
            for item in publicSetting?.fileModelList.value ?? [] {
                if String(format: "%04X", item.crc) == crc {
                    publicSetting?.activeVIE(name: item.fileName, vieImage: model.img)
                    return
                }
            }
        }
        guard let viewController = viewController ,let publicSetting = publicSetting else {return}
        let vc1 = ProtectPreviewVC()
        vc1.showImage = model.img
        if type == PublicSettingViewModel.screenSaver {
            vc1.fileName = "VIE_CST"
        } else {
            vc1.fileName = "csbg_x"
        }
        vc1.sourceType = type
        vc1.publicSettingVM = publicSetting
        viewController.navigationController?.pushViewController(vc1, animated: true)
    }
}

@objcMembers class CustomPtModel: PtColModel {
    var isChoosed: Bool = false
    var imagePath: String = ""
}

class CustomPtCell: PtColCell {
    let editImgv = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(editImgv)
        editImgv.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(4)
            make.width.height.equalTo(24)
        }
        editImgv.image = UIImage(named: "Theme.bundle/edit_icon_choose_sel")
        editImgv.isHidden = true
    }

    func makeCell(_ model: CustomPtModel) {
        imgView.image = model.img
        selImgv.isHidden = !model.isSel
        centerImgv.isHidden = true
        if model.isSel {
            layer.borderColor = UIColor.purple.cgColor
        } else {
            layer.borderColor = UIColor.clear.cgColor
        }
        if model.isChoosed {
            editImgv.image = R.Image.img("Theme.bundle/edit_icon_choose_sel")
        } else {
            editImgv.image = R.Image.img("Theme.bundle/edit_icon_choose_nor")
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CustomProtectView:LanguagePtl{
    func languageChange() {
        initUI()
    }
}
