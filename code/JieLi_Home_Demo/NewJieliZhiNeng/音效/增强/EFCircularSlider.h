//
//  EFCircularSlider.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/6/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IACircularSlider.h"

NS_ASSUME_NONNULL_BEGIN

@interface EFCircularSlider : UIView<LanguagePtl>

@property(nonatomic, strong) IACircularSlider* bassSlider;
@property(nonatomic, strong) IACircularSlider* volSlider;
@property(nonatomic, strong) IACircularSlider* trebleSlider;

@property(nonatomic, strong) UILabel *bassLabel;
@property(nonatomic, strong) UILabel *volLabel;
@property(nonatomic, strong) UILabel *trebleLabel;

@property(nonatomic, assign) float  max_h;
-(id)initByFrame:(CGRect)rect;

@end

NS_ASSUME_NONNULL_END
