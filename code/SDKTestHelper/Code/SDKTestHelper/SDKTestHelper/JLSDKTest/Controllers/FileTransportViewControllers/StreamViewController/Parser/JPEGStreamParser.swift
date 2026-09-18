//
//  JPEGStreamParser.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/5/28.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import Foundation
import JLVideoTool
import JLLogHelper

struct JPEGStreamFileHeader {
    let magic: String
    let version: UInt32
    let frameCount: UInt32
    let indexOffset: UInt32
    let dataOffset: UInt32
}

struct JPEGStreamFrameEntry {
    let frameIndex: UInt32
    let offset: UInt32
    let length: UInt32
    let timestamp: UInt32
}

struct JPEGFrameData {
    let frameIndex: Int
    let headerData: Data?
    let bodyData: Data
    let timestamp: UInt32
}

class JPEGStreamParser {
    private let fileData: Data
    private let header: JPEGStreamFileHeader
    private var frameEntries: [JPEGStreamFrameEntry] = []

    var totalFrames: Int { Int(header.frameCount) }

    init?(filePath: String) {
        guard let fileData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            JLLogManager.logLevel(.ERROR, content: "JPEGStreamParser: 无法读取文件 \(filePath)")
            return nil
        }
        self.fileData = fileData

        guard fileData.count >= 32 else {
            JLLogManager.logLevel(.ERROR, content: "JPEGStreamParser: 文件太小，无法解析头部")
            return nil
        }

        let magicData = fileData.subdata(in: 0..<4)
        guard let magic = String(data: magicData, encoding: .ascii), magic == "JSTR" else {
            JLLogManager.logLevel(.ERROR, content: "JPEGStreamParser: 无效的Magic标识")
            return nil
        }

        let version = JPEGStreamParser.readUInt32(from: fileData, offset: 4)
        let frameCount = JPEGStreamParser.readUInt32(from: fileData, offset: 8)
        let indexOffset = JPEGStreamParser.readUInt32(from: fileData, offset: 12)
        let dataOffset = JPEGStreamParser.readUInt32(from: fileData, offset: 16)

        self.header = JPEGStreamFileHeader(
            magic: magic,
            version: version,
            frameCount: frameCount,
            indexOffset: indexOffset,
            dataOffset: dataOffset
        )

        let indexStart = Int(indexOffset)
        let entrySize = 16
        for i in 0..<Int(frameCount) {
            let offset = indexStart + i * entrySize
            guard offset + entrySize <= fileData.count else {
                JLLogManager.logLevel(.ERROR, content: "JPEGStreamParser: 索引表越界")
                return nil
            }
            let frameIndex = JPEGStreamParser.readUInt32(from: fileData, offset: offset)
            let frameOffset = JPEGStreamParser.readUInt32(from: fileData, offset: offset + 4)
            let length = JPEGStreamParser.readUInt32(from: fileData, offset: offset + 8)
            let timestamp = JPEGStreamParser.readUInt32(from: fileData, offset: offset + 12)

            frameEntries.append(JPEGStreamFrameEntry(
                frameIndex: frameIndex,
                offset: frameOffset,
                length: length,
                timestamp: timestamp
            ))
        }

        JLLogManager.logLevel(.DEBUG, content: "JPEGStreamParser: 解析完成，共 \(frameCount) 帧")
    }

    func getFrame(at index: Int) -> Data? {
        guard index >= 0 && index < frameEntries.count else { return nil }
        let entry = frameEntries[index]
        let dataStart = Int(header.dataOffset) + Int(entry.offset)
        let dataEnd = dataStart + Int(entry.length)
        guard dataEnd <= fileData.count else { return nil }
        return fileData.subdata(in: dataStart..<dataEnd)
    }

    func getSeparatedFrame(at index: Int, encoder: JLJPEGEncoder) -> JPEGFrameData? {
        guard let frameData = getFrame(at: index) else { return nil }
        let entry = frameEntries[index]

        let headerData: Data?
        let bodyData: Data

        if index == 0 {
            if let separated = try?encoder.separateJPEGData(frameData) {
                headerData = separated.headerData
                bodyData = separated.scanData
            } else {
                headerData = nil
                bodyData = frameData
            }
        } else {
            if let scan = try?encoder.extractScanData(frameData) {
                bodyData = scan
            } else {
                bodyData = frameData
            }
            headerData = nil
        }

        return JPEGFrameData(
            frameIndex: index,
            headerData: headerData,
            bodyData: bodyData,
            timestamp: entry.timestamp
        )
    }

    func extractFirstFrameHeader(encoder: JLJPEGEncoder) -> Data? {
        guard let firstFrame = getFrame(at: 0) else { return nil }
        return try?encoder.extractHeaderData(firstFrame)
    }

    static func readUInt32(from data: Data, offset: Int) -> UInt32 {
        data.subdata(in: offset..<offset + 4).withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}
