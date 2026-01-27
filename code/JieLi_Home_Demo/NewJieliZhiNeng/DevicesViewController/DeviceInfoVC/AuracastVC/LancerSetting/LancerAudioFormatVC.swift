//
//  LancerAudioFormatVC.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/10/10.
//

import UIKit

class LancerAudioFormatVC: BaseViewController {
    private let audioFormatLab = UILabel()
    private let selectAudioFormatBtn = UIButton()
    private let currentAudioFormatLab = UILabel()
    private let audioFormatImgv = UIImageView()
    private let subTable = UITableView()

    private let itemArray = BehaviorRelay<[(String, String)]>(value: [])
    private weak var deviceVM: DeviceInfoViewModel!

    override func initUI() {
        super.initUI()
        navigationView.title = R.localStr.audioFormat()
        view.addSubview(audioFormatLab)
        view.addSubview(selectAudioFormatBtn)
        selectAudioFormatBtn.addSubview(currentAudioFormatLab)
        selectAudioFormatBtn.addSubview(audioFormatImgv)
        view.addSubview(subTable)

        audioFormatLab.text = R.localStr.audioFormat()
        audioFormatLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        audioFormatLab.textColor = R.color.fontBackText242424()
        audioFormatLab.adjustsFontSizeToFitWidth = true

        selectAudioFormatBtn.backgroundColor = .clear
        currentAudioFormatLab.textColor = R.color.fontBackText_50()
        currentAudioFormatLab.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        currentAudioFormatLab.textAlignment = .center
        audioFormatImgv.image = R.image.icon_next_gray()

        subTable.backgroundColor = .white
        subTable.separatorStyle = .none
        subTable.separatorColor = .clear
        subTable.register(LancerAudioFormatCell.self, forCellReuseIdentifier: "LancerAudioFormatCell")
        subTable.rowHeight = 56
        subTable.isScrollEnabled = false
        subTable.allowsSelection = false
        subTable.layer.cornerRadius = 12
        subTable.layer.masksToBounds = true

        audioFormatLab.text = R.localStr.audioFormat() + ":"
        audioFormatLab.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(28)
            make.top.equalTo(navigationView.snp.bottom).offset(16)
            make.height.equalTo(30)
        }
        selectAudioFormatBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(28)
            make.top.equalTo(navigationView.snp.bottom).offset(16)
            make.height.equalTo(30)
        }
        currentAudioFormatLab.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.bottom.left.top.equalToSuperview()
            make.right.equalTo(audioFormatImgv.snp.left).offset(-12)
        }
        audioFormatImgv.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.width.equalTo(16)
        }

        subTable.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(12)
            make.top.equalTo(selectAudioFormatBtn.snp.bottom).offset(8)
            make.height.equalTo(6 * 56)
        }
    }

    override func initData() {
        super.initData()
        itemArray.bind(to: subTable.rx.items(cellIdentifier: "LancerAudioFormatCell",
                                             cellType: LancerAudioFormatCell.self)) { _, model, cell in
            cell.configCell(model)
        }.disposed(by: disposeBag)

        selectAudioFormatBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else {
                return
            }
            let viewController = LancerAudioFormatListVC(deviceVM)
            self.present(viewController, animated: true)
        }.disposed(by: disposeBag)
    }

    func makeInit(_ deviceVM: DeviceInfoViewModel) {
        self.deviceVM = deviceVM
        self.deviceVM.lancerSettingModel.subscribe { [weak self] _ in
            guard let self = self else {
                return
            }
            self.makeData()
        }.disposed(by: disposeBag)

        makeData()
    }

    func makeData() {
        let currentAudioFormat = deviceVM.auracastLancerManager?.settingMode?.audioFormatIndex ?? .format16_1_1
        let audioFormat = JLAudioFormatModel(audioFormat: currentAudioFormat)
        currentAudioFormatLab.text = audioFormat.name
        var list: [(String, String)] = []
        list.append((R.localStr.sduIntervalUs(), String(audioFormat.sduInterval)))
        list.append((R.localStr.sampleRateHZ(), String(audioFormat.sampleRate)))
        list.append((R.localStr.maxSDUOctets(), String(audioFormat.maxSDUOctetsStr)))
        list.append((R.localStr.rtN(), String(audioFormat.rtn)))
        list.append((R.localStr.maxTransportLatencyMs(), String(audioFormat.maxTransportLatency)))
        list.append((R.localStr.presentationDelayMs(), String(audioFormat.presentaionDelay)))
        itemArray.accept(list)
    }
}
