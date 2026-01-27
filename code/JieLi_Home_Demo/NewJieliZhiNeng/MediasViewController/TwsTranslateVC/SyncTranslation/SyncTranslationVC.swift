//
//  SyncTranslationVC.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/5/27.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import JLAudioUnitKit
import UIKit

class SyncTranslationVC: BasicViewController {
    let headerView = TimeHeaderView()
    let speakBtn = UIButton()
    let spectrogramView = SpectrogramView()
    let subTable = UITableView()
    let bottomView = SyncTraBottomView()
    let lanSelectView = LanguageSelect()
    private var syncVM: SyncTranslationVM!
    private var isMuteObs: NSKeyValueObservation?
    private let disposeBag = DisposeBag()
    private let bottomInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isMuteObs?.invalidate()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        TimerHelper.stopAllTimers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncVM.syncSpeakArray
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let tableView = subTable
                guard tableView.numberOfSections > 0 else { return }
                let rowCount = tableView.numberOfRows(inSection: 0)
                guard rowCount > 0 else { return }

                let lastIndex = IndexPath(row: rowCount - 1, section: 0)
                tableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
            })
            .disposed(by: disposeBag)
        configLanguage()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func backBtnAction() {
        if TranslateVM.shared.currentMode.modeType != .recordTranslate {
            exitSyncTranslationVC()
            return
        }
        let alert = UIAlertController(title: nil, message: R.Language.lan("Are you sure you want to exit simultaneous interpretation and delete the translation history?"), preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: R.Language.lan("Cancel"), style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            syncVM.exitMode()
        }
        let confirmAction = UIAlertAction(title: R.Language.lan("confirm"), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
                syncVM.exitMode(delete: true)
            exitSyncTranslationVC()
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true, completion: nil)
    }

    override func initUI() {
        super.initUI()
        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(speakBtn)
        view.addSubview(spectrogramView)
        view.addSubview(subTable)
        view.addSubview(bottomView)
        view.addSubview(lanSelectView)

        speakBtn.setImage(R.Image.img("icon_mute_sync_open"), for: .normal)
        headerView.configSwitch(R.Image.img("arrow_left"))
        headerView.configImage(
            R.Image.img("translation_icon_our"),
            R.Image.img("translation_icon_phone")
        )
        headerView.configText(
            TranslateVM.shared.translateLanguage.1[0].title(),
            TranslateVM.shared.translateLanguage.0.title()
        )
        lanSelectView.languangeSelectView.configLanguageTitle(
            mySide: LanguageCls.localizableTxt("Play"),
            otherSide: LanguageCls.localizableTxt("Receive")
        )

        spectrogramView.layer.cornerRadius = 4
        spectrogramView.layer.masksToBounds = true

        subTable.register(TranslateSyncSpeakCell.self, forCellReuseIdentifier: "cell")
        subTable.separatorStyle = .none
        subTable.rowHeight = UITableView.automaticDimension
        subTable.estimatedRowHeight = 60
        subTable.keyboardDismissMode = .interactive
        subTable.allowsSelection = false
        subTable.backgroundColor = .clear

        headerView.snp.makeConstraints { make in
            make.top.equalTo(naviView.titleLab).offset(-10)
            make.centerX.equalTo(naviView.snp.centerX)
        }

        speakBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(16)
            make.width.height.equalTo(26)
            make.centerY.equalTo(headerView.snp.centerY)
        }

        spectrogramView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(headerView.snp.bottom).offset(4)
            make.height.equalTo(40)
        }

        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(spectrogramView.snp.bottom).offset(8)
            make.bottom.equalTo(bottomView.snp.top).offset(-4)
        }

        bottomView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(4)
        }

        lanSelectView.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalToSuperview()
        }
    }

    override func initData() {
        super.initData()
        syncVM = SyncTranslationVM(viewController: self)
        syncVM.syncSpeakArray.bind(to: subTable.rx.items(cellIdentifier: "cell", cellType: TranslateSyncSpeakCell.self)) { _, element, cell in
            cell.configContent(original: element.original, translate: element.translate)
        }.disposed(by: disposeBag)

        syncVM.timerCounter.subscribe(onNext: { [weak self] time in
            guard let self = self else { return }
            self.headerView.setTime(time: time)
        }).disposed(by: disposeBag)

        bottomView.languageBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            syncVM.exitMode()
            self.lanSelectView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }).disposed(by: disposeBag)

        bottomView.controlBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            syncVM.controlAction()
        }).disposed(by: disposeBag)

        bottomView.stopBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            syncVM.exitMode()
            self.exitSyncTranslationVC()
        }).disposed(by: disposeBag)

        lanSelectView.confirmBtn.rx.tap.subscribe(onNext: { [weak self] _ in
            guard let self = self else { return }
            self.lanSelectView.snp.remakeConstraints { make in
                make.top.equalTo(self.view.snp.bottom)
                make.left.right.equalToSuperview()
                make.height.equalToSuperview()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            syncVM.dicChangeLanguage()
        }).disposed(by: disposeBag)

        speakBtn.rx.tap.subscribe(onNext: { _ in
            TranslateVM.shared.mute(isMute: !TranslateVM.shared.isMute)
        }).disposed(by: disposeBag)

        isMuteObs = TranslateVM.shared.observe(\.isMute, options: .new) { [weak self] _, change in
            guard let self = self else { return }
            if change.newValue == true {
                self.speakBtn.setImage(R.Image.img("icon_mute_sync_close"), for: .normal)
            } else {
                self.speakBtn.setImage(R.Image.img("icon_mute_sync_open"), for: .normal)
            }
        }

        TranslateVM.shared.subjectCurrentMode.subscribe(onNext: { [weak self] mode in
            guard let self = self else { return }
            if mode.modeType == .recordTranslate {
                bottomView.controlBtn.setImage(R.Image.img("icon_pause"), for: .normal)
            } else if mode.modeType == .idle {
                bottomView.controlBtn.setImage(R.Image.img("icon_play_sync"), for: .normal)
            }
            configLanguage()
        }).disposed(by: disposeBag)

        TranslateVM.shared.recordPcmData.subscribe(onNext: { [weak self] pcmData in
            guard let self = self else { return }
            DispatchQueue.main.async(execute: DispatchWorkItem(block: {
                self.spectrogramView.appendPCMData(from: pcmData)
            }))
        }).disposed(by: disposeBag)
    }



    func configLanguage() {
        lanSelectView.languangeSelectView
            .configLanguage(
                mySide: TranslateVM.shared.translateLanguage.1[0],
                otherSide: TranslateVM.shared.translateLanguage.0
            )
        headerView.configText(
            TranslateVM.shared.translateLanguage.1[0].title(),
            TranslateVM.shared.translateLanguage.0.title()
        )
        TranslateTools.saveLanguages(
            (
                TranslateVM.shared.translateLanguage.1[0],
                TranslateVM.shared.translateLanguage.0
            ),
            type: .sync
        )
    }

    private func exitSyncTranslationVC() {
        guard let viewControllers = navigationController?.viewControllers, viewControllers.count >= 3 else { return }
        navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
}
