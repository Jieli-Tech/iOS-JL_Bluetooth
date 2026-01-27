//
//  JLBroadcastDataBase.swift
//  JieLiAuracastAssistant
//
//  Created by EzioChan on 2025/3/11.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit
import JLLogHelper

/// 广播历史记录模型，封装数据库存储所需的基础信息
class BroadcastDBInfo: NSObject {
    var uuid: String = ""
    var address: Data = .init()
    var baseData: Data = .init()
    var timeStamp: TimeInterval = 0
    var strongType: BroadcastStrongType = .history
    var model: JLBroadcastDataModel {
        return JLBroadcastDataModel(parseData: baseData)
    }

    init(uuid: String, baseData: JLBroadcastDataModel, timeStamp: TimeInterval) {
        super.init()
        self.uuid = uuid
        self.baseData = baseData.toLTVData()
        address = baseData.advertiserAddress
        self.timeStamp = timeStamp
    }
}

/// 广播信息数据库访问层，提供线性同步的增删查改接口
class JLBroadcastDataBase: NSObject {
    static let share = JLBroadcastDataBase()
    private lazy var fmdbQueue = FMDatabaseQueue(path: R.SoundBoxPath.dbPath)
    override init() {
        super.init()
        let createSql = """
        create table if not exists broadcastInfo (
            id integer primary key autoincrement,
            uuid text,
            address BLOB,
            baseData BLOB,
            timeStamp double
        )
        """
        fmdbQueue?.inDatabase { dataBase in
            _ = dataBase.executeUpdate(createSql, withArgumentsIn: [])
        }
    }

    func update(info: BroadcastDBInfo) {
        let checkSql = "select * from broadcastInfo where uuid = ? and baseData = ?"
        let updateSql = "update broadcastInfo set baseData = ?, timeStamp = ? where uuid = ? and baseData = ?"
        let insertSql = "insert into broadcastInfo(uuid, address, baseData, timeStamp) values(?, ?, ?, ?)"

        fmdbQueue?.inDatabase { dataBase in
            do {
                let res = try dataBase.executeQuery(checkSql, values: [info.uuid, info.baseData])
                if res.next() {
                    let result = dataBase.executeUpdate(updateSql, withArgumentsIn: [info.baseData, info.timeStamp, info.uuid, info.baseData])
                    if !result {
                        
                        JLLogManager.logLevel(.DEBUG, content: "Update broadcastInfo failed for uuid: \(info.uuid)")
                    }
                } else {
                    let result = dataBase.executeUpdate(insertSql, withArgumentsIn: [info.uuid, info.address, info.baseData, info.timeStamp])
                    if !result {
                        JLLogManager.logLevel(.DEBUG, content: "Insert broadcastInfo failed for uuid: \(info.uuid)")
                    }
                }
            } catch {
                JLLogManager.logLevel(.DEBUG, content: "Error executing update/insert: \(error.localizedDescription)")
            }
        }
    }

    func query(uuid: String) -> [BroadcastDBInfo] {
        let SQL = "select * from broadcastInfo where uuid = ?"
        var array = [BroadcastDBInfo]()
        fmdbQueue?.inDatabase { dataBase in
            do {
                let res = try dataBase.executeQuery(SQL, values: [uuid])
                while res.next() {
                    let uuid = res.string(forColumn: "uuid") ?? ""
                    let baseData = res.data(forColumn: "baseData") ?? Data()
                    let timeStamp = res.double(forColumn: "timeStamp")
                    let mode = JLBroadcastDataModel(parseData: baseData)
                    let info = BroadcastDBInfo(uuid: uuid, baseData: mode, timeStamp: timeStamp)
                    array.append(info)
                    JLLogManager.logLevel(.DEBUG, content: "query uuid = \(uuid), baseData = \(baseData.map { String(format: "%02x", $0) }.joined())")
                }
            } catch {
                JLLogManager.logLevel(.DEBUG, content: "Error querying broadcastInfo: \(error.localizedDescription)")
                array.removeAll()
            }
        }
        return array
    }

    func delete(uuid: String) {
        let SQL = "delete from broadcastInfo where uuid = ?"
        fmdbQueue?.inDatabase { dataBase in
            let res = dataBase.executeUpdate(SQL, withArgumentsIn: [uuid])
            JLLogManager.logLevel(.DEBUG, content: "SQL = \(SQL), res = \(res)")
        }
    }

    func delete(uuid: String, baseData: Data) {
        JLLogManager.logLevel(.DEBUG, content: "delete uuid = \(uuid), baseData = \(baseData.map { String(format: "%02x", $0) }.joined())")
        let SQL = "delete from broadcastInfo where uuid = ? and baseData = ?"
        fmdbQueue?.inDatabase { dataBase in
            let res = dataBase.executeUpdate(SQL, withArgumentsIn: [uuid, baseData])
            JLLogManager.logLevel(.DEBUG, content: "SQL = \(SQL), res = \(res)")
        }
    }
}
