//
//  AppSettingVC.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AppSettingVC.h"
#import "AppAboutVC.h"
#import "ProductInstructionsVC.h"
#import "JL_RunSDK.h"

@interface AppSettingVC (){
    UIView *aboutView; //关于View
    UIView *productInstructionsView; //产品使用说明View
    
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
}

@end

@implementation AppSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
    [self initUI];
}

-(void)initUI{
    
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    float sw = [DFUITools screen_2_W];
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("设置");
    titleName.bounds = CGRectMake(0, 0, 200, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    
    
    //    titleName.numberOfLines = 0;
    //    NSMutableAttributedString *titleNameStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("设置") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    //    titleName.attributedText = titleNameStr;
    
    //关于
    aboutView  = [[UIView alloc] init];
    if([DFUITools screen_2_H] >=812.0){
        aboutView.frame = CGRectMake(0,kJL_HeightNavBar+10,[DFUITools screen_2_W],55);
    }else{
        aboutView.frame = CGRectMake(0,84,[DFUITools screen_2_W],55);
    }
    //    if (@available(iOS 13.0, *)) {
    //        UIColor *myColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
    //            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
    //                return [UIColor whiteColor];
    //            }
    //            else {
    //                return [UIColor colorWithRed:30/255.0 green:31/255.0 blue:48/255.0 alpha:1.0];
    //            }
    //        }];
    //        [aboutView setBackgroundColor:myColor];
    //    } else {
    [aboutView setBackgroundColor:[UIColor whiteColor]];
    //    }
    [self.view addSubview:aboutView];
    
    UILabel *aboutLabel = [[UILabel alloc] init];
    aboutLabel.frame = CGRectMake(15.5,21,50,13);
    aboutLabel.numberOfLines = 0;
    [aboutView addSubview:aboutLabel];
    //    if (@available(iOS 13.0, *)) {
    //        UIColor *myColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
    //            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
    //                return [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
    //            }
    //            else {
    //                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
    //            }
    //        }];
    //        NSMutableAttributedString *nameStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("关于") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: myColor}];
    //
    //        aboutLabel.attributedText = nameStr;
    //    } else {
    NSMutableAttributedString *nameStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("关于") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0]}];
    
    aboutLabel.attributedText = nameStr;
    //    }
    
    aboutLabel = [[UILabel alloc] init];
    aboutLabel.numberOfLines = 0;
    [aboutView addSubview:aboutLabel];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aboutClick)];
    [aboutView addGestureRecognizer:tapGestureRecognizer];
    aboutView.userInteractionEnabled=YES;
    
    
    UIButton *aboutBtn = [[UIButton alloc] initWithFrame:CGRectMake([DFUITools screen_2_W]-32,22.5,24.5,11)];
    [aboutBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_app_settings_next"] forState:UIControlStateNormal];
    [aboutView addSubview:aboutBtn];
    
    //设备使用说明
    productInstructionsView  = [[UIView alloc] init];
    productInstructionsView.frame = CGRectMake(0,aboutView.frame.origin.y+aboutView.frame.size.height+10,[DFUITools screen_2_W],55);
    [productInstructionsView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:productInstructionsView];
    
    UILabel *productInstructionsLabel = [[UILabel alloc] init];
    productInstructionsLabel.frame = CGRectMake(15.5,21,200,20);
    productInstructionsLabel.numberOfLines = 0;
    [productInstructionsView addSubview:productInstructionsLabel];
    
    NSMutableAttributedString *productInstructionsStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("设备使用说明") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0]}];
    
    productInstructionsLabel.attributedText = productInstructionsStr;
    
    aboutLabel = [[UILabel alloc] init];
    aboutLabel.numberOfLines = 0;
    [productInstructionsView addSubview:aboutLabel];
    
    UITapGestureRecognizer *productInstructionsGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(productInstructionsClick)];
    [productInstructionsView addGestureRecognizer:productInstructionsGestureRecognizer];
    productInstructionsView.userInteractionEnabled=YES;
    
    
    UIButton *productInstructionsBtn = [[UIButton alloc] initWithFrame:CGRectMake([DFUITools screen_2_W]-32,22.5,24.5,11)];
    [productInstructionsBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_app_settings_next"] forState:UIControlStateNormal];
    [productInstructionsView addSubview:productInstructionsBtn];
}

#pragma mark 退出App设置界面
- (IBAction)backExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 进入关于界面
- (void)aboutClick {
    AppAboutVC *vc = [[AppAboutVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark 进入设备使用说明界面
-(void)productInstructionsClick{
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    
    if(!bleSDK.mBleEntityM){
        [DFUITools showText:kJL_TXT("请先连接设备") onView:self.view delay:1.0];
        return;
    }
    ProductInstructionsVC *vc = [[ProductInstructionsVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLUuidType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}


-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

@end
