//
//  TranslationCallDB.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/17.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

enum CallRecordTextType: Int {
    case original = 1
    case translate = 0
    var intValue: Int {
        switch self {
        case .original:
            return 1
        case .translate:
            return 0
        }
    }
}

enum CallRecordSideType: Int {
    case mySide = 0
    case otherSide = 1
    var sideStr: String {
        switch self {
        case .mySide:
            return LanguageCls.localizableTxt("Our side")
        case .otherSide:
            return LanguageCls.localizableTxt("Other side")
        }
    }

    var sideColor: UIColor {
        switch self {
        case .mySide:
            return .systemGreen
        case .otherSide:
            return .systemRed
        }
    }
}

class CallRecord: NSObject, NSCopying {
    var groupID: String
    var id: Int
    var startTime: TimeInterval
    var originText: String = ""
    var translateText: String = ""
    var direction: CallRecordSideType
    var audioData: Data
    var audioDataOrigin: Data

    init(id: Int = 0, groupID: String, startTime: TimeInterval, originText: String, translateText: String, direction: CallRecordSideType, audioData: Data = Data(), audioDataOrigin: Data = Data() as Data) {
        self.id = id
        self.groupID = groupID
        self.startTime = startTime
        self.originText = originText
        self.translateText = translateText
        self.direction = direction
        self.audioData = audioData
        self.audioDataOrigin = audioDataOrigin
    }

    func copy(with _: NSZone? = nil) -> Any {
        let copy = CallRecord(
            id: id,
            groupID: groupID,
            startTime: startTime,
            originText: originText,
            translateText: translateText,
            direction: direction,
            audioData: audioData,
            audioDataOrigin: audioDataOrigin
        )
        return copy
    }
}

class TranslationCallDB {
    static let share = TranslationCallDB()
    private let dbQueue: FMDatabaseQueue = TranslateDBManager.shared.dbQueue

    /// 保存记录（根据groupID和startTime判断存在则更新，不存在则插入）
    func save(record: CallRecord) -> Bool {
        var success = false

        dbQueue.inDatabase { db in
            // 先查询是否已存在相同groupID和startTime的记录
            let querySql = "SELECT id FROM call_records WHERE group_id = ? AND start_time = ? LIMIT 1"
            var existingId = 0

            if let rs = try? db.executeQuery(querySql, values: [record.groupID, record.startTime]) {
                if rs.next() {
                    existingId = Int(rs.long(forColumn: "id"))
                }
                rs.close()
            }

            if existingId > 0 {
                // 更新现有记录
                record.id = existingId
                let updateSql = """
                UPDATE call_records SET
                    origin_text = ?,
                    translate_text = ?,
                    direction = ?,
                    audio_data = ?,
                    audio_data_origin = ?
                WHERE id = ?;
                """
                let args: [Any] = [
                    record.originText,
                    record.translateText,
                    record.direction.rawValue,
                    record.audioData,
                    record.audioDataOrigin,
                    record.id,
                ]
                success = db.executeUpdate(updateSql, withArgumentsIn: args)
            } else {
                // 插入新记录
                let insertSql = """
                INSERT INTO call_records
                (group_id, start_time, origin_text, translate_text, direction, audio_data, audio_data_origin)
                VALUES (?, ?, ?, ?, ?, ?, ?);
                """
                let args: [Any] = [
                    record.groupID,
                    record.startTime,
                    record.originText,
                    record.translateText,
                    record.direction.rawValue,
                    record.audioData,
                    record.audioDataOrigin,
                ]
                success = db.executeUpdate(insertSql, withArgumentsIn: args)
                if success {
                    record.id = Int(db.lastInsertRowId)
                }
            }
        }

        return success
    }

    /// 查询指定 group 的所有记录
    func query(groupID: String) -> [CallRecord] {
        var results: [CallRecord] = []

        dbQueue.inDatabase { db in
            let sql = "SELECT * FROM call_records WHERE group_id = ? ORDER BY start_time ASC"
            if let rs = try? db.executeQuery(sql, values: [groupID]) {
                while rs.next() {
                    results.append(parseRecord(from: rs))
                }
                rs.close()
            }
        }

        return results
    }

    func queryGroupIdList() -> [CallRecord] {
        var results: [CallRecord] = []
        dbQueue.inDatabase { db in
            let sql = "SELECT * FROM call_records GROUP BY group_id"
            if let rs = try? db.executeQuery(sql, values: nil) {
                while rs.next() {
                    results.append(parseRecord(from: rs))
                }
                rs.close()
            }
        }
        return results
    }

    /// 查询所有记录
    func queryAll() -> [CallRecord] {
        var results: [CallRecord] = []

        dbQueue.inDatabase { db in
            let sql = "SELECT * FROM call_records ORDER BY start_time ASC"
            if let rs = try? db.executeQuery(sql, values: nil) {
                while rs.next() {
                    results.append(parseRecord(from: rs))
                }
                rs.close()
            }
        }

        return results
    }

    /// 删除指定记录
    func delete(recordID: Int) -> Bool {
        var success = false
        dbQueue.inDatabase { db in
            let sql = "DELETE FROM call_records WHERE id = ?"
            success = db.executeUpdate(sql, withArgumentsIn: [recordID])
        }
        return success
    }

    /// 删除指定 group 的所有记录
    /// - Parameter groupId: 组 ID
    /// - Returns: 是否删除成功
    @discardableResult func delete(groupId: String) -> Bool {
        var success = false
        dbQueue.inDatabase { db in
            let sql = "DELETE FROM call_records WHERE group_id = ?"
            success = db.executeUpdate(sql, withArgumentsIn: [groupId])
        }
        return success
    }

    /// 清空所有记录
    func deleteAll() {
        dbQueue.inDatabase { db in
            db.executeUpdate("DELETE FROM call_records", withArgumentsIn: [])
        }
    }

    /// 从 ResultSet 构建 CallRecord 实例
    private func parseRecord(from rs: FMResultSet) -> CallRecord {
        return CallRecord(
            id: Int(rs.long(forColumn: "id")),
            groupID: rs.string(forColumn: "group_id") ?? "",
            startTime: rs.double(forColumn: "start_time"),
            originText: rs.string(forColumn: "origin_text") ?? "",
            translateText: rs.string(forColumn: "translate_text") ?? "",
            direction: CallRecordSideType(rawValue: rs.long(forColumn: "direction")) ?? .mySide,
            audioData: rs.data(forColumn: "audio_data") ?? Data(),
            audioDataOrigin: rs.data(forColumn: "audio_data_origin") ?? Data()
        )
    }

    // MARK: - 模拟数据生成

    /// 生成时间戳分组测试数据
    @discardableResult
    static func generateMockData(groupCount: Int = 3, recordsPerGroup: Int = 4) -> [CallRecord] {
        let conversations = [
            ("今天天气怎样？", "How's the weather today?"),
            ("会议将在三点开始", "The meeting will start at 3 PM"),
            ("请查看附件文档", "Please check the attached document"),
        ]
        var records = [CallRecord]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"

        for _ in 0 ..< groupCount {
            // 生成组时间戳（未来1年内随机时间）
            let randomSeconds = Int.random(in: -3 * 86400 ... 0) // 前 3 天（单位：秒）
            let groupDate = Date().addingTimeInterval(TimeInterval(randomSeconds))
            let groupID = dateFormatter.string(from: groupDate)

            // 生成组内记录
            for i in 0 ..< recordsPerGroup {
                let timeOffset = Double(60 * Int.random(in: 1 ... 60)) // 1-60分钟间隔
                let (original, translation) = conversations[i % conversations.count]
                let record = CallRecord(
                    groupID: groupID,
                    startTime: groupDate.timeIntervalSince1970 + Double(i / 2) * timeOffset,
                    originText: original,
                    translateText: translation,
                    direction: i % 2 == 0 ? .mySide : .otherSide,
                    audioData: Data(),
                    audioDataOrigin: Data()
                )
                _ = share.save(record: record)
                records.append(record)
            }
        }
        return records
    }
}
