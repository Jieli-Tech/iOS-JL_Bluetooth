//
//  OCHelper.h
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/18.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCHelper : NSObject

+(void)handleBr28Bmp:(NSString *)path size:(CGSize) size binPath:(NSString *)binPath;

+(void)handleBr23mp:(NSString *)bmpPath size:(CGSize) size binPath:(NSString *)binPath;

+(void)testApi:(JL_ManagerM *)manager;

@end

NS_ASSUME_NONNULL_END
