//
//  ProtectUpdateVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/6/3.
//  Copyright © 2025 杰理科技. All rights reserved.
//
import UIKit
import WebKit

class ProtectUpdateVC: BasicViewController {
    var publicSetting: PublicSettingViewModel!
    var orginImage: UIImage!
    var showImage: UIImage!
    var gifUrl: URL!
    var fileName: String = ""
    var sourceType: UInt8 = 0x01
    

    private let uploadingLab = UILabel()
    private let preViewImgv = UIImageView()
    private var gifImgv: WKWebView?
    private let pViewCenterImgv = UIImageView()
    private let lockImgv = UIImageView()
    private let uploadingTipsLab = UILabel()
    private let progressView = UIProgressView()
    private let presentLab = UILabel()
    private let cancelBtn = UIButton()
    private let successLab = UILabel()
    private let confirmBtn = UIButton()

    private var tmpBin: String = ""
    private let disposeBag = DisposeBag()

    override func initUI() {
        super.initUI()
        tmpBin = "\(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!)/tmp.bin"
        setupUI()
        layoutUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTp()
    }

    private func setupUI() {
        naviView.titleLab.text = R.Language.lan("Charging Case Update")

        uploadingLab.text = R.Language.lan("Uploading...")
        uploadingLab.font = R.Font.medium(15)
        uploadingLab.textColor = UIColor.black.withAlphaComponent(0.6)
        uploadingLab.textAlignment = .center
        uploadingLab.adjustsFontSizeToFitWidth = true

        preViewImgv.image = showImage
        preViewImgv.layer.cornerRadius = 8
        preViewImgv.clipsToBounds = true

        if let gifUrl = gifUrl {
            let webView = WKWebView()
            webView.load(URLRequest(url: gifUrl))
            webView.isUserInteractionEnabled = false
            webView.layer.cornerRadius = 8
            webView.clipsToBounds = true
            gifImgv = webView
        }

        lockImgv.image = UIImage(named: "Theme.bundle/bay_img_lock")
        pViewCenterImgv.image = UIImage(named: "Theme.bundle/bay_img_bg")

        uploadingTipsLab.text = R.Language.lan("Please keep Bluetooth and network on during the upload process. \n This process takes about 2 minutes.")
        uploadingTipsLab.font = R.Font.medium(14)
        uploadingTipsLab.textColor = .eHex("#242424")
        uploadingTipsLab.textAlignment = .center
        uploadingTipsLab.numberOfLines = 0

        progressView.progress = 0
        progressView.progressTintColor = .eHex("#7657EC")
        progressView.trackTintColor = .eHex("#D8D8D8")

        presentLab.text = "0%"
        presentLab.font = R.Font.medium(14)
        presentLab.textColor = .eHex("#242424")
        presentLab.textAlignment = .center

        cancelBtn.setTitle(R.Language.lan("jl_cancel"), for: .normal)
        cancelBtn.titleLabel?.font = R.Font.medium(14)
        cancelBtn.setTitleColor(.eHex("#242424"), for: .normal)
        cancelBtn.backgroundColor = UIColor.black.withAlphaComponent(0.07)
        cancelBtn.layer.cornerRadius = 24
        cancelBtn.clipsToBounds = true
        cancelBtn.rx.tap.bind { [weak self] in self?.cancelAction() }
            .disposed(by: disposeBag)

        successLab.text = R.Language.lan("Update Successfully")
        successLab.font = R.Font.medium(18)
        successLab.textColor = UIColor.black.withAlphaComponent(0.9)
        successLab.textAlignment = .center
        successLab.isHidden = true
        
        confirmBtn.setTitle(R.Language.lan("device_paired_finish"), for: .normal)
        confirmBtn.titleLabel?.font = R.Font.medium(15)
        confirmBtn.setTitleColor(.white, for: .normal)
        confirmBtn.backgroundColor = .eHex("#7657EC")
        confirmBtn.layer.cornerRadius = 24
        confirmBtn.clipsToBounds = true
        confirmBtn.rx.tap.bind { [weak self] in self?.confirmAction() }
            .disposed(by: disposeBag)
        confirmBtn.isHidden = true

        [uploadingLab, uploadingTipsLab, progressView, presentLab, pViewCenterImgv,
         preViewImgv, lockImgv, cancelBtn, successLab, confirmBtn].forEach {
            view.addSubview($0)
        }

        if let gifView = gifImgv {
            view.addSubview(gifView)
        }

        if sourceType == PublicSettingViewModel.backgroundPaper {
            lockImgv.isHidden = true
        }
    }

    private func layoutUI() {
        uploadingLab.snp.makeConstraints {
            $0.top.equalTo(naviView.snp.bottom).offset(36)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }

        pViewCenterImgv.snp.makeConstraints {
            $0.top.equalTo(uploadingLab.snp.bottom).offset(39)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 238, height: 222))
        }

        preViewImgv.snp.makeConstraints {
            $0.top.equalTo(pViewCenterImgv.snp.top).offset(102)
            $0.centerX.equalTo(pViewCenterImgv)
            $0.size.equalTo(CGSize(width: 120, height: 65))
        }

        gifImgv?.snp.makeConstraints { $0.edges.equalTo(preViewImgv) }

        lockImgv.snp.makeConstraints {
            $0.top.equalTo(pViewCenterImgv.snp.top).offset(102)
            $0.centerX.equalTo(pViewCenterImgv)
            $0.size.equalTo(CGSize(width: 120, height: 65))
        }

        uploadingTipsLab.snp.makeConstraints {
            $0.bottom.equalTo(progressView.snp.top).offset(-30)
            $0.left.right.equalToSuperview().inset(40)
        }

        progressView.snp.makeConstraints {
            $0.bottom.equalTo(presentLab.snp.top).offset(-20)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(4)
        }

        presentLab.snp.makeConstraints {
            $0.bottom.equalTo(cancelBtn.snp.top).offset(-20)
            $0.left.right.equalToSuperview().inset(40)
        }

        cancelBtn.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-64)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }

        successLab.snp.makeConstraints {
            $0.top.equalTo(pViewCenterImgv.snp.bottom).offset(54)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }

        confirmBtn.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-64)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
    }

    private func cancelAction() {
        guard let mgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else { return }
        mgr.mFileManager.cmdStopBigFileData()
        if let targetVC = navigationController?.viewControllers.first(where: { $0 is ColorScreenSetVC }) {
            navigationController?.popToViewController(targetVC, animated: true)
        }
    }

    private func confirmAction() {
        if let targetVC = navigationController?.viewControllers.first(where: { $0 is ColorScreenSetVC }) {
            navigationController?.popToViewController(targetVC, animated: true)
        }
    }
    
    private func startTp() {
        if let gifUrl = gifUrl {
            guard let data = try? Data(contentsOf: gifUrl) else {return}
            publicSetting.makeGIFBin(data) { [weak self] binData in
                guard let self = self,
                      let binData = binData else { return }
                publicSetting.transportToDev(data: binData, name: fileName.withoutExt()) { status, progress, err in
                    if status == -1 {
                        self.refreshUI(false)
                    }
                    if status == 0 {
                        self.refreshUI(true)
                    }
                    if status == 1 {
                        self.progressView.progress = Float(progress)
                        self.presentLab.text = String(format: "%.0f%%", progress * 100)
                    }
                }
            }
        }else{
            guard let imageData = publicSetting.makeConvert(showImage) else {return}
            let targetName = fileName.withoutExt()
            publicSetting.transportToDev(data: imageData, name: targetName) {
                status,
                progress,
                err in
                if status == -1 {
                    self.refreshUI(false, err as NSError?)
                }
                if status == 0 {
                    self.refreshUI(true)
                    self.publicSetting.activeVIE(name: targetName, vieImage: self.orginImage)
                }
                if status == 1 {
                    self.progressView.progress = Float(progress)
                    self.presentLab.text = String(format: "%.0f%%", progress * 100)
                }
            }
        }
    }
    
    private func refreshUI(_ status: Bool, _ err: NSError? = nil) {
        successLab.text = status ? R.Language
            .lan("Update Successfully") : R.Language
            .lan("Upload Failed")
        if let err = err, let result = err.userInfo["result"] as? Int {
            if result == 6 {
                successLab.text = R.Language.lan("Insufficient space on device")
            }
        }
        uploadingLab.isHidden = true
        uploadingTipsLab.isHidden = true
        cancelBtn.isHidden = true
        confirmBtn.isHidden = false
        successLab.isHidden = false
        progressView.isHidden = true
        presentLab.isHidden = true
    }
}

