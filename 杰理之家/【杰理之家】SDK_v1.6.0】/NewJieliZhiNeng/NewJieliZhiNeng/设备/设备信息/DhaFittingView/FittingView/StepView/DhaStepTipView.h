//
//  DhaStepTipView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/30.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol StepTipsPtl <NSObject>

-(void)stepViewToDismiss;

@end

NS_ASSUME_NONNULL_BEGIN

@interface DhaStepTipView : UIView

@property(nonatomic,weak)id<StepTipsPtl> delegate;

@end

NS_ASSUME_NONNULL_END
