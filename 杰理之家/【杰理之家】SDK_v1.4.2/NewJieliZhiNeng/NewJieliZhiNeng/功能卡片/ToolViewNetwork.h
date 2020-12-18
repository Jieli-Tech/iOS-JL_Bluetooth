//
//  ToolViewNetwork.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/9.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ToolViewNetworkDelegate <NSObject>
-(void)enterNetVC;
@end

@interface ToolViewNetwork : UIView

@property (assign, nonatomic) id <ToolViewNetworkDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
