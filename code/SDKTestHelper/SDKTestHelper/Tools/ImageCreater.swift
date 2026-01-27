//
//  ImageCreater.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2025/12/12.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

import UIKit

class ImageCreater: NSObject {

    /// 根据传入的字符串生成圆形带背景颜色的图片
    /// - Parameters:
    ///   - text: 需要显示的字符串（建议 1-4 个字符效果最佳，如“小米”、“JL”）
    ///   - size: 图片尺寸，默认 80x80
    /// - Returns: 生成的 UIImage
    static func create(from text: String, size: CGSize = CGSize(width: 80, height: 80)) -> UIImage? {
        // 1. 开启图形上下文
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 2. 绘制圆形背景
        // 生成随机颜色 (为了保证文字可见性，可以稍微控制一下随机范围，或者完全随机)
        let randomColor = UIColor(
            red: CGFloat.random(in: 0...1),
            green: CGFloat.random(in: 0...1),
            blue: CGFloat.random(in: 0...1),
            alpha: 1.0
        )
        context.setFillColor(randomColor.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        // 3. 绘制文字
        if !text.isEmpty {
            // 根据文字长度动态调整字体大小，尽可能填满
            // 简单的自适应逻辑：基础大小为高度的一半，随着字数增加缩小
            let baseFontSize = size.height * 0.5
            let fontSize: CGFloat
            if text.count <= 2 {
                fontSize = baseFontSize
            } else if text.count <= 4 {
                fontSize = baseFontSize * 0.7
            } else {
                fontSize = baseFontSize * 0.5
            }
            
            let font = UIFont.boldSystemFont(ofSize: fontSize)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.white,
                .paragraphStyle: NSMutableParagraphStyle() // 默认居中
            ]
            
            let attrString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attrString.size()
            
            // 计算居中位置
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            attrString.draw(in: textRect)
        }
        
        // 4. 获取图片并关闭上下文
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
