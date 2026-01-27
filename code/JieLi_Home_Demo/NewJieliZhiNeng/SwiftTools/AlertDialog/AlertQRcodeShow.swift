//
//  AlertQRcodeShow.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/10/11.
//

import CoreImage
import Photos
import SwiftyAttributes
import UIKit
import JLLogHelper

class AlertQRcodeShow: BasicView {
    private let bgView = UIView()
    private let centerView = UIView()
    private let nameLab = UILabel()
    private let pswLab = UILabel()
    private let qrcodeImgv = UIImageView()
    private let tipsLab = UILabel()
    private let cancelBtn = UIButton()
    private let confirmBtn = UIButton()

    weak var deviceVM: DeviceInfoViewModel?

    override func initUI() {
        super.initUI()
        bgView.backgroundColor = .black.withAlphaComponent(0.4)
        centerView.backgroundColor = .white
        centerView.layer.cornerRadius = 16
        centerView.layer.masksToBounds = true

        let width = UIScreen.main.bounds.size.width
        centerView.frame = CGRect(x: 0, y: 0, width: width - 64, height: 353)
        let bgLayer1 = CAGradientLayer()
        bgLayer1.colors = [UIColor(red: 0.83, green: 0.88, blue: 1, alpha: 1).cgColor,
                           UIColor(red: 0.99, green: 1, blue: 1, alpha: 1).cgColor,
                           UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
                           UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor]
        bgLayer1.locations = [0, 0.33, 0.36, 1]
        bgLayer1.frame = centerView.bounds
        bgLayer1.startPoint = CGPoint(x: 1, y: 0)
        bgLayer1.endPoint = CGPoint(x: 1, y: 1)
        centerView.layer.insertSublayer(bgLayer1, at: 1)

        addSubview(bgView)
        addSubview(centerView)
        centerView.addSubview(nameLab)
        centerView.addSubview(pswLab)
        centerView.addSubview(qrcodeImgv)
        centerView.addSubview(tipsLab)
        centerView.addSubview(cancelBtn)
        addSubview(confirmBtn)

        cancelBtn.setImage(R.image.popup_icon_close(), for: .normal)

        confirmBtn.setTitle(R.localStr.saveImage(), for: .normal)
        confirmBtn.setTitleColor(R.color.btnBlueText(), for: .normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        confirmBtn.backgroundColor = .white
        confirmBtn.layer.cornerRadius = 22
        confirmBtn.layer.masksToBounds = true
        confirmBtn.layer.borderWidth = 1
        confirmBtn.layer.borderColor = R.color.btnBlueText()?.cgColor

        tipsLab.text = R.localStr.pleaseSaveTheQRCodeForYourReceivingDeviceToListenToTheAudioFromThisDevice()
        tipsLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        tipsLab.textColor = R.color.fontBackText_90()
        tipsLab.adjustsFontSizeToFitWidth = true
        tipsLab.numberOfLines = 0
        tipsLab.textAlignment = .center

        nameLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nameLab.attributedText = (R.localStr.name() + ":").withTextColor(R.color.fontBackText_40()!) +
            "HomeTV#2".withTextColor(R.color.fontBackText_90()!)
        nameLab.textAlignment = .center

        pswLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        pswLab.attributedText = (R.localStr.password() + ":").withTextColor(R.color.fontBackText_40()!) +
            "123456".withTextColor(R.color.fontBackText_90()!)
        pswLab.textAlignment = .center

        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        centerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.8)
            make.left.right.equalToSuperview().inset(32)
            make.height.equalTo(353)
        }

        cancelBtn.snp.makeConstraints { make in
            make.right.top.equalToSuperview().inset(8)
            make.width.height.equalTo(32)
        }

        nameLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(cancelBtn.snp.bottom)
            make.height.equalTo(22)
        }

        pswLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(nameLab.snp.bottom).offset(4)
            make.height.equalTo(22)
        }

        qrcodeImgv.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(pswLab.snp.bottom).offset(16)
            make.width.height.equalTo(160)
        }

        tipsLab.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.top.equalTo(qrcodeImgv.snp.bottom).offset(20)
            make.bottom.equalToSuperview().inset(16)
        }

        confirmBtn.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(32)
            make.top.equalTo(centerView.snp.bottom).offset(16)
            make.height.equalTo(44)
        }
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidden)))
    }

    override func initData() {
        super.initData()
        makeData()

        cancelBtn.rx.tap.subscribe { _ in
            self.hidden()
        }.disposed(by: disposeBag)

        confirmBtn.rx.tap.subscribe { _ in
            self.checkAndRequestPermission { status in
                if status {
                    self.saveToLibrary()
                } else {
                    self.showSettingsAlert()
                }
            }
        }.disposed(by: disposeBag)
    }

    func show(_ model: DeviceInfoViewModel) {
        deviceVM = model
        makeData()
        AlertManager.windows()?.addSubview(self)
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @objc func hidden() {
        removeFromSuperview()
        deviceVM = nil
        isHidden = true
    }

    private func makeData() {
        guard let auracastLancerManager = deviceVM?.auracastLancerManager else {
            JLLogManager.logLevel(.DEBUG, content:"deviceVM is nil")
            return
        }
        var broadcastCodeStr = ""
        if let broadcastCode = auracastLancerManager.settingMode?.broadcastCode {
            broadcastCodeStr = String(data: broadcastCode, encoding: .utf8) ?? ""
        }
            
            
        nameLab.attributedText = (R.localStr.name() + ":").withTextColor(R.color.fontBackText_40()!) +
        (auracastLancerManager.settingMode?.broadcastName ?? "").withTextColor(R.color.fontBackText_90()!)
        if broadcastCodeStr.count > 0 {
            pswLab.attributedText = (R.localStr.password() + ":").withTextColor(R.color.fontBackText_40()!) +
            broadcastCodeStr.withTextColor(R.color.fontBackText_90()!)
        } else {
            pswLab.attributedText = (R.localStr.password() + ":").withTextColor(R.color.fontBackText_40()!) +
                R.localStr.unencrypted().withTextColor(R.color.fontBackText_90()!)
        }

        let dict = ["code": broadcastCodeStr, "name": auracastLancerManager.settingMode?.broadcastName]
        
        do {
            let dictData = try JSONSerialization.data(withJSONObject: dict, options: [])
            let dictStrStr = String(data: dictData, encoding: .utf8) ?? ""
            let code = generateQRCode(from: dictStrStr)
            qrcodeImgv.image = code
        } catch {
            JLLogManager.logLevel(.ERROR, content: "生成二维码失败")
        }
    }

    private func generateQRCode(from string: String, size: CGSize = CGSize(width: 160, height: 160)) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")

            if let output = filter.outputImage {
                let scalex = size.width / output.extent.size.width
                let scaley = size.height / output.extent.size.height
                let ciImg = output.transformed(by: CGAffineTransform(scaleX: scalex, y: scaley))
                return UIImage(ciImage: ciImg, scale: 1, orientation: .up)
            }
        }

        return nil
    }

    private func saveToLibrary() {
        if qrcodeImgv.image != nil {
            cancelBtn.isHidden = true
            UIGraphicsBeginImageContextWithOptions(centerView.bounds.size, true, UIScreen.main.scale)
            guard let context = UIGraphicsGetCurrentContext() else {
                JLLogManager.logLevel(.ERROR, content: "获取图形上下文失败")
                makeToast(R.localStr.failedToSaveImage(), position: .center)
                cancelBtn.isHidden = false
                return
            }
            centerView.layer.render(in: context)
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                JLLogManager.logLevel(.ERROR, content: "获取图像失败")
                cancelBtn.isHidden = false
                makeToast(R.localStr.failedToSaveImage(), position: .center)
                return
            }
            UIGraphicsEndImageContext()
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            makeToast(R.localStr.imageSaved(), position: .center)
            cancelBtn.isHidden = false
        } else {
            makeToast(R.localStr.failedToSaveImage(), position: .center)
        }
    }

    private func checkAndRequestPermission(completion: @escaping (Bool) -> Void) {
        // 检查权限状态
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    // 权限已授权
                    completion(true)
                case .denied:
                    // 用户拒绝了权限
                    completion(false)
                case .restricted:
                    // 权限受限制，例如家长控制
                    completion(false)
                case .notDetermined:
                    // 用户未决定是否授权
                    completion(false)
                case .limited:
                    break
                @unknown default:
                    // 处理未知情况
                    completion(false)
                }
            }
        }
    }

    private func showSettingsAlert() {
        let message = R.localStr.pleaseGoToApplicationManagementPermissionManagementToAllowPermissions()
        let alertController = UIAlertController(title: R.localStr.missingPermissions(),
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: R.localStr.oK(), style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        alertController.addAction(UIAlertAction(title: R.localStr.cancel(), style: .cancel, handler: nil))
        contextView?.present(alertController, animated: true, completion: nil)
    }
}
