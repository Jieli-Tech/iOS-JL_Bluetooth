//
//  EQSelectView.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/6/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

typedef void(^EQSelectViewBlock)(uint8_t eqMode,NSArray *__nullable eqArray);


@interface EQSelectView : UIView

-(void)onShow;

-(void)onDismiss;

-(void)setEQSelectBLK:(EQSelectViewBlock)blk;

@end

NS_ASSUME_NONNULL_END
