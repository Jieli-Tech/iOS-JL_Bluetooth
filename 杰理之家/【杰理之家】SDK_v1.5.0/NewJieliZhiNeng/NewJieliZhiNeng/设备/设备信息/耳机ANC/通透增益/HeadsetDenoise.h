//
//  HeadsetDenoise.h
//  NewJieliZhiNeng
//
//  Created by 李放 on 2021/3/25.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@protocol HeadsetDenoiseDelegate <NSObject>

-(void)HeadsetDenoiseMore:(JLModel_Device *) deviceModel;

@end

@interface HeadsetDenoise : UIView
@property (nonatomic,assign) int currentMode;
@property (nonatomic,strong) NSDictionary *headsetDict;
@property (nonatomic,weak)id <HeadsetDenoiseDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
