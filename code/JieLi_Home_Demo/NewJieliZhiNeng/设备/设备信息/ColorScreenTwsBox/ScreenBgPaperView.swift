//
//  ScreenBgPaperView.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/1/13.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class ScreenBgPaperView: BasicView {
    let titleLab = UILabel()
    let moreBtn = UIButton()
    var collectionView: UICollectionView!
    weak var publicSetting: PublicSettingViewModel?
    weak var viewController: UIViewController?
    let itemsList = BehaviorRelay<[PtColModel]>(value: [])

    override func initUI() {
        super.initUI()
        backgroundColor = UIColor.white
        layer.cornerRadius = 12
        layer.masksToBounds = true

        addSubview(titleLab)
        addSubview(moreBtn)

        titleLab.text = LanguageCls.localizableTxt("Wallpaper")
        titleLab.font = R.Font.medium(15)
        titleLab.textColor = UIColor.eHex("#000000", alpha: 0.9)
        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(14)
            make.height.equalTo(20)
        }

        moreBtn.semanticContentAttribute = .forceRightToLeft
        moreBtn.setTitle(LanguageCls.localizableTxt("More"), for: .normal)
        moreBtn.setTitleColor(UIColor.eHex("#919191"), for: .normal)
        moreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        moreBtn.setImage(R.Image.img("Theme.bundle/icon_next_nol"), for: .normal)

        let fw = UICollectionViewFlowLayout()
        let w = (UIScreen.main.bounds.size.width - 22 * 2 - 11.0) / 2
        fw.itemSize = CGSizeMake(w, 86)
        fw.minimumLineSpacing = 11
        fw.minimumInteritemSpacing = 11
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: fw)
        collectionView.backgroundColor = UIColor.clear
        collectionView.register(PtColCell.self, forCellWithReuseIdentifier: "PtColCell")
        addSubview(collectionView!)

        itemsList.bind(to: collectionView.rx.items(cellIdentifier: "PtColCell", cellType: PtColCell.self)) { _, item, cell in
            cell.makeCell(item)
            cell.editCustomImageHandle = { [weak self] model in
                guard let `self` = self, let _ = viewController, let publicSetting = publicSetting else { return }
                let vc = CustomSourcesVC()
                vc.publicSetting = publicSetting
                vc.sourceType = PublicSettingViewModel.backgroundPaper
                self.viewController?.navigationController?.pushViewController(vc, animated: true)
            }
        }.disposed(by: disposeBag)

        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(14)
            make.height.equalTo(20)
        }
        moreBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLab)
            make.width.equalTo(60)
            make.height.equalTo(20)
        }

        collectionView!.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(14)
            make.top.equalTo(titleLab.snp.bottom).offset(14)
            make.height.equalTo(86 * 2 + 11 * 2)
        }
        makeBindHandle()
    }

    override func initData() {
        super.initData()
        updateData()
        publicSetting?.currentWallpaper.subscribe(onNext: { [weak self] model in
            guard let `self` = self, let model = model else { return }
            self.updateData(model)
        }).disposed(by: disposeBag)
    }

    private func makeBindHandle() {
        collectionView.rx.modelSelected(PtColModel.self).subscribe(onNext: { [weak self] model in
            guard let `self` = self, let viewController = viewController, let publicSetting = publicSetting else { return }
            if model.tag == 0 {
                let vc = CustomSourcesVC()
                vc.publicSetting = self.publicSetting
                vc.sourceType = PublicSettingViewModel.backgroundPaper
                self.viewController?.navigationController?.pushViewController(vc, animated: true)
                return
            }
            let currentFilePath = self.publicSetting?.currentWallpaper.value?.filePath ?? ""
            let currentFileName = (currentFilePath as NSString).lastPathComponent
            let list = publicSetting.fileModelList.value.filter { !$0.fileName.hasPrefix("csbg_") }
            let fileName = model.imgPath?.lastPathComponent ?? ""
            if fileName.uppercased() == currentFileName.uppercased() {
                JLLogManager.logLevel(.DEBUG, content: "same file")
                return
            }
            let index = list.firstIndex(where: { $0.fileName == fileName }) ?? 0
            if index == 0 {
                let vc1 = ProtectPreviewVC()
                vc1.fileName = model.imgPath?.lastPathComponent.replacingOccurrences(of: ".png", with: "") ?? "csbg_001"
                vc1.showImage = model.img
                vc1.publicSettingVM = publicSetting
                vc1.sourceType = PublicSettingViewModel.backgroundPaper
                viewController.navigationController?.pushViewController(vc1, animated: true)
                return
            }
            publicSetting.setWallPaper(model)
        }).disposed(by: disposeBag)
        moreBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            let vc = ScreenProtectMoreVC()
            vc.sourceType = PublicSettingViewModel.backgroundPaper
            self.viewController?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }

    private func updateData(_ model: JLPublicSourceInfoModel? = nil) {
        let uuid = JL_RunSDK.sharedMe().mBleEntityM?.mItem ?? "unKnow"
        var tmpList = [PtColModel]()
        let localCustom = SwiftHelper.listFiles(R.path.wallPaperCustom + "/" + uuid)
        if localCustom.count == 0 {
            tmpList.append(PtColModel(img: UIImage(), isSel: false, tag: 0))
        }
        for i in 0 ..< 3 {
            let tmpPath = Bundle.main.path(forResource: "csbg_00\(i + 1)", ofType: ".png")
            guard let dt = try? Data(contentsOf: URL(fileURLWithPath: tmpPath!)) else {
                JLLogManager.logLevel(.ERROR, content: "读取不到工程中的图片路径")
                continue
            }
            let img = UIImage(data: dt)
            let pm = PtColModel(img: img ?? UIImage(), isSel: false, tag: i + 1)
            pm.imgPath = URL(fileURLWithPath: tmpPath!)
            tmpList.append(pm)
        }

        if let model = model {
            let currentName = (model.filePath as NSString).lastPathComponent
            if currentName == "csbg_x" {
                for item in localCustom {
                    if let f = (item as NSString).lastPathComponent.components(separatedBy: ".").first {
                        guard let crc = f.components(separatedBy: "-").last else { return }
                        if crc == String(model.crc) {
                            guard let md = tmpList.first else { return }
                            md.img = item.beImage()
                            md.isSel = true
                            break
                        }
                    }
                }
            } else {
                for item in tmpList {
                    let nameStr = (item.imgPath?.absoluteString ?? "") as NSString
                    item.isSel = nameStr.lastPathComponent == currentName
                }
            }
        }
        itemsList.accept(tmpList)
    }
}
