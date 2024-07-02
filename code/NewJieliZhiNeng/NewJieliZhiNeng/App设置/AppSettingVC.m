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
#import "LanguageViewController.h"

#define SHACK_SONG  @"SHACK_SONG"
#define SHACK_LIGHT @"SHACK_LIGHT"

@interface AppSettingVC ()<LanguagePtl>{
    UIView *shackView; //摇一摇切歌
    UIView *shackView2;//摇一摇切换灯光颜色
    UIView *languageView;//多语言设置选项
    
    UILabel *shakeChangeMusicLab;
    UILabel *shakeChangeLightLab;
    UILabel *onlySupportLab;
    UILabel *aboutLabel;
    UILabel *productInstructionsLabel;
    
    UIView *aboutView; //关于View
    UIView *productInstructionsView; //产品使用说明View
    
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    
    UILabel *languageLab1;
    UILabel *languageLab2;
}

@end

@implementation AppSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LanguageCls share] add:self];
    [self addNote];
    [self initUI];
}

-(void)initUI{
    
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    float sw = [UIScreen mainScreen].bounds.size.width;
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("setting");
    titleName.bounds = CGRectMake(0, 0, 200, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    CGFloat hh = kJL_HeightNavBar;
    
    shackView = [[UIView alloc] initWithFrame:CGRectMake(0, hh+10, sw, 55)];
    shakeChangeMusicLab = [[UILabel alloc] initWithFrame:CGRectMake(15.5, 0, sw-60, 55)];
    shakeChangeMusicLab.textColor = kDF_RGBA(36, 36, 36, 1);
    shakeChangeMusicLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    shakeChangeMusicLab.text = kJL_TXT("shake_cut_song");
    [shackView addSubview:shakeChangeMusicLab];
    UISwitch *swv1 = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-67, shackView.frame.size.height/2-15, 50, 30)];
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
    shakeChangeLightLab = [[UILabel alloc] initWithFrame:CGRectMake(15.5, 5, sw-60, 25)];
    shakeChangeLightLab.textColor = kDF_RGBA(36, 36, 36, 1);
    shakeChangeLightLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    shakeChangeLightLab.text = kJL_TXT("shake_change_light_color");
    [shackView2 addSubview:shakeChangeLightLab];
    
    onlySupportLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, sw-60, 20)];
    onlySupportLab.textColor = kDF_RGBA(149, 149, 149, 1);
    onlySupportLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:11];
    onlySupportLab.text = kJL_TXT("shake_change_light_color_note");
    [shackView2 addSubview:onlySupportLab];
    
    UISwitch *swv2 = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-67, shackView.frame.size.height/2-15, 50, 30)];
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
    
    languageView = [[UIView alloc] init];
    languageView.frame = CGRectMake(0, hh+10, [UIScreen mainScreen].bounds.size.width,55);
    [languageView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:languageView];
    
    languageLab1 = [[UILabel alloc] initWithFrame:CGRectMake(15.5,21, 100, 20)];
    languageLab1.textColor = kDF_RGBA(36, 36, 36, 1);
    languageLab1.font = [UIFont fontWithName:@"PingFangSC-Medium" size:14];
    languageLab1.text = kJL_TXT("multilingual");
    [languageView addSubview:languageLab1];
    
    languageLab2 = [[UILabel alloc] initWithFrame:CGRectMake(sw-100-20-12,21, 100, 15)];
    languageLab2.textColor = [UIColor lightGrayColor];
    languageLab2.font = [UIFont fontWithName:@"PingFangSC-Medium" size:13];
    [self setlanguage];
    languageLab2.textAlignment = NSTextAlignmentRight;
    [languageView addSubview:languageLab2];
    
    
    UITapGestureRecognizer *tapGestureRecognizerLangague = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(languageClick)];
    [languageView addGestureRecognizer:tapGestureRecognizerLangague];
    languageView.userInteractionEnabled=YES;
    
    UIButton *languageBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-32,22.5,24.5,11)];
    [languageBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_app_settings_next"] forState:UIControlStateNormal];
    [languageView addSubview:languageBtn];
    hh+=65;
    
    //关于
    aboutView  = [[UIView alloc] init];
    aboutView.frame = CGRectMake(0,hh+10,[UIScreen mainScreen].bounds.size.width,55);
    [aboutView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:aboutView];
    
    aboutLabel = [[UILabel alloc] init];
    aboutLabel.frame = CGRectMake(15.5,21,50,13);
    aboutLabel.numberOfLines = 0;
    [aboutView addSubview:aboutLabel];
    
    NSMutableAttributedString *nameStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("about") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    aboutLabel.attributedText = nameStr;
    aboutLabel.numberOfLines = 0;
    [aboutView addSubview:aboutLabel];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(aboutClick)];
    [aboutView addGestureRecognizer:tapGestureRecognizer];
    aboutView.userInteractionEnabled=YES;
    
    
    UIButton *aboutBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-32,22.5,24.5,11)];
    [aboutBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_app_settings_next"] forState:UIControlStateNormal];
    [aboutView addSubview:aboutBtn];

    hh+=65;
    
    //设备使用说明
    productInstructionsView  = [[UIView alloc] init];
    productInstructionsView.frame = CGRectMake(0,aboutView.frame.origin.y+aboutView.frame.size.height+10,[UIScreen mainScreen].bounds.size.width,55);
    [productInstructionsView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:productInstructionsView];
    
    productInstructionsLabel = [[UILabel alloc] init];
    productInstructionsLabel.frame = CGRectMake(15.5,21,200,20);
    productInstructionsLabel.numberOfLines = 0;
    [productInstructionsView addSubview:productInstructionsLabel];
    
    NSMutableAttributedString *productInstructionsStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("device_instructions") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    
    productInstructionsLabel.attributedText = productInstructionsStr;
    
    UITapGestureRecognizer *productInstructionsGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(productInstructionsClick)];
    [productInstructionsView addGestureRecognizer:productInstructionsGestureRecognizer];
    productInstructionsView.userInteractionEnabled=YES;
    
    
    UIButton *productInstructionsBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-32,22.5,24.5,11)];
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

//MARK: - 进入多语言
-(void)languageClick{
    LanguageViewController *vc = [[LanguageViewController alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:true completion:nil];
}

#pragma mark 进入设备使用说明界面
-(void)productInstructionsClick{
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    
    if(!bleSDK.mBleEntityM){
        [DFUITools showText:kJL_TXT("first_connect_device") onView:self.view delay:1.0];
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


-(void)setlanguage{
    if ([kJL_GET isEqualToString:@"zh-Hans"]) {
        languageLab2.text = kJL_TXT("simplified_chinese");
    }else if([kJL_GET isEqualToString:@"en"]){
        languageLab2.text = kJL_TXT("english");
    }else if ([kJL_GET isEqualToString:@"ja"]){
        languageLab2.text = kJL_TXT("japanese");
    }else{
        languageLab2.text = kJL_TXT("follow_system");
    }
}

- (void)languageChange {
    titleName.text = kJL_TXT("setting");
    languageLab1.text = kJL_TXT("multilingual");
    shakeChangeMusicLab.text = kJL_TXT("shake_cut_song");
    shakeChangeLightLab.text = kJL_TXT("shake_change_light_color");
    onlySupportLab.text = kJL_TXT("shake_change_light_color_note");
    NSMutableAttributedString *nameStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("about") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    aboutLabel.attributedText = nameStr;
    
    NSMutableAttributedString *productInstructionsStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("device_instructions") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    productInstructionsLabel.attributedText = productInstructionsStr;
    [self setlanguage];
}

@end
