//
//  BasicViewController.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/9/5.
//  Copyright © 2023 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavTopView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BasicViewController : UIViewController

@property(nonatomic, strong)  NavTopView*naviView;

-(void)initUI;

-(void)initData;

-(void)backBtnAction;

-(void)goBackToRoot;

@end

NS_ASSUME_NONNULL_END
