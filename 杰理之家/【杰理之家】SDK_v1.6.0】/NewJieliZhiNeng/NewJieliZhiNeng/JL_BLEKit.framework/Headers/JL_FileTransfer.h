//
//  JL_FileTransfer.h
//  JL_BLEKit
//
//  Created by 杰理科技 on 2021/11/1.
//  Copyright © 2021 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLModel_SmallFile.h"
#import "JL_TypeEnum.h"
#import "JL_Tools.h"
#import "JL_RCSP.h"

NS_ASSUME_NONNULL_BEGIN



typedef NS_ENUM(UInt8, JL_SmallFileOperate) {
    JL_SmallFileOperateFail        = 0x00, //失败
    JL_SmallFileOperateDoing       = 0x01, //操作中
    JL_SmallFileOperateSuceess     = 0x02, //成功
    JL_SmallFileOperateUnknown     = 0x03, //未知
    JL_SmallFileOperateExcess      = 0x04, //超量
    JL_SmallFileOperateCrcError    = 0x05, //CRC错误
    JL_SmallFileOperateTimeout     = 0x06, //超时
};
typedef void(^JL_SMALLFILE_DEL)(JL_SmallFileOperate status);
typedef void(^JL_SMALLFILE_READ)(JL_SmallFileOperate status,
                                 float progress, NSData* __nullable data);
typedef void(^JL_SMALLFILE_NEW)(JL_SmallFileOperate status,
                                 float progress, uint16_t fileID);
typedef void(^JL_SMALLFILE_UPDATE)(JL_SmallFileOperate status,
                                 float progress);


@interface JL_FileTransfer : NSObject
@property(nonatomic,strong)NSString *mBleUUID;
@property(nonatomic,assign)uint8_t mCmdSN;

-(void)intputPKG_FileTransfer:(JL_PKG*)pkg;

#pragma mark - 查询文件

-(void)cmdSmallFileQueryType:(JL_SmallFileType)type
                      Result:(JL_SMALLFILE_LIST __nullable)result;

#pragma mark - 删除文件
-(void)cmdSmallFileDelete:(JLModel_SmallFile*)file Result:(JL_SMALLFILE_DEL)result;

#pragma mark - 读取文件
-(void)cmdSmallFileRead:(JLModel_SmallFile*)file Result:(JL_SMALLFILE_READ)result;

#pragma mark - 新增文件
-(void)cmdSmallFileNew:(NSData*)data Type:(JL_SmallFileType)type Result:(JL_SMALLFILE_NEW)result;

#pragma mark - 更新文件
-(void)cmdSmallFileUpdate:(JLModel_SmallFile*)file Data:(NSData*)data Result:(JL_SMALLFILE_UPDATE)result;


#pragma mark - 底层API
-(void)cmdSmallFileReadType:(uint8_t)type
                     FileID:(uint16_t)fileId
                     Offset:(uint16_t)offset
                   FileSize:(uint16_t)fileSize
                       Flag:(uint8_t)flag
                     Result:(JL_SMALLFILE_RT __nullable)result;

-(void)cmdSmallFileNewType:(uint8_t)type
                    Offset:(uint16_t)offset
                  FileSize:(uint16_t)fileSize
                     Crc16:(uint16_t)crc16
                  FileData:(NSData*)data
                    Result:(JL_SMALLFILE_RT __nullable)result;

-(void)cmdSmallFileUpdateType:(uint8_t)type
                       FileID:(uint16_t)fileId
                       Offset:(uint16_t)offset
                     FileSize:(uint16_t)fileSize
                        Crc16:(uint16_t)crc16
                     FileData:(NSData*)data
                       Result:(JL_SMALLFILE_RT __nullable)result;

-(void)cmdSmallFileDeleteType:(uint8_t)type
                       FileID:(uint16_t)fileId
                       Result:(JL_SMALLFILE_RT __nullable)result;

-(void)closeTimer;

@end

NS_ASSUME_NONNULL_END
