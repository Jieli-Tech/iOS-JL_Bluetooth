//
//  JLEncryptModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/29.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 加密模型
@interface JLEncryptModel : NSObject

/// 是否加密
@property (nonatomic,assign)BOOL isEncrypt;

/// 密码
@property (nonatomic,strong) NSString *broadcastCode;

- (instancetype) initWithData:(NSData *)data;

-(NSData *)beData;
@end

NS_ASSUME_NONNULL_END
