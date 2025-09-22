//
//  SpeechSigner.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/2.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import Starscream
import Foundation
import CommonCrypto

class SpeechSigner {
    static let share = SpeechSigner()
    private static let baseUrl = "wss://translate.volces.com/api/translate/speech/v1/"
    private static let accessKeyId = KeyAuth.ByteDance.accessKeyId
    private static let secretAccessKey = KeyAuth.ByteDance.secretAccessKey
    private static let api = "SpeechTranslate"
    private static let version = "2020-06-01"
    private static let path = "/api/translate/speech/v1/"
    private static let host = "translate.volces.com"
    private static let service = "translate"
    private static let region = "cn-north-1"
    
    private let urlAllowedCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~")
    
    func generateWebSocketURL() throws -> String {
        let query = try getSignUrl()
        return "\(Self.baseUrl)?\(query)"
    }
    
    private func dateToISO8601String(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // 强制 UTC
        formatter.locale = Locale(identifier: "en_US_POSIX") // 避免本地化影响
        let dateStr1 = formatter.string(from: date)
        formatter.dateFormat = "HHmmss"
        let dateStr2 = formatter.string(from: date)
        let targetStr = dateStr1 + "T" + dateStr2 + "Z"
        return targetStr
    }
    
    private func getSignUrl() throws -> String {
        let xContentSha256 = sha256Digest(data: Data())
        let xDate = dateToISO8601String(Date()) 
        let shortXDate = String(xDate.prefix(8))
        
        let signQueries = "Action;Version;X-Algorithm;X-Credential;X-Date;X-NotSignBody;X-SignedHeaders;X-SignedQueries"
        let credentialScope = "\(shortXDate)/\(Self.region)/\(Self.service)/request"
        
        var queryParams: [String: String] = [
            "Action": Self.api,
            "Version": Self.version,
            "X-Algorithm": "HMAC-SHA256",
            "X-Credential": "\(Self.accessKeyId)/\(credentialScope)",
            "X-Date": xDate,
            "X-NotSignBody": "",
            "X-SignedHeaders": "",
            "X-SignedQueries": signQueries
        ]
        
        let sortedQuery = queryParams.sorted { $0.key < $1.key }
        let queryString = sortedQuery.map { "\(percentEncode($0.key))=\(percentEncode($0.value))" }.joined(separator: "&")
        
        let canonicalRequest = [
            "GET",
            Self.path,
            queryString,
            "\n\n\n"
        ].joined(separator: "\n") + xContentSha256
        
        let hashedCanonical = sha256Digest(string: canonicalRequest)
        let stringToSign = [
            "HMAC-SHA256",
            xDate,
            credentialScope,
            hashedCanonical
        ].joined(separator: "\n")
        
        
        let signatureKey = try generateSignatureKey(secretKey: Self.secretAccessKey, date: shortXDate, region: Self.region, service: Self.service)
        let signature = try hmacSHA256(key: signatureKey, data: stringToSign)
        
        queryParams["X-Signature"] = signature
        
        return queryParams.sorted { $0.key < $1.key }
            .map { "\(percentEncode($0.key))=\(percentEncode($0.value))" }
            .joined(separator: "&")
    }
    
    private func percentEncode(_ string: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.~")
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? string
    }
    
    private func sha256Digest(data: Data) -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        let hex = Data(hash).map { String(format: "%02hhx", $0) }.joined()
        return hex
    }
    
    private func sha256Digest(string: String) -> String {
        return sha256Digest(data: Data(string.utf8))
    }
    
    private func hmacSHA256(key: Data, data: String) throws -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256),
               (key as NSData).bytes,
               key.count,
               data,
               data.utf8.count,
               &digest)
        return Data(digest).map { String(format: "%02hhx", $0) }.joined()
    }
    
    private func generateSignatureKey(secretKey: String, date: String, region: String, service: String) throws -> Data {
        let kSecret = Data(secretKey.utf8)
        let kDate = try hmacSHA256Raw(key: kSecret, data: date)
        let kRegion = try hmacSHA256Raw(key: kDate, data: region)
        let kService = try hmacSHA256Raw(key: kRegion, data: service)
        return try hmacSHA256Raw(key: kService, data: "request")
    }
    
    private func hmacSHA256Raw(key: Data, data: String) throws -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256),
               (key as NSData).bytes,
               key.count,
               data,
               data.utf8.count,
               &digest)
        return Data(digest)
    }
}


