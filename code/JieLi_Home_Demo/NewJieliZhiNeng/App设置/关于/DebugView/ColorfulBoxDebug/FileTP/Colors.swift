//
//  Colors.swift
//  Alamofire
//
//  Created by EzioChan on 2023/10/25.
//

import Foundation

public extension UIColor{
    
    class func eHex(_ hex: String, alpha: CGFloat = 1.0) -> UIColor {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 1
        var color:Int64 = 0
        scanner.scanHexInt64(&color)
        let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(color & 0x0000FF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: alpha)
    }
}
