//
//  ANCModeView.h
//  NewJieliZhiNeng
//
//  Created by 李放 on 2021/3/26.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ANCModeViewDelegate <NSObject>
@optional
-(void)onANCSure:(NSArray *) array;
@end

@interface ANCModeView : UIView

@property(assign,nonatomic)NSArray  *mAncArray;

@property(nonatomic,weak)id<ANCModeViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
