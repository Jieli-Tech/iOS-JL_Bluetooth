//
//  AuracastHistoryListView.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2024/9/12.
//

import UIKit
import RxSwift
import RxCocoa

/// Auracast 历史列表视图：展示历史广播并提供“离开/移除”侧滑操作
class AuracastHistoryListView: BasicView, UITableViewDelegate, UITableViewDataSource {

    
    private let titleLab = UILabel()
    private let subTable = UITableView()
    private weak var _deviceVM: DeviceInfoViewModel?
    private var hasBound = false
    private var historyList: [BroadcastDBInfo] = []
    private var isEditingRow: Bool = false
    private var broadcastModelListDisposable: Disposable?

    
    var deviceVM: DeviceInfoViewModel? {
        didSet {
            if window != nil {
                bindAll()
            }
        }
    }
    
    
    
    override func initUI() {
        super.initUI()
        addSubview(titleLab)
        addSubview(subTable)
        layer.cornerRadius = 8
        layer.masksToBounds = true
        backgroundColor = .clear
        
        titleLab.text = R.localStr.myAuracastBroadcast()
        titleLab.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleLab.textColor = R.color.fontGrayText838383()
        
        subTable.register(AuracastHistoryCell.self, forCellReuseIdentifier: "AuracastHistoryCell")
        subTable.separatorColor = .clear
        subTable.rowHeight = 62
        subTable.backgroundColor = .clear
        subTable.tintColor = .clear
        subTable.delegate = self
        subTable.dataSource = self
        subTable.isScrollEnabled = false
        
        titleLab.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.left.equalToSuperview().inset(16)
            make.height.equalTo(26)
        }
        
        subTable.snp.makeConstraints { make in
            make.top.equalTo(titleLab.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil, deviceVM != nil {
            bindAll()
        }
    }

    private func bindAll() {
        if hasBound { return }
        addWatcher()
        updateReceiveStatus()
        configBroadcastMode()
        hasBound = true
    }
    
    override func initData() {
        super.initData()
    }
    
    private func addWatcher() {
        guard let deviceVM else { return }
        deviceVM.broadcastDbVm.historyList.subscribe(onNext: { [weak self] list in
          guard let self else { return }
            sortDevices(list)
        }).disposed(by: disposeBag)        
    }
    
    private func sortDevices(_ list: [BroadcastDBInfo]){
        guard let deviceVM else { return }
        var newList:[BroadcastDBInfo] = []
        let currentModel = self.deviceVM?.currentSourceModel.value
        for item in list {
            item.strongType = .history
            if item.model.broadcastID == currentModel?.broadcastID {
                item.strongType = .near
                if currentModel?.syncState == .success {
                    item.strongType = .watching
                }
            }else{
                if deviceVM.isNear(item.model) {
                    item.strongType = .near
                }
            }
            newList.append(item)
        }
        newList.sort { $0.strongType.rawValue > $1.strongType.rawValue }
        
        self.historyList = newList
        if window != nil {
            if isEditingRow {
                isEditingRow = false
                subTable.setEditing(false, animated: false)
            }
            UIView.performWithoutAnimation {
                self.subTable.reloadData()
            }
        }
    }
    
    private func updateReceiveStatus() {
        guard let deviceVM else { return }
        deviceVM.currentSourceModel
            .subscribe { [weak self] mode in
                guard let self = self ,let mode = mode, self.window != nil else { return }
                showError(syncModel: mode)
                if let visibleIndexPaths = self.subTable.indexPathsForVisibleRows {
                    if self.isEditingRow {
                        self.isEditingRow = false
                        self.subTable.setEditing(false, animated: false)
                    }
                    UIView.performWithoutAnimation {
                        self.subTable.beginUpdates()
                        self.subTable.reloadRows(at: visibleIndexPaths, with: .none)
                        self.subTable.endUpdates()
                    }
                }
                let lists = deviceVM.broadcastDbVm.historyDevices
                sortDevices(lists)
                // 列表可能发生增删或排序变化，确保完整刷新
                if self.window != nil {
                    if self.isEditingRow {
                        self.isEditingRow = false
                        self.subTable.setEditing(false, animated: false)
                    }
                    UIView.performWithoutAnimation {
                        self.subTable.reloadData()
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func configBroadcastMode() {
        subscribeBroadcastModelList()
    }

    private func subscribeBroadcastModelList() {
        guard let deviceVM else { return }
        broadcastModelListDisposable?.dispose()
        broadcastModelListDisposable = deviceVM.broadcastModelList
            .subscribe(onNext: { [weak self] updatedList in
                guard let self, self.window != nil else { return }
                guard let visibleIndexPaths = self.subTable.indexPathsForVisibleRows else { return }
                var rowsToReload: [IndexPath] = []
                for indexPath in visibleIndexPaths {
                    guard indexPath.row < updatedList.count else { continue }
                    rowsToReload.append(indexPath)
                }
                if !rowsToReload.isEmpty {
                    UIView.performWithoutAnimation {
                        self.subTable.beginUpdates()
                        self.subTable.reloadRows(at: rowsToReload, with: .none)
                        self.subTable.endUpdates()
                    }
                }
            })
    }
    
    private func showError(syncModel: JLBroadcastDataModel) {
        if syncModel.syncState == .idle {
            let errorMessage: String?
            switch syncModel.errorCode {
            case .none:
                errorMessage = nil
            case .name :
                errorMessage = "broadcastName error"
            case .address:
                errorMessage = "broadcastAddress error"
            case .ID:
                errorMessage = "broadcastID error"
            case .key:
                errorMessage = "broadcastKey error"
            case .syncFailed:
                errorMessage = "syncFail error"
            case .syncTimeout:
                errorMessage = "syncTimeout error"
            case .syncLost:
                errorMessage = "syncLost error"
            @unknown default:
                errorMessage = nil
            }
            if let errorMessage {
                AlertManager.windows()?.makeToast(errorMessage, position: .center)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AuracastHistoryCell", for: indexPath) as? AuracastHistoryCell
        let element = historyList[indexPath.row]
        let isNear = deviceVM?.isNear(element.model) ?? false
        if let deviceModel = deviceVM?.currentSourceModel.value {
            let isSameID = deviceModel.broadcastID == element.model.broadcastID
            if isSameID {
                let syncState = deviceVM?.currentSourceModel.value?.syncState ?? .idle
                let isSyncing = syncState == .syncing
                let isSyncSuccess = syncState == .success
                cell?.cellConfig(bassModel: element, isSyncSuccess, isSyncing, isNear)
            }else{
                cell?.cellConfig(bassModel: element, false, false, isNear)
            }
        }else{
            cell?.cellConfig(bassModel: element, false, false, isNear)
        }
        cell?.callback = { _ in }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.subTable.deselectRow(at: indexPath, animated: true)
        guard let deviceVM = self.deviceVM else { return }
        let baseModel = historyList[indexPath.row]
        let currentModel = deviceVM.currentSourceModel.value
        let currentID = currentModel?.broadcastID
        let baseModelId = baseModel.model.broadcastID
        
        if currentID == baseModelId {
            let syncState = currentModel?.syncState ?? .idle
            if syncState == .success {
                let items = deviceVM.broadcastDbVm.historyDevices
                self.sortDevices(items)
                return
            }
            deviceVM.addBroadcast(model: baseModel.model)
        }else{
            deviceVM.addBroadcast(model: baseModel.model)
        }
    }
    
    func tableView(_: UITableView, editingStyleForRowAt _: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath, let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        isEditingRow = false
        if window != nil {
            UIView.performWithoutAnimation {
                self.subTable.reloadData()
            }
        }
        subscribeBroadcastModelList()
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        let status = deviceVM?.currentSourceModel.value?.syncState ?? .idle
        if status == .idle {
            return R.localStr.leave()
        } else {
            return R.localStr.remove()
        }
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        guard let deviceVM else { return nil }
        let currentBroadcastID = deviceVM.currentSourceModel.value?.broadcastID
        guard indexPath.row < historyList.count else { return nil }
        let historyDevice = historyList[indexPath.row]
        var tipStr = R.localStr.leave()
        if currentBroadcastID == historyDevice.model.broadcastID {
            if deviceVM.currentSourceModel.value?.syncState == .idle {
                tipStr = R.localStr.remove()
            }
        }else{
            tipStr = R.localStr.remove()
        }
        let action = UIContextualAction(
            style: .normal,
            title: tipStr
        ) { _, _, completionHandler in
            
            if currentBroadcastID == historyDevice.model.broadcastID {
                if deviceVM.currentSourceModel.value?.syncState == .idle {
                    deviceVM.remvoveBroadcast(model: historyDevice)
                }else{
                    deviceVM.auracastManager?.removeDevCurrentSource()
                }
            }else{
                deviceVM.remvoveBroadcast(model: historyDevice)
            }
            completionHandler(true)
            if !self.isEditingRow {
                self.subTable.reloadData()
            }
        }
        action.backgroundColor = .red
        
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        isEditingRow = true
        broadcastModelListDisposable?.dispose()
        broadcastModelListDisposable = nil
    }
     
}
