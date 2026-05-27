//
//  ColorScreenSetVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/12/5.
//  Copyright © 2023 杰理科技. All rights reserved.
//

import UIKit
import SnapKit

@objcMembers
class ColorScreenSetVC: BasicViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HQImageEditViewControllerDelegate {
    
    private var scrollV: UIScrollView!
    private var contentView: UIView!
    private var lightSetView: ScreenLightSetView!
    private var protectSetView: ScreenProtectSetView!
    private var bgPaperView: ScreenBgPaperView?
    private var animationView: ScreenAnimationView?
    private var imagePickerController: UIImagePickerController!
    private var publicSetting: PublicSettingViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.naviView.titleLab.text = LanguageCls.localizableTxt("Charging Case Setting")
        
        scrollV = UIScrollView()
        self.view.addSubview(scrollV)
        
        scrollV.snp.makeConstraints { make in
            make.top.equalTo(self.naviView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        contentView = UIView()
        contentView.backgroundColor = .clear
        scrollV.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        lightSetView = ScreenLightSetView()
        lightSetView.publicSetting = publicSetting
        lightSetView.addHandle()
        contentView.addSubview(lightSetView)
        
        lightSetView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(106)
        }
        
        protectSetView = ScreenProtectSetView()
        protectSetView.publicSetting = publicSetting
        protectSetView.contextView = self
        contentView.addSubview(protectSetView)
        
        protectSetView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.equalTo(lightSetView.snp.bottom).offset(10)
            make.height.equalTo(252)
        }
        
        if publicSetting.wallPaperMode != nil {
            let bgView = ScreenBgPaperView()
            bgView.publicSetting = publicSetting
            bgView.setupDataBinding()
            bgView.viewController = self
            contentView.addSubview(bgView)
            
            bgView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(8)
                make.top.equalTo(protectSetView.snp.bottom).offset(10)
                make.height.equalTo(252)
            }
            
            contentView.snp.makeConstraints { make in
                make.bottom.equalTo(bgView.snp.bottom).offset(10)
            }
            bgPaperView = bgView
        } else {
            contentView.snp.makeConstraints { make in
                make.bottom.equalTo(protectSetView.snp.bottom).offset(10)
            }
        }
        
        if publicSetting.sdkInfo?.projectId == 0x01 && publicSetting.sdkInfo?.chipId == 0x01 {
            let animView = ScreenAnimationView()
            animView.publicSetting = publicSetting
            animView.setupDataBinding()
            animView.updateData()
            contentView.addSubview(animView)
            animView.snp.makeConstraints { make in
                make.left.right.equalToSuperview().inset(8)
                if let bgView = bgPaperView {
                    make.top.equalTo(bgView.snp.bottom).offset(10)
                } else {
                    make.top.equalTo(protectSetView.snp.bottom).offset(10)
                }
                make.height.equalTo(158)
            }
            
            // Re-adjust contentView bottom
            contentView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
                make.width.equalToSuperview()
                make.bottom.equalTo(animView.snp.bottom).offset(10)
            }
            animationView = animView
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if SettingDefault.getWeatherPush() {
            JLWeatherSync.share().startWeather()
        }
        
        if let cmdMgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager {
            DialManager.openDialFileSystem(withCmdManager: cmdMgr) { type, progress in
                // do nothing
            }
        }
        
        protectSetView.updateByModel(publicSetting.screenSaverMode)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        publicSetting.getScreenLight()
    }
    
    func showAlbumView() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: R.Language.lan("Take Photo"), style: .default) { [weak self] _ in
            self?.makePickerImage(type: .camera)
        }
        let chooseFromAlbumAction = UIAlertAction(title: R.Language.lan("Choose From Album"), style: .default) { [weak self] _ in
            self?.makePickerImage(type: .savedPhotosAlbum)
        }
        let cancelAction = UIAlertAction(title: R.Language.lan("Cancel"), style: .cancel, handler: nil)
        
        alertController.addAction(takePhotoAction)
        alertController.addAction(chooseFromAlbumAction)
        alertController.addAction(cancelAction)
        
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func initDataAction(_ block: @escaping (Bool) -> Void) {
        publicSetting = PublicSettingViewModel.shared
        // 已经在 DeviceInfoViewController 中调用了 setup()
        if publicSetting.isReady {
            block(true)
        } else {
            publicSetting.isFinish = block
            if !publicSetting.isRunning {
                publicSetting.setup()
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    private func makePickerImage(type: UIImagePickerController.SourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = type
        if type == .camera {
            imagePickerController.cameraDevice = .rear
        }
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .fullScreen
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false) { [weak self] in
            guard let self = self else { return }
            guard let image = info[.originalImage] as? UIImage else { return }
            
            let md = JL_RunSDK.sharedMe().dialInfoExtentedModel
            var imageSize = CGSize(width: 320, height: 172)
            if let mdSize = md?.size, mdSize.width != 0 {
                imageSize = mdSize
            }
            
            let vc = HQImageEditViewController()
            vc.originImage = image
            vc.delegate = self
            vc.maskViewAnimation = true
            vc.editViewSize = imageSize
            if let model = md {
                vc.model = model
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - HQImageEditViewControllerDelegate
    
    func edit(_ vc: HQImageEditViewController, finishiEditShotImage image: UIImage, originSizeImage: UIImage) {
        let vc1 = ProtectPreviewVC()
        let targetImg = JLHomeImageTools.machRadius(image)
        vc1.showImage = targetImg
        vc1.fileName = "VIE_CST"
        vc1.publicSettingVM = publicSetting
        self.navigationController?.pushViewController(vc1, animated: true)
    }
    
    func editControllerDidClickCancel(_ vc: HQImageEditViewController) {
        vc.navigationController?.popViewController(animated: true)
    }
}
