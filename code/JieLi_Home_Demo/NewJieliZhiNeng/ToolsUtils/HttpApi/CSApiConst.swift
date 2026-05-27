//
//  CSApiConst.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2026-03-25.
//  Copyright © 2026 杰理科技. All rights reserved.
//

import Foundation

/// 彩屏舱服务端 API 相关的常量与环境配置
struct CSApiConst {
    /// 运行环境枚举
    enum Environment {
        case test
        case production
        
        /// 获取域名
        var baseURL: String {
            switch self {
            case .test:
                return "http://test03.jieliapp.com"
            case .production:
                return "https://health.jieliapp.com"
            }
        }
    }
    
    /// 当前使用的环境（可以在开发/测试时修改）
    static let currentEnvironment: Environment = .test
    
    /// 统一接口前缀
    static let apiPrefix = "/health/v1/home/colorscreen/"
    
    /// 拼接完整的基础路径
    static var baseApiPath: String {
        return currentEnvironment.baseURL + apiPrefix
    }
    
    /// 具体接口的 Path 定义
    struct Paths {
        /// 获取 Token
        static let authToken = "auth/token"
        /// 查询产品信息
        static let productInfo = "product/info"
        /// 分页查询资源列表
        static let resourcePage = "resource/page"
        /// 查询资源详情
        static let resourceDetail = "resource/onebyuuid"
    }
    
    /// HTTP 请求头相关的常量
    struct Headers {
        static let jwtTokenKey = "jwt-token"
    }
    
    /// 业务状态码
    struct ErrorCodes {
        static let success = 0
        static let productNotExist = -10102
        static let resourceNotExist = -10104
        static let tokenExpired = 401 // 假设401是Token过期，可以根据实际情况调整
    }
}
