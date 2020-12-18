//
//  HeadphoneFunVC.h
//  IntelligentBox
//
//  Created by kaka on 2019/7/24.
//  Copyright © 2019 Zhuhia Jieli Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HeadphoneFunVC : UIViewController
@property(assign,nonatomic)int      funType; //0:短按耳机 1:轻点两下耳机 2:耳机模式 3:麦克风 4:闪灯功能列表
@property(assign,nonatomic)int      directionType; //0:左耳 1:右耳 2:未配对 3：未连接 4:已连接
@property(assign,nonatomic)NSArray  *key_function; //按键功能列表
@property(assign,nonatomic)NSArray  *key_effect;  //闪灯功能列表
@property(assign,nonatomic)NSArray  *work_mode;  //工作模式
@property(assign,nonatomic)NSArray  *mic_channel;  //麦克风


//按键功能
@property(assign,nonatomic) int oneClickkeyFunc;

//耳机模式
@property(assign,nonatomic) int workMode;
//麦克风
@property(assign,nonatomic) int micMode;
//闪灯设置
//未配对
@property(assign,nonatomic) int noPairLedEffect;
//未连接
@property(assign,nonatomic) int noConnectLedEffect;
//已连接
@property(assign,nonatomic) int connectedLedEffect;
@end
