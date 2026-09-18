//
//  JLVersionInfo.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/25.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 版本信息类，提供 JLVideoTool 框架版本和 FFmpeg 版本查询
 *
 * 版本号格式: 主版本.次版本.修订版本 (如 1.2.3)
 * 构建日期格式: YYYY-MM-DD
 */
@interface JLVersionInfo : NSObject

#pragma mark - 框架版本信息

/**
 * 框架主版本号
 * 重大更新或架构变更时递增
 */
+ (NSInteger)majorVersion;

/**
 * 框架次版本号
 * 新增功能时递增
 */
+ (NSInteger)minorVersion;

/**
 * 框架修订版本号
 * Bug修复或优化时递增
 */
+ (NSInteger)patchVersion;

/**
 * 完整版本号字符串
 * 格式: "主版本.次版本.修订版本"
 * 示例: "1.2.3"
 */
+ (NSString *)versionString;

/**
 * 构建日期字符串
 * 格式: "YYYY-MM-DD"
 * 示例: "2026-05-25"
 */
+ (NSString *)buildDateString;

/**
 * 完整版本信息
 * 格式: "JLVideoTool v1.2.3 (Build: 2026-05-25)"
 */
+ (NSString *)fullVersionInfo;

#pragma mark - FFmpeg 版本信息

/**
 * FFmpeg 版本号字符串
 * 示例: "4.4.2"
 */
+ (NSString *)ffmpegVersionString;

/**
 * FFmpeg 编译配置信息
 * 返回 FFmpeg 编译时的配置参数
 */
+ (NSString *)ffmpegConfiguration;

/**
 * FFmpeg 完整版本信息
 * 包含版本号和编译信息
 */
+ (NSString *)ffmpegFullVersionInfo;

#pragma mark - 版本检查

/**
 * 检查当前框架版本是否满足最低版本要求
 *
 * @param minMajor 最低主版本号
 * @param minMinor 最低次版本号
 * @param minPatch 最低修订版本号
 * @return YES 表示当前版本满足要求，NO 表示不满足
 */
+ (BOOL)isVersionAtLeastMajor:(NSInteger)minMajor
                       minor:(NSInteger)minMinor
                       patch:(NSInteger)minPatch;

/**
 * 比较两个版本号
 *
 * @param version1 第一个版本号字符串，格式 "x.y.z"
 * @param version2 第二个版本号字符串，格式 "x.y.z"
 * @return NSOrderedAscending 表示 version1 < version2
 *         NSOrderedSame 表示 version1 == version2
 *         NSOrderedDescending 表示 version1 > version2
 */
+ (NSComparisonResult)compareVersion:(NSString *)version1
                          withVersion:(NSString *)version2;

@end

NS_ASSUME_NONNULL_END
