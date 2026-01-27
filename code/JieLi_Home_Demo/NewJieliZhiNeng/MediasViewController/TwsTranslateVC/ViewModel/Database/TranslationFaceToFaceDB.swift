//
//  TranslationFaceToFaceDB.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2025/7/24.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

// 设备类型枚举
enum FaceDeviceType: Int {
    case earpiece
    case phone
    var title: String {
        switch self {
        case .earpiece:
            return R.Language.lan("Headphones")
        case .phone:
            return R.Language.lan("Mobile phone")
        }
    }

    var color: UIColor {
        switch self {
        case .earpiece:
            return .systemRed
        case .phone:
            return .systemGreen
        }
    }
}

// MARK: - 数据模型

class FaceToFaceRecord: NSObject, NSCopying {
    var id: Int = 0
    var groupId: String
    var startTime: Int
    var duration: Int
    var originalText: String
    var translatedText: String
    var deviceType: FaceDeviceType = .earpiece
    var audioData: Data

    init(id: Int = 0, groupId: String, startTime: Int, duration: Int, originalText: String, translatedText: String, deviceType: FaceDeviceType, audioData: Data = Data()) {
        self.id = id
        self.groupId = groupId
        self.startTime = startTime
        self.duration = duration
        self.originalText = originalText
        self.translatedText = translatedText
        self.deviceType = deviceType
        self.audioData = audioData
    }

    func copy(with _: NSZone? = nil) -> Any {
        let copy = FaceToFaceRecord(
            id: id,
            groupId: groupId,
            startTime: startTime,
            duration: duration,
            originalText: originalText,
            translatedText: translatedText,
            deviceType: deviceType,
            audioData: audioData
        )
        return copy
    }
}

// MARK: - 数据库操作

class TranslationFaceToFaceDB {
    static let share = TranslationFaceToFaceDB()

    private let dbQueue: FMDatabaseQueue = TranslateDBManager.shared.dbQueue

    // 增/改
    func saveRecord(_ record: FaceToFaceRecord) {
        let sql = """
        INSERT OR REPLACE INTO face_to_face (
            id, group_id, start_time, duration,
            original_text, translated_text, device_type, audio_data
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """

        dbQueue.inDatabase { db in
            try? db.executeUpdate(sql, values: [
                record.id == 0 ? NSNull() : record.id,
                record.groupId,
                record.startTime,
                record.duration,
                record.originalText,
                record.translatedText,
                record.deviceType.rawValue,
                record.audioData,
            ])
        }
    }

    // 删
    func deleteRecord(byId id: Int) {
        let sql = "DELETE FROM face_to_face WHERE id = ?"
        dbQueue.inDatabase { db in
            try? db.executeUpdate(sql, values: [id])
        }
    }

    func delete(groupId: String) {
        let sql = "DELETE FROM face_to_face WHERE group_id = ?"
        dbQueue.inDatabase { db in
            try? db.executeUpdate(sql, values: [groupId])
        }
    }

    // 查
    func getRecords(groupId: String? = nil) -> [FaceToFaceRecord] {
        var sql = "SELECT * FROM face_to_face"
        var arguments: [Any] = []

        if let groupId = groupId {
            sql += " WHERE group_id = ?"
            arguments.append(groupId)
        }

        sql += " ORDER BY start_time ASC"

        var results = [FaceToFaceRecord]()
        dbQueue.inDatabase { db in
            if let rs = try? db.executeQuery(sql, values: arguments) {
                while rs.next() {
                    let record = FaceToFaceRecord(
                        id: Int(rs.int(forColumn: "id")),
                        groupId: rs.string(forColumn: "group_id") ?? "",
                        startTime: Int(rs.int(forColumn: "start_time")),
                        duration: Int(rs.int(forColumn: "duration")),
                        originalText: rs.string(forColumn: "original_text") ?? "",
                        translatedText: rs.string(forColumn: "translated_text") ?? "",
                        deviceType: FaceDeviceType(rawValue: Int(rs.int(forColumn: "device_type"))) ?? .earpiece,
                        audioData: rs.data(forColumn: "audio_data") ?? Data()
                    )
                    results.append(record)
                }
            }
        }
        return results
    }

    func queryWithGroupId() -> [FaceToFaceRecord] {
        var records = [FaceToFaceRecord]()
        let sql = "SELECT * FROM face_to_face GROUP BY group_id"
        dbQueue.inDatabase { db in
            if let rs = try? db.executeQuery(sql, values: nil) {
                while rs.next() {
                    records.append(FaceToFaceRecord(
                        id: Int(rs.long(forColumn: "id")),
                        groupId: rs.string(forColumn: "group_id") ?? "",
                        startTime: Int(rs.int(forColumn: "start_time")),
                        duration: Int(rs.int(forColumn: "duration")),
                        originalText: rs.string(forColumn: "original_text") ?? "",
                        translatedText: rs.string(forColumn: "translated_text") ?? "",
                        deviceType: FaceDeviceType(rawValue: Int(rs.int(forColumn: "device_type"))) ?? .earpiece,
                        audioData: rs.data(forColumn: "audio_data") ?? Data()
                    ))
                }
            }
        }
        return records
    }

    // MARK: - 模拟数据生成

    @discardableResult
    static func generateMockData(groupCount: Int = 3, recordsPerGroup: Int = 4) -> [FaceToFaceRecord] {
        var records = [FaceToFaceRecord]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"

        let conversations = [
            ("今天天气怎样？", "How's the weather today?"),
            ("会议将在三点开始", "The meeting will start at 3 PM"),
            ("请查看附件文档", "Please check the attached document"),
        ]

        for _ in 0 ..< groupCount {
            let randomSeconds = Int.random(in: -3 * 86400 ... 0) // 前 3 天（单位：秒）
            let groupDate = Date().addingTimeInterval(TimeInterval(randomSeconds))
            let groupID = dateFormatter.string(from: groupDate)

            for i in 0 ..< recordsPerGroup {
                let timeOffset = Double(60 * Int.random(in: 1 ... 60))
                let deviceType: FaceDeviceType = i % 2 == 0 ? .earpiece : .phone
                let (original, translation) = conversations[i % conversations.count]

                let record = FaceToFaceRecord(
                    groupId: groupID,
                    startTime: Int(groupDate.timeIntervalSince1970 + Double(i) * timeOffset),
                    duration: Int.random(in: 10 ... 200),
                    originalText: original,
                    translatedText: translation,
                    deviceType: deviceType
                )

                share.saveRecord(record)
                records.append(record)
            }
        }
        return records
    }
}
