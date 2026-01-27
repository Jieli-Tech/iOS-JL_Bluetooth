//
//  LancerAudioFormatListVC.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/10/10.
//

import RxCocoa
import RxSwift
import UIKit

class LancerAudioFormatListVC: UIViewController {
    private let titleLab = UILabel()
    private let closeBtn = UIButton()
    private let subTable = UITableView()
    private let disposeBag = DisposeBag()
    private let itemArray = BehaviorRelay<[(String, JLBroadcastSetAudioFormat)]>(value: [])
    private weak var deviceVM: DeviceInfoViewModel!

    init(_ dev: DeviceInfoViewModel) {
        super.init(nibName: nil, bundle: nil)
        deviceVM = dev
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(titleLab)
        view.addSubview(closeBtn)
        view.addSubview(subTable)

        titleLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLab.text = R.localStr.audioFormat()
        titleLab.textAlignment = .center
        titleLab.adjustsFontSizeToFitWidth = true

        closeBtn.setImage(R.image.icon_close(), for: .normal)

        subTable.backgroundColor = .clear
        subTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        subTable.rowHeight = 56

        titleLab.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
        }
        closeBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.centerY.equalTo(titleLab)
            make.width.height.equalTo(16)
        }

        subTable.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom)
            make.bottom.left.right.equalToSuperview()
        }
        initData()
    }

    func initData() {
        var tmpList: [(String, JLBroadcastSetAudioFormat)] = []
        tmpList.append(("8_1_1", .format8_1))
        tmpList.append(("8_2_1", .format8_2))
        tmpList.append(("16_1_1", .format16_1_1))
        tmpList.append(("16_2_1", .format16_2_1))
        tmpList.append(("24_1_1", .format24_1_1))
        tmpList.append(("24_2_1", .format24_2_1))
        tmpList.append(("32_1_1", .format32_1_1))
        tmpList.append(("32_2_1", .format32_2_1))
        tmpList.append(("441_1_1", .format441_1_1))
        tmpList.append(("441_2_1", .format441_2_1))
        tmpList.append(("48_1_1", .format48_1))
        tmpList.append(("48_2_1", .format48_2))
        itemArray.accept(tmpList)

        itemArray.bind(to: subTable.rx.items(cellIdentifier: "cell")) { _, model, cell in
            cell.textLabel?.text = model.0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
            cell.tintColor = R.color.btnBlueText()
            if model.1 == self.deviceVM.auracastLancerManager?.settingMode?.audioFormatIndex {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }.disposed(by: disposeBag)

        subTable.rx.modelSelected((String, JLBroadcastSetAudioFormat).self).subscribe(onNext: { [weak self] model in
            guard let self = self else { return }
            self.deviceVM.auracastLancerManager?.setAudioFormatIndex(model.1)
        }).disposed(by: disposeBag)

        closeBtn.rx.tap.subscribe { [weak self] _ in
            guard let self = self else {
                return
            }
            self.dismiss(animated: true)
        }.disposed(by: disposeBag)

        deviceVM.lancerSettingModel.subscribe() { [weak self] _ in
            guard let self = self else {
                return
            }
            self.subTable.reloadData()
        }.disposed(by: disposeBag)
        
    }
}
