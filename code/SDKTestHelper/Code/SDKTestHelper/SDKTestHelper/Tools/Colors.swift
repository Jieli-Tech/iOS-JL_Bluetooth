//
//  Colors.swift
//  Alamofire
//
//  Created by EzioChan on 2023/10/25.
//

import Foundation
import UIKit

public extension UIColor {
    class func eHex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1
        var color: Int64 = 0
        scanner.scanHexInt64(&color)
        let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(color & 0x0000FF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }

    static func random() -> UIColor {
        return UIColor(red: .random(in: 0 ... 1), green: .random(in: 0 ... 1), blue: .random(in: 0 ... 1), alpha: 1.0)
    }
    
    // MARK: - iOS 12.0 Compatibility
    
    /// iOS 12.0 兼容的 systemBlue
    static var compatibleSystemBlue: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBlue
        } else {
            return eHex("#007AFF")
        }
    }
    
    /// iOS 12.0 兼容的 systemRed
    static var compatibleSystemRed: UIColor {
        if #available(iOS 13.0, *) {
            return .systemRed
        } else {
            return eHex("#FF3B30")
        }
    }
    
    /// iOS 12.0 兼容的 systemGreen
    static var compatibleSystemGreen: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGreen
        } else {
            return eHex("#34C759")
        }
    }
    
    /// iOS 12.0 兼容的 systemGray
    static var compatibleSystemGray: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray
        } else {
            return eHex("#8E8E93")
        }
    }
    
    /// iOS 12.0 兼容的 systemBackground
    static var compatibleSystemBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .systemBackground
        } else {
            return .white
        }
    }
    
    /// iOS 12.0 兼容的 secondarySystemBackground
    static var compatibleSecondarySystemBackground: UIColor {
        if #available(iOS 13.0, *) {
            return .secondarySystemBackground
        } else {
            return eHex("#F2F2F7")
        }
    }
    
    /// iOS 12.0 兼容的 label
    static var compatibleLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }
    
    /// iOS 12.0 兼容的 secondaryLabel
    static var compatibleSecondaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .secondaryLabel
        } else {
            return eHex("#3C3C43", alpha: 0.6)
        }
    }
    
    /// iOS 12.0 兼容的 systemIndigo
    static var compatibleSystemIndigo: UIColor {
        if #available(iOS 13.0, *) {
            return .systemIndigo
        } else {
            return eHex("#5856D6")
        }
    }
    
    /// iOS 12.0 兼容的 systemTeal
    static var compatibleSystemTeal: UIColor {
        if #available(iOS 13.0, *) {
            return .systemTeal
        } else {
            return eHex("#5AC8FA")
        }
    }
    
    /// iOS 12.0 兼容的 systemOrange
    static var compatibleSystemOrange: UIColor {
        if #available(iOS 13.0, *) {
            return .systemOrange
        } else {
            return eHex("#FF9500")
        }
    }
    
    /// iOS 12.0 兼容的 systemGray6
    static var compatibleSystemGray6: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray6
        } else {
            return eHex("#F2F2F7")
        }
    }

    /// iOS 12.0 兼容的 systemGray4
    static var compatibleSystemGray4: UIColor {
        if #available(iOS 13.0, *) {
            return .systemGray4
        } else {
            return eHex("#D1D1D6")
        }
    }
    
    /// iOS 12.0 兼容的 systemPink
    static var compatibleSystemPink: UIColor {
        if #available(iOS 13.0, *) {
            return .systemPink
        } else {
            return eHex("#FF2D55")
        }
    }
    
    /// iOS 12.0 兼容的 systemPurple
    static var compatibleSystemPurple: UIColor {
        if #available(iOS 13.0, *) {
            return .systemPurple
        } else {
            return eHex("#AF52DE")
        }
    }
    
    /// iOS 12.0 兼容的 systemYellow
    static var compatibleSystemYellow: UIColor {
        if #available(iOS 13.0, *) {
            return .systemYellow
        } else {
            return eHex("#FFCC00")
        }
    }
    
    /// iOS 12.0 兼容的 tertiaryLabel
    static var compatibleTertiaryLabel: UIColor {
        if #available(iOS 13.0, *) {
            return .tertiaryLabel
        } else {
            return UIColor.black.withAlphaComponent(0.3)
        }
    }
    
    /// iOS 12.0 兼容的 link
    static var compatibleLink: UIColor {
        if #available(iOS 13.0, *) {
            return .link
        } else {
            return eHex("#007AFF")
        }
    }
}
