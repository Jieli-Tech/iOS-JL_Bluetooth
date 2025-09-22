//
//  DevHistory.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/3/7.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import CoreBluetooth
import UIKit

class DevHistoryModel: NSObject {
    var name: String = ""
    var uuidStr: String = ""
    var advData: Data?
    var isAttDev: Bool = false
}

class DevHistory: NSObject {
    static let share = DevHistory()
    private lazy var databaseQueue: FMDatabaseQueue? = {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            JLLogManager.logLevel(.DEBUG, content: "获取文档目录失败")
            return nil
        }
        let databasePath = path + "/deviceHistory.db"
        let database = FMDatabaseQueue(path: databasePath)
        return database
    }()

    override private init() {
        super.init()
        let createSQL = """
        create table if not exists devHistory (
            name text primary key, 
            uuidStr text, 
            advData blob, 
            isAttDev bool
        )
        """
        databaseQueue?.inDatabase { db in
            if db.open() {
                do {
                    try db.executeUpdate(createSQL, values: nil)
                } catch {
                    JLLogManager.logLevel(.DEBUG, content: "数据库创建失败：\(error.localizedDescription)")
                }
                db.close()
            } else {
                JLLogManager.logLevel(.DEBUG, content: "数据库打开失败")
            }
        }
    }

    func insert(_ peripheral: CBPeripheral, _ advData: Data? = nil, _ isAttDev: Bool) {
        JLLogManager.logLevel(.DEBUG, content: "设备插入\n name:\(peripheral.name ?? ""),uuid:\(peripheral.identifier.uuidString),isAttDev:\(isAttDev)")

        databaseQueue?.inDatabase { database in
            let checkSQL = "select * from devHistory where uuidStr = ?"
            if let checkResult = database.executeQuery(checkSQL, withArgumentsIn: [peripheral.identifier.uuidString]) {
                if checkResult.next() {
                    if let advData = advData {
                        let updateSQL = "update devHistory set name = ?, advData = ?, isAttDev = ? where uuidStr = ?"
                        if database.executeUpdate(updateSQL, withArgumentsIn: [peripheral.name ?? "unKnow", advData, isAttDev, peripheral.identifier.uuidString]) {
                            JLLogManager.logLevel(.DEBUG, content: "设备更新成功")
                        }
                    } else {
                        let updateSQL = "update devHistory set name = ?, isAttDev = ? where uuidStr = ?"
                        if database.executeUpdate(updateSQL, withArgumentsIn: [peripheral.name ?? "unKnow", isAttDev, peripheral.identifier.uuidString]) {
                            JLLogManager.logLevel(.DEBUG, content: "设备更新成功, 不含广播包信息")
                        }
                    }
                } else {
                    if let advData = advData {
                        let insertSQL = "insert into devHistory (name, uuidStr, advData, isAttDev) values (?,?,?,?)"
                        if database.executeUpdate(insertSQL, withArgumentsIn: [peripheral.name ?? "unKnow", peripheral.identifier.uuidString, advData, isAttDev]) {
                            JLLogManager.logLevel(.DEBUG, content: "设备插入成功")
                        } else {
                            JLLogManager.logLevel(.DEBUG, content: "设备插入失败")
                        }
                    } else {
                        let insertSQL = "insert into devHistory (name, uuidStr, isAttDev) values (?,?,?)"
                        if database.executeUpdate(insertSQL, withArgumentsIn: [peripheral.name ?? "unKnow", peripheral.identifier.uuidString, isAttDev]) {
                            JLLogManager.logLevel(.DEBUG, content: "设备插入成功, 不含广播包信息")
                        } else {
                            JLLogManager.logLevel(.DEBUG, content: "设备插入失败")
                        }
                    }
                }
            }
        }
    }

    func update(_ peripheral: CBPeripheral, _ advData: Data) {
        databaseQueue?.inDatabase { database in
            let updateSQL = "update devHistory set advData = ? where uuidStr = ?"
            if database.executeUpdate(updateSQL, withArgumentsIn: [advData, peripheral.identifier.uuidString]) {
                JLLogManager.logLevel(.DEBUG, content: "设备更新成功")
            }
        }
    }

    func delete(_ uuid: String) {
        databaseQueue?.inDatabase { database in
            let deleteSQL = "delete from devHistory where uuidStr = ?"
            if database.executeUpdate(deleteSQL, withArgumentsIn: [uuid]) {
                JLLogManager.logLevel(.DEBUG, content: "设备删除成功")
            }
        }
    }

    func queryAll() async -> [DevHistoryModel] {
        var result = [DevHistoryModel]()
        return await withCheckedContinuation { continuation in
            databaseQueue?.inDatabase { database in
                let querySQL = "select * from devHistory"
                if let queryResult = database.executeQuery(querySQL, withArgumentsIn: []) {
                    while queryResult.next() {
                        let model = DevHistoryModel()
                        model.name = queryResult.string(forColumn: "name") ?? "unKnow"
                        model.uuidStr = queryResult.string(forColumn: "uuidStr") ?? "unKnow"
                        model.advData = queryResult.data(forColumn: "advData")
                        model.isAttDev = queryResult.bool(forColumn: "isAttDev")
                        result.append(model)
                        JLLogManager.logLevel(.DEBUG, content: "name:\(model.name), uuidStr:\(model.uuidStr), advData:\(model.advData?.eHex ?? ""), isAttDev:\(model.isAttDev)")
                    }
                    continuation.resume(returning: result)
                }
            }
        }
    }
}
