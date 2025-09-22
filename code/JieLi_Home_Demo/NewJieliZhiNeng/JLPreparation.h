//
//  JLPreparation.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/9/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *kUI_JL_UUID_PREPARATE_OK;

@interface JLPreparation : NSObject
@property(strong,nonatomic)JL_EntityM   *__nullable mBleEntityM;
@property(strong,nonatomic)NSString     *__nullable mBleUUID;
@property(assign,atomic)int          isPreparateOK; //0：没开始 1：正在开始 2：准备好了

-(void)actionPreparation;
-(void)actionDismiss;

@end

NS_ASSUME_NONNULL_END
