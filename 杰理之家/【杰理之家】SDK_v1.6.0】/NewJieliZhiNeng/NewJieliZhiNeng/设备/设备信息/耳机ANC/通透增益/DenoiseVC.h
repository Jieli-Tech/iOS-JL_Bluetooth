//
//  DenoiseVC.h
//  NewJieliZhiNeng
//
//  Created by 李放 on 2021/3/25.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface DenoiseVC : UIViewController

@property(nonatomic,strong)JLModel_ANC *model_ANC;

@end

NS_ASSUME_NONNULL_END
