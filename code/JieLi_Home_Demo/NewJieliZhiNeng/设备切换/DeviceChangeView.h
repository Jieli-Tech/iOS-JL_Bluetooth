//
//  DeviceChangeView.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DeviceChangeBlock)(NSString *uuid,NSInteger index);


@interface DeviceChangeView : UIView
@property(nonatomic, strong)NSArray *dataArray;
-(void)onShow;
-(void)onDismiss;
-(void)setDeviceChangeBlock:(DeviceChangeBlock)block;
@end

NS_ASSUME_NONNULL_END
