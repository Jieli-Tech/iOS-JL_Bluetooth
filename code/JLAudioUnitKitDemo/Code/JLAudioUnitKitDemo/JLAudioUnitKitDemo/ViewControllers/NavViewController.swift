//
//  NavViewController.swift
//  
//
//  Created by EzioChan on 2022/10/17.
//  Copyright © 2022 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

import UIKit

class NavViewController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    var bgColor = UIColor.random()
    var textColor = UIColor.eHex("#000000")

    override func viewDidLoad() {
        super.viewDidLoad()

        self.interactivePopGestureRecognizer?.delegate = self
        self.delegate = self

        self.view.backgroundColor = UIColor.white

        self.navigationController?.navigationBar.tintColor = bgColor
        self.navigationController?.navigationBar.barTintColor = bgColor
        self.navigationController?.navigationBar.backgroundColor = bgColor

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = bgColor
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18) as Any]
            appearance.shadowColor = UIColor.clear
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = self.navigationBar.standardAppearance
        } else {
            // Fallback on earlier versions
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18) as Any]
            self.navigationController?.navigationBar.backgroundColor = bgColor
        }

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.children.count == 1 {
            return false
        }
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self)
    }

}

extension UINavigationController {
    func popViewController(count: Int, animated: Bool ) {
        let index: Int = self.children.count - count - 1
        if index >= 0 {
            let vc = self.children[index]
            self.popToViewController(vc, animated: animated)
        } else {
            self.popViewController(animated: animated)
        }
    }
}
