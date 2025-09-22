//
//  ImageTools.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2024/4/30.
//  Copyright © 2024 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageTools : NSObject
/// 裁剪图片方法
/// - Parameter image: 图片
/// - Returns: 裁剪后的图片
+(UIImage *)machRadius:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
