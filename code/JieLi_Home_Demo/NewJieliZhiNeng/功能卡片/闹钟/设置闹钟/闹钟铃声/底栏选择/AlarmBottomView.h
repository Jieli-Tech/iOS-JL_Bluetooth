//
//  AlarmBottomView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/7.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol AlarmBottomDelegate <NSObject>

-(void)bottomDidSelected:(NSInteger)index;

@end

@interface AlarmBottomView : UIView
@property(nonatomic,weak)id<AlarmBottomDelegate> delegate;
@property(nonatomic,strong)NSArray *buttonsArray;
-(void)btnSelect:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
