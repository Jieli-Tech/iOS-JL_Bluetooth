//
//  MofifyNameAlert.h
//  IntelligentBox
//
//  Created by kaka on 2019/10/8.
//  Copyright © 2019 Zhuhia Jieli Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

@protocol MofifyNameAlertDelegate <NSObject>

-(void)didSelectBtnAction:(UIButton *)btn;

@end

@interface MofifyNameAlert : UIView

@property(assign,nonatomic)int      funType; //0:修改名字 1：用于ADV设置同步后需要主机操作的行为 2:忽略设备

@property (assign, nonatomic) id <MofifyNameAlertDelegate> delegate;

-(void)updateAlertInfo;

@end
