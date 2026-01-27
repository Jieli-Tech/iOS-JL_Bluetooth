//
//  RTCAlertView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/25.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^rtcAlarmBlock)(BOOL status);

@interface RTCAlertView : UIView
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UILabel *msgLab;
@property (strong,nonatomic) rtcAlarmBlock ablock;
@end

NS_ASSUME_NONNULL_END
