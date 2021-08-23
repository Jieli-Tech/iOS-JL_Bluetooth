//
//  RingSelectView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/7.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"
NS_ASSUME_NONNULL_BEGIN
@class RingSelectView;
@protocol RingSelectDelegate <NSObject>

-(void)ringSelect:(RingSelectView *)view;

@end
@interface RingSelectView : UIView
@property(nonatomic,assign)NSInteger type;
@property(nonatomic,strong)JLModel_RTC *rtcModel;
@property(nonatomic,strong)NSArray *dfArray;
@property(nonatomic,weak)id <RingSelectDelegate> delegate;
-(void)startLoad;
-(void)reloadView;

@end

NS_ASSUME_NONNULL_END
