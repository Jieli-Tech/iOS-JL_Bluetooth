//
//  EqParamView.h
//  TestUIDemo
//
//  Created by 杰理科技 on 2020/6/1.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"
NS_ASSUME_NONNULL_BEGIN


typedef void(^EQParamBlock)(uint8_t eqMode,NSArray *__nullable eqArray);

@protocol EQSettingsDelegate <NSObject>

-(void)enterEQSettingsUI;

@end

@interface EqParamView : UIView
-(void)setEQParamBLK:(EQParamBlock)blkParam;
//-(void)setEQMode:(uint8_t)eqMode;
-(void)setEQArray:(NSArray*)eqArray EQMode:(uint8_t)eqMode;
-(void) updateHighLowVol;
-(void) highLowEnable;
-(void)updateBtnWithMode:(JL_EQMode)mode;

@property(nonatomic,weak)id<EQSettingsDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
