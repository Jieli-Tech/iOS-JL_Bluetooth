//
//  UpgradeVC.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface UpgradeVC : UIViewController
@property(nonatomic,assign)BOOL needUpgrade;
@property(nonatomic,weak  )JL_EntityM *otaEntity;
@property(nonatomic,assign)int  rootNumber;
@end

NS_ASSUME_NONNULL_END
