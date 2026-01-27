//
//  TranslationNavVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/8.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import MarqueeLabel
import Toast_Swift
import UIKit

class TranslationNavVC: BasicViewController {
    private var subTable = UITableView()
    private var itemsArray = BehaviorRelay<[TranslationTypeMode]>(value: [])
    private var promission = false
    private var disposeBag = DisposeBag()

    override func initUI() {
        super.initUI()
        naviView.titleLab.text = LanguageCls.localizableTxt("Translation")
        subTable.register(TranslationTypeCell.self, forCellReuseIdentifier: "cell")
        subTable.rowHeight = 82
        subTable.separatorStyle = .none
        subTable.backgroundColor = .clear
        view.addSubview(subTable)
        subTable.snp.makeConstraints { make in
            make.top.equalTo(naviView.snp.bottom).offset(7)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-16)
        }

        itemsArray.bind(to: subTable.rx.items(cellIdentifier: "cell", cellType: TranslationTypeCell.self)) { _, model, cell in
            cell.configModel(model: model)
        }.disposed(by: disposeBag)
    }

    override func initData() {
        super.initData()
        itemsArray.accept([
            // TranslationTypeMode(image: R.Image.img("icon_call_translation"),
            //                     title: LanguageCls.localizableTxt("Call translation"),
            //                     detail: LanguageCls.localizableTxt("During a call, both parties will hear the translated voice content")),
            TranslationTypeMode(image: R.Image.img("icon_facetoface"),
                                title: LanguageCls.localizableTxt("Face-to-face translation"),
                                detail: LanguageCls.localizableTxt("One person holds the phone and the other wears headphones, and two-way translation is possible")),
            TranslationTypeMode(image: R.Image.img("icon_chuanyi"),
                                title: LanguageCls.localizableTxt("Simultaneous interpretation"),
                                detail: LanguageCls.localizableTxt("Put the phone close to the sound source, and the headphones will play the translated sound")),
        ])

        subTable.rx.itemSelected.subscribe(
            onNext: { [weak self] index in
                guard let self = self,
                      let mgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else { return }
                if index.row == 3 {
                    if mgr.getDeviceModel().mCallType == .OFF {
                        self.view.makeToast(
                            LanguageCls.localizableTxt("No call currently"),
                            position: .center
                        )
                        return
                    }
//                    if mgr.mTwsManager.electricity.powerLeft <= 0 || mgr.mTwsManager.electricity.powerRight <= 0 {
//                        showTwsNotWear()
//                        return
//                    }
                    let vc = LanguageSelectVC()
                    vc.type = .call
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                if mgr.getDeviceModel().mCallType == .ON {
                    self.view.makeToast(
                        LanguageCls.localizableTxt("msg_call_tip"),
                        position: .center
                    )
                    return
                }
                if index.row == 0 {
                    if !self.promission {
                        requestRecordPermission()
                        return
                    }
                    let vc = LanguageSelectVC()
                    vc.type = .face
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                if index.row == 1 {
                    if !self.promission {
                        requestRecordPermission()
                        return
                    }
                    let vc = LanguageSelectVC()
                    vc.type = .sync
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }).disposed(by: disposeBag)

        guard let mgr = JL_RunSDK.sharedMe().mBleEntityM?.mCmdManager else {
            return
        }
        TranslateVM.shared.initTranslateMgr(mgr)
        TranslateVM.shared.isLocal = false
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent {
            TranslateVM.shared.clear()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestRecordPermission()
    }
    
    
    private func showTwsNotWear() {
        let alert = UIAlertController(title: LanguageCls.localizableTxt("Please wear left + right headphones"),
                                      message: LanguageCls.localizableTxt("You need to wear both left and right headphones to use the call translation function."), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LanguageCls.localizableTxt("I understand"), style: .default, handler: {  _ in
        }))
        present(alert, animated: true, completion: nil)
    }

    private func requestRecordPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            self.promission = granted
            DispatchQueue.main.async {
                if granted {
                    // 权限获取成功
                    self.requestQRScan()
                } else {
                    let alert = UIAlertController(
                        title: LanguageCls.localizableTxt("Microphone permission is required"),
                        message: LanguageCls.localizableTxt("Please enable microphone permission in settings"),
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: LanguageCls.localizableTxt("Cancel"), style: .cancel))
                    alert.addAction(UIAlertAction(title: LanguageCls.localizableTxt("Go to settings"), style: .default) { _ in
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    })
                    // 在当前的ViewController中弹出
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    private func requestQRScan(){
        if KeyAuth.ByteDance.getAiAuth()?.isInvalid() != true {
            let alert = UIAlertController(title: R.localStr.tips(), message: R.localStr.theDoubaoModelKeyHasNotYetBeenAddedPleaseScanTheQRCodeToEnterTheKey(), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: R.localStr.cancel(), style: .cancel) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            let confirmAction = UIAlertAction(title: R.localStr.confirm(), style: .default) { _ in
                self.scanQRCode()
            }
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func scanQRCode() {
        let qrScanVc = QRScanerViewController()
        qrScanVc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(qrScanVc, animated: true)
        qrScanVc.handleScanResult = { [weak self] result in
            guard let self = self else { return }
            let auth = KeyAuth.makeAuth(result)
            self.navigationController?.popViewController(animated: true)
            if auth.isInvalid(),!auth.accessToken.isEmpty {
                self.view.makeToast(R.localStr.keyAddSuccess())
                return
            }
            self.view.makeToast(R.localStr.keyAddFailed())
        }
    }
}

private struct TranslationTypeMode {
    let image: UIImage
    let title: String
    let detail: String
}

private class TranslationTypeCell: UITableViewCell {
    private let imgView = UIImageView()
    private let titleLab = UILabel()
    private let detailLab = MarqueeLabel()
    private let bgContentView = UIView()
    private let nextIconImgv = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        imgView.contentMode = .scaleAspectFit
        contentView.addSubview(bgContentView)
        bgContentView.addSubview(imgView)
        bgContentView.addSubview(titleLab)
        bgContentView.addSubview(detailLab)
        bgContentView.addSubview(nextIconImgv)

        bgContentView.backgroundColor = .white
        bgContentView.layer.cornerRadius = 8
        bgContentView.layer.shadowColor = UIColor.eHex("#CDE6FB", alpha: 0.2).cgColor
        bgContentView.layer.shadowOffset = CGSize(width: 0, height: -2)
        bgContentView.layer.shadowOpacity = 1
        bgContentView.layer.shadowRadius = 16

        titleLab.textColor = .eHex("#000000", alpha: 0.9)
        titleLab.font = R.Font.medium(16)

        detailLab.textColor = .eHex("#000000", alpha: 0.5)
        detailLab.font = R.Font.medium(12)

        nextIconImgv.image = R.Image.img("Theme.bundle/icon_next")

        bgContentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.left.right.equalToSuperview()
        }

        imgView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().inset(10)
        }

        titleLab.snp.makeConstraints { make in
            make.left.equalTo(imgView.snp.right).offset(6)
            make.top.equalTo(imgView.snp.top)
            make.right.equalTo(nextIconImgv.snp.left).offset(-4)
            make.bottom.equalTo(detailLab.snp.top).offset(-4)
        }

        detailLab.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom).offset(4)
            make.left.equalTo(imgView.snp.right).offset(6)
            make.bottom.equalTo(imgView.snp.bottom)
            make.right.equalTo(nextIconImgv.snp.left).offset(-4)
        }

        nextIconImgv.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(12)
        }
    }

    func configModel(model: TranslationTypeMode) {
        imgView.image = model.image
        titleLab.text = model.title
        detailLab.text = model.detail
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
