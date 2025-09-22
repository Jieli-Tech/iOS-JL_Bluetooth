//
//  CustomSourcesVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/6/4.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

class CustomSourcesVC: BasicViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HQImageEditViewControllerDelegate {
    
    ///0x01 屏保
    ///0x03 背景纸
    public var sourceType:UInt8 = 1
    
    // MARK: - Properties
    private var customView: CustomProtectView!
    private var albumView: ShowSelectAlbumView!
    private var imagePickerController: UIImagePickerController!
    private var deleteBtn: UIButton = UIButton()
    private var selectBtn: UIButton!
    private var addBtn: UIButton!
    private var viewModel: PublicSettingViewModel!
    private let disposeBag = DisposeBag()
    
    /// Public setter for injecting the ViewModel
    var publicSetting: PublicSettingViewModel! {
        didSet {
            viewModel = publicSetting
        }
    }
    
    // MARK: - Life Cycle
    // MARK: - UI Setup
    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
        // Navigation title
        
        naviView.titleLab.text = R.Language.lan("Custom")
        
        // Right bar button (Select/Deselect All)
        selectBtn = UIButton()
        selectBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        selectBtn.titleLabel?.font = R.Font.medium(14)
        selectBtn.setTitleColor(.eHex("#242424"), for: .normal)
        let editIcon = UIImage(named: "Theme.bundle/bay_icon_edit.png")?.withRenderingMode(.alwaysOriginal)
        selectBtn.setImage(editIcon, for: .normal)
        
        // Bind tap to edit action
        selectBtn.rx.tap
            .bind { [weak self] in
                self?.editBtnAction()
            }
            .disposed(by: disposeBag)
        
        naviView.rightView.addSubview(selectBtn)
        selectBtn.snp.makeConstraints { make in
            make.edges.equalTo(naviView.rightView)
        }
        
        // CustomProtectView
        customView = CustomProtectView()
        customView.publicSetting = viewModel
        customView.type = sourceType
        customView.viewController = self
        view.addSubview(customView)
        customView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(naviView.snp.bottom).offset(8)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        // Delete Button (initially hidden)
        deleteBtn.backgroundColor = .eHex("#F4F4F4")
        deleteBtn.setTitle(R.Language.lan("delete"), for: .normal)
        deleteBtn.setTitleColor(.eHex("#242424"), for: .normal)
        deleteBtn.setTitleColor(.gray, for: .highlighted)
        deleteBtn.setImage(UIImage(named: "Theme.bundle/photo_icon_delete"), for: .normal)
        deleteBtn.titleLabel?.font = R.Font.medium(10)
        deleteBtn.titleLabel?.textAlignment = .center
        
        // Configure image/title insets
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
        
        // Add Button (floating)
        addBtn = UIButton(type: .custom)
        addBtn.setImage(UIImage(named: "Theme.bundle/bay_icon_add_02"), for: .normal)
        addBtn.rx.tap
            .bind { [weak self] in
                self?.addBtnAction()
            }
            .disposed(by: disposeBag)
        
        view.addSubview(addBtn)
        addBtn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-18)
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(78)
        }
        
        // Album selection overlay (initially hidden)
        albumView = ShowSelectAlbumView()
        if let window = UIApplication.shared.windows.first {
            window.addSubview(albumView)
            albumView.snp.makeConstraints { make in
                make.edges.equalTo(window)
            }
            albumView.isHidden = true
            
            albumView.selectBlock = { [weak self] index in
                guard let self = self else { return }
                self.albumView.isHidden = true
                self.addBtn.isHidden = false
                if index == 0 {
                    self.makePickerImage(type: .camera)
                } else if index == 1 {
                    self.makePickerImage(type: .savedPhotosAlbum)
                }
            }
        }
        
        // Handle choose callback from customView
        customView.handleChoose = { [weak self] list in
            guard let self = self else { return }
            if self.customView.isSelectedAll() {
                self.selectBtn.setTitle(R.Language.lan("Deselect All"), for: .normal)
                self.selectBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
            } else {
                self.selectBtn.setTitle(R.Language.lan("Select All"), for: .normal)
                self.selectBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
            }
        }
    }
    
    // MARK: - Button Actions
    
    private func editBtnAction() {
        if customView.isChooseType {
            if customView.isSelectedAll() {
                selectBtn.setTitle(R.Language.lan("Select All"), for: .normal)
                selectBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
                customView.selectAll(isSelect: false)
            } else {
                selectBtn.setTitle(R.Language.lan("Deselect All"), for: .normal)
                selectBtn.frame = CGRect(x: 0, y: 0, width: 70, height: 30)
                customView.selectAll(isSelect: true)
            }
        } else {
            // Switch to choose mode
            selectBtn.setImage(UIImage(), for: .normal)
            selectBtn.setTitle(R.Language.lan("Select All"), for: .normal)
            naviView.existBtn.setImage(UIImage(), for: .normal)
            naviView.existBtn.setTitle(R.Language.lan("jl_cancel"), for: .normal)
            
            customView.isChooseType = true
            deleteBtn.isHidden = false
            addBtn.isHidden = true
            customView.collectView.reloadData()
        }
    }
    
    override func backBtnAction() {
        let editIcon = UIImage(named: "Theme.bundle/bay_icon_edit.png")?.withRenderingMode(.alwaysOriginal)
        let backIcon = UIImage(named: "Theme.bundle/icon_return.png")?.withRenderingMode(.alwaysOriginal)
        
        if customView.isChooseType {
            selectBtn.setImage(editIcon, for: .normal)
            selectBtn.setTitle("", for: .normal)
            
            naviView.existBtn.setImage(backIcon, for: .normal)
            naviView.existBtn.setTitle("", for: .normal)
            
            customView.isChooseType = false
            customView.selectAll(isSelect: false)
            deleteBtn.isHidden = true
            addBtn.isHidden = false
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func deleteBtnAction() {
        let deleteArray = customView.getSelected()
        if deleteArray.count == 0 {
            self.view.makeToast(R.Language.lan("Please select at least one item"), position: .center)
            return
        }
        var removeList: [JLDialSourceModel] = []
        for path in deleteArray {
            try? FileManager.default.removeItem(atPath: path)
            let name = path.lastComponent()
            var isCompareCRC = false
            var crc = ""
            if name.hasPrefix("VIE_CST") {
                isCompareCRC = true
                crc = name.components(separatedBy: "-").last ?? ""
            }
            for item in publicSetting.fileModelList.value {
                if isCompareCRC {
                    if String(format: "%04X", item.crc) == crc {
                        removeList.append(item)
                    }
                } else {
                    if item.fileName.uppercased() == name.uppercased() {
                        removeList.append(item)
                    }
                }
            }
        }
        if removeList.count > 0 {
            publicSetting.deleteScreenSavers(removeList)
        }
        customView.reloadData(publicSetting.currentScreenSaver.value)
        backBtnAction()
    }
    
    private func addBtnAction() {
        albumView.isHidden = false
        addBtn.isHidden = true
    }
    
    // MARK: - UIImagePickerController
    
    private func makePickerImage(type: UIImagePickerController.SourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = type
        if type == .camera {
            imagePickerController.cameraDevice = .rear
        }
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            if let image = info[.originalImage] as? UIImage {
                let md = JL_RunSDK.sharedMe().dialInfoExtentedModel
                var imageSize = CGSize(width: 320, height: 172)
                if md?.size.width != 0 {
                    imageSize = md?.size ?? CGSize(width: 320, height: 172)
                }
                let vc = HQImageEditViewController()
                vc.originImage = image
                vc.delegate = self
                vc.maskViewAnimation = true
                vc.editViewSize = CGSize(width: imageSize.width, height: imageSize.height)
                vc.model = md!
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - HQImageEditViewControllerDelegate
    func edit(_ vc: HQImageEditViewController,
                        finishiEditShotImage image: UIImage,
                        originSizeImage: UIImage) {
        let previewVC = ProtectPreviewVC()
        let targetImg = ImageTools.machRadius(image)
        previewVC.showImage = targetImg
        previewVC.fileName = "VIE_CST"
        previewVC.publicSettingVM = viewModel
        previewVC.sourceType = sourceType
        if sourceType == PublicSettingViewModel.backgroundPaper {
            previewVC.fileName = "csbg_x"
        }
        navigationController?.pushViewController(previewVC, animated: true)
    }
    
    func editControllerDidClickCancel(_ vc: HQImageEditViewController) {
        vc.navigationController?.popViewController(animated: true)
    }
}
