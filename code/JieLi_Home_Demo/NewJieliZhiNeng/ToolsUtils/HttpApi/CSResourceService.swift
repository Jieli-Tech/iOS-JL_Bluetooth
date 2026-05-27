//
//  CSResourceService.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2026-03-25.
//  Copyright © 2026 杰理科技. All rights reserved.
//

import Foundation
import JLLogHelper

/// 彩屏舱资源服务封装类
class CSResourceService {
    static let shared = CSResourceService()
    
    private init() {}
    
    /// 封装带有 Token 鉴权的通用请求
    private func requestWithToken<T: Codable>(
        vid: Int,
        pid: Int,
        path: String,
        method: String = "POST",
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, CSNetworkError>) -> Void
    ) {
        CSTokenManager.shared.getValidToken(vid: vid, pid: pid) { token in
            guard let token = token else {
                completion(.failure(.serverError(code: -1, message: "Failed to get valid token")))
                return
            }
            
            let headers = [CSApiConst.Headers.jwtTokenKey: token]
            CSNetworkManager.shared.request(
                path: path,
                method: method,
                parameters: parameters,
                headers: headers,
                completion: completion
            )
        }
    }
    
    /// 查询产品信息
    /// - Parameters:
    ///   - vid: 设备的 vid
    ///   - pid: 设备的 pid
    ///   - completion: 请求回调
    func getProductInfo(
        vid: Int,
        pid: Int,
        completion: @escaping (Result<CSProductInfoModel, CSNetworkError>) -> Void
    ) {
        let params: [String: Any] = ["vid": vid, "pid": pid]
        requestWithToken(
            vid: vid,
            pid: pid,
            path: CSApiConst.Paths.productInfo,
            method: "POST",
            parameters: params,
            completion: completion
        )
    }
    
    /// 分页查询当前彩屏舱资源列表
    /// - Parameters:
    ///   - vid: 设备的 vid
    ///   - pid: 设备的 pid
    ///   - type: 资源类型 (wallpaper, boot_animation, screen_saver)，传 nil 表示全部
    ///   - fileTypes: 主资源文件类型（image, gif, video），传 nil 表示全部
    ///   - page: 当前页码 (从 1 开始)
    ///   - size: 每页数量
    ///   - completion: 请求回调
    func getResourcePage(
        vid: Int,
        pid: Int,
        type: String? = nil,
        fileTypes: [String]? = nil,
        page: Int = 1,
        size: Int = 10,
        completion: @escaping (Result<CSResourcePageModel, CSNetworkError>) -> Void
    ) {
        var params: [String: Any] = [
            "page": [
                "current": page,
                "size": size
            ]
        ]
        
        var wrapper: [[String: Any]] = []
        
        if let type = type {
            wrapper.append([
                "column": "type",
                "type": "equal",
                "value": type
            ])
        }
        
        if let fileTypes = fileTypes, !fileTypes.isEmpty {
            wrapper.append([
                "column": "fileType",
                "type": "in",
                "value": fileTypes
            ])
        }
        
        if !wrapper.isEmpty {
            params["wrapper"] = wrapper
        }
        
        // 默认按 id 降序排序
        params["orders"] = [
            [
                "column": "id",
                "type": "desc"
            ]
        ]
        
        requestWithToken(
            vid: vid,
            pid: pid,
            path: CSApiConst.Paths.resourcePage,
            method: "POST",
            parameters: params,
            completion: completion
        )
    }
    
    /// 根据 UUID 查询当前彩屏舱资源详情
    /// - Parameters:
    ///   - vid: 设备的 vid
    ///   - pid: 设备的 pid
    ///   - uuid: 资源的唯一标识 UUID
    ///   - completion: 请求回调
    func getResourceDetail(
        vid: Int,
        pid: Int,
        uuid: String,
        completion: @escaping (Result<CSResourceDetailModel, CSNetworkError>) -> Void
    ) {
        let params: [String: Any] = ["uuid": uuid]
        
        requestWithToken(
            vid: vid,
            pid: pid,
            path: CSApiConst.Paths.resourceDetail,
            method: "GET",
            parameters: params,
            completion: completion
        )
    }
}
