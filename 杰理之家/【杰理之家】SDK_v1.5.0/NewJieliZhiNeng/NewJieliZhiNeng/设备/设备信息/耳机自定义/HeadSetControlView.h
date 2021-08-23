//
//  HeadSetControlView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceInfoUsage;
NS_ASSUME_NONNULL_BEGIN

@protocol HeadSetControlDelegate <NSObject>

-(void)headSetControlDidTouch:(DeviceInfoUsage *)usage;

@end

@interface HeadSetControlView : UIView
@property(nonatomic,weak)id<HeadSetControlDelegate> delegate;

/// 初始化数据
/// @param sort 短按设备列表
/// @param doubleA 双击设备列表
-(void)initWithDataWithSort:(NSArray<DeviceInfoUsage *>*)sort withDouble:(NSArray<DeviceInfoUsage *> *)doubleA;

@end
NS_ASSUME_NONNULL_END
