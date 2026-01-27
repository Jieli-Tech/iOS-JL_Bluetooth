//
//  BroadcastInfoDbVM.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2025/3/11.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

/// 广播历史视图模型，提供历史记录的增删与查询逻辑
class BroadcastInfoDbVM: NSObject {
    private var currentUUID: String = ""
    private let _historyList = BehaviorSubject<[BroadcastDBInfo]>(value: [])
    private let disposeBag = DisposeBag()

    init(_ uuid: String) {
        super.init()
        currentUUID = uuid
        query()
    }

    var historyList: Observable<[BroadcastDBInfo]> {
        return _historyList
    }

    var historyDevices: [BroadcastDBInfo] {
        if let list = try? _historyList.value() {
            return list
        } else {
            return []
        }
    }

    func addModelToHistory(_ bdm: JLBroadcastDataModel) {
        let model = BroadcastDBInfo(uuid: currentUUID, baseData: bdm, timeStamp: Date().timeIntervalSince1970)
        JLBroadcastDataBase.share.update(info: model)
        query()
    }

    func removeModelFromHistory(_ bdm: JLBroadcastDataModel) {
        JLBroadcastDataBase.share.delete(uuid: currentUUID, baseData: bdm.toLTVData())
        query()
    }
    
    func refreshData() {
        let newList = historyDevices
        _historyList.onNext(newList)
    }

    private func query() {
        let list = JLBroadcastDataBase.share.query(uuid: currentUUID)
        let newList = list.sorted(by: { $0.timeStamp > $1.timeStamp })
        DispatchQueue.main.async { [weak self] in
            self?._historyList.onNext(newList)
        }
    }

    static func removeAllBy(uuid: String) {
        JLBroadcastDataBase.share.delete(uuid: uuid)
    }
}
