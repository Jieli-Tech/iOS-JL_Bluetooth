//
//  DFSliderView.h
//  TestUIDemo
//
//  Created by 杰理科技 on 2020/5/30.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DFSliderViewBlock)(NSArray* eqArray);
typedef void(^DFSliderViewUIChangeBlock)(NSArray* eqArray,int value,int index);

@interface DFSliderView : UIView

@property(nonatomic,assign) int eqType; // 0:公共EQ 1:话筒音效

-(void)setBottomColor:(UIColor*)color;

-(void)setSliderEqArray:(NSArray*)eqArray EqFrequecyArray:(NSArray * _Nullable )eqFre EqType:(JL_EQType)eqType;

-(void)outputEqArray:(DFSliderViewBlock __nullable)block
            ChangeUI:(DFSliderViewUIChangeBlock __nullable)blockUI;
@end

NS_ASSUME_NONNULL_END
