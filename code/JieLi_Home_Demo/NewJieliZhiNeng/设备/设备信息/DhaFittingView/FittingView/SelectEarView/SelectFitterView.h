//
//  SelectFitterView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/6.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SelectFitterViewDelegate <NSObject>


/// 选择了哪一个模式
/// @param index 0 = 双耳 ；1 = 左耳 ； 2 = 右耳
-(void)fitterDidSelect:(NSInteger)index;

@end

@interface SelectFitterView : UIView

@property(nonatomic,weak)id<SelectFitterViewDelegate> delegate;

-(void)setDhaType:(NSString *)fittingType;

@end

NS_ASSUME_NONNULL_END
