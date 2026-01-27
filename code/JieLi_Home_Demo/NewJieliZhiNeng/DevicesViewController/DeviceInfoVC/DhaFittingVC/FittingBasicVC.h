//
//  FittingBasicVC.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/26.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavTopView.h"

NS_ASSUME_NONNULL_BEGIN

#define UseSaveCache 0

@interface FittingBasicVC : UIViewController

@property(nonatomic, strong)  NavTopView*naviView;

-(void)backBtnAction;

-(void)goBackToRoot;

-(void)test;
@end

NS_ASSUME_NONNULL_END
