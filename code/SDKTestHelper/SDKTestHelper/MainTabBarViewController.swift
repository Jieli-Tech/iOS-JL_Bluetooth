//
//  MainTabBarViewController.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/11.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

/// 主入口 TabBar 控制器：承载 JLSDK 测试主页面与 NFR 模拟页面
class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarAppearance()
        setupTabs()
    }
    
    private func setupTabs() {
        let mainVC = MainViewController()
        mainVC.tabBarItem = UITabBarItem(title: "SDK", image: UIImage(systemName: "list.bullet"), tag: 0)
        let mainNavc = NavViewController(rootViewController: mainVC)
        mainNavc.setNavigationBarHidden(true, animated: false)

        let nrfVC = NRFViewController()
        nrfVC.tabBarItem = UITabBarItem(title: "iNRf", image: UIImage(systemName: "antenna.radiowaves.left.and.right"), tag: 1)
        let nrfNavc = NavViewController(rootViewController: nrfVC)
        nrfNavc.setNavigationBarHidden(true, animated: false)
        viewControllers = [mainNavc, nrfNavc]
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        let normalTitleAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.darkGray]
        let selectedTitleAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemBlue]
        appearance.stackedLayoutAppearance.normal.iconColor = .darkGray
        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalTitleAttr
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedTitleAttr
        tabBar.standardAppearance = appearance
        tabBar.tintColor = .systemBlue
        tabBar.unselectedItemTintColor = .darkGray
    }

}
