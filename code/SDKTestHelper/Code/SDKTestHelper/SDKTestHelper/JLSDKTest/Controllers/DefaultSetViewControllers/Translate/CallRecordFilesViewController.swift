//
//  CallRecordFilesViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/6/8.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import RxSwift
import SnapKit
import UIKit

class CallRecordFilesViewController: BaseViewController {

    /// 空状态提示
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "暂无录音文件"
        label.textColor = .gray
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    /// 文件列表
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.separatorStyle = .none
        table.backgroundColor = UIColor.eHex("#F6F7F8")
        table.register(UITableViewCell.self, forCellReuseIdentifier: "CallRecordFileCell")
        return table
    }()

    /// 底部操作栏
    private lazy var bottomToolbar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -1)
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 2
        view.isHidden = true
        return view
    }()

    private let selectAllBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("全选", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        btn.setTitleColor(.systemBlue, for: .normal)
        return btn
    }()

    private let deleteSelectedBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("删除", for: .normal)
        btn.setTitleColor(.systemRed, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 15)
        return btn
    }()

    /// 文件数据源
    private var files: [CallRecordFile] = []

    /// 编辑模式
    private var isEditingMode: Bool = false

    /// 已选中的文件 index 集合
    private var selectedIndices = Set<Int>()

    override func initUI() {
        super.initUI()
        navigationView.title = "录音文件"
        navigationView.leftBtn.setTitle(R.localStr.back(), for: .normal)
        navigationView.rightBtn.setTitle("删除", for: .normal)
        navigationView.rightBtn.isHidden = false

        // 底部操作栏
        bottomToolbar.addSubview(selectAllBtn)
        bottomToolbar.addSubview(deleteSelectedBtn)
        selectAllBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        deleteSelectedBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }

        view.addSubview(emptyLabel)
        view.addSubview(tableView)
        view.addSubview(bottomToolbar)

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalToSuperview().inset(40)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomToolbar.snp.top)
        }

        bottomToolbar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(0)
        }

        tableView.dataSource = self
        tableView.delegate = self
    }

    override func initData() {
        super.initData()

        navigationView.leftBtn.rx.tap.subscribe(onNext: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)

        // 右上角"删除/完成"
        navigationView.rightBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.isEditingMode {
                self.endEditing()
            } else {
                self.beginEditing()
            }
        }).disposed(by: disposeBag)

        // 全选
        selectAllBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            if self.selectedIndices.count == self.files.count {
                self.selectedIndices.removeAll()
            } else {
                self.selectedIndices = Set(0..<self.files.count)
            }
            self.updateSelectionUI()
        }).disposed(by: disposeBag)

        // 删除选中
        deleteSelectedBtn.rx.tap.subscribe(onNext: { [weak self] in
            guard let self = self, !self.selectedIndices.isEmpty else { return }
            self.confirmDeleteSelected()
        }).disposed(by: disposeBag)

        // 订阅文件列表
        TranslateVM.shared.recordFiles.subscribe(onNext: { [weak self] files in
            self?.files = files
            self?.emptyLabel.isHidden = !files.isEmpty
            self?.tableView.reloadData()
        }).disposed(by: disposeBag)

        TranslateVM.shared.fetchRecordFiles()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TranslateVM.shared.stopPlaying()
    }

    // MARK: - 编辑模式

    private func beginEditing() {
        isEditingMode = true
        selectedIndices.removeAll()
        updateEditingUI(animated: true)
    }

    private func endEditing() {
        isEditingMode = false
        selectedIndices.removeAll()
        updateEditingUI(animated: true)
    }

    private func updateEditingUI(animated: Bool) {
        navigationView.rightBtn.setTitle(isEditingMode ? "完成" : "删除", for: .normal)

        bottomToolbar.snp.updateConstraints { make in
            make.height.equalTo(isEditingMode ? 50 : 0)
        }

        let block = {
            self.bottomToolbar.isHidden = !self.isEditingMode
            self.tableView.reloadData()
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.25) { block() }
        } else {
            block()
        }
    }

    private func updateSelectionUI() {
        if selectedIndices.count == files.count, !files.isEmpty {
            selectAllBtn.setTitle("取消全选", for: .normal)
        } else {
            selectAllBtn.setTitle("全选", for: .normal)
        }
        tableView.reloadData()
    }

    @objc private func toggleSelection(_ sender: UIButton) {
        let index = sender.tag
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)
        }
        updateSelectionUI()
    }

    // MARK: - 分享

    private func shareFile(at url: URL, from view: UIView) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = view
        activityVC.popoverPresentationController?.sourceRect = view.bounds
        present(activityVC, animated: true, completion: nil)
    }

    // MARK: - 删除

    private func confirmDelete(at url: URL) {
        let alert = UIAlertController(title: "删除文件", message: "确定要删除这个录音文件吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { _ in
            TranslateVM.shared.deleteRecordFile(at: url)
        })
        present(alert, animated: true)
    }

    private func confirmDeleteSelected() {
        let count = selectedIndices.count
        let alert = UIAlertController(title: "批量删除", message: "确定要删除选中的 \(count) 个录音文件吗？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            let urls = self.selectedIndices.sorted().reversed().compactMap { i -> URL? in
                i < self.files.count ? self.files[i].url : nil
            }
            TranslateVM.shared.deleteRecordFiles(at: urls)
            self.endEditing()
        })
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension CallRecordFilesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallRecordFileCell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.eHex("#F6F7F8")
        cell.contentView.backgroundColor = UIColor.eHex("#F6F7F8")
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let file = files[indexPath.row]
        let isPlaying = TranslateVM.shared.playingFileURL == file.url
        let isSelected = selectedIndices.contains(indexPath.row)

        // 编辑模式下的选中圆圈
        if isEditingMode {
            let checkBtn = UIButton(type: .custom)
            checkBtn.tag = indexPath.row
            checkBtn.setImage(UIImage(systemName: isSelected ? "checkmark.circle.fill" : "circle"), for: .normal)
            checkBtn.tintColor = isSelected ? .systemBlue : .lightGray
            checkBtn.addTarget(self, action: #selector(toggleSelection(_:)), for: .touchUpInside)
            cell.contentView.addSubview(checkBtn)
            checkBtn.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.centerY.equalToSuperview()
                make.width.height.equalTo(24)
            }
        }

        let cellView = CallRecordFileCell()
        cellView.configure(with: file, isPlaying: isPlaying)
        cell.contentView.addSubview(cellView)

        let leftInset: CGFloat = isEditingMode ? 52 : 16
        cellView.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 16))
            make.left.equalToSuperview().offset(leftInset)
        }

        if isEditingMode {
            cellView.playBtn.isHidden = true
            cellView.shareBtn.isHidden = true
            cellView.deleteBtn.isHidden = true
        } else {
            cellView.playBtn.isHidden = false
            cellView.shareBtn.isHidden = false
            cellView.deleteBtn.isHidden = false

            cellView.playBtn.rx.tap.subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if TranslateVM.shared.playingFileURL == file.url {
                    TranslateVM.shared.stopPlaying()
                } else {
                    TranslateVM.shared.playRecordFile(at: file.url)
                }
                self.tableView.reloadData()
            }).disposed(by: cellView.disposeBag)

            cellView.shareBtn.rx.tap.subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.shareFile(at: file.url, from: cellView.shareBtn)
            }).disposed(by: cellView.disposeBag)

            cellView.deleteBtn.rx.tap.subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.confirmDelete(at: file.url)
            }).disposed(by: cellView.disposeBag)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
