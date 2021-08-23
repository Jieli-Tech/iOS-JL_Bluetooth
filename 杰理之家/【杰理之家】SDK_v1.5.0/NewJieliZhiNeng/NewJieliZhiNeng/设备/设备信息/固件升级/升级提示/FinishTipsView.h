//
//  FinishTipsView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^FinishBlock)(void);
@interface FinishTipsView : UIView
-(void)okBlock:(FinishBlock)block;
@end

NS_ASSUME_NONNULL_END
