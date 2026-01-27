import Foundation

class TranslationRecord {
    var id: Int = 0
    var startTime: String
    var groupId: String
    var duration: Double
    var originText: String
    var translateText: String
    var audioData: Data
    init(id: Int = 0, startTime: String, groupId: String, duration: Double, originText: String, translateText: String, audioData: Data) {
        self.id = id
        self.startTime = startTime
        self.groupId = groupId
        self.duration = duration
        self.originText = originText
        self.translateText = translateText
        self.audioData = audioData
    }
}

class TranslationRecordDB {
    static let shared = TranslationRecordDB()
    private let dbQueue: FMDatabaseQueue = TranslateDBManager.shared.dbQueue
    func save(record: TranslationRecord) {
        dbQueue.inDatabase { db in
            // 查询是否已存在相同的主键id
            let sqlCheck = "SELECT COUNT(*) FROM sync_records WHERE startTime = ?"
            if let resultSet = try? db.executeQuery(sqlCheck, values: [record.startTime]),
               resultSet.next()
            {
                let count = resultSet.int(forColumnIndex: 0)

                if count > 0 { // 如果记录存在，执行更新操作
                    let sqlUpdate = """
                    UPDATE sync_records SET
                        groupId = ?,
                        duration = ?,
                        originText = ?,
                        translateText = ?,
                        audioData = ?
                    WHERE startTime = ?
                    """
                    try? db.executeUpdate(sqlUpdate, values: [
                        record.groupId,
                        record.duration,
                        record.originText,
                        record.translateText,
                        record.audioData,
                        record.startTime,
                    ])
                } else { // 如果记录不存在，执行插入操作
                    let sqlInsert = """
                    INSERT INTO sync_records (
                        startTime,
                        groupId,
                        duration,
                        originText,
                        translateText,
                        audioData
                    ) VALUES (?, ?, ?, ?, ?, ?)
                    """
                    try? db.executeUpdate(sqlInsert, values: [
                        record.startTime,
                        record.groupId,
                        record.duration,
                        record.originText,
                        record.translateText,
                        record.audioData,
                    ])
                }
            }
        }
    }

    func delete(startTime: String) {
        dbQueue.inDatabase { db in
            try? db.executeUpdate("DELETE FROM sync_records WHERE startTime = ?",
                                  values: [startTime])
        }
    }

    func delete(groupId: String) {
        dbQueue.inDatabase { db in
            try? db.executeUpdate("DELETE FROM sync_records WHERE groupId = ?",
                                  values: [groupId])
        }
    }

    func getRecordsByGroupId(_ groupId: String) -> [TranslationRecord] {
        var records = [TranslationRecord]()

        dbQueue.inDatabase { db in
            if let rs = try? db.executeQuery("SELECT * FROM sync_records WHERE groupId = ?", values: [groupId]) {
                while rs.next() {
                    records.append(TranslationRecord(
                        id: Int(rs.long(forColumn: "id")),
                        startTime: rs.string(forColumn: "startTime") ?? "",
                        groupId: rs.string(forColumn: "groupId") ?? "default",
                        duration: rs.double(forColumn: "duration"),
                        originText: rs.string(forColumn: "originText") ?? "",
                        translateText: rs.string(forColumn: "translateText") ?? "",
                        audioData: rs.data(forColumn: "audioData") ?? Data()
                    ))
                }
            }
        }
        return records
    }

    func getAllRecords() -> [TranslationRecord] {
        var records = [TranslationRecord]()

        dbQueue.inDatabase { db in
            if let rs = try? db.executeQuery("SELECT * FROM sync_records", values: nil) {
                while rs.next() {
                    records.append(TranslationRecord(
                        id: Int(rs.long(forColumn: "id")),
                        startTime: rs.string(forColumn: "startTime") ?? "",
                        groupId: rs.string(forColumn: "groupId") ?? "default",
                        duration: rs.double(forColumn: "duration"),
                        originText: rs.string(forColumn: "originText") ?? "",
                        translateText: rs.string(forColumn: "translateText") ?? "",
                        audioData: rs.data(forColumn: "audioData") ?? Data()
                    ))
                }
            }
        }
        return records
    }

    func queryWithGroupId() -> [TranslationRecord] {
        var records = [TranslationRecord]()
        let sql = "SELECT * FROM sync_records GROUP BY groupId"
        dbQueue.inDatabase { db in
            if let rs = try? db.executeQuery(sql, values: nil) {
                while rs.next() {
                    records.append(TranslationRecord(
                        id: Int(rs.long(forColumn: "id")),
                        startTime: rs.string(forColumn: "startTime") ?? "",
                        groupId: rs.string(forColumn: "groupId") ?? "default",
                        duration: rs.double(forColumn: "duration"),
                        originText: rs.string(forColumn: "originText") ?? "",
                        translateText: rs.string(forColumn: "translateText") ?? "",
                        audioData: rs.data(forColumn: "audioData") ?? Data()
                    ))
                }
            }
        }
        return records
    }

    // MARK: - 模拟数据生成

    @discardableResult
    static func generateMockData(groupCount: Int = 3, recordsPerGroup: Int = 4) -> [TranslationRecord] {
        var records = [TranslationRecord]()
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
                let timestamp = groupDate.addingTimeInterval(Double(i) * timeOffset)
                let (original, translation) = conversations[i % conversations.count]

                let record = TranslationRecord(
                    startTime: dateFormatter.string(from: timestamp),
                    groupId: groupID,
                    duration: Double.random(in: 10 ... 200),
                    originText: original,
                    translateText: translation,
                    audioData: Data()
                )

                shared.save(record: record)
                records.append(record)
            }
        }
        return records
    }
}
