//
//  ReNameView.h
//  CMD_APP
//
//  Created by Ezio on 2018/2/5.
//  Copyright © 2018年 DFung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

@protocol ReNameViewDelegate <NSObject>

-(void)didSelectBtnAction:(UIButton *)btn WithText:(NSString *)text;

@end


@interface ReNameView : UIView
@property (strong, nonatomic) UILabel *titleLab;
@property (strong, nonatomic) UITextField *nameTxfd;
@property (strong, nonatomic) UIButton *cancelBtn;
@property (strong, nonatomic) UIButton *finishBtn;
@property (strong, nonatomic) NSString *txfdStr;
@property (assign, nonatomic) NSInteger sizeLength;
@property (assign, nonatomic) id <ReNameViewDelegate> delegate;

@end
