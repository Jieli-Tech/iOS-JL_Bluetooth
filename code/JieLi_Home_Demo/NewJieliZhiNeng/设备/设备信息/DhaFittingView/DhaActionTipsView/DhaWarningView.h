//
//  DhaWarningView.h
//  NewJieliZhiNeng
//
//  Created by JLee on 2022/7/12.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DhaAlertSelectType) {
    DhaAlertSelectType_Confirm,
    DhaAlertSelectType_Cancel
};

typedef void(^DhaSelectAlert)(DhaAlertSelectType type);


NS_ASSUME_NONNULL_BEGIN

@interface DhaWarningView : UIView

-(void)dhaMessage:(NSString *)msg cancel:(NSString *)cancelName confirm:(NSString *)confirmName action:(DhaSelectAlert) select;

-(void)dhaMessage:(NSString *)msg confirm:(NSString *)confirmName action:(DhaSelectAlert) select;

@end

NS_ASSUME_NONNULL_END
