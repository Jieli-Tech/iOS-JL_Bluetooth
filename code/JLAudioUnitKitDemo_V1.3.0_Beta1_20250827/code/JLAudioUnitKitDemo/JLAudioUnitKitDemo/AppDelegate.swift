//
//  AppDelegate.swift
//  JLAudioUnitKitDemo
//
//  Created by EzioChan on 2024/11/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var rootVC: BaseViewController?
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let vc = MainVC()
        let navc = NavViewController(rootViewController: vc)
        vc.navigationController?.setNavigationBarHidden(true, animated: false)
        if #available(iOS 15.0, *) {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }
        rootVC = vc
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = navc
        window?.makeKeyAndVisible()
        
        Tools.createFolders()
        
        return true
    }

  

}

