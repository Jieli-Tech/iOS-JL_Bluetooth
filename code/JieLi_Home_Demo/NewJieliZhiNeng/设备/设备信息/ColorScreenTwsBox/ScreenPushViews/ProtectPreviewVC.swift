//
//  ProtectPreviewVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/6/3.
//  Copyright © 2025 杰理科技. All rights reserved.
//
import UIKit
import WebKit

@objcMembers class ProtectPreviewVC: BasicViewController {

    var publicSettingVM: PublicSettingViewModel!
    var showImage: UIImage?
    var gifUrl: URL?
    var fileName: String = ""
    var sourceType: UInt8 = 0x01 // 0x01 屏保，0x03 墙纸

    private let disposeBag = DisposeBag()
    private let ctView = UIView()
    private let tipsLockLabel = UILabel()
    private let lockSwitch = UISwitch()
    private let screenView = UIView()
    private let screenImageView = UIImageView()
    private var gifWebView: WKWebView?
    private let lockImageView = UIImageView()
    private let confirmButton = UIButton()

    override func initUI() {
        super.initUI()
        naviView.titleLab.text = R.Language.lan("Screen Savers")
        setupUI()
        setupLayout()
        bindActions()

        if sourceType == PublicSettingViewModel.backgroundPaper {
            ctView.isHidden = true
            lockSwitch.isOn = false
            lockImageView.isHidden = true
            naviView.titleLab.text = R.Language.lan("Wall Paper")
        }
    }

    private func setupUI() {
        ctView.backgroundColor = .white
        ctView.layer.cornerRadius = 12
        view.addSubview(ctView)
        
        tipsLockLabel.text = R.Language.lan("Display Unlock Indicator")
        tipsLockLabel.font = R.Font.medium(15)
        tipsLockLabel.textColor = UIColor.black.withAlphaComponent(0.9)
        ctView.addSubview(tipsLockLabel)

        lockSwitch.onTintColor = .eHex( "#7657EC")
        lockSwitch.isOn = true
        ctView.addSubview(lockSwitch)

        screenView.backgroundColor = .white
        screenView.layer.cornerRadius = 14
        view.addSubview(screenView)

        screenImageView.image = showImage
        screenView.addSubview(screenImageView)

        if let gifUrl = gifUrl {
            let webView = WKWebView()
            webView.load(URLRequest(url: gifUrl))
            webView.isUserInteractionEnabled = false
            screenView.addSubview(webView)
            screenImageView.isHidden = true
            gifWebView = webView
        }

        lockImageView.image = UIImage(named: "Theme.bundle/bay_img_lock")
        screenView.addSubview(lockImageView)

        confirmButton.layer.cornerRadius = 24
        confirmButton.backgroundColor = .eHex( "#7657EC")
        confirmButton.setTitle(R.Language.lan("Upload"), for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.setTitleColor(.gray, for: .highlighted)
        confirmButton.titleLabel?.font = R.Font.medium(15)
        view.addSubview(confirmButton)
    }

    private func setupLayout() {
        ctView.snp.makeConstraints {
            $0.left.right.equalTo(view).inset(8)
            $0.top.equalTo(naviView.snp.bottom).offset(14)
            $0.height.equalTo(48)
        }

        tipsLockLabel.snp.makeConstraints {
            $0.left.equalTo(ctView).offset(16)
            $0.centerY.equalTo(ctView)
            $0.height.equalTo(20)
        }

        lockSwitch.snp.makeConstraints {
            $0.right.equalTo(ctView).offset(-16)
            $0.centerY.equalTo(ctView)
        }

        screenView.snp.makeConstraints {
            $0.top.equalTo(ctView.snp.bottom).offset(31)
            $0.centerX.equalTo(view)
            $0.width.equalTo(320)
            $0.height.equalTo(172)
        }

        screenImageView.snp.makeConstraints { $0.edges.equalToSuperview() }

        gifWebView?.snp.makeConstraints { $0.edges.equalToSuperview() }

        lockImageView.snp.makeConstraints {
            $0.center.equalTo(screenImageView)
        }

        confirmButton.snp.makeConstraints {
            $0.left.equalTo(view).offset(24)
            $0.right.equalTo(view).offset(-24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-98)
            $0.height.equalTo(48)
        }
    }

    private func bindActions() {
        lockSwitch.rx.isOn
            .bind(to: lockImageView.rx.isHiddenInverted)
            .disposed(by: disposeBag)

        confirmButton.rx.tap
            .bind { [weak self] in self?.onConfirmTapped() }
            .disposed(by: disposeBag)
    }

    private func onConfirmTapped() {
        let vc = ProtectUpdateVC()
        vc.publicSetting = publicSettingVM
        vc.showImage = saveAsImage()
        vc.orginImage = showImage
        vc.gifUrl = gifUrl
        vc.sourceType = sourceType
        vc.fileName = fileName
        navigationController?.pushViewController(vc, animated: true)
    }

    private func saveAsImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 320, height: 172))
        screenView.layer.cornerRadius = 0
        let image = renderer.image { context in
            screenView.layer.render(in: context.cgContext)
        }
        screenView.layer.cornerRadius = 14
        return image
    }
}

extension Reactive where Base: UIView {
    var isHiddenInverted: Binder<Bool> {
        return Binder(self.base) { view, isOn in
            view.isHidden = !isOn
        }
    }
}
