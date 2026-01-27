//
//  ToolViewFM.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToolViewFM : UIView
@property(weak,nonatomic)UIViewController* onVC;
-(void)updateFmtxUI:(uint16_t)fmPoint;
@end

NS_ASSUME_NONNULL_END
