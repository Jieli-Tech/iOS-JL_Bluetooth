//
//  ScreenProtectMoreVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/12/8.
//  Copyright © 2023 杰理科技. All rights reserved.
//

import UIKit

@objcMembers class ScreenProtectMoreVC: BasicViewController{

    public var publicSettingMode:PublicSettingViewModel?
    public var sourceType:UInt8 = PublicSettingViewModel.screenSaver
    private let centerView = UIView()
    private var collectView:UICollectionView!
    private let itemsArray = BehaviorRelay<[PtColModel]>(value: [])
    private let selectAlbum = ShowSelectAlbumView()
    private var selectStatus = false
    private var selectItems : [PtColModel] = []
    private lazy var rightBtn : UIButton = {
        let button = UIButton()
        button.setImage(R.Image.img("Theme.bundle/bay_icon_edit"), for: .normal)
        button.setTitleColor(.eHex("#242424"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    private let deleteBtn = UIButton()
    private var imagePickerController:UIImagePickerController!
    private var cutImgv:HQImageEditViewController!
    private let disposeBag = DisposeBag()
    
    override func initData() {
        super.initData()
        LanguageCls.share().add(self)
        guard let vm = publicSettingMode else {return}
        vm.fileModelList.subscribe(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.initItemsList()
        }).disposed(by: disposeBag)
        
        rightBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else {return}
            editBtnAction()
        }.disposed(by: disposeBag)
    }
    override func backBtnAction() {
        if selectStatus {
            let editIcon = UIImage(named: "Theme.bundle/bay_icon_edit.png")?.withRenderingMode(.alwaysOriginal)
            let backIcon = UIImage(named: "Theme.bundle/icon_return.png")?.withRenderingMode(.alwaysOriginal)
            selectStatus = false
            selectItems.removeAll()
            rightBtn.setImage(editIcon, for: .normal)
            rightBtn.setTitle("", for: .normal)
            naviView.existBtn.setImage(backIcon, for: .normal)
            naviView.existBtn.setTitle("", for: .normal)
            deleteBtn.isHidden = true
            naviView.rightView.snp.updateConstraints { make in
                make.width.equalTo(35)
            }
            self.collectView.reloadData()
            return
        }
        navigationController?.popViewController(animated: true)
    }
    override func initUI() {
        super.initUI()
        naviView.titleLab.text = R.Language.lan("Screen Savers")
        naviView.rightView.addSubview(rightBtn)
        rightBtn.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.addSubview(centerView)
        centerView.backgroundColor = .white
        
        centerView.snp.makeConstraints { make in
            make.top.equalTo(naviView.snp.bottom).offset(8)
            make.left.right.bottom.equalToSuperview()
        }
        
        let fw = UICollectionViewFlowLayout()
        let w = (UIScreen.main.bounds.size.width - 22*2)/2
        fw.itemSize = CGSizeMake(w, 86)
        fw.minimumLineSpacing = 11
        fw.minimumInteritemSpacing = 11
        collectView = UICollectionView(frame: .zero, collectionViewLayout: fw)
        collectView.backgroundColor = UIColor.clear
        collectView.register(PtColCell.self, forCellWithReuseIdentifier: "PtColCell")
        centerView.addSubview(collectView)
        
        itemsArray.bind(to: collectView.rx.items(cellIdentifier: "PtColCell", cellType: PtColCell.self)) { [weak self] (index,item,cell) in
            guard let self = self else {return}
            let isUsing = self.publicSettingMode?.currentScreenSaver.value?.fileName.uppercased() == item.name.uppercased()
            cell.makeCell(item)
            cell.isSelect(
                selectStatus,
                selectItems.contains(where: { $0 == item }),
                isUsing
            )
            if sourceType == PublicSettingViewModel.backgroundPaper {
                guard let vm = self.publicSettingMode else { return }
                let isExit = vm.fileModelList.value.contains(where: {
                    item.name.uppercased() == $0.fileName.uppercased()
                })
                cell.wallPaperInDevice(isExit)
            }
        }.disposed(by: disposeBag)
        
        collectView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(20)
        }
        
        let windows = UIApplication.shared.windows.first
        windows?.addSubview(selectAlbum)
        selectAlbum.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        selectAlbum.isHidden = true
        
        selectAlbum.selectBlock = { [weak self] index in
            self?.selectAlbum.isHidden = true
            if (index == 0) {
                self?.makePickerImage(.camera)
            } else if (index == 1) {
                self?.makePickerImage(.savedPhotosAlbum)
            }
        }
        
        deleteBtn.backgroundColor = .eHex("#F4F4F4")
        deleteBtn.setTitle(R.Language.lan("delete"), for: .normal)
        deleteBtn.setTitleColor(.eHex("#242424"), for: .normal)
        deleteBtn.setTitleColor(.gray, for: .highlighted)
        deleteBtn.setImage(UIImage(named: "Theme.bundle/photo_icon_delete"), for: .normal)
        deleteBtn.titleLabel?.font = R.Font.medium(10)
        deleteBtn.titleLabel?.textAlignment = .center
        deleteBtn.layoutIfNeeded()
        let titleHeight = deleteBtn.titleLabel?.intrinsicContentSize.height ?? 0
        let imageWidth = deleteBtn.imageView?.intrinsicContentSize.width ?? 0
        let imageHeight = deleteBtn.imageView?.intrinsicContentSize.height ?? 0
        deleteBtn.imageEdgeInsets = UIEdgeInsets(
            top: -titleHeight - 5,
            left: imageWidth,
            bottom: 0,
            right: 0
        )
        deleteBtn.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -((deleteBtn.titleLabel?.intrinsicContentSize.width) ?? 0),
            bottom: -imageHeight - 5,
            right: 0
        )
        deleteBtn.rx.tap
            .bind { [weak self] in
                self?.deleteBtnAction()
            }
            .disposed(by: disposeBag)
        
        view.addSubview(deleteBtn)
        // Compute safe bottom inset
        let safeBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        deleteBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(46 + safeBottom)
        }
        deleteBtn.isHidden = true
        
        handleTouchUp()
    }
    
    private func initScreenSaver(_ uuid: String) {
        var items = [PtColModel]()
        let custom = checkLocalCustom(sourceType, uuid)
        var fmType = custom.0
        items.append(custom.1)
        var tagNum = 0
        if fmType == "" {
            fmType = publicSettingMode?.currentScreenSaver.value?.fileName ?? "unKnow"
        }
        if publicSettingMode?.sdkInfo?.isSupportGif == true ||
            publicSettingMode?.chipType == .AC701N {
            let urls = PtColModel.loadAllGifImgUrl()
            for i in 0..<urls.count {
                let pm = PtColModel(img: UIImage(), isSel: false,tag: i+1)
                pm.gifUrl = urls[i]
                if fmType == urls[i].lastPathComponent.components(separatedBy: ".").first {
                    pm.isSel = true
                }
                items.append(pm)
            }
            tagNum = urls.count
        }
        var range = [1,2,3]
        if publicSettingMode?.chipType == .AC707N {
            range = [0,1,2,3,4]
        }
        for i in range {
            var url = Bundle.main.path(forResource: "VIE\(i)", ofType: ".png")
            if publicSettingMode?.chipType == .AC707N {
                url = Bundle.main.path(forResource: "VIE\(i)", ofType: ".jpg")
            }
            let dt = try?Data(contentsOf: URL(fileURLWithPath: url ?? ""))
            let img = UIImage(data: dt ?? Data()) ?? UIImage()
            let model = PtColModel(img: img, isSel: false,tag: i + tagNum + 1)
            model.imgPath = URL(fileURLWithPath: url ?? "")
            if fmType == "VIE\(i)" {
                model.isSel = true
                model.isExit = true
            }
            for item in publicSettingMode?.fileModelList.value ?? [] {
                if item.fileName == "VIE\(i)" {
                    model.isExit = true
                }
            }
            items.append(model)
        }
        itemsArray.accept(items)
    }
    
    private func initWallPaper(_ uuid: String) {
        var items = [PtColModel]()
        let custom = checkLocalCustom(sourceType, uuid)
        let fmType = custom.0
        items.append(custom.1)
        naviView.titleLab.text = LanguageCls.localizableTxt("Wallpaper")
        let urls = PtColModel.loadAllWallPaperUrl()
        for i in 0..<urls.count {
            let url = Bundle.main.path(forResource: urls[i].lastPathComponent, ofType: nil)
            let dt = try?Data(contentsOf: URL(fileURLWithPath: url ?? ""))
            let img = UIImage(data: dt ?? Data()) ?? UIImage()
            let pm = PtColModel(img: img, isSel: false,tag: i+1, name: urls[i].lastPathComponent)
            if fmType == urls[i].lastPathComponent.components(separatedBy: ".").first {
                pm.isSel = true
            }
            items.append(pm)
        }
        itemsArray.accept(items)
    }
    
    private func editBtnAction() {
        if selectStatus {
            var allCount = 0
            for item in itemsArray.value  {
                if item.isExit {
                    allCount += 1
                }
            }
            if selectItems.count == allCount {
                rightBtn.setTitle(R.Language.lan("Select All"), for: .normal)
                selectItems.removeAll()
            }else{
                rightBtn.setTitle(R.Language.lan("Deselect All"), for: .normal)
                selectItems.removeAll()
                for item in itemsArray.value {
                    if item.tag == 0 {
                        continue
                    }
                    if !item.isExit {
                        continue
                    }
                    if item.name.uppercased() == publicSettingMode?.currentScreenSaver.value?.fileName.uppercased(){
                        continue
                    }
                    selectItems.append(item)
                }
            }
        }else{
            rightBtn.setImage(UIImage(), for: .normal)
            rightBtn.setTitle(R.Language.lan("Select All"), for: .normal)
            rightBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            naviView.rightView.snp.updateConstraints { make in
                make.width.equalTo(70)
            }
            naviView.existBtn.setImage(UIImage(), for: .normal)
            naviView.existBtn.setTitle(R.Language.lan("jl_cancel"), for: .normal)
            selectStatus = true
            deleteBtn.isHidden = false
        }
        collectView.reloadData()
    }
    
    private func deleteBtnAction(){
        if selectItems.count == 0 {
            self.view.makeToast(R.Language.lan("Please select at least one item"), position: .center)
            return
        }
        var removeList: [JLDialSourceModel] = []
        for item in selectItems {
            let name =  item.imgPath?.lastPathComponent.withoutExt() ?? ""
            for item in publicSettingMode?.fileModelList.value ?? [] {
                if item.fileName.uppercased() == name.uppercased() {
                    removeList.append(item)
                }
            }
        }
        
        removeList.removeAll(where: { $0.fileName.uppercased() == publicSettingMode?.currentScreenSaver.value?.fileName.uppercased()})
        
        if removeList.count > 0 {
            publicSettingMode?.deleteScreenSavers(removeList)
        }
        backBtnAction()
    }
    
    
    private func initItemsList() {
        let uuid = JL_RunSDK.sharedMe().mBleEntityM?.mUUID ?? "unKnow"
        if sourceType == PublicSettingViewModel.screenSaver {
            initScreenSaver(uuid)
        } else {
            initWallPaper(uuid)
        }
    }
    
    private func checkLocalCustom(_ type:UInt8, _ uuid: String) ->(String,PtColModel) {
        var localCustom = SwiftHelper.listFiles(R.path.protectCustom+"/"+uuid)
        var currentCrc = publicSettingMode?.currentScreenSaver.value?.crc ?? 0
        var fmType = publicSettingMode?.currentScreenSaver.value?.fileName ?? ""
        if type == PublicSettingViewModel.backgroundPaper {
            localCustom = SwiftHelper.listFiles(R.path.wallPaperCustom+"/"+uuid)
            fmType = publicSettingMode?.currentWallpaper.value?.filePath.withoutExt() ?? ""
            currentCrc = publicSettingMode?.currentWallpaper.value?.crc ?? 0
        }
        for i in 0..<localCustom.count {
            if let f = (localCustom[i] as NSString).lastPathComponent.components(separatedBy: ".").first {
                guard let crc = f.components(separatedBy: "-").last else{
                    return ("", PtColModel(img: UIImage(), isSel: false, tag: 0))
                }
                if String(format: "%04X", currentCrc) == crc {
                    let dt = try?Data(contentsOf: URL(fileURLWithPath: localCustom[i]))
                    let t = PtColModel(img: UIImage(data: dt ?? Data()) ?? UIImage(), isSel: false, tag: -1)
                    t.isSel = true
                    return (fmType, t)
                }
            }
        }
        if localCustom.count > 0 {
            let dt = try?Data(contentsOf: URL(fileURLWithPath: localCustom[0]))
            let t = PtColModel(img: UIImage(data: dt ?? Data()) ?? UIImage(), isSel: false, tag: 0)
            return (fmType, t)
        }
        return ("", PtColModel(img: UIImage(), isSel: false, tag: 0))
    }
    
    private func handleTouchUp(){
        let uuid = JL_RunSDK.sharedMe().mBleEntityM?.mUUID ?? "unKnow"
        collectView.rx.modelSelected(PtColModel.self).subscribe(onNext: { [weak self] model in
            guard let self = self else {return}
            if model.tag == 0 {
                if selectStatus { return }
                if SwiftHelper.listFiles(R.path.protectCustom+"/"+uuid).count > 0{
                    let vc = CustomSourcesVC()
                    vc.publicSetting = self.publicSettingMode
                    vc.sourceType = PublicSettingViewModel.screenSaver
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.selectAlbum.isHidden = false
                }
            }else{
                if (selectStatus) {
                    if !model.isExit { return }
                    if let index = selectItems.firstIndex(where: {$0.tag == model.tag}) {
                        selectItems.remove(at: index)
                    }else{
                        if sourceType == PublicSettingViewModel.screenSaver {
                            if publicSettingMode?.chipType == .AC707N {
                                if publicSettingMode?.currentScreenSaver.value?.fileName.uppercased() == model.name.uppercased() {
                                    return
                                }
                            }
                            selectItems.append(model)
                        } else {
                            selectItems.append(model)
                        }
                    }
                    collectView.reloadData()
                    var allCount = 0
                    for item in itemsArray.value {
                        if item.isExit {
                            allCount += 1
                        }
                    }
                    if allCount == selectItems.count {
                        rightBtn.setTitle(R.Language.lan("Deselect All"), for: .normal)
                    }else{
                        rightBtn.setTitle(R.Language.lan("Select All"), for: .normal)
                    }
                    return
                }
                if sourceType == PublicSettingViewModel.screenSaver {
                    if publicSettingMode?.chipType == .AC707N {
                        let fileName = model.imgPath?.lastPathComponent ?? ""
                        for item in publicSettingMode?.fileModelList.value ?? [] {
                            JLLogManager.logLevel(.DEBUG, content: "list updateCollect: \(item.fileName), selectFile: \(fileName.withoutExt())")
                            if item.fileName.uppercased() == fileName.withoutExt().uppercased() {
                                publicSettingMode?.activeVIE(name: item.fileName, vieImage: model.img)
                                return
                            }
                        }
                    }
                    if(model.gifUrl != nil){
                        let vc = ProtectPreviewVC()
                        vc.publicSettingVM = self.publicSettingMode
                        vc.gifUrl = model.gifUrl!
                        vc.fileName = (model.gifUrl!.path as NSString).lastPathComponent.replacingOccurrences(of: ".gif", with: "")
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else if(model.imgPath != nil){
                        let vc = ProtectPreviewVC()
                        vc.publicSettingVM = self.publicSettingMode
                        vc.showImage = model.img
                        vc.fileName = (model.imgPath!.path as NSString).lastPathComponent.replacingOccurrences(of: ".png", with: "")
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    guard let vm = self.publicSettingMode else { return }
                    if vm.fileModelList.value.contains(where: {
                        $0.fileName.uppercased() == model.name.uppercased()
                    }) {
                        vm.setWallPaper(model)
                    } else {
                        let vc = ProtectPreviewVC()
                        vc.showImage = model.img
                        vc.publicSettingVM = self.publicSettingMode
                        vc.fileName = (model.imgPath!.path as NSString).lastPathComponent.replacingOccurrences(of: ".png", with: "")
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func makePickerImage(_ type:UIImagePickerController.SourceType){
        
        imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = type
        if (type == .camera) {
            imagePickerController.cameraDevice = .rear;
        }
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .fullScreen
        self.present(imagePickerController, animated: true)
    }
    
}


extension ScreenProtectMoreVC:UIImagePickerControllerDelegate & UINavigationControllerDelegate,HQImageEditViewControllerDelegate,LanguagePtl{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false)
        if let image = info[.originalImage] as? UIImage {
            cutImgv = HQImageEditViewController()
            cutImgv.originImage = image
            cutImgv.delegate = self
            cutImgv.maskViewAnimation = true;
            cutImgv.editViewSize = CGSizeMake(320, 176)
            self.navigationController?.pushViewController(cutImgv, animated: true)
        }
    }
    

    func edit(_ vc: HQImageEditViewController, finishiEditShotImage image: UIImage, originSizeImage: UIImage) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: DispatchWorkItem(block: { [weak self] in
            let vc = ProtectPreviewVC()
            vc.showImage = image
            vc.publicSettingVM = self!.publicSettingMode
            self?.navigationController?.pushViewController(vc, animated: true)
        }))
    }
    
    func editControllerDidClickCancel(_ vc: HQImageEditViewController) {
        vc.navigationController?.popViewController(animated: true)
    }

    func languageChange() {
        initUI()
    }
}
