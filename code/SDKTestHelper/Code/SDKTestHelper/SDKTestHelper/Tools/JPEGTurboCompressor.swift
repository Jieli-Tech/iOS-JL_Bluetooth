//
//  JPEGTurboCompressor.swift
//  SDKTestHelper
//
//  Created by EzioChan on 2026/5/29.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

import UIKit


/// 基于 JPEGTurbo 的 JPEG 压缩工具类
class JPEGTurboCompressor {
    
    /// 压缩图片为 JPEG 数据
    /// - Parameters:
    ///   - image: 原始图片
    ///   - targetSize: 目标尺寸（如果为原尺寸，传入 image.size）
    ///   - quality: 压缩质量 (0.0 - 1.0)
    ///   - maxFileSize: 最大文件大小（字节），0 表示不限制
    /// - Returns: 压缩后的 JPEG 数据
    static func compressImage(_ image: UIImage, targetSize: CGSize, quality: Float, maxFileSize: Int) -> Data? {
        guard image.cgImage != nil else {
            print("Failed to get CGImage")
            return nil
        }
        
        let width = Int32(targetSize.width)
        let height = Int32(targetSize.height)
        
        // 创建缩放后的图片
        let resizedImage = resizeImage(image, to: targetSize)
        guard let resizedCGImage = resizedImage.cgImage else {
            print("Failed to resize image")
            return nil
        }
        
        // 获取图片数据
        guard let data = resizedCGImage.dataProvider?.data as Data? else {
            print("Failed to get image data")
            return nil
        }
        
        // 使用 JPEGTurbo 进行压缩
        return compressWithTurbo(data: data, width: width, height: height, quality: quality, maxFileSize: maxFileSize)
    }
    
    /// 调整图片尺寸
    private static func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? image
    }
    
    /// 使用 JPEGTurbo 压缩
    private static func compressWithTurbo(data: Data, width: Int32, height: Int32, quality: Float, maxFileSize: Int) -> Data? {
        // 初始化 TurboJPEG 压缩器
        guard let tjInstance = tjInitCompress() else {
            print("Failed to initialize TurboJPEG compressor")
            return nil
        }
        defer {
            tjDestroy(tjInstance)
        }
        
        // 准备像素数据（假设是 RGBA 格式）
        let pixelFormat = Int32(TJPF_RGBA.rawValue)
        let flags: Int32 = 0
        
        // 计算最大缓冲区大小
        let maxBufSize = tjBufSize(width, height, Int32(TJSAMP_420.rawValue))
        guard maxBufSize > 0 else {
            print("Failed to calculate buffer size")
            return nil
        }
        
        // 分配输出缓冲区
        var jpegBuf: UnsafeMutablePointer<UInt8>? = nil
        var jpegSize: UInt = 0
        
        // 执行压缩
        let result = data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> Int32 in
            guard let baseAddress = rawBufferPointer.baseAddress else {
                return -1
            }
            return tjCompress2(tjInstance,
                              baseAddress.assumingMemoryBound(to: UInt8.self),
                              width,
                              0, // pitch
                              height,
                              pixelFormat,
                              &jpegBuf,
                              &jpegSize,
                              Int32(TJSAMP_420.rawValue),
                              Int32(quality * 100),
                              flags)
        }
        
        guard result == 0, let compressedBuf = jpegBuf, jpegSize > 0 else {
            print("TurboJPEG compression failed: \(result)")
            return nil
        }
        
        // 转换为 Data
        let compressedData = Data(bytes: compressedBuf, count: Int(jpegSize))
        
        // 释放 TurboJPEG 分配的缓冲区
        tjFree(jpegBuf)
        
        // 检查文件大小限制
        if maxFileSize > 0 && compressedData.count > maxFileSize {
            print("Compressed size (\(compressedData.count)) exceeds max file size (\(maxFileSize))")
            // 可以尝试降低质量重新压缩
            return tryLowerQuality(width: width, height: height, data: data, maxFileSize: maxFileSize)
        }
        
        return compressedData
    }
    
    /// 尝试降低质量以满足文件大小限制
    private static func tryLowerQuality(width: Int32, height: Int32, data: Data, maxFileSize: Int) -> Data? {
        var quality: Float = 90.0
        
        while quality >= 10.0 {
            if let result = compressWithQuality(width: width, height: height, data: data, quality: quality) {
                if result.count <= maxFileSize {
                    return result
                }
            }
            quality -= 10.0
        }
        
        return nil
    }
    
    /// 使用指定质量压缩
    private static func compressWithQuality(width: Int32, height: Int32, data: Data, quality: Float) -> Data? {
        guard let tjInstance = tjInitCompress() else {
            return nil
        }
        defer {
            tjDestroy(tjInstance)
        }
        
        var jpegBuf: UnsafeMutablePointer<UInt8>? = nil
        var jpegSize: UInt = 0
        
        let result = data.withUnsafeBytes { (rawBufferPointer: UnsafeRawBufferPointer) -> Int32 in
            guard let baseAddress = rawBufferPointer.baseAddress else {
                return -1
            }
            return tjCompress2(tjInstance,
                              baseAddress.assumingMemoryBound(to: UInt8.self),
                              width,
                              0,
                              height,
                              Int32(TJPF_RGBA.rawValue),
                              &jpegBuf,
                              &jpegSize,
                              Int32(TJSAMP_420.rawValue),
                              Int32(quality),
                              0)
        }
        
        guard result == 0, let compressedBuf = jpegBuf, jpegSize > 0 else {
            return nil
        }
        
        let compressedData = Data(bytes: compressedBuf, count: Int(jpegSize))
        tjFree(jpegBuf)
        
        return compressedData
    }
}
