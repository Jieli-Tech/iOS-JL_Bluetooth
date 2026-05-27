//
//  CSNetworkManager.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2026-03-25.
//  Copyright © 2026 杰理科技. All rights reserved.
//

import Foundation
import JLLogHelper

/// 彩屏舱专用的网络请求类错误定义
enum CSNetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(code: Int, message: String)
    case requestFailed(Error)
}

/// 基础网络请求封装
class CSNetworkManager {
    static let shared = CSNetworkManager()
    
    private let session: URLSession
    
    // 用于下载任务去重，存储 URL 对应的所有回调
    private var downloadCallbacks: [String: [(Result<URL, Error>) -> Void]] = [:]
    private let downloadQueue = DispatchQueue(label: "com.jieli.csnetworkmanager.download", attributes: .concurrent)
    
    // 获取云端资源缓存目录
    private var cloudResourceCacheDirectory: URL {
        let fileManager = FileManager.default
        let cacheDirs = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        let cacheDir = cacheDirs[0].appendingPathComponent("CloudResource", isDirectory: true)
        if !fileManager.fileExists(atPath: cacheDir.path) {
            try? fileManager.createDirectory(at: cacheDir, withIntermediateDirectories: true, attributes: nil)
        }
        return cacheDir
    }
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)
    }
    
    /// 统一的网络请求方法
    /// - Parameters:
    ///   - path: 接口相对路径（例如 `auth/token`）
    ///   - method: HTTP 方法（GET/POST）
    ///   - parameters: 请求参数字典
    ///   - headers: 额外的请求头（如果有）
    ///   - completion: 请求完成的回调
    func request<T: Codable>(
        path: String,
        method: String = "POST",
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, CSNetworkError>) -> Void
    ) {
        let fullURLString = CSApiConst.baseApiPath + path
        guard let url = URL(string: fullURLString) else {
            JLLogManager.logLevel(.ERROR, content: "CSNetworkManager: Invalid URL - \(fullURLString)")
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 注入额外的请求头（比如 JWT token）
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // 处理参数
        if let params = parameters {
            if method == "GET" {
                var components = URLComponents(string: fullURLString)
                components?.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = components?.url
            } else {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                } catch {
                    JLLogManager.logLevel(.ERROR, content:"CSNetworkManager: Parameters serialization failed - \(error.localizedDescription)")
                }
            }
        }
        
        JLLogManager.logLevel(.DEBUG, content:"CSNetworkManager Request: [\(method)] \(fullURLString)")
        if let params = parameters {
            JLLogManager.logLevel(.DEBUG, content:"CSNetworkManager Params: \(params)")
        }
        
        let task = session.dataTask(with: request) {  data, response, error in
            if let error = error {
                JLLogManager.logLevel(.ERROR, content: "CSNetworkManager Request Failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
                return
            }
            
            guard let data = data else {
                JLLogManager.logLevel(.ERROR, content: "CSNetworkManager No Data Received")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            // 打印响应数据以便调试
            if let jsonString = String(data: data, encoding: .utf8) {
                JLLogManager.logLevel(.DEBUG, content: "CSNetworkManager Response: \(jsonString)")
            }
            
            do {
                let decoder = JSONDecoder()
                // 解析外壳
                let baseResponse = try decoder.decode(CSBaseResponse<T>.self, from: data)
                
                if baseResponse.code == CSApiConst.ErrorCodes.success {
                    if let responseData = baseResponse.data {
                        DispatchQueue.main.async {
                            completion(.success(responseData))
                        }
                    } else {
                        // 有些接口（如资源列表）可能没有 data 字段，数据在顶层
                        if let rootData = try? decoder.decode(T.self, from: data) {
                            DispatchQueue.main.async {
                                completion(.success(rootData))
                            }
                        } else {
                            JLLogManager.logLevel(.WARN, content: "CSNetworkManager Success but no data field and failed to decode T from root")
                            DispatchQueue.main.async {
                                completion(.failure(.noData))
                            }
                        }
                    }
                } else {
                    let errMsg = baseResponse.message ?? "Unknown server error"
                    JLLogManager.logLevel(.ERROR, content: "CSNetworkManager Server Error: \(baseResponse.code) - \(errMsg)")
                    DispatchQueue.main.async {
                        completion(.failure(.serverError(code: baseResponse.code, message: errMsg)))
                    }
                }
            } catch {
                JLLogManager.logLevel(.ERROR, content: "CSNetworkManager Decoding Error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }
        
        task.resume()
    }
    
    /// 下载文件到本地缓存目录（支持并发去重）
    func downloadFile(url: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let downloadUrl = URL(string: url) else {
            completion(.failure(CSNetworkError.invalidURL))
            return
        }
        
        let fileName = downloadUrl.lastPathComponent
        let destinationUrl = cloudResourceCacheDirectory.appendingPathComponent(fileName)
        
        // 1. 检查缓存
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            JLLogManager.logLevel(.DEBUG, content: "CSNetworkManager Cache hit for: \(fileName)")
            DispatchQueue.main.async {
                completion(.success(destinationUrl))
            }
            return
        }
        
        // 2. 检查是否正在下载（去重）
        var isDownloading = false
        downloadQueue.sync(flags: .barrier) {
            if downloadCallbacks[url] != nil {
                downloadCallbacks[url]?.append(completion)
                isDownloading = true
            } else {
                downloadCallbacks[url] = [completion]
            }
        }
        
        if isDownloading {
            JLLogManager.logLevel(.DEBUG, content: "CSNetworkManager Task already running for: \(url)")
            return
        }
        
        // 3. 发起下载请求
        let task = session.downloadTask(with: downloadUrl) { [weak self] localUrl, response, error in
            guard let self = self else { return }
            
            let completeAll: (Result<URL, Error>) -> Void = { result in
                var callbacks: [(Result<URL, Error>) -> Void] = []
                self.downloadQueue.sync(flags: .barrier) {
                    callbacks = self.downloadCallbacks[url] ?? []
                    self.downloadCallbacks.removeValue(forKey: url)
                }
                DispatchQueue.main.async {
                    callbacks.forEach { $0(result) }
                }
            }
            
            if let error = error {
                completeAll(.failure(error))
                return
            }
            
            guard let localUrl = localUrl else {
                completeAll(.failure(CSNetworkError.noData))
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: destinationUrl.path) {
                    try FileManager.default.removeItem(at: destinationUrl)
                }
                try FileManager.default.moveItem(at: localUrl, to: destinationUrl)
                completeAll(.success(destinationUrl))
            } catch {
                completeAll(.failure(error))
            }
        }
        task.resume()
    }
}
