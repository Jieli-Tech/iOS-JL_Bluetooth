//
//  ParseWatchObj.h
//  Test
//
//  Created by EzioChan on 2020/12/9.
//  Copyright © 2020 Zhuhai Jieli Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WatchInfo : NSObject

/// 名称
@property(nonatomic,strong) NSString *name;
/// 偏移
@property(nonatomic,assign) NSInteger offset;
/// 长度
@property(nonatomic,assign) NSInteger len;
/// 内容
@property(nonatomic,strong) NSData *content;

@end

@interface ParseWatchObj : NSObject

/// 表盘文件格式化操作
/// @param path 表盘文件存放的路径
/// @return * NSMutableArray<WatchInfo *>
/// 表盘文件的格式内容：包含名称、偏移、长度、内容
-(NSMutableArray<WatchInfo *> *)analyzeWithPath:(NSString *)path;

/// 标准库解压zip文件
/// @param path 目标文件存放路径
/// @param path1 解压后存放文件夹路径
/// 如：/var/mobile/Containers/Data/Application/55129CAE-FD4A-4400-9A74-ED45B6DC4831/Documents/
/// @return bool 成功失败的标记
-(BOOL)unArchiveFile:(NSString *)path saveToFold:(NSString *)path1;

@end



NS_ASSUME_NONNULL_END
