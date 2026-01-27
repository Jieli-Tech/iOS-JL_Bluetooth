//
//  HealthDataBase.swift
//  JLPiHome
//
//  Created by EzioChan on 2025/10/16.
//  Copyright © 2025 杰理科技. All rights reserved.
//

import UIKit

/// 健康数据数据库封装
/// - 以“单个属性对象”为粒度保存：心率/步数/SpO2 每条记录一行
/// - 支持按日期与数据类型查询，返回与 HealthDataChartView.swift 中结构体一致的数据模型
final class HealthDataBase: NSObject {
    // MARK: - Singleton
    static let shared = HealthDataBase()

    // MARK: - DB
    private let dbQueue: FMDatabaseQueue

    private override init() {
        // 默认路径：Documents/health_data.sqlite
        let path = HealthDataBase.defaultDBPath()
        self.dbQueue = FMDatabaseQueue(path: path)!
        super.init()
        createTablesIfNeeded()
    }

    /// 自定义路径初始化（如需）
    init(dbPath: String) {
        self.dbQueue = FMDatabaseQueue(path: dbPath)!
        super.init()
        createTablesIfNeeded()
    }

    private static func defaultDBPath() -> String {
        let doc = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? NSTemporaryDirectory()
        return (doc as NSString).appendingPathComponent("health_data.sqlite")
    }

    // MARK: - Schema
    private func createTablesIfNeeded() {
        dbQueue.inDatabase { db in
            // 心率表：一条记录包含日期、最小/最大 bpm
            let hrSQL = """
            CREATE TABLE IF NOT EXISTS heart_rate_entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ts INTEGER NOT NULL,
                min_bpm REAL NOT NULL,
                max_bpm REAL NOT NULL,
                avg_bpm REAL NOT NULL
            );
            """
            // 步数表：一条记录包含日期与步数
            let stepsSQL = """
            CREATE TABLE IF NOT EXISTS steps_entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ts INTEGER NOT NULL,
                steps REAL NOT NULL
            );
            """
            // SpO2 表：一条记录包含日期、最小/最大百分比
            let spo2SQL = """
            CREATE TABLE IF NOT EXISTS spo2_entries (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                ts INTEGER NOT NULL,
                min_percent REAL NOT NULL,
                max_percent REAL NOT NULL,
                avg_percent REAL NOT NULL
            );
            """
            _ = db.executeStatements(hrSQL)
            _ = db.executeStatements(stepsSQL)
            _ = db.executeStatements(spo2SQL)

            // 索引：提升按日期查询效率
            let idxHr = "CREATE INDEX IF NOT EXISTS idx_hr_ts ON heart_rate_entries(ts);"
            let idxSteps = "CREATE INDEX IF NOT EXISTS idx_steps_ts ON steps_entries(ts);"
            let idxSpo2 = "CREATE INDEX IF NOT EXISTS idx_spo2_ts ON spo2_entries(ts);"
            _ = db.executeUpdate(idxHr, withArgumentsIn: [])
            _ = db.executeUpdate(idxSteps, withArgumentsIn: [])
            _ = db.executeUpdate(idxSpo2, withArgumentsIn: [])
        }
    }

    // MARK: - Insert APIs (单个对象保存)
    func insertHeartRate(_ entry: HeartRateEntryData) {
        let ts = Int64(entry.date.timeIntervalSince1970)
        dbQueue.inDatabase { db in
            let sql = "INSERT INTO heart_rate_entries (ts, min_bpm, max_bpm, avg_bpm) VALUES (?,?,?,?)"
            _ = db.executeUpdate(sql, withArgumentsIn: [ts, entry.minBpm, entry.maxBpm, entry.averageBpm])
        }
    }

    func insertHeartRates(_ entries: [HeartRateEntryData]) {
        guard !entries.isEmpty else { return }
        dbQueue.inTransaction { db, _ in
            let sql = "INSERT INTO heart_rate_entries (ts, min_bpm, max_bpm, avg_bpm) VALUES (?,?,?,?)"
            for e in entries {
                let ts = Int64(e.date.timeIntervalSince1970)
                _ = db.executeUpdate(sql, withArgumentsIn: [ts, e.minBpm, e.maxBpm, e.averageBpm])
            }
        }
    }

    func insertSteps(_ entry: StepsEntryData) {
        let ts = Int64(entry.date.timeIntervalSince1970)
        dbQueue.inDatabase { db in
            let sql = "INSERT INTO steps_entries (ts, steps) VALUES (?,?)"
            _ = db.executeUpdate(sql, withArgumentsIn: [ts, entry.steps])
        }
    }

    func insertSteps(_ entries: [StepsEntryData]) {
        guard !entries.isEmpty else { return }
        dbQueue.inTransaction { db, _ in
            let sql = "INSERT INTO steps_entries (ts, steps) VALUES (?,?)"
            for e in entries {
                let ts = Int64(e.date.timeIntervalSince1970)
                _ = db.executeUpdate(sql, withArgumentsIn: [ts, e.steps])
            }
        }
    }

    func insertSpO2(_ entry: Spo2EntryData) {
        let ts = Int64(entry.date.timeIntervalSince1970)
        dbQueue.inDatabase { db in
            let sql = "INSERT INTO spo2_entries (ts, min_percent, max_percent) VALUES (?,?,?)"
            _ = db.executeUpdate(sql, withArgumentsIn: [ts, entry.minPercent, entry.maxPercent])
        }
    }

    func insertSpO2(_ entries: [Spo2EntryData]) {
        guard !entries.isEmpty else { return }
        dbQueue.inTransaction { db, _ in
            let sql = "INSERT INTO spo2_entries (ts, min_percent, max_percent, avg_percent) VALUES (?,?,?,?)"
            for e in entries {
                let ts = Int64(e.date.timeIntervalSince1970)
                _ = db.executeUpdate(sql, withArgumentsIn: [ts, e.minPercent, e.maxPercent, e.averagePercent])
            }
        }
    }

    // MARK: - Query APIs（按日期与类型分类查询）
    /// 查询某日（当天0点～次日0点）心率数据
    func queryHeartRate(onDay day: Date) -> [HeartRateEntryData] {
        let (start, end) = dayRange(for: day)
        var results: [HeartRateEntryData] = []
        dbQueue.inDatabase { db in
            let sql = "SELECT ts, min_bpm, max_bpm, avg_bpm FROM heart_rate_entries WHERE ts >= ? AND ts < ? ORDER BY ts ASC"
            if let rs = db.executeQuery(sql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                while rs.next() {
                    let ts = TimeInterval(rs.longLongInt(forColumn: "ts"))
                    let date = Date(timeIntervalSince1970: ts)
                    let minBpm = rs.double(forColumn: "min_bpm")
                    let maxBpm = rs.double(forColumn: "max_bpm")
                    let avgBpm = rs.double(forColumn: "avg_bpm")
                    results.append(HeartRateEntryData(date: date, minBpm: minBpm, maxBpm: maxBpm, averageBpm: avgBpm))
                }
                rs.close()
            }
        }
        return results
    }

    /// 查询某日步数数据
    func querySteps(onDay day: Date) -> [StepsEntryData] {
        let (start, end) = dayRange(for: day)
        var results: [StepsEntryData] = []
        dbQueue.inDatabase { db in
            let sql = "SELECT ts, steps FROM steps_entries WHERE ts >= ? AND ts < ? ORDER BY ts ASC"
            if let rs = db.executeQuery(sql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                while rs.next() {
                    let ts = TimeInterval(rs.longLongInt(forColumn: "ts"))
                    let date = Date(timeIntervalSince1970: ts)
                    let steps = rs.double(forColumn: "steps")
                    results.append(StepsEntryData(date: date, steps: steps))
                }
                rs.close()
            }
        }
        return results
    }

    /// 查询某日 SpO2 数据
    func querySpO2(onDay day: Date) -> [Spo2EntryData] {
        let (start, end) = dayRange(for: day)
        var results: [Spo2EntryData] = []
        dbQueue.inDatabase { db in
            let sql = "SELECT ts, min_percent, max_percent, avg_percent FROM spo2_entries WHERE ts >= ? AND ts < ? ORDER BY ts ASC"
            if let rs = db.executeQuery(sql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                while rs.next() {
                    let ts = TimeInterval(rs.longLongInt(forColumn: "ts"))
                    let date = Date(timeIntervalSince1970: ts)
                    let minP = rs.double(forColumn: "min_percent")
                    let maxP = rs.double(forColumn: "max_percent")
                    let avgP = rs.double(forColumn: "avg_percent")
                    results.append(Spo2EntryData(date: date, minPercent: minP, maxPercent: maxP, averagePercent: avgP))
                }
                rs.close()
            }
        }
        return results
    }

    func queryHeartRateRange(start: Date, end: Date) -> [HeartRateEntryData] {
        var results: [HeartRateEntryData] = []
        dbQueue.inDatabase { db in
            let sql = "SELECT ts, min_bpm, max_bpm, avg_bpm FROM heart_rate_entries WHERE ts >= ? AND ts < ? ORDER BY ts ASC"
            if let rs = db.executeQuery(sql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                while rs.next() {
                    let ts = TimeInterval(rs.longLongInt(forColumn: "ts"))
                    let date = Date(timeIntervalSince1970: ts)
                    let minBpm = rs.double(forColumn: "min_bpm")
                    let maxBpm = rs.double(forColumn: "max_bpm")
                    let avgBpm = rs.double(forColumn: "avg_bpm")
                    results.append(HeartRateEntryData(date: date, minBpm: minBpm, maxBpm: maxBpm, averageBpm: avgBpm))
                }
                rs.close()
            }
        }
        return results
    }

    func queryStepsRange(start: Date, end: Date) -> [StepsEntryData] {
        var results: [StepsEntryData] = []
        dbQueue.inDatabase { db in
            let sql = "SELECT ts, steps FROM steps_entries WHERE ts >= ? AND ts < ? ORDER BY ts ASC"
            if let rs = db.executeQuery(sql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                while rs.next() {
                    let ts = TimeInterval(rs.longLongInt(forColumn: "ts"))
                    let date = Date(timeIntervalSince1970: ts)
                    let steps = rs.double(forColumn: "steps")
                    results.append(StepsEntryData(date: date, steps: steps))
                }
                rs.close()
            }
        }
        return results
    }

    func querySpO2Range(start: Date, end: Date) -> [Spo2EntryData] {
        var results: [Spo2EntryData] = []
        dbQueue.inDatabase { db in
            let sql = "SELECT ts, min_percent, max_percent, avg_percent FROM spo2_entries WHERE ts >= ? AND ts < ? ORDER BY ts ASC"
            if let rs = db.executeQuery(sql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                while rs.next() {
                    let ts = TimeInterval(rs.longLongInt(forColumn: "ts"))
                    let date = Date(timeIntervalSince1970: ts)
                    let minP = rs.double(forColumn: "min_percent")
                    let maxP = rs.double(forColumn: "max_percent")
                    let avgP = rs.double(forColumn: "avg_percent")
                    results.append(Spo2EntryData(date: date, minPercent: minP, maxPercent: maxP, averagePercent: avgP))
                }
                rs.close()
            }
        }
        return results
    }

    // MARK: - Maintenance
    func clearAll() {
        dbQueue.inDatabase { db in
            _ = db.executeUpdate("DELETE FROM heart_rate_entries", withArgumentsIn: [])
            _ = db.executeUpdate("DELETE FROM steps_entries", withArgumentsIn: [])
            _ = db.executeUpdate("DELETE FROM spo2_entries", withArgumentsIn: [])
        }
    }

    // MARK: - Delete APIs（按类别与日期删除）
    /// 删除某日的心率条目（当天0点～次日0点范围内）
    /// - Returns: 预计删除的条目数量（删除前统计）
    func deleteHeartRate(onDay day: Date) -> Int {
        let (start, end) = dayRange(for: day)
        var count = 0
        dbQueue.inDatabase { db in
            // 先统计条数，再删除（返回预计删除数，更直观）
            let cntSql = "SELECT COUNT(*) AS cnt FROM heart_rate_entries WHERE ts >= ? AND ts < ?"
            if let rs = db.executeQuery(cntSql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                if rs.next() { count = Int(rs.int(forColumn: "cnt")) }
                rs.close()
            }
            _ = db.executeUpdate("DELETE FROM heart_rate_entries WHERE ts >= ? AND ts < ?", withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)])
        }
        return count
    }

    /// 删除某日的步数条目
    func deleteSteps(onDay day: Date) -> Int {
        let (start, end) = dayRange(for: day)
        var count = 0
        dbQueue.inDatabase { db in
            let cntSql = "SELECT COUNT(*) AS cnt FROM steps_entries WHERE ts >= ? AND ts < ?"
            if let rs = db.executeQuery(cntSql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                if rs.next() { count = Int(rs.int(forColumn: "cnt")) }
                rs.close()
            }
            _ = db.executeUpdate("DELETE FROM steps_entries WHERE ts >= ? AND ts < ?", withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)])
        }
        return count
    }

    /// 删除某日的 SpO2 条目
    func deleteSpO2(onDay day: Date) -> Int {
        let (start, end) = dayRange(for: day)
        var count = 0
        dbQueue.inDatabase { db in
            let cntSql = "SELECT COUNT(*) AS cnt FROM spo2_entries WHERE ts >= ? AND ts < ?"
            if let rs = db.executeQuery(cntSql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                if rs.next() { count = Int(rs.int(forColumn: "cnt")) }
                rs.close()
            }
            _ = db.executeUpdate("DELETE FROM spo2_entries WHERE ts >= ? AND ts < ?", withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)])
        }
        return count
    }

    /// 删除日期范围内的心率条目（闭区间 [start, end)）
    func deleteHeartRateRange(start: Date, end: Date) -> Int {
        var count = 0
        dbQueue.inDatabase { db in
            let cntSql = "SELECT COUNT(*) AS cnt FROM heart_rate_entries WHERE ts >= ? AND ts < ?"
            if let rs = db.executeQuery(cntSql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                if rs.next() { count = Int(rs.int(forColumn: "cnt")) }
                rs.close()
            }
            _ = db.executeUpdate("DELETE FROM heart_rate_entries WHERE ts >= ? AND ts < ?", withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)])
        }
        return count
    }

    /// 删除日期范围内的步数条目
    func deleteStepsRange(start: Date, end: Date) -> Int {
        var count = 0
        dbQueue.inDatabase { db in
            let cntSql = "SELECT COUNT(*) AS cnt FROM steps_entries WHERE ts >= ? AND ts < ?"
            if let rs = db.executeQuery(cntSql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                if rs.next() { count = Int(rs.int(forColumn: "cnt")) }
                rs.close()
            }
            _ = db.executeUpdate("DELETE FROM steps_entries WHERE ts >= ? AND ts < ?", withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)])
        }
        return count
    }

    /// 删除日期范围内的 SpO2 条目
    func deleteSpO2Range(start: Date, end: Date) -> Int {
        var count = 0
        dbQueue.inDatabase { db in
            let cntSql = "SELECT COUNT(*) AS cnt FROM spo2_entries WHERE ts >= ? AND ts < ?"
            if let rs = db.executeQuery(cntSql, withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)]) {
                if rs.next() { count = Int(rs.int(forColumn: "cnt")) }
                rs.close()
            }
            _ = db.executeUpdate("DELETE FROM spo2_entries WHERE ts >= ? AND ts < ?", withArgumentsIn: [Int64(start.timeIntervalSince1970), Int64(end.timeIntervalSince1970)])
        }
        return count
    }

    // MARK: - Helpers
    private func dayRange(for day: Date) -> (Date, Date) {
        let cal = Calendar.current
        let start = cal.startOfDay(for: day)
        let end = cal.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(24 * 3600)
        return (start, end)
    }
}
