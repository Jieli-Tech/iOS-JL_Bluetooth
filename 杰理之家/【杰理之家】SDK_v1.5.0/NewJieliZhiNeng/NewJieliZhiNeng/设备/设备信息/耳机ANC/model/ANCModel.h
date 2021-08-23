//
//  ANCModel.h
//  NewJieliZhiNeng
//
//  Created by 李放 on 2021/3/26.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface ANCModel : NSObject
@property(assign,nonatomic) BOOL            isSelct;                //选中效果
@property(assign,nonatomic) JL_AncMode      mAncMode;               //耳机降噪模式

@end

NS_ASSUME_NONNULL_END
