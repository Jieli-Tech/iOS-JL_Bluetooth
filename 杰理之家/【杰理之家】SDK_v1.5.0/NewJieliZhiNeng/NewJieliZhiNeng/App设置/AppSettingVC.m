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

#define SHACK_SONG  @"SHACK_SONG"
#define SHACK_LIGHT @"SHACK_LIGHT"

@interface AppSettingVC (){
    UIView *shackView; //摇一摇切歌
    UIView *shackView2;//摇一摇切换灯光颜色
    
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
    
    CGFloat hh = kJL_HeightNavBar;
    
    shackView = [[UIView alloc] initWithFrame:CGRectMake(0, hh+10, sw, 55)];
    UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, sw-60, 55)];
    lab1.textColor = kDF_RGBA(67, 67, 67, 1);
    lab1.font = [UIFont systemFontOfSize:14];
    lab1.text = kJL_TXT("摇一摇切歌");
    [shackView addSubview:lab1];
    UISwitch *swv1 = [[UISwitch alloc] initWithFrame:CGRectMake(sw-60, shackView.frame.size.height/2-15, 50, 30)];
    swv1.onTintColor = kColor_0000;
    swv1.on = YES;
    int value = [[[NSUserDefaults standardUserDefaults] valueForKey:SHACK_SONG] intValue];
    if (value == 0) {
        swv1.on = NO;
    }
    [swv1 addTarget:self action:@selector(shackSwtichSong:) forControlEvents:UIControlEventValueChanged];
    [shackView addSubview:swv1];
    shackView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:shackView];
    hh+=65;
    
    shackView2 = [[UIView alloc] initWithFrame:CGRectMake(0, hh+10, sw, 55)];
    UILabel *lab2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, sw-60, 25)];
    lab2.textColor = kDF_RGBA(67, 67, 67, 1);
    lab2.font = [UIFont systemFontOfSize:14];
    lab2.text = kJL_TXT("摇一摇切换灯光颜色");
    [shackView2 addSubview:lab2];
    
    UILabel *lab3 = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, sw-60, 20)];
    lab3.textColor = kDF_RGBA(149, 149, 149, 1);
    lab3.font = [UIFont systemFontOfSize:11];
    lab3.text = kJL_TXT("仅在设备支持灯光设置时生效");
    [shackView2 addSubview:lab3];
    
    UISwitch *swv2 = [[UISwitch alloc] initWithFrame:CGRectMake(sw-60, shackView.frame.size.height/2-15, 50, 30)];
    swv2.onTintColor = kColor_0000;
    swv2.on = YES;
    int value2 = [[[NSUserDefaults standardUserDefaults] valueForKey:SHACK_LIGHT] intValue];
    if (value2 == 0) {
        swv2.on = NO;
    }
    [swv2 addTarget:self action:@selector(shackSwtichLight:) forControlEvents:UIControlEventValueChanged];
    [shackView2 addSubview:swv2];
    shackView2.backgroundColor = [UIColor whiteColor];

    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    uint32_t function     = deviceModel.function;
    uint32_t fun_light    = function>>5&0x01;
    if(fun_light ==1){
        hh+=65;
        [self.view addSubview:shackView2];
    }
    
    //关于
    aboutView  = [[UIView alloc] init];
    aboutView.frame = CGRectMake(0,hh+10,[DFUITools screen_2_W],55);
    [aboutView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:aboutView];
    
    UILabel *aboutLabel = [[UILabel alloc] init];
    aboutLabel.frame = CGRectMake(15.5,21,50,13);
    aboutLabel.numberOfLines = 0;
    [aboutView addSubview:aboutLabel];
    
    NSMutableAttributedString *nameStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("关于") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:67/255.0 green:67/255.0 blue:67/255.0 alpha:1.0]}];
    
    aboutLabel.attributedText = nameStr;
    aboutLabel = [[UILabel alloc] init];
    aboutLabel.numberOfLines = 0;
    [aboutView addSubview:aboutLabel];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aboutClick)];
    [aboutView addGestureRecognizer:tapGestureRecognizer];
    aboutView.userInteractionEnabled=YES;
    
    
    UIButton *aboutBtn = [[UIButton alloc] initWithFrame:CGRectMake([DFUITools screen_2_W]-32,22.5,24.5,11)];
    [aboutBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_app_settings_next"] forState:UIControlStateNormal];
    [aboutView addSubview:aboutBtn];

    hh+=65;
    
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

#pragma mark ///设置摇一摇事件切歌响应
-(void)shackSwtichSong:(UISwitch *)sender{
    int value = sender.on;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",value] forKey:SHACK_SONG];
}
/// MARK:///设置摇一摇事件换灯色响应
-(void)shackSwtichLight:(UISwitch *)sender{
    int value = sender.on;
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%d",value] forKey:SHACK_LIGHT];
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
