//
//  SwiftToolsHelper.swift
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2024/1/11.
//  Copyright © 2024 杰理科技. All rights reserved.
//

import Foundation

@objcMembers class SwiftHelper:NSObject{
    // 打印所有资源路径用于调试
    static func printAllResources() {
        let paths = Bundle.main.paths(forResourcesOfType: "", inDirectory: nil)
        JLLogManager.logLevel(.DEBUG, content: "\(paths)")
    }
    class func createFolds(){
       _ = R.shared
    }
    class func saveProtectCustomToCache(_ img:UIImage,_ fileName:String){
        let dt = img.pngData() ?? Data()
        let uuid = JL_RunSDK.sharedMe().mBleEntityM?.mUUID ?? "unKnow"
        let path = R.path.protectCustom+"/"+uuid+"/"+fileName
        if !FileManager.default.fileExists(atPath: R.path.protectCustom+"/"+uuid) {
            try? FileManager.default.createDirectory(atPath: R.path.protectCustom+"/"+uuid, withIntermediateDirectories: true, attributes: nil)
        }
        FileManager.default.createFile(atPath: path, contents: dt)
    }
    
    class func listFiles(_ path:String) -> [String]{
        do{
            let files = try FileManager.default.contentsOfDirectory(atPath: path)
            var items:[String] = []
            let sortedFiles = files.sorted { p1,p2  in
                let att1 = try? FileManager.default.attributesOfItem(atPath: path+"/"+p1)
                let att2 = try? FileManager.default.attributesOfItem(atPath: path+"/"+p2)
                let date1 = att1?[.creationDate] as? Date
                let date2 = att2?[.creationDate] as? Date
                return date1!.compare(date2!) == .orderedDescending
            }
            for item in sortedFiles{
                items.append(path+"/"+item)
            }
            return items
        }catch{
            return []
        }
    }
    
    class func saveWallPaperToCache(_ img:UIImage,_ fileName:String){
        let dt = img.pngData() ?? Data()
        let uuid = JL_RunSDK.sharedMe().mBleEntityM?.mItem ?? "unKnow"
        let path = R.path.wallPaperCustom+"/"+uuid+"/"+fileName
        if !FileManager.default.fileExists(atPath: R.path.wallPaperCustom+"/"+uuid) {
            try? FileManager.default.createDirectory(atPath: R.path.wallPaperCustom+"/"+uuid, withIntermediateDirectories: true, attributes: nil)
        }
        FileManager.default.createFile(atPath: path, contents: dt)
    }
    
}

extension String{
    
    func beImage()->UIImage{
        let dt = try?Data(contentsOf: URL(fileURLWithPath: self))
        let img = UIImage(data: dt ?? Data()) ?? UIImage()
        return img
    }
    
    func withoutExt()->String{
        return self.components(separatedBy: ".").first ?? ""
    }
    
    func lastComponent()->String{
        return self.components(separatedBy: "/").last ?? ""
    }
}

extension URL {
    func beImage()->UIImage {
        let dt = try?Data(contentsOf: self)
        let image = UIImage(data: dt ?? Data()) ?? UIImage()
        return image
    }
}


extension UIButton {
    /// 设置按钮为上图下字布局
    func layoutButtonImageTopTitleBottom(spacing: CGFloat = 6.0) {
        guard
            let imageSize = imageView?.image?.size,
            let title = titleLabel?.text,
            let font = titleLabel?.font
        else {
            return
        }

        let titleSize = (title as NSString).size(withAttributes: [.font: font])

        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center

        titleEdgeInsets = UIEdgeInsets(
            top: spacing,
            left: -imageSize.width,
            bottom: -imageSize.height,
            right: 0
        )

        imageEdgeInsets = UIEdgeInsets(
            top: -titleSize.height - spacing,
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
    }
    /// 设置按钮为左字右图布局
    /// - Parameter spacing: 标题与图片之间的间距
    func layoutLeftTitleRightImage(spacing: CGFloat = 18.0) {
        guard let imageView = self.imageView, let titleLabel = self.titleLabel else { return }
        
        self.contentHorizontalAlignment = .center
        
        // 重置内边距，避免旧设置干扰
        self.titleEdgeInsets = .zero
        self.imageEdgeInsets = .zero
        
        // 让系统先布局，获取 size
        self.layoutIfNeeded()
        
        let titleSize = titleLabel.intrinsicContentSize
        let imageSize = imageView.frame.size
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: 0,
            right: imageSize.width + spacing
        )
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: 0,
            left: titleSize.width + spacing,
            bottom: 0,
            right: -titleSize.width
        )
    }
}
