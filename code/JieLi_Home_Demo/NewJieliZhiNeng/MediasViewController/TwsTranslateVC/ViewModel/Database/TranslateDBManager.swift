//
//  TranslateDBManager.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/28.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import Foundation

enum TranslateDBType {
    case call
    case sync
    case face
    case all
    var weight: Int {
        switch self {
        case .call:
            return 0
        case .sync:
            return 1
        case .face:
            return 2
        case .all:
            return 3
        }
    }
}

class TranslateDBManager {
    static let shared = TranslateDBManager()
    let dbQueue: FMDatabaseQueue

    init() {
        JLLogManager.logLevel(.DEBUG, content: "TranslateDBManager init")
        let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = docsDir.appendingPathComponent("translation_records.db").path
        let queue = FMDatabaseQueue(path: dbPath)
        dbQueue = queue!
        createTables()
    }

    private func createTables() {
        dbQueue.inDatabase { db in
            let sql = """
            CREATE TABLE IF NOT EXISTS sync_records (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                startTime TEXT UNIQUE,
                groupId TEXT NOT NULL DEFAULT 'default',
                duration REAL,
                originText TEXT,
                translateText TEXT,
                audioData BLOB
            )
            """
            try? db.executeUpdate(sql, values: nil)

            let sql1 = """
            CREATE TABLE IF NOT EXISTS call_records (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                group_id TEXT NOT NULL,
                start_time REAL NOT NULL,
                origin_text TEXT,
                translate_text TEXT,
                direction INTEGER NOT NULL,
                audio_data BLOB,
                audio_data_origin BLOB
            );
            """
            try? db.executeUpdate(sql1, values: nil)
            let sql2 = """
            CREATE TABLE IF NOT EXISTS face_to_face (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                group_id TEXT,
                start_time INTEGER NOT NULL,
                duration INTEGER NOT NULL,
                original_text TEXT NOT NULL,
                translated_text TEXT NOT NULL,
                device_type INTEGER NOT NULL,
                audio_data BLOB
            );
            """
            try? db.executeUpdate(sql2, values: nil)
        }
    }

    static func makeData() {
        TranslationRecordDB.generateMockData()
        TranslationCallDB.generateMockData()
        TranslationFaceToFaceDB.generateMockData()
    }

    func deleteByModel(_ modes: [MessageModel]) {
        for item in modes {
            let groupId = item.date.toString("yyyyMMddHHmmss")
            if item.type == .call {
                TranslationCallDB.share.delete(groupId: groupId)
            }
            if item.type == .sync {
                TranslationRecordDB.shared.delete(groupId: groupId)
            }
            if item.type == .face {
                TranslationFaceToFaceDB.share.delete(groupId: groupId)
            }
        }
    }

    func queryAll(_ type: TranslateDBType, _ date: Date = Date()) -> [MessageModel] {
        let callDBList = TranslationCallDB.share.queryGroupIdList()
        let syncDBList = TranslationRecordDB.shared.queryWithGroupId()
        let faceDBList = TranslationFaceToFaceDB.share.queryWithGroupId()

        var groupList: [MessageModel] = []
        if type == .all || type == .call {
            var callList: [MessageModel] = []
            for record in callDBList {
                let item = Date.strBeDate(record.groupID)!
                if !date.isSameDate(item) {
                    continue
                }
                let model = MessageModel(type: .call, icon: R.Image.img("record_icon_translation"), date: item, title: record.originText, subtitle: record.translateText)
                callList.append(model)
            }
            groupList.append(contentsOf: callList)
        }
        if type == .all || type == .sync {
            var syncList: [MessageModel] = []
            for record in syncDBList {
                let item = Date.strBeDate(record.groupId)!
                if !date.isSameDate(item) {
                    continue
                }
                let model = MessageModel(type: .sync, icon: R.Image.img("icon_record_chuanyi"), date: item, title: record.originText, subtitle: record.translateText)
                syncList.append(model)
            }
            groupList.append(contentsOf: syncList)
        }

        if type == .all || type == .face {
            var faceList: [MessageModel] = []
            for record in faceDBList {
                let item = Date.strBeDate(record.groupId)!
                if !date.isSameDate(item) {
                    continue
                }
                let model = MessageModel(type: .face, icon: R.Image.img("icon_record_facetoface"), date: item, title: record.originalText, subtitle: record.translatedText)
                faceList.append(model)
            }
            groupList.append(contentsOf: faceList)
        }
        groupList.sort { $0.date > $1.date }
        return groupList
    }

    func queryDataWithDate(_ type: TranslateDBType) -> [Date] {
        let callDBList = TranslationCallDB.share.queryGroupIdList()
        let syncDBList = TranslationRecordDB.shared.queryWithGroupId()
        let faceDBList = TranslationFaceToFaceDB.share.queryWithGroupId()
        var dateList: [Date] = []
        if type == .all || type == .call {
            for record in callDBList {
                let item = Date.strBeDate(record.groupID)!
                dateList.append(item)
            }
        }
        if type == .all || type == .sync {
            for record in syncDBList {
                let item = Date.strBeDate(record.groupId)!
                dateList.append(item)
            }
        }
        if type == .all || type == .face {
            for record in faceDBList {
                let item = Date.strBeDate(record.groupId)!
                dateList.append(item)
            }
        }
        return dateList
    }
}
