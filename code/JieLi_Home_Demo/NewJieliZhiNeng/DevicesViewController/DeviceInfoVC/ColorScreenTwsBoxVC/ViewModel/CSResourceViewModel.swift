//
//  CSResourceViewModel.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2026/03/26.
//  Copyright © 2026 杰理科技. All rights reserved.
//

import UIKit
import JLLogHelper

/// 管理在线资源的 ViewModel
@objcMembers
class CSResourceViewModel: NSObject {
    
    /// 在线壁纸资源列表
    let onlineWallpapers: BehaviorRelay<[CSResourceItemModel]> = BehaviorRelay(value: [])
    /// 在线开机动画资源列表
    let onlineBootAnimations: BehaviorRelay<[CSResourceItemModel]> = BehaviorRelay(value: [])
    /// 在线屏保资源列表
    let onlineScreenSavers: BehaviorRelay<[CSResourceItemModel]> = BehaviorRelay(value: [])
    /// 当前产品信息
    let productInfo: BehaviorRelay<CSProductInfoModel?> = BehaviorRelay(value: nil)
    
    private let disposeBag = DisposeBag()
    
    private var vid: Int = 0
    private var pid: Int = 0
    
    override init() {
        super.init()
        setupVidPid()
    }
    
    private func setupVidPid() {
        var uidStr = JL_RunSDK.sharedMe().mBleEntityM?.mUID ?? "0000"
        var pidStr = JL_RunSDK.sharedMe().mBleEntityM?.mPID ?? "0000"
        
        if CSApiConst.currentEnvironment == .test {
            uidStr = "2710"
            pidStr = "0001"
        }
        
        self.vid = Int(uidStr, radix: 16) ?? 0
        self.pid = Int(pidStr, radix: 16) ?? 0
        
        JLLogManager.logLevel(.DEBUG, content: "CSResourceViewModel init with vid: \(vid), pid: \(pid)")
    }
    
    /// 获取产品信息
    func fetchProductInfo() {
        CSResourceService.shared.getProductInfo(vid: vid, pid: pid) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let model):
                JLLogManager.logLevel(.DEBUG, content: "Fetch product info success: \(model.title ?? "")")
                self.productInfo.accept(model)
            case .failure(let error):
                JLLogManager.logLevel(.ERROR, content: "Fetch product info error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 分页状态
    private(set) var wallpaperPage = 1
    private(set) var hasMoreWallpapers = true
    
    private(set) var bootAnimationPage = 1
    private(set) var hasMoreBootAnimations = true
    
    private(set) var screenSaverPage = 1
    private(set) var hasMoreScreenSavers = true
    
    func resetPagination() {
        wallpaperPage = 1
        hasMoreWallpapers = true
        bootAnimationPage = 1
        hasMoreBootAnimations = true
        screenSaverPage = 1
        hasMoreScreenSavers = true
    }
    
    /// 加载下一页壁纸
    func loadMoreWallpapers() {
        guard hasMoreWallpapers else { return }
        wallpaperPage += 1
        fetchOnlineWallpapers(page: wallpaperPage)
    }
    
    /// 加载下一页开机动画
    func loadMoreBootAnimations() {
        guard hasMoreBootAnimations else { return }
        bootAnimationPage += 1
        fetchOnlineBootAnimations(page: bootAnimationPage)
    }
    
    /// 加载下一页屏保
    func loadMoreScreenSavers() {
        guard hasMoreScreenSavers else { return }
        screenSaverPage += 1
        fetchOnlineScreenSavers(page: screenSaverPage)
    }
    
    /// 获取在线壁纸资源
    /// - Parameters:
    ///   - page: 页码
    ///   - size: 大小
    func fetchOnlineWallpapers(page: Int = 1, size: Int = 20) {
        CSResourceService.shared.getResourcePage(vid: vid, pid: pid, type: "wallpaper", fileTypes: ["image"], page: page, size: size) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let pageModel):
                JLLogManager.logLevel(.DEBUG, content: "Fetch online wallpapers success, count: \(pageModel.records?.count ?? 0)")
                var current = self.onlineWallpapers.value
                if page == 1 {
                    current = pageModel.records ?? []
                } else {
                    current.append(contentsOf: pageModel.records ?? [])
                }
                self.onlineWallpapers.accept(current)
                self.hasMoreWallpapers = (pageModel.current ?? 1) < (pageModel.pages ?? 1)
            case .failure(let error):
                JLLogManager.logLevel(.ERROR, content: "Fetch online wallpapers error: \(error.localizedDescription)")
            }
        }
    }
    
    /// 获取在线开机动画资源
    /// - Parameters:
    ///   - page: 页码
    ///   - size: 大小
    func fetchOnlineBootAnimations(page: Int = 1, size: Int = 20) {
        CSResourceService.shared.getResourcePage(vid: vid, pid: pid, type: "boot_animation", fileTypes: ["gif","video"], page: page, size: size) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let pageModel):
                JLLogManager.logLevel(.DEBUG, content: "Fetch online boot animations success, count: \(pageModel.records?.count ?? 0)")
                var current = self.onlineBootAnimations.value
                if page == 1 {
                    current = pageModel.records ?? []
                } else {
                    current.append(contentsOf: pageModel.records ?? [])
                }
                self.onlineBootAnimations.accept(current)
                self.hasMoreBootAnimations = (pageModel.current ?? 1) < (pageModel.pages ?? 1)
            case .failure(let error):
                JLLogManager.logLevel(.ERROR, content: "Fetch online boot animations error: \(error.localizedDescription)")
            }
        }
    }
    
    /// 获取在线屏保资源
    /// - Parameters:
    ///   - page: 页码
    ///   - size: 大小
    func fetchOnlineScreenSavers(page: Int = 1, size: Int = 20) {
        CSResourceService.shared.getResourcePage(vid: vid, pid: pid, type: "screen_saver", fileTypes: ["image"], page: page, size: size) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let pageModel):
                JLLogManager.logLevel(.DEBUG, content: "Fetch online screen savers success, count: \(pageModel.records?.count ?? 0)")
                var current = self.onlineScreenSavers.value
                if page == 1 {
                    current = pageModel.records ?? []
                } else {
                    current.append(contentsOf: pageModel.records ?? [])
                }
                self.onlineScreenSavers.accept(current)
                self.hasMoreScreenSavers = (pageModel.current ?? 1) < (pageModel.pages ?? 1)
            case .failure(let error):
                JLLogManager.logLevel(.ERROR, content: "Fetch online screen savers error: \(error.localizedDescription)")
            }
        }
    }
    
    /// 获取全部资源
    func fetchAllResources() {
        resetPagination()
        fetchProductInfo()
        fetchOnlineWallpapers()
        fetchOnlineBootAnimations()
        fetchOnlineScreenSavers()
    }
}
