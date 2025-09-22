//
//  JLGifBin.h
//  JLGifLib
//
//  Created by EzioChan on 2024/1/18.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^JLGif2BinBlock)(int code,NSData *_Nullable binData);

@interface JLGifBin : NSObject

/// 打印当前SDK的版本
+(void)sdkVersion;

/// 根据 Gif 创建 Bin
/// - Parameters:
///   - gifData: Gif 图片数据
///   - level: 等级
///          1: 低码率
///          2: 中码率
///          3: 高码率
///   - block: 回调内容
+(void)makeDataToBin:(NSData *)gifData Level:(int)level Result:(JLGif2BinBlock)block;

@end

NS_ASSUME_NONNULL_END
