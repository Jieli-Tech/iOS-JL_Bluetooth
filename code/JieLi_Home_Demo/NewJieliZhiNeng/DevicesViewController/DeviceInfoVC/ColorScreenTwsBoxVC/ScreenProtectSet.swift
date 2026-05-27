//
//  ScreenProtectSet.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/12/5.
//  Copyright © 2023 杰理科技. All rights reserved.
//

import RxCocoa
import UIKit
import RxSwift

import WebKit

// MARK: - 屏保程序

@objcMembers class ScreenProtectSetView: BasicView {
    private let moreBtn = UIButton()
    private var viewModel: PublicSettingViewModel?
    private let titleLab = UILabel()
    private let cusImgv = PtColView()
    private let wbImgv1 = PtColView()
    private let wbImgv2 = PtColView()
    private let wbImgv3 = PtColView()
    private var itemsArray: [PtColModel] = []
    var publicSetting: PublicSettingViewModel? {
        get {
            viewModel
        }
        set {
            viewModel = newValue
            viewModel?.currentScreenSaver.subscribe(onNext: { [weak self] model in
                guard let `self` = self else { return }
                self.updateByModel(model)
            }).disposed(by: disposeBag)
            viewModel?.fileModelList.subscribe(onNext: { [weak self] list in
                guard let `self` = self else { return }
                self.updateByModel(viewModel?.currentScreenSaver.value)
            }).disposed(by: disposeBag)
        }
    }

    override func initUI() {
        super.initUI()
        backgroundColor = UIColor.white
        layer.cornerRadius = 12
        layer.masksToBounds = true

        addSubview(titleLab)
        addSubview(moreBtn)
        addSubview(cusImgv)
        addSubview(wbImgv1)
        addSubview(wbImgv2)
        addSubview(wbImgv3)
        
        titleLab.text = R.Language.lan("Screen Savers")
        titleLab.font = R.Font.medium(15)
        titleLab.textColor = UIColor.eHex("#000000", alpha: 0.9)
        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(14)
            make.height.equalTo(20)
        }

        moreBtn.semanticContentAttribute = .forceRightToLeft
        moreBtn.setTitle(R.Language.lan("More"), for: .normal)
        moreBtn.setTitleColor(UIColor.eHex("#919191"), for: .normal)
        moreBtn.titleLabel?.font = R.Font.medium(13)
        moreBtn.setImage(R.Image.img("Theme.bundle/icon_next_nol"), for: .normal)
        moreBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.width.equalTo(60)
            make.centerY.equalTo(titleLab.snp.centerY)
        }

        cusImgv.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(14)
            make.width.equalTo(wbImgv1.snp.width)
            make.left.equalToSuperview().inset(14)
            make.right.equalTo(wbImgv1.snp.left).offset(-14)
            make.height.equalTo(86)
        }
        wbImgv1.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(14)
            make.width.equalTo(cusImgv.snp.width)
            make.right.equalToSuperview().inset(14)
            make.left.equalTo(wbImgv1.snp.right).offset(14)
            make.height.equalTo(86)
        }
        wbImgv2.snp.makeConstraints { make in
            make.top.equalTo(wbImgv1.snp.bottom).offset(9)
            make.width.equalTo(wbImgv3.snp.width)
            make.left.equalToSuperview().inset(14)
            make.right.equalTo(wbImgv3.snp.left).offset(-14)
            make.height.equalTo(86)
        }
        wbImgv3.snp.makeConstraints { make in
            make.top.equalTo(wbImgv1.snp.bottom).offset(9)
            make.width.equalTo(wbImgv2.snp.width)
            make.right.equalToSuperview().inset(14)
            make.left.equalTo(wbImgv2.snp.right).offset(14)
            make.height.equalTo(86)
        }
        handleTouchUp()
    }

    override func initData() {
        super.initData()
        LanguageCls.share().add(self)
        updateCollect()
    }

    func updateCollect() {
        JLLogManager.logLevel(.DEBUG, content: "currentScreenSaver updateCollect: \(publicSetting?.currentScreenSaver.value?.fileName ?? "")")
        
        let uuid = JL_RunSDK.sharedMe().mBleEntityM?.mUUID ?? "unKnow"
        var items = [PtColModel]()
        let localCustom = SwiftHelper.listFiles(R.path.protectCustom + "/" + uuid)
        if localCustom.count > 0 {
            let t = PtColModel(img: localCustom.first!.beImage(), isSel: false, tag: 0)
            items.append(t)
        } else {
            items.append(PtColModel(img: UIImage(), isSel: false, tag: 0))
        }
        if publicSetting?.sdkInfo?.isSupportGif == true ||
            publicSetting?.chipType == .AC701N {
            let urls = PtColModel.loadAllGifImgUrl()
            for i in 0 ..< min(3, urls.count) {
                let pm = PtColModel(img: UIImage(), isSel: false, tag: i + 1)
                pm.gifUrl = urls[i]
                items.append(pm)
            }
        } else {
            var paths = PtColModel.loadAllScreenSaverUrl()
            if publicSetting?.chipType == .AC707N {
                paths = PtColModel.loadAllScreenSaverUrl(".jpg")
            }
            for i in 0 ..< min(3, paths.count) {
                let pm = PtColModel(img: UIImage(), isSel: false, tag: i + 1)
                pm.imgPath = paths[i]
                pm.img = paths[i].beImage()
                for item in publicSetting?.fileModelList.value ?? [] {
                    if item.fileName.uppercased() == paths[i].lastPathComponent.withoutExt().uppercased() {
                        pm.isExit = true
                    }
                }
                items.append(pm)
            }
        }
        
        if let onlineRes = publicSetting?.resourceViewModel.onlineScreenSavers.value {
            let needCount = 4 - items.count
            for i in 0 ..< min(needCount, onlineRes.count) {
                items.append(PtColModel(resource: onlineRes[i]))
            }
        }

        while items.count < 4 {
             items.append(PtColModel(img: UIImage(), isSel: false, tag: items.count))
        }

        itemsArray = items
        cusImgv.makeItemModel(items[0])
        wbImgv1.makeItemModel(items[1])
        wbImgv2.makeItemModel(items[2])
        wbImgv3.makeItemModel(items[3])
    }

    func updateByModel(_ model: ScreenSaverModel?) {
        updateCollect()
        let uuid = JL_RunSDK.sharedMe().mBleEntityM?.mUUID ?? "unKnow"
        let fmType = model?.fileName.lastComponent().withoutExt() ?? "unKnow"
        if fmType == "VIE_CST" {
            let localCustom = SwiftHelper.listFiles(R.path.protectCustom + "/" + uuid)
            for item in localCustom {
                if let f = (item as NSString).lastPathComponent.components(separatedBy: ".").first {
                    guard let crc = f.components(separatedBy: "-").last else { return }
                    if crc == String(format: "%04X", model?.crc ?? 0) {
                        guard let md = cusImgv.model else { return }
                        md.img = item.beImage()
                        md.isSel = true
                        cusImgv.makeItemModel(md)
                        break
                    }
                }
            }
        } else {
            for item in itemsArray {
                var str = item.gifUrl?.lastPathComponent.components(separatedBy: ".").first ?? "unKnow"
                if str == "unKnow" {
                    str = item.imgPath?.lastPathComponent.components(separatedBy: ".").first ?? "unKnow"
                }
                if str == "unKnow" {
                    str = item.name.withoutExt()
                }
                if fmType.uppercased() == str.uppercased() {
                    item.isSel = true
                } else {
                    item.isSel = false
                }
                
            }
            cusImgv.makeItemModel(itemsArray[0])
            wbImgv1.makeItemModel(itemsArray[1])
            wbImgv2.makeItemModel(itemsArray[2])
            wbImgv3.makeItemModel(itemsArray[3])
        }
    }

    private func handleTouchUp() {
        cusImgv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCus)))
        wbImgv1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleWbg1)))
        wbImgv2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleWbg2)))
        wbImgv3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleWbg3)))
        moreBtn.rx.tap.subscribe(
            onNext: { [weak self] _ in
                guard let self = self,
                      let viewController = self.contextView as? ColorScreenSetVC else { return }
                let vc = ScreenProtectMoreVC()
                vc.publicSettingMode = self.publicSetting
                viewController.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }

    @objc private func handleCus() {
//        publicSetting?.testBrowse()
//        return Void()
        guard let viewController = contextView as? ColorScreenSetVC else { return }
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/protectCustom"
        if SwiftHelper.listFiles(path).count > 0 {
            let vc = CustomSourcesVC()
            vc.publicSetting = publicSetting
            vc.sourceType = PublicSettingViewModel.screenSaver
            viewController.navigationController?.pushViewController(vc, animated: true)
        } else {
            viewController.showAlbumView()
        }
    }

    @objc private func handleWbg1() {
        if itemsArray.count > 1 {
            handleSelect(itemsArray[1])
        }
    }

    @objc private func handleWbg2() {
        if itemsArray.count > 2 {
            handleSelect(itemsArray[2])
        }
    }

    @objc private func handleWbg3() {
        if itemsArray.count > 3 {
            handleSelect(itemsArray[3])
        }
    }
    private func handleSelect(_ model: PtColModel) {
        if publicSetting?.chipType == .AC707N {
            let fileName = model.imgPath?.lastPathComponent ?? ""
            for item in publicSetting?.fileModelList.value ?? [] {
                if item.fileName.uppercased() == fileName.withoutExt().uppercased() {
                    publicSetting?.activeVIE(name: item.fileName, vieImage: model.img)
                    return
                }
            }
        }
        
        guard let vc1 = contextView as? ColorScreenSetVC else { return }
        
        if model.tag == 100, let resourceUrl = model.downloadUrl {
            DFUITools.showHUD(withLabel: R.Language.lan("Downloading..."), on: vc1.view)
            CSNetworkManager.shared.downloadFile(url: resourceUrl) { [weak vc1] result in
                guard let vc1 = vc1 else { return }
                DFUITools.removeHUD()
                switch result {
                case .success(let localUrl):
                    let vc = ProtectPreviewVC()
                    vc.publicSettingVM = self.publicSetting
                    if resourceUrl.lowercased().hasSuffix(".gif") {
                        vc.gifUrl = localUrl
                    } else {
                        if let image = UIImage(contentsOfFile: localUrl.path) {
                            vc.showImage = image
                        } else {
                            vc1.view.makeToast(R.Language.lan("Image format error"), position: .center)
                            return
                        }
                    }
                    vc.fileName = (resourceUrl as NSString).lastPathComponent.components(separatedBy: ".").first ?? "online_res"
                    vc1.navigationController?.pushViewController(vc, animated: true)
                case .failure(let error):
                    JLLogManager.logLevel(.ERROR, content: "Download failed: \(error)")
                    vc1.view.makeToast(R.Language.lan("Download failed"), position: .center)
                }
            }
            return
        }
        
        if let _ = model.imgPath {
            guard let path = model.imgPath?.absoluteString else { return }
            let vc = ProtectPreviewVC()
            vc.fileName = (path as NSString).lastPathComponent
            vc.showImage = model.imgPath!.beImage()
            vc.publicSettingVM = publicSetting
            vc1.navigationController?.pushViewController(vc, animated: true)
            return
        }
        guard let path = model.gifUrl?.absoluteString else { return }
        if path.hasSuffix(".gif") {
            let vc = ProtectPreviewVC()
            vc.fileName = (path as NSString).lastPathComponent.replacingOccurrences(of: ".gif", with: "")
            vc.gifUrl = model.gifUrl!
            vc.publicSettingVM = publicSetting
            vc1.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

class PtColView: BasicView {
    let imgView = UIImageView()
    let imgGif = WKWebView()
    let selImgv = UIImageView()
    let centerImgv = UIImageView()
    var model: PtColModel?
    let notExitInDevImgv = UIImageView()

    override func initUI() {
        super.initUI()
        addSubview(imgGif)
        addSubview(imgView)
        addSubview(centerImgv)
        addSubview(selImgv)
        addSubview(notExitInDevImgv)
        backgroundColor = UIColor.eHex("#EAEAEA")
        selImgv.image = R.Image.img("Theme.bundle/bay_icon_choose")
        centerImgv.image = R.Image.img("Theme.bundle/bay_icon_add")
        notExitInDevImgv.image = R.Image.img("Theme.bundle/icon_cloud")
        notExitInDevImgv.isHidden = true
        centerImgv.isHidden = true
        imgGif.isHidden = true
        imgGif.isUserInteractionEnabled = false

        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imgGif.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        centerImgv.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.center.equalToSuperview()
        }
        selImgv.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(18)
        }
        notExitInDevImgv.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(22)
        }
    }

    func makeItemModel(_ model: PtColModel) {
        self.model = model
        imgView.image = model.img
        selImgv.isHidden = !model.isSel
        centerImgv.isHidden = model.tag != 0
        
        if model.gifUrl != nil {
            imgGif.isHidden = false
            let request = URLRequest(url: model.gifUrl!)
            imgGif.load(request)
        } else {
            imgGif.isHidden = true
        }
        if model.tag == 0 {
            centerImgv.image = UIImage(named: "Theme.bundle/bay_icon_edit_02")
        }
        if model.isSel {
            layer.borderColor = UIColor.purple.cgColor
            notExitInDevImgv.isHidden = true
        } else {
            layer.borderColor = UIColor.clear.cgColor
            if model.tag != 0 {
                notExitInDevImgv.isHidden = model.isExit
            }
        }
    }
}

// MARK: - 屏幕开机动画

class ScreenAnimationView: BasicView {
    private let titleLab = UILabel()
    let itemsArray = BehaviorRelay<[PtColModel]>(value: [])
    private var collectView: UICollectionView!
    weak var publicSetting: PublicSettingViewModel?
    private var dataDisposeBag = DisposeBag()

    override func initUI() {
        super.initUI()
        backgroundColor = UIColor.white
        layer.cornerRadius = 12
        layer.masksToBounds = true

        addSubview(titleLab)

        let fw = UICollectionViewFlowLayout()
        let w = (UIScreen.main.bounds.size.width - 22 * 2 - 11.0) / 2
        fw.itemSize = CGSizeMake(w, 86)
        fw.minimumLineSpacing = 11
        fw.minimumInteritemSpacing = 11
        fw.scrollDirection = .horizontal
        collectView = UICollectionView(frame: .zero, collectionViewLayout: fw)
        collectView.backgroundColor = UIColor.clear
        collectView.showsHorizontalScrollIndicator = false
        collectView.register(PtColCell.self, forCellWithReuseIdentifier: "PtColCell")
        addSubview(collectView)
        
        titleLab.text = R.Language.lan("Boot Animation")
        titleLab.font = R.Font.medium(15)
        titleLab.textColor = UIColor.eHex("#000000", alpha: 0.9)
        titleLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(14)
            make.height.equalTo(20)
        }

        itemsArray.bind(to: collectView.rx.items(cellIdentifier: "PtColCell", cellType: PtColCell.self)) { _, item, cell in
            cell.makeCell(item)
        }.disposed(by: disposeBag)
        
        collectView.rx.modelSelected(PtColModel.self).subscribe(onNext: { [weak self] model in
            guard let self = self, let vc1 = self.contextView as? ColorScreenSetVC else { return }
            if model.tag == 100, let resourceUrl = model.downloadUrl {
                DFUITools.showHUD(withLabel: R.Language.lan("Downloading..."), on: vc1.view)
                CSNetworkManager.shared.downloadFile(url: resourceUrl) { [weak vc1, weak self] result in
                    guard let vc1 = vc1, let self = self else { return }
                    DFUITools.removeHUD()
                    switch result {
                    case .success(let localUrl):
                        let vc = ProtectPreviewVC()
                        vc.publicSettingVM = self.publicSetting
                        if resourceUrl.lowercased().hasSuffix(".gif") {
                            vc.gifUrl = localUrl
                        } else {
                            if let image = UIImage(contentsOfFile: localUrl.path) {
                                vc.showImage = image
                            } else {
                                vc1.view.makeToast(R.Language.lan("Image format error"), position: .center)
                                return
                            }
                        }
                        vc.fileName = (resourceUrl as NSString).lastPathComponent.components(separatedBy: ".").first ?? "online_ani"
                        vc.sourceType = 0x02 // 0x02 indicates animation, assuming this is correct or handled by ProtectUpdateVC
                        vc1.navigationController?.pushViewController(vc, animated: true)
                    case .failure(let error):
                        JLLogManager.logLevel(.ERROR, content: "Download failed: \(error)")
                        vc1.view.makeToast(R.Language.lan("Download failed"), position: .center)
                    }
                }
                return
            }
            
            if let path = model.gifUrl?.absoluteString {
                if path.hasSuffix(".gif") {
                    let vc = ProtectPreviewVC()
                    vc.fileName = (path as NSString).lastPathComponent.replacingOccurrences(of: ".gif", with: "")
                    vc.gifUrl = model.gifUrl!
                    vc.publicSettingVM = self.publicSetting
                    vc.sourceType = 0x02
                    vc1.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }).disposed(by: disposeBag)

        collectView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(14)
            make.top.equalTo(titleLab.snp.bottom).offset(18)
            make.right.equalToSuperview().inset(14)
            make.bottom.equalToSuperview().inset(20)
        }
        handleTouchUp()
    }

    override func initData() {
        super.initData()
        updateData()
        setupDataBinding()
    }
    
    func updateData() {
        var items = [PtColModel]()
        let md = PtColModel(img: UIImage(), isSel: true, tag: 1)
        md.gifUrl = Bundle.main.url(forResource: "ANI1", withExtension: "gif")
        items.append(md)
        
        // 合并云端开机动画
        if let publicSetting = publicSetting {
            let bootAnimations = publicSetting.resourceViewModel.onlineBootAnimations.value
            for res in bootAnimations {
                let pm = PtColModel(resource: res)
                items.append(pm)
            }
        }
        
        itemsArray.accept(items)
    }
    
    func setupDataBinding() {
        dataDisposeBag = DisposeBag()
        
        // 监听云端资源变化
        if let publicSetting = publicSetting {
            publicSetting.resourceViewModel.onlineBootAnimations
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.updateData()
                })
                .disposed(by: dataDisposeBag)
                
            publicSetting.fileModelList
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    self.updateData()
                })
                .disposed(by: dataDisposeBag)
        }
    }

    private func handleTouchUp() {}
}

// MARK: - 数据模型

@objcMembers class PtColModel: NSObject {
    var img: UIImage
    var isSel: Bool
    var gifUrl: URL?
    var tag: Int
    var isExit: Bool = false
    var imgPath: URL?
    var onlineUrl: String? // 用于显示缩略图
    var downloadUrl: String? // 用于下载原资源文件
    var resourceModel: CSResourceItemModel?
    
    var name: String {
        if gifUrl != nil {
            let path = gifUrl?.lastPathComponent.components(separatedBy: ".").first ?? ""
            return path
        }
        if imgPath != nil {
            let path = imgPath?.lastPathComponent.components(separatedBy: ".").first ?? ""
            return path
        }
        return ""
    }
    private var _name: String
    
    init(img: UIImage, isSel: Bool, tag: Int, name: String = "") {
        self.img = img
        self.isSel = isSel
        self.tag = tag
        _name = name
    }
    
    /// 从在线资源初始化
    convenience init(resource: CSResourceItemModel) {
        self.init(img: UIImage(), isSel: false, tag: 100) // 使用 100 表示在线资源
        self.onlineUrl = resource.icon ?? resource.url
        self.downloadUrl = resource.url
        self.resourceModel = resource
        if let urlStr = resource.url, let url = URL(string: urlStr) {
            SDWebImageManager.shared.loadImage(with: url, options: [], progress: nil) { [weak self] (image, data, error, cacheType, finished, imageURL) in
                if let img = image {
                    self?.img = img
                }
            }
        }
        
        let resourceFileName = (self.downloadUrl as NSString?)?.lastPathComponent.components(separatedBy: ".").first ?? ""
        self.isExit = false
        for item in PublicSettingViewModel.shared.fileModelList.value {
            if item.fileName.uppercased() == resourceFileName.uppercased() {
                self.isExit = true
                break
            }
        }
    }

    func getImgData() -> Data {
        if gifUrl == nil {
            return img.pngData() ?? Data()
        } else {
            let dt = try? Data(contentsOf: gifUrl!)
            return dt ?? Data()
        }
    }

    static func loadAllGifImgUrl() -> [URL] {
        var list: [URL] = []
        for i in 2 ... 7 {
            let url = Bundle.main.url(forResource: "ANI\(i)", withExtension: ".gif")
            list.append(url!)
        }
        return list
    }
    
    
    static func loadAllScreenSaverUrl(_ type: String = ".png")-> [URL] {
        var list: [URL] = []
        for i in 1 ... 3 {
            if type == ".jpg" {
                let url = Bundle.main.url(forResource: "VIE\(i-1)", withExtension: ".jpg")
                list.append(url!)
                continue
            }
            let url = Bundle.main.url(forResource: "VIE\(i)", withExtension: ".png")
            list.append(url!)
        }
        return list
    }

    static func loadAllWallPaperUrl() -> [URL] {
        var list: [URL] = []
        for i in 0 ... 5 {
            let url = Bundle.main.url(forResource: "csbg_00\(i + 1)", withExtension: ".png")
            list.append(url!)
        }
        return list
    }
}

class PtColCell: UICollectionViewCell {
    let imgView = UIImageView()
    let imgGif = WKWebView()
    let selImgv = UIImageView()
    let selectImgv = UIImageView()
    let centerImgv = UIButton()
    private let maskSelectView = UIView()
    private let cloudImgv = UIImageView()
    var editCustomImageHandle: ((PtColModel) -> Void)?
    private let disposeBag = DisposeBag()
    private var cellModel: PtColModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imgGif)
        addSubview(imgView)
        addSubview(centerImgv)
        addSubview(selImgv)
        addSubview(maskSelectView)
        addSubview(selectImgv)
        addSubview(cloudImgv)
        backgroundColor = UIColor.eHex("#EAEAEA")
        selImgv.image = R.Image.img("Theme.bundle/bay_icon_choose")
        centerImgv.setImage(R.Image.img("Theme.bundle/bay_icon_add"), for: .normal)
        selectImgv.image = R.Image.img("Theme.bundle/edit_icon_choose_nor")
        cloudImgv.image = R.Image.img("Theme.bundle/icon_cloud")
        maskSelectView.backgroundColor = .eHex("#000000", alpha: 0.6)
        
        selectImgv.isHidden = true
        centerImgv.isHidden = true
        cloudImgv.isHidden = true
        imgGif.isHidden = true
        maskSelectView.isHidden = true
        imgGif.isUserInteractionEnabled = false

        layer.cornerRadius = 8
        layer.masksToBounds = true
        layer.borderColor = UIColor.clear.cgColor
        layer.borderWidth = 1
        imgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        imgGif.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        centerImgv.snp.makeConstraints { make in
            make.width.height.equalTo(36)
            make.center.equalToSuperview()
        }
        selImgv.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(18)
        }
        
        maskSelectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selectImgv.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(30)
        }
        
        cloudImgv.snp.makeConstraints { make in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(22)
        }
        
        centerImgv.rx.tap.subscribe(onNext: { [weak self] in
            guard let `self` = self else { return }
            self.editCustomImageHandle?(self.cellModel!)
        }).disposed(by: disposeBag)
    }

    func makeCell(_ model: PtColModel) {
        cellModel = model
        selImgv.isHidden = !model.isSel
        wallPaperInDevice(true)
        centerImgv.isHidden = model.tag != 0
        
        // 加载图片 (支持在线URL或本地图片)
        if let onlineUrlStr = model.onlineUrl, let url = URL(string: onlineUrlStr) {
            imgView.sd_setImage(with: url, placeholderImage: UIImage(named: "Theme.bundle/icon_default_pic"))
        } else {
            imgView.image = model.img
        }
        
        if model.gifUrl != nil {
            imgGif.isHidden = false
            let request = URLRequest(url: model.gifUrl!)
            imgGif.load(request)
        } else {
            imgGif.isHidden = true
        }
        if model.tag == 0 && model.getImgData().count > 0 {
            centerImgv.setImage(UIImage(named: "Theme.bundle/bay_icon_edit_02"), for: .normal)
        }
        if model.isSel {
            layer.borderColor = UIColor.purple.cgColor
        } else {
            layer.borderColor = UIColor.clear.cgColor
            if model.tag != 0 {
                wallPaperInDevice(model.isExit)
            }
        }
    }
    
    /// 设置选中状态
    /// - Parameters:
    ///   - isShowSelect: 是否在选择模式
    ///   - isSelectStatus: 是否被选中
    func isSelect(_ isShowSelect: Bool,_ isSelectStatus: Bool = false, _ disableSelect: Bool = true) {
        if disableSelect {
            selectImgv.isHidden = true
            maskSelectView.isHidden = true
            return
        }
        selectImgv.isHidden = !isShowSelect
        maskSelectView.isHidden = !isShowSelect
        
        if isSelectStatus {
            selectImgv.image = R.Image.img("Theme.bundle/edit_icon_choose_sel")
        } else {
            selectImgv.image = R.Image.img("Theme.bundle/edit_icon_choose_nor")
        }
        guard let model = cellModel else { return }
        if model.isSel && !isShowSelect {
            layer.borderColor = UIColor.purple.cgColor
            selectImgv.isHidden = true
        } else {
            layer.borderColor = UIColor.clear.cgColor
        }
        if !cloudImgv.isHidden {
            selectImgv.isHidden = true
        }
        if model.tag == 0 {
            selectImgv.isHidden = true
        }
    }
    
    /// 墙纸是否在设备端存在
    /// - Parameter isShow: 是否在设备端存在
    func wallPaperInDevice(_ isShow: Bool) {
        cloudImgv.isHidden = isShow
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ScreenProtectSetView:LanguagePtl{
    func languageChange() {
        initUI()
    }
}
