//
//  JLPackageSourceMgr.h
//  JLPackageResKit
//
//  Created by EzioChan on 2025/4/28.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 信息
@interface JLPackageBaseInfo : NSObject

/// 文件内容
@property(nonatomic,strong)NSData *contentData;

/// 文件名称
/// 限制 15 个Byte
@property(nonatomic,strong)NSString *fileName;

/// 昵称
@property(nonatomic,strong)NSString *nickName;

/// 文件路径
@property(nonatomic,strong) NSString *filePath;

/// 初始化
/// - Parameters:
///   - fileName: 文件名称
///   - nickName: 昵称
///   - filePath: 文件路径
- (instancetype)initWithFileName:(NSString *)fileName nickName:(NSString *)nickName filePath:(NSString *)filePath;

@end

/// 资源打包类
@interface JLPackageSourceMgr : NSObject

/// 打包多个文件成 xxx.package 数据
/// - Parameters:
///   - infos: 文件信息
///   - packageName: 包名
///   一般为 res 或者 tone，如果不填时为 packet
+(NSData *_Nullable)makePks:(NSArray<JLPackageBaseInfo *>*)infos packetName:(NSString * __nullable)packetName;



@end

NS_ASSUME_NONNULL_END
