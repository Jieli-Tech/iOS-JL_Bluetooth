//
//  DeviceMusicVC.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeviceMusicVC : UIViewController
@property(nonatomic,assign)int type;
@property(nonatomic,strong)JLModel_Device *devel;
@end

NS_ASSUME_NONNULL_END
