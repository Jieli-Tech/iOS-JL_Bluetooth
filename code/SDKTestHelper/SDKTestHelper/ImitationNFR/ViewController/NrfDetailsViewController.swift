//
//  NrfDetailsViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import CoreBluetooth

/// 外设详情页
/// 展示服务/特征列表；可写特征支持弹窗下发；notify 特征支持订阅并在红框区域显示最近一次推送内容
class NrfDetailsViewController: BaseViewController {
    private let subFuncTable = UITableView(frame: .zero, style: .grouped)
    private let bag = DisposeBag()
    private let viewModel = NrfDetailsViewModel()
    private var sections: [NrfDetailsViewModel.Section] = []
    private var peripheral: CBPeripheral?

    func setPeripheral(_ p: CBPeripheral) {
        self.peripheral = p
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindVM()
    }
    
    override func initData() {
        super.initData()
        navigationView.leftBtn.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        navigationView.leftBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: bag)
    }

    override func initUI() {
        super.initUI()
        navigationView.title = "Peripheral Details"
        navigationView.rightBtn.isHidden = true

        subFuncTable.register(NrfCharacteristicCell.self, forCellReuseIdentifier: "charcell")
        subFuncTable.register(NrfServiceHeaderView.self, forHeaderFooterViewReuseIdentifier: "svc_header")
        subFuncTable.separatorStyle = .none
        subFuncTable.rowHeight = UITableView.automaticDimension
        subFuncTable.estimatedRowHeight = 100
        view.addSubview(subFuncTable)
        subFuncTable.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    private func bindVM() {
        guard let p = peripheral else { return }
        viewModel.bind(peripheral: p)

        // 数据源
        viewModel.sectionsDriver
            .drive(onNext: { [weak self] secs in
                self?.sections = secs
                self?.subFuncTable.reloadData()
            })
            .disposed(by: bag)

        // notify 文本更新：找到对应 cell 更新红框文本
        viewModel.notifyValueDriver
            .drive(onNext: { [weak self] uuid, text in
                guard let self = self else { return }
                for case let cell as NrfCharacteristicCell in self.subFuncTable.visibleCells {
                    if let idx = self.indexPath(for: cell), let ch = self.characteristic(at: idx), ch.uuid == uuid {
                        cell.configure(ch, notifyText: text, isNotifying: ch.isNotifying)
                    }
                }
            })
            .disposed(by: bag)

        // 写入/订阅结果提示
        viewModel.writeResultDriver
            .drive(onNext: { [weak self] _, ok, err in
                self?.showToast(ok ? "写入成功" : ("写入失败：" + (err ?? "未知错误")))
            })
            .disposed(by: bag)

        viewModel.notifyStateDriver
            .drive(onNext: { [weak self] uuid, on, err in
                guard let self = self else { return }
                for case let cell as NrfCharacteristicCell in self.subFuncTable.visibleCells {
                    if let idx = self.indexPath(for: cell), let ch = self.characteristic(at: idx), ch.uuid == uuid {
                        cell.configure(ch, notifyText: nil, isNotifying: on)
                    }
                }
                if let e = err { self.showToast("订阅失败：" + e) }
            })
            .disposed(by: bag)

        viewModel.errorDriver
            .drive(onNext: { [weak self] msg in
                self?.showToast(msg)
            })
            .disposed(by: bag)

        // 设置数据源与代理
        subFuncTable.dataSource = self
        subFuncTable.delegate = self
    }

    private func indexPath(for cell: UITableViewCell) -> IndexPath? { subFuncTable.indexPath(for: cell) }

    private func characteristic(at indexPath: IndexPath) -> CBCharacteristic? {
        guard indexPath.section < sections.count else { return nil }
        let chs = sections[indexPath.section].characteristics
        return indexPath.row < chs.count ? chs[indexPath.row] : nil
    }

    private func showWriteAlert(for ch: CBCharacteristic) {
        let vc = NrfWriteInputViewController()
        vc.properties = ch.properties
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        vc.onConfirm = { [weak self] input in
            self?.viewModel.writeValue(input: input, characteristic: ch)
        }
        present(vc, animated: true)
    }

    private func showToast(_ text: String) {
        let a = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        present(a, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { a.dismiss(animated: true) }
    }
}

extension NrfDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[safe: section]?.characteristics.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "charcell", for: indexPath) as! NrfCharacteristicCell
        if let ch = characteristic(at: indexPath) {
            let val = viewModel.getValue(for: ch.uuid)
            cell.configure(ch, notifyText: val, isNotifying: ch.isNotifying)
            cell.onReadTapped = { [weak self] in self?.viewModel.readValue(for: ch) }
            cell.onWriteTapped = { [weak self] in self?.showWriteAlert(for: ch) }
            cell.onToggleNotify = { [weak self] in self?.viewModel.toggleNotify(for: ch) }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "svc_header") as? NrfServiceHeaderView else { return nil }
        if let s = sections[safe: section]?.service { header.configure(s) }
        return header
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? { (indices.contains(index)) ? self[index] : nil }
}
