//
//  DevicesListView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeviceObjc;
NS_ASSUME_NONNULL_BEGIN
@protocol DevicesListViewDelegate <NSObject>

-(void)onDeviceListViewDidSelect:(DeviceObjc *)objc;
-(void)onDeviceMapLocationSelect:(DeviceObjc *)objc;

@end

@interface DevicesListView : UIView


@property(nonatomic,assign)NSInteger selectIndex;
@property(nonatomic,weak)id<DevicesListViewDelegate> delegate;

/// 初始化数据列表
/// @param array 设备列表
-(void)setArrayData:(NSArray *)array;

/// 刷新连接状态
-(void)refreshStatus;

-(void)closeAllDeleteBtn;
@end

NS_ASSUME_NONNULL_END
