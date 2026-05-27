//
//  CSNetworkModels.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2026-03-25.
//  Copyright © 2026 杰理科技. All rights reserved.
//

import Foundation

// MARK: - 通用响应包装模型
/// 彩屏舱服务端接口统一的响应外壳
struct CSBaseResponse<T: Codable>: Codable {
    let code: Int
    let message: String?
    let data: T?
}

// MARK: - Token 模型
/// 解析 Token 和过期时间的模型
struct CSAuthTokenModel: Codable {
    let accessToken: String?
    let expiresIn: Int?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}

// MARK: - 产品信息模型
/// 解析产品信息的模型（芯片名、分辨率等）
struct CSProductInfoModel: Codable {
    let id: String?
    let uuid: String?
    let custid: String?
    let vid: Int?
    let pid: Int?
    let title: String?
    let chipName: String?
    let width: Int?
    let height: Int?
    let icon: String?
    let content: String?
    let createTime: String?
    let updateTime: String?
    let explain: String?
}

// MARK: - 资源列表与详情模型
/// 分页查询的外壳模型
struct CSResourcePageModel: Codable {
    let total: Int?
    let size: Int?
    let current: Int?
    let pages: Int?
    let records: [CSResourceItemModel]?
}

/// 解析资源列表项和详情信息的模型
struct CSResourceItemModel: Codable {
    let id: String?
    let uuid: String?
    let productId: String?
    let custid: String?
    let sn: Int?
    let name: String?
    let nickName: String?
    let type: String?
    let fileType: String?
    let width: Int?
    let height: Int?
    let size: Int?
    let url: String?
    let lockUrl: String?
    let lockSize: Int?
    let icon: String?
    let content: String?
    let createTime: String?
    let updateTime: String?
    let explain: String?
}

/// 解析资源详情信息的模型
typealias CSResourceDetailModel = CSResourceItemModel

