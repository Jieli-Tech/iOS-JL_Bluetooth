//
//  AppDelegate.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/2.
//

@_exported import JLUsefulTools
@_exported import RxCocoa
@_exported import RxSwift
@_exported import SnapKit
@_exported import Toast_Swift
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let jlav2 = JLAV2Codec()
    static func getCurrentWindows() -> UIWindow? {
        let windows = UIApplication.shared.windows
        return windows.last
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        let mainVc = MainViewController()
        let navc = NavViewController(rootViewController: mainVc)
        mainVc.navigationController?.setNavigationBarHidden(true, animated: true)
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        window = UIWindow(frame: UIScreen.main.bounds)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navc
        window?.makeKeyAndVisible()

        _R.initFold()
        
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        SoundInfoManager.share.addListen()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    
}
