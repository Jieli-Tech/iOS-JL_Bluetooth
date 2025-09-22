//
//  NormalSettingView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NormalSettingView;
NS_ASSUME_NONNULL_BEGIN
@interface NormalSettingObject : NSObject

@property(nonatomic,strong)UIImage *img;
@property(nonatomic,strong)NSString *funcStr;
@property(nonatomic,strong)NSString *detailStr;
@property(nonatomic,assign)int funType;

@end

@protocol NormalSettingDelegate <NSObject>

-(void)noremalSetting:(NormalSettingView *) view Selected:(NormalSettingObject *)object;

@end

@interface NormalSettingView : UIView
@property(nonatomic,weak)id<NormalSettingDelegate> delegate;

/// 配置设置的内容
/// @param array 设置列表
-(void)config:(NSArray<NormalSettingObject *>*)array;

@end



NS_ASSUME_NONNULL_END
