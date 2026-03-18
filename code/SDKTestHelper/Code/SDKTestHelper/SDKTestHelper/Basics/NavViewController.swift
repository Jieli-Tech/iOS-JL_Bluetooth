//
//  NavViewController.swift
//
//
//  Created by EzioChan on 2022/10/17.
//  Copyright © 2022 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

import UIKit

class NavViewController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {
    var bgColor = R.color.jlThemeRed()!
    var textColor = UIColor.eHex("#000000")

    override func viewDidLoad() {
        super.viewDidLoad()

        interactivePopGestureRecognizer?.delegate = self
        delegate = self

        view.backgroundColor = UIColor.white

        navigationController?.navigationBar.tintColor = bgColor
        navigationController?.navigationBar.barTintColor = bgColor
        navigationController?.navigationBar.backgroundColor = bgColor

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
            navigationController?.navigationBar.backgroundColor = bgColor
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated)
    }

    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        if children.count == 1 {
            return false
        }
        return true
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy _: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self)
    }
}

extension UINavigationController {
    func popViewController(count: Int, animated: Bool) {
        let index: Int = children.count - count - 1
        if index >= 0 {
            let vc = children[index]
            popToViewController(vc, animated: animated)
        } else {
            popViewController(animated: animated)
        }
    }
}
