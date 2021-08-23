//
//  LightControlVC.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/9/11.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "LightControlVC.h"
#import "JL_RunSDK.h"
#import "RSColorPickerView.h"
#import "FlashCell.h"
#import "SceneCell.h"
#import "JLUI_Cache.h"
#import "JLCacheBox.h"
#import "ShackHandler.h"

#define min3v(v1, v2, v3) ((v1)>(v2)? ((v2)>(v3)?(v3):(v2)):((v1)>(v3)?(v3):(v1)))
#define max3v(v1, v2, v3) ((v1)<(v2)? ((v2)<(v3)?(v3):(v2)):((v1)<(v3)?(v3):(v1)))

@interface LightControlVC ()<UIScrollViewDelegate,RSColorPickerViewDelegate,UITableViewDelegate,UITableViewDataSource
,UICollectionViewDelegate,UICollectionViewDataSource>
{
    float sW;
    float sH;
    __weak IBOutlet NSLayoutConstraint *topViewH;
    __weak IBOutlet NSLayoutConstraint *btn1_c_x;
    __weak IBOutlet NSLayoutConstraint *btn2_c_x;
    __weak IBOutlet NSLayoutConstraint *btn3_c_x;
    
    __weak IBOutlet UILabel *titleName;
    
    __weak IBOutlet UIButton *btn_1;
    __weak IBOutlet UIButton *btn_2;
    __weak IBOutlet UIButton *btn_3;
    __weak IBOutlet UISwitch *switchAll;
    
    __weak IBOutlet UIView *lbView3;
    __weak IBOutlet UIScrollView *subScrollView;
    
    JL_RunSDK   *bleSDK;
    UITapGestureRecognizer *tapGesture; //单击事件
    UIPanGestureRecognizer *panGestureRecognizer; //拖拽事件
    
    //彩灯View
    IBOutlet UIView *lightView_0;
    //闪烁View
    IBOutlet UIView *lightView_1;
    //情景View
    IBOutlet UIView *lightView_2;
        
    //彩灯控制【部分】
    UIColor *addColor;
    __weak IBOutlet UIButton *btnColor;
    NSMutableArray *colectionColors;
    RSColorPickerView *colorPicker;
    
    __weak IBOutlet UILabel *coldLabel;
    __weak IBOutlet UILabel *warmLabel;
    __weak IBOutlet UILabel *grayLabel;
    __weak IBOutlet UILabel *brightLabel;
    __weak IBOutlet UILabel *darkLabel;
    __weak IBOutlet UILabel *sunshineLabel;
    
    __weak IBOutlet UISlider *sliderSewen_0;
    __weak IBOutlet UISlider *sliderSewen_1;
    __weak IBOutlet UISlider *sliderSewen_2;
    
    UIButton *btnColect_0;
    UIButton *btnColect_1;
    UIButton *btnColect_2;
    UIButton *btnColect_3;
    UIButton *btnColect_4;
    UIButton *btnColect_5;
    UIButton *btnColect_6;
    UIButton *btnColect_7;
    UIButton *btnColect_8;
    UIButton *btnColect_9;
    UIButton *btnColect_10;
    UIButton *btnColect_11;
    
    //闪烁控制 【部分】
    UITableView *subTableView;
    NSArray     *imageArray;
    NSArray     *dataArray;
    NSInteger   flashIndex;
    int       freqenyIndex;
    
    UIButton *btnFlash_0;
    UIButton *btnFlash_1;
    UIButton *btnFlash_2;
    UIButton *btnFlash_3;
    
    //情景控制 【部分】
    UICollectionView   *collections;
    NSArray     *sceneImageArray;
    NSArray     *sceneDataArray;
    NSInteger   sceneIndex;
}

@end

@implementation LightControlVC

typedef struct
{
    int  red;              // [0,255]
    int  green;            // [0,255]
    int  blue;             // [0,255]
}COLOR_RGB;

typedef struct
{
    float hue;              // [0,360]
    float saturation;       // [0,100]
    float luminance;        // [0,100]
}COLOR_HSL;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bleSDK = [JL_RunSDK sharedMe];

    [self setupUI];
    [self updateUIFromFirework];
    
    [self addNote];
    
    [self becomeFirstResponder];
}

-(void)setupUI{
    sW = [DFUITools screen_2_W];
    sH = [DFUITools screen_2_H];
    
    [switchAll setOnTintColor:kColor_0000];
    titleName.text= kJL_TXT("灯效设置");
    topViewH.constant = kJL_HeightNavBar+42;
    btn1_c_x.constant = -(sW/4.0);
    btn2_c_x.constant = 0;
    btn3_c_x.constant = +(sW/4.0);
    
    subScrollView.contentSize = CGSizeMake(sW*3.0, 0);
    subScrollView.pagingEnabled = YES;
    subScrollView.delegate = self;
    subScrollView.scrollEnabled= NO;
    
    [btn_1 setTitle:kJL_TXT("彩灯") forState:UIControlStateNormal];
    [btn_2 setTitle:kJL_TXT("闪烁") forState:UIControlStateNormal];
    [btn_3 setTitle:kJL_TXT("情景") forState:UIControlStateNormal];
    
    lightView_0.frame = CGRectMake(0, 0, sW, sH-topViewH.constant);
    lightView_1.frame = CGRectMake(sW, 0, sW, sH-topViewH.constant);
    lightView_2.frame = CGRectMake(sW*2.0, 0, sW, sH-topViewH.constant);
    [lightView_0 setBackgroundColor:kDF_RGBA(248, 250, 252, 1.0)];
    [lightView_1 setBackgroundColor:kDF_RGBA(248, 250, 252, 1.0)];
    [lightView_2 setBackgroundColor:kDF_RGBA(248, 250, 252, 1.0)];
    
    [subScrollView addSubview:lightView_0];
    [subScrollView addSubview:lightView_1];
    [subScrollView addSubview:lightView_2];
    
    //彩灯控制
    colorPicker = [[RSColorPickerView alloc] init];
    colorPicker.center = CGPointMake(sW/2.0, sW/2.0-50.0);
    colorPicker.bounds = CGRectMake(0, 0, (sW/2.0-60.0)*2.0, (sW/2.0-60.0)*2.0);
    colorPicker.cropToCircle = YES;
    colorPicker.delegate = self;
    [lightView_0 addSubview:colorPicker];
    
    btnColor.layer.cornerRadius = 21.0f;
    btnColor.layer.shadowColor  = kDF_RGBA(0, 0, 0, 0.16).CGColor;
    btnColor.layer.shadowOffset = CGSizeMake(0,0);
    btnColor.layer.shadowOpacity= 1;
    btnColor.layer.shadowRadius = 7;
    
    addColor = [UIColor redColor];
    colectionColors = [NSMutableArray new];
    
    UIView *firstView;
    UIView *secView;
    if(sW<=375.0){
        if(sW == 320.0){
            firstView = [[UIView alloc] initWithFrame:CGRectMake(16, colorPicker.frame.origin.y+colorPicker.frame.size.height+15, [DFUITools screen_2_W]-16*2, 32)];
            secView = [[UIView alloc] initWithFrame:CGRectMake(16, colorPicker.frame.origin.y+colorPicker.frame.size.height+60, [DFUITools screen_2_W]-16*2, 32)];
        }else{
            firstView = [[UIView alloc] initWithFrame:CGRectMake(16, colorPicker.frame.origin.y+colorPicker.frame.size.height+40.5, [DFUITools screen_2_W]-16*2, 32)];
            secView = [[UIView alloc] initWithFrame:CGRectMake(16, colorPicker.frame.origin.y+colorPicker.frame.size.height+85, [DFUITools screen_2_W]-16*2, 32)];
        }
    }else{
        firstView = [[UIView alloc] initWithFrame:CGRectMake(32, colorPicker.frame.origin.y+colorPicker.frame.size.height+40.5, [DFUITools screen_2_W]-32*2, 32)];
        secView = [[UIView alloc] initWithFrame:CGRectMake(32, colorPicker.frame.origin.y+colorPicker.frame.size.height+85, [DFUITools screen_2_W]-32*2, 32)];
    }
    
    [lightView_0 addSubview:firstView];
    [lightView_0 addSubview:secView];
    
    int distance_1 = 0;
    int distance_2 = 0;
    if(sW == 320.0){
        distance_1 = 6;
        distance_2 = 19;
    }else{
        distance_1 = 12;
        distance_2 = 29;
    }
    for (int i = 0; i<6; i++) {
        UIButton *btn;
        btn = [[UIButton alloc] initWithFrame:CGRectMake(distance_1+30*i+distance_2*i, 1, 30,30)];
        if(i==0) {
            btnColect_0 =btn;
        }
        if(i==1) {
            btnColect_1 =btn;
        }
        if(i==2) {
            btnColect_2 =btn;
        }
        if(i==3) {
            btnColect_3 =btn;
        }
        if(i==4) {
            btnColect_4 =btn;
        }
        if(i==5) {
            btnColect_5 =btn;
        }
        [firstView addSubview:btn];
        btn.tag = i;
        btn.layer.cornerRadius = 15.f;
        btn.backgroundColor = kDF_RGBA(242, 242, 247, 1.0);
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    for (int i = 0; i<6; i++) {
        UIButton *btn;
        btn = [[UIButton alloc] initWithFrame:CGRectMake(distance_1+30*i+distance_2*i, 1, 30,30)];
        if(i==0) {
            btnColect_6 =btn;
        }
        if(i==1) {
            btnColect_7 =btn;
        }
        if(i==2) {
            btnColect_8 =btn;
        }
        if(i==3) {
            btnColect_9 =btn;
        }
        if(i==4) {
            btnColect_10 =btn;
        }
        if(i==5) {
            btnColect_11 =btn;
            [btnColect_11 setImage:[UIImage imageNamed:@"Theme.bundle/icon_add"] forState:UIControlStateNormal];
        }
        [secView addSubview:btn];
        btn.tag = i+6;
        btn.layer.cornerRadius = 15.f;
        btn.backgroundColor = kDF_RGBA(242, 242, 247, 1.0);
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //H
    if(sW == 320.0){
        sliderSewen_0.frame = CGRectMake(42.5,secView.frame.origin.y+secView.frame.size.height+19, [DFUITools screen_2_W] - 2*47.5, 30);
        if([kJL_GET hasPrefix:@"zh"]){
            coldLabel.frame = CGRectMake(22, secView.frame.origin.y+secView.frame.size.height+23, 25, 25);
            warmLabel.frame = CGRectMake([DFUITools screen_2_W]-44, secView.frame.origin.y+secView.frame.size.height+23, 25, 25);
        }else{
            coldLabel.frame = CGRectMake(10, secView.frame.origin.y+secView.frame.size.height+23, 50, 25);
            warmLabel.frame = CGRectMake([DFUITools screen_2_W]-50, secView.frame.origin.y+secView.frame.size.height+23, 50, 25);
        }
    }else{
        sliderSewen_0.frame = CGRectMake(42.5,secView.frame.origin.y+secView.frame.size.height+24, [DFUITools screen_2_W] - 2*47.5, 30);
        if([kJL_GET hasPrefix:@"zh"]){
            coldLabel.frame = CGRectMake(22, secView.frame.origin.y+secView.frame.size.height+28, 25, 25);
            warmLabel.frame = CGRectMake([DFUITools screen_2_W]-44, secView.frame.origin.y+secView.frame.size.height+28, 25, 25);
        }else{
            coldLabel.frame = CGRectMake(10, secView.frame.origin.y+secView.frame.size.height+28, 50, 25);
            warmLabel.frame = CGRectMake([DFUITools screen_2_W]-50, secView.frame.origin.y+secView.frame.size.height+28, 50, 25);
        }
    }
    [sliderSewen_0 setMinimumTrackTintColor:kColor_0000];
    
    coldLabel.contentMode = UIViewContentModeRight;
    coldLabel.attributedText = [self setHSLText:kJL_TXT("冷")];
    warmLabel.contentMode = UIViewContentModeLeft;
    warmLabel.attributedText = [self setHSLText:kJL_TXT("暖")];
    
    //S
    if(sW == 320.0){
        sliderSewen_1.frame = CGRectMake(42.5, warmLabel.frame.origin.y+warmLabel.frame.size.height+19, [DFUITools screen_2_W] - 2*47.5, 30);
        if([kJL_GET hasPrefix:@"zh"]){
            grayLabel.frame = CGRectMake(22, warmLabel.frame.origin.y+warmLabel.frame.size.height+23, 25, 25);
            brightLabel.frame = CGRectMake([DFUITools screen_2_W]-44, warmLabel.frame.origin.y+warmLabel.frame.size.height+23, 54, 25);
        }else{
            grayLabel.frame = CGRectMake(10, warmLabel.frame.origin.y+warmLabel.frame.size.height+23, 50, 25);
            brightLabel.frame = CGRectMake([DFUITools screen_2_W]-50, warmLabel.frame.origin.y+warmLabel.frame.size.height+23, 54, 25);
        }
    }else{
        sliderSewen_1.frame = CGRectMake(42.5, warmLabel.frame.origin.y+warmLabel.frame.size.height+24, [DFUITools screen_2_W] - 2*47.5, 30);
        if([kJL_GET hasPrefix:@"zh"]){
            grayLabel.frame = CGRectMake(22, warmLabel.frame.origin.y+warmLabel.frame.size.height+28, 25, 25);
            brightLabel.frame = CGRectMake([DFUITools screen_2_W]-44, warmLabel.frame.origin.y+warmLabel.frame.size.height+28, 54, 25);
        }else{
            grayLabel.frame = CGRectMake(10, warmLabel.frame.origin.y+warmLabel.frame.size.height+28, 50, 25);
            brightLabel.frame = CGRectMake([DFUITools screen_2_W]-50, warmLabel.frame.origin.y+warmLabel.frame.size.height+28, 54, 25);
        }
    }
    [sliderSewen_1 setMinimumTrackTintColor:kColor_0000];
    
    grayLabel.contentMode = UIViewContentModeRight;
    grayLabel.attributedText = [self setHSLText:kJL_TXT("灰")];
    brightLabel.contentMode = UIViewContentModeLeft;
    brightLabel.attributedText = [self setHSLText:kJL_TXT("鲜艳")];
    
    //L
    if(sW == 320.0){
        sliderSewen_2.frame = CGRectMake(42.5,grayLabel.frame.origin.y+grayLabel.frame.size.height+19, [DFUITools screen_2_W] - 2*47.5, 30);
        if([kJL_GET hasPrefix:@"zh"]){
            darkLabel.frame = CGRectMake(22, grayLabel.frame.origin.y+grayLabel.frame.size.height+23, 25, 25);
            sunshineLabel.frame = CGRectMake([DFUITools screen_2_W]-44, grayLabel.frame.origin.y+grayLabel.frame.size.height+23, 54, 25);
        }else{
            darkLabel.frame = CGRectMake(10, grayLabel.frame.origin.y+grayLabel.frame.size.height+23, 50, 25);
            sunshineLabel.frame = CGRectMake([DFUITools screen_2_W]-50, grayLabel.frame.origin.y+grayLabel.frame.size.height+23, 54, 25);
        }
    }else{
        sliderSewen_2.frame = CGRectMake(42.5,grayLabel.frame.origin.y+grayLabel.frame.size.height+24, [DFUITools screen_2_W] - 2*47.5, 30);
        if([kJL_GET hasPrefix:@"zh"]){
            darkLabel.frame = CGRectMake(22, grayLabel.frame.origin.y+grayLabel.frame.size.height+28, 25, 25);
            sunshineLabel.frame = CGRectMake([DFUITools screen_2_W]-44, grayLabel.frame.origin.y+grayLabel.frame.size.height+28, 54, 25);
        }else{
            darkLabel.frame = CGRectMake(10, grayLabel.frame.origin.y+grayLabel.frame.size.height+28, 50, 25);
            sunshineLabel.frame = CGRectMake([DFUITools screen_2_W]-50, grayLabel.frame.origin.y+grayLabel.frame.size.height+28, 54, 25);
        }
    }
    [sliderSewen_2 setMinimumTrackTintColor:kColor_0000];
    
    darkLabel.contentMode = UIViewContentModeRight;
    darkLabel.attributedText = [self setHSLText:kJL_TXT("暗")];
    sunshineLabel.contentMode = UIViewContentModeLeft;
    sunshineLabel.attributedText = [self setHSLText:kJL_TXT("阳光")];
    
    //闪烁控制
    subTableView = [[UITableView alloc] init];
    if(sW == 320.0){
        subTableView.frame = CGRectMake(0, 0, sW, 350);
    }else{
        subTableView.frame = CGRectMake(0, 0, sW, 440);
    }
    subTableView.backgroundColor = [UIColor whiteColor];
    subTableView.tableFooterView =  [UIView new];
    subTableView.showsVerticalScrollIndicator = NO;
    subTableView.rowHeight  = 55.0;
    subTableView.dataSource = self;
    subTableView.delegate   = self;
    [lightView_1 addSubview:subTableView];
    subTableView.separatorInset = UIEdgeInsetsZero;
    subTableView.layoutMargins = UIEdgeInsetsZero;
    [subTableView setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    imageArray= @[@"Theme.bundle/icon_colorful",@"Theme.bundle/icon_red",@"Theme.bundle/icon_orange",
                  @"Theme.bundle/icon_yellow",@"Theme.bundle/icon_green",@"Theme.bundle/icon_cyan",
                  @"Theme.bundle/icon_blue",@"Theme.bundle/icon_purple"];
    dataArray = @[kJL_TXT("七彩闪烁"),kJL_TXT("红色闪烁"),kJL_TXT("橙色闪烁"),kJL_TXT("黄色闪烁"),
                  kJL_TXT("绿色闪烁"),kJL_TXT("青色闪烁"),kJL_TXT("蓝色闪烁"),kJL_TXT("紫色闪烁")];
    [subTableView reloadData];
    
    [self setFlashBtns];
    
    //情景控制 【部分】
    //创建一个layout布局类
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection    = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    CGFloat itemW = (sW - 12)/ 3;
    CGFloat itemH = itemW;
    layout.itemSize           = CGSizeMake(itemW, itemH);
    layout.minimumLineSpacing = 0.0;
    layout.minimumInteritemSpacing = 0.0;
    
    float w = [DFUITools screen_2_W];
    float h = [DFUITools screen_2_H] - topViewH.constant;
    collections = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 12, w, h)
                                     collectionViewLayout:layout];
    
    collections.backgroundColor = [UIColor clearColor];
    collections.showsVerticalScrollIndicator   = NO;
    collections.showsHorizontalScrollIndicator = NO;
    collections.scrollEnabled = NO;
    
    UINib *nib = [UINib nibWithNibName:@"SceneCell" bundle:nil];
    [collections registerNib:nib forCellWithReuseIdentifier:@"SceneCell"];
    [lightView_2 addSubview:collections];
    collections.delegate   = self;
    collections.dataSource = self;
    
    sceneImageArray = @[@"Theme.bundle/light_icon_rainbow",@"Theme.bundle/light_icon_heart",@"Theme.bundle/light_icon_candle",
                        @"Theme.bundle/light_icon_night",@"Theme.bundle/light_icon_soundbox",@"Theme.bundle/light_icon_colorful",
                        @"Theme.bundle/light_icon_red",@"Theme.bundle/light_icon_green",@"Theme.bundle/light_icon_blue",@"Theme.bundle/light_icon_greenleaf",@"Theme.bundle/light_icon_sun",@"Theme.bundle/light_icon_music"];
    sceneDataArray = @[kJL_TXT("彩虹"),kJL_TXT("心跳"),kJL_TXT("烛火"),kJL_TXT("夜灯"),
                       kJL_TXT("舞台"),kJL_TXT("漫彩呼吸"),kJL_TXT("漫红呼吸"),kJL_TXT("漫绿呼吸")
                       ,kJL_TXT("漫蓝呼吸"),kJL_TXT("绿色心情"),kJL_TXT("夕阳美景"),kJL_TXT("音乐律动")];
    
    //btnColor.backgroundColor = [UIColor whiteColor];
    //colorPicker.selectionColor = [UIColor whiteColor];
    NSMutableArray *array = [[self getLights] mutableCopy];
    if(array.count >0){
        colectionColors = array;
        [self updateColectColorBtn];
    }
    lbView3.center = CGPointMake(sW/4.0, topViewH.constant-1.5);
}

//彩灯控制界面
-(void)btnAction:(UIButton *)btn{
    NSInteger  ct = colectionColors.count;
    NSInteger tag = btn.tag;
    
    if(tag == 11){
        [self btnAddColor];
    }else{
        if (tag+1 <= ct) {
            UIColor *color = colectionColors[tag];
            colorPicker.selectionColor = color;
            colorPicker.brightness = 0.5;
            
            const CGFloat *cls = CGColorGetComponents(color.CGColor);
            int led_r = (int)(cls[0]*255.0);
            int led_g = (int)(cls[1]*255.0);
            int led_b = (int)(cls[2]*255.0);
            COLOR_RGB rgb = {led_r,led_g,led_b};

            COLOR_HSL hsl = {0,0,0};
            RGBtoHSL(&rgb, &hsl);

            if(hsl.hue>0) sliderSewen_0.value = hsl.hue/360;
            if(hsl.saturation>0) sliderSewen_1.value = hsl.saturation/100;
            sliderSewen_2.value = hsl.luminance/100;
            
            [self sendMessageLightState:2 withLightMode:0];
        }
    }
}

#pragma mark 闪烁界面---》闪灯频率
-(void)bottomBtnAction:(UIButton *)btn{
    freqenyIndex = (int) btn.tag;
    switch (btn.tag) {
        case 0:
        {
            [btnFlash_0 setTitleColor: kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
            btnFlash_0.backgroundColor = kColor_0000;
            
            [btnFlash_1 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_1.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_2 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_2.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_3 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_3.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
        }
            break;
        case 1:
        {
            [btnFlash_1 setTitleColor: kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
            btnFlash_1.backgroundColor = kColor_0000;
            
            [btnFlash_0 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_0.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_2 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_2.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_3 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_3.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
        }
            break;
        case 2:
        {
            [btnFlash_2 setTitleColor: kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
            btnFlash_2.backgroundColor = kColor_0000;
            
            [btnFlash_0 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_0.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_1 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_1.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_3 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_3.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
        }
            break;
        case 3:
        {
            [btnFlash_3 setTitleColor: kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
            btnFlash_3.backgroundColor = kColor_0000;
            
            [btnFlash_0 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_0.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_1 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_1.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_2 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_2.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
        }
            break;
        default:
            break;
    }
    [self sendMessageLightState:2 withLightMode:1];
}

- (IBAction)btn_back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onSwitchChange:(UISwitch *)sender {
    NSLog(@"--->总开关:%d",sender.isOn);
    switchAll.on = sender.on;
    [self handleSwitch];
    [self sendMessageLightState:sender.isOn withLightMode:0];
}

- (IBAction)btn_control:(UIButton *)sender {
    [subScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (IBAction)btn_flash:(UIButton *)sender {
    [subScrollView setContentOffset:CGPointMake(sW, 0) animated:YES];
}

- (IBAction)btn_scene:(id)sender {
    [subScrollView setContentOffset:CGPointMake(2.0*sW, 0) animated:YES];
}

static UIButton *btnStart = nil;
- (void)btnAddColor{
    [DFAction setMinExecutionGap:0.35];
    
    UIColor *nowColor = [addColor copy];
    if ([colectionColors containsObject:nowColor]) {
        for (UIColor *color in colectionColors) {
            if ([color isEqual:nowColor]) {
                [colectionColors removeObject:color];
                break;
            }
        }
    }else{
        if (colectionColors.count == 11) {
            [colectionColors removeLastObject];
        }
    }
    
    [colectionColors insertObject:nowColor atIndex:0];
    [self saveLights];
    [self addCopyBtnWithColor:nowColor];
    [self addColorAnimation];
}

-(void)addCopyBtnWithColor:(UIColor*)color{
    if (btnStart) {
        [btnStart removeFromSuperview];
        btnStart = nil;
    }
    btnStart = [[UIButton alloc] init];
    btnStart.layer.cornerRadius = btnColor.layer.cornerRadius;
    btnStart.bounds = CGRectMake(0, 0, btnColor.frame.size.width, btnColor.frame.size.height);
    btnStart.center = CGPointMake(btnColor.center.x,btnColor.center.y);
    btnStart.backgroundColor = color;
    [lightView_0 addSubview:btnStart];
}

-(void)addColorAnimation{
    CAKeyframeAnimation *keyframeAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, btnStart.layer.position.x, btnStart.layer.position.y);//移动到起始点
    CGPathAddQuadCurveToPoint(path, NULL, sW/2.0, -100, btnColect_0.center.x, btnColect_0.center.y);
    keyframeAnimation.path = path;
    CGPathRelease(path);
    keyframeAnimation.duration = 0.35;
    [btnStart.layer addAnimation:keyframeAnimation forKey:@"KCKeyframeAnimation_Position"];
    [DFAction delay:0.32 Task:^{
        [self updateColectColorBtn];
        [btnStart removeFromSuperview];
        btnStart = nil;
    }];
}

-(void)updateColectColorBtn{
    for (int i = 0 ; i < colectionColors.count; i++) {
        UIColor *color = colectionColors[i];
        if (i == 0)  btnColect_0.backgroundColor = color;
        if (i == 1)  btnColect_1.backgroundColor = color;
        if (i == 2)  btnColect_2.backgroundColor = color;
        if (i == 3)  btnColect_3.backgroundColor = color;
        if (i == 4)  btnColect_4.backgroundColor = color;
        if (i == 5)  btnColect_5.backgroundColor = color;
        if (i == 6)  btnColect_6.backgroundColor = color;
        if (i == 7)  btnColect_7.backgroundColor = color;
        if (i == 8)  btnColect_8.backgroundColor = color;
        if (i == 9)  btnColect_9.backgroundColor = color;
        if (i == 10) btnColect_10.backgroundColor = color;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float x = scrollView.contentOffset.x;
    
    if(x==0.f){
        return;
    }
    float scale = x/(2.0*sW);
    NSLog(@"---> %.2f",scale);
    self->lbView3.center = CGPointMake(self->sW/2.0-self->sW/4.0+(scale*2*self->sW/4.0), self->topViewH.constant-1.5);
    
    if (scale < 0.33f) {
        [DFUITools setButton:btn_1 Color:[UIColor blackColor]];
        [DFUITools setButton:btn_2 Color:kDF_RGBA(154, 154, 154, 1.0)];
        [DFUITools setButton:btn_3 Color:kDF_RGBA(154, 154, 154, 1.0)];
    }
    if (scale >= 0.33f && scale <= 0.67f){
        [DFUITools setButton:btn_1 Color:kDF_RGBA(154, 154, 154, 1.0)];
        [DFUITools setButton:btn_2 Color:[UIColor blackColor]];
        [DFUITools setButton:btn_3 Color:kDF_RGBA(154, 154, 154, 1.0)];
    }
    if (scale >= 0.67f){
        [DFUITools setButton:btn_1 Color:kDF_RGBA(154, 154, 154, 1.0)];
        [DFUITools setButton:btn_2 Color:kDF_RGBA(154, 154, 154, 1.0)];
        [DFUITools setButton:btn_3 Color:[UIColor blackColor]];
    }
}

#pragma mark <------ 彩灯控制 ------>
#pragma mark RSColorPickerView【Delegate】
- (void)colorPickerDidChangeSelection:(RSColorPickerView *)colorPicker
{
    const CGFloat *cls = CGColorGetComponents(colorPicker.selectionColor.CGColor);
    uint8_t led_r = (uint8_t)(cls[0]*255.0);
    uint8_t led_g = (uint8_t)(cls[1]*255.0);
    uint8_t led_b = (uint8_t)(cls[2]*255.0);
    NSLog(@"CHANGE ==> R:%d G:%d B:%d",led_r,led_g,led_b);
}

- (void)colorPicker:(RSColorPickerView *)colorPicker
       touchesEnded:(NSSet *)touches
          withEvent:(UIEvent *)event
{
    const CGFloat *cls = CGColorGetComponents(colorPicker.selectionColor.CGColor);
    uint8_t led_r = (uint8_t)(cls[0]*255.0);
    uint8_t led_g = (uint8_t)(cls[1]*255.0);
    uint8_t led_b = (uint8_t)(cls[2]*255.0);
    NSLog(@"END ==> R:%d G:%d B:%d",led_r,led_g,led_b);
           
    COLOR_RGB rgb = {led_r,led_g,led_b};
    COLOR_HSL hsl = {0,0,0};
    RGBtoHSL(&rgb, &hsl);

    if(hsl.hue>0) sliderSewen_0.value = hsl.hue/360;
    if(hsl.saturation>0) sliderSewen_1.value = hsl.saturation/100;
    
    [self sendMessageLightState:2 withLightMode:0];
}

#pragma mark RGB to HSL
static void RGBtoHSL(const COLOR_RGB *rgb, COLOR_HSL *hsl)
{
    float h=0, s=0, l=0;
    // normalizes red-green-blue values
    float r = rgb->red/255.0f;
    float g = rgb->green/255.0f;
    float b = rgb->blue/255.0f;
    float maxVal = max3v(r, g, b);
    float minVal = min3v(r, g, b);
    
    // hue
    if(maxVal == minVal)
    {
        h = 0; // undefined
    }
    else if(maxVal==r && g>=b)
    {
        h = 60.0f*(g-b)/(maxVal-minVal);
    }
    else if(maxVal==r && g<b)
    {
        h = 60.0f*(g-b)/(maxVal-minVal) + 360.0f;
    }
    else if(maxVal==g)
    {
        h = 60.0f*(b-r)/(maxVal-minVal) + 120.0f;
    }
    else if(maxVal==b)
    {
        h = 60.0f*(r-g)/(maxVal-minVal) + 240.0f;
    }
    
    // luminance
    l = (maxVal+minVal)/2.0f;
    
    // saturation
    if(l == 0 || maxVal == minVal)
    {
        s = 0;
    }
    else if(0<l && l<=0.5f)
    {
        s = (maxVal-minVal)/(maxVal+minVal);
    }
    else if(l>0.5f)
    {
        s = (maxVal-minVal)/(maxVal+minVal); // s = (maxVal-minVal)/(2 - (maxVal+minVal)); //(maxVal-minVal > 0)?
    }
    
    hsl->hue = (h>360)? 360 : ((h<0)?0:h);
    hsl->saturation = ((s>1)? 1 : ((s<0)?0:s))*100;
    hsl->luminance = ((l>1)? 1 : ((l<0)?0:l))*100;
}

#pragma mark  HSL to RGB
static void HSLtoRGB(const COLOR_HSL *hsl, COLOR_RGB *rgb)
{
    float h = hsl->hue;                  // h must be [0, 360]
    float s = hsl->saturation/100.f;     // s must be [0, 1]
    float l = hsl->luminance/100.f;      // l must be [0, 1]
    float R, G, B;
    if(hsl->saturation == 0)
    {
        // achromatic color (gray scale)
        R = G = B = l*255.0f;
    }
    else
    {
        float q = (l<0.5f)?(l * (1.0f+s)):(l+s - (l*s));
        float p = (2.0f * l) - q;
        float Hk = h/360.0f;
        float T[3];
        T[0] = Hk + 0.3333333f; // Tr   0.3333333f=1.0/3.0
        T[1] = Hk;              // Tb
        T[2] = Hk - 0.3333333f; // Tg
        for(int i=0; i<3; i++)
        {
            if(T[i] < 0) T[i] += 1.0f;
            if(T[i] > 1) T[i] -= 1.0f;
            if((T[i]*6) < 1)
            {
                T[i] = p + ((q-p)*6.0f*T[i]);
            }
            else if((T[i]*2.0f) < 1) //(1.0/6.0)<=T[i] && T[i]<0.5
            {
                T[i] = q;
            }
            else if((T[i]*3.0f) < 2) // 0.5<=T[i] && T[i]<(2.0/3.0)
            {
                T[i] = p + (q-p) * ((2.0f/3.0f) - T[i]) * 6.0f;
            }
            else T[i] = p;
        }
        R = T[0]*255.0f;
        G = T[1]*255.0f;
        B = T[2]*255.0f;
    }
    
    rgb->red = (int)((R>255)? 255 : ((R<0)?0 : R));
    rgb->green = (int)((G>255)? 255 : ((G<0)?0 : G));
    rgb->blue = (int)((B>255)? 255 : ((B<0)?0 : B));
}

- (IBAction)sliderSeWenActionDownFir:(UISlider *)sender {
    subScrollView.scrollEnabled = NO;
}

- (IBAction)sliderSeWenActionDownSec:(UISlider *)sender {
    subScrollView.scrollEnabled = NO;
}

- (IBAction)sliderSeWenActionDownThird:(UISlider *)sender {
    subScrollView.scrollEnabled = NO;
}

- (IBAction)sliderSeWenActionFir:(UISlider *)sender {
    subScrollView.scrollEnabled = NO;
    sliderSewen_0.value=sender.value;
    COLOR_HSL hsl = {360*(sender.value),100*(sliderSewen_1.value),100*(0.5)};
    COLOR_RGB rgb = {0,0,0};
    HSLtoRGB(&hsl, &rgb);
    
    colorPicker.selectionColor = kDF_RGBA(rgb.red, rgb.green, rgb.blue, 1.0);
    
    [self sendMessageLightState:2 withLightMode:0];
}

- (IBAction)sliderSeWenActionSec:(UISlider *)sender {
    subScrollView.scrollEnabled = NO;
    sliderSewen_1.value=sender.value;
    COLOR_HSL hsl = {360*(sliderSewen_0.value),100*(sender.value),100*(0.5)};
    COLOR_RGB rgb = {0,0,0};
    HSLtoRGB(&hsl, &rgb);
    
    colorPicker.selectionColor = kDF_RGBA(rgb.red, rgb.green, rgb.blue, 1.0);
    
    [self sendMessageLightState:2 withLightMode:0];
}

- (IBAction)sliderSeWenActionThird:(UISlider *)sender {
    subScrollView.scrollEnabled = NO;
    sliderSewen_2.value=sender.value;
    
    [self sendMessageLightState:2 withLightMode:0];
}

#pragma mark <------ 闪烁控制 ------>
#pragma mark <- tableView Delegate ->
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    static NSString * IDCell = @"FLASH_CELL";
    FlashCell *cell = [tableView dequeueReusableCellWithIdentifier:[FlashCell ID]];
    if (cell == nil) {
        cell = [[FlashCell alloc] init];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.subText.text = dataArray[indexPath.row];
    cell.subImage_0.image = [UIImage imageNamed:imageArray[indexPath.row]];
    if(flashIndex == indexPath.row){
        cell.isSelected = YES;
    }else{
        cell.isSelected = NO;
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    flashIndex = indexPath.row;
    
    [self sendMessageLightState:2 withLightMode:1];
    [tableView reloadData];
}

#pragma mark <------ 情景控制 ------>
#pragma mark <- collectionView Delegate ->
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return sceneDataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SceneCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SceneCell" forIndexPath:indexPath];
    
    cell.cellView.backgroundColor = [UIColor whiteColor];
    cell.cellView.layer.shadowOpacity = 1;
    cell.cellView.layer.shadowRadius = 8;
    cell.cellView.layer.cornerRadius = 15;
    
    if(sceneIndex == indexPath.row){
        cell.cellView.layer.shadowColor =  kDF_RGBA(0, 38, 68, 0.3).CGColor;
        cell.cellView.layer.shadowOffset = CGSizeMake(0,0);
    }else{
        cell.cellView.layer.shadowColor = kDF_RGBA(205, 231, 251, 0.2).CGColor;
        cell.cellView.layer.shadowOffset = CGSizeMake(1,1);
    }
    
    [cell.cellImv setImage:[UIImage imageNamed:sceneImageArray[indexPath.row]]];
    [cell.cellLabel setText:sceneDataArray[indexPath.row]];
    [cell.cellLabel setFont:[UIFont fontWithName:@"PingFang SC" size: 15]];
    [cell.cellLabel setTextColor:kDF_RGBA(36, 36, 36, 1.0)];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    sceneIndex = indexPath.row;
    [self sendMessageLightState:2 withLightMode:2];
    [collections reloadData];
}

#pragma mark 彩灯控制界面--->HSL进度条文本显示
-(NSMutableAttributedString *)setHSLText:(NSString *) txt{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:txt attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:96/255.0 green:96/255.0 blue:96/255.0 alpha:1.0]}];
    return str;
}

#pragma mark 闪烁控制界面--->设置闪灯频率文本显示
-(NSMutableAttributedString *)setFlashText:(NSString *) txt{
    NSMutableAttributedString *flashStr = [[NSMutableAttributedString alloc] initWithString:txt attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    return flashStr;
}

#pragma mark 闪烁控制界面--->设置闪灯频率显示
-(void)setFlashBtns{
    UIView *bottomView = [[UIView alloc] init];
    bottomView.frame = CGRectMake(0,subTableView.frame.origin.y+subTableView.frame.size.height+10.5,[DFUITools screen_2_W],100.5);
    bottomView.backgroundColor = [UIColor whiteColor];
    [lightView_1 addSubview:bottomView];
    
    UILabel *flashFrelabel = [[UILabel alloc] init];
    flashFrelabel.frame = CGRectMake(20.5,14.5,200,30);
    flashFrelabel.numberOfLines = 0;
    [bottomView addSubview:flashFrelabel];
    flashFrelabel.attributedText = [self setFlashText:kJL_TXT("闪灯频率")];
    
    UIView *buttonsView;
    int distance = 0;
    if(sW <=375.0){
        if(sW == 320.0){
            buttonsView = [[UIView alloc] initWithFrame:CGRectMake(6, 48.5, [DFUITools screen_2_W]-2*6, 32)];
            distance = 19;
        }else{
            buttonsView = [[UIView alloc] initWithFrame:CGRectMake(13, 48.5, [DFUITools screen_2_W]-2*13, 32)];
            distance = 33;
        }
    }else{
        buttonsView = [[UIView alloc] initWithFrame:CGRectMake(26, 48.5, [DFUITools screen_2_W]-2*26, 32)];
        distance = 37;
    }    
    [bottomView addSubview:buttonsView];
    
    for (int i = 0; i<4; i++) {
        UIButton *btn;
        if(i == 0){
            btnFlash_0 =btn;
            btnFlash_0 = [[UIButton alloc] initWithFrame:CGRectMake(57*i+distance*i, 1, 57,30)];
            [btnFlash_0 setTitle:kJL_TXT("快闪") forState:UIControlStateNormal];
            
            [buttonsView addSubview:btnFlash_0];
            btnFlash_0.tag = i;
            [btnFlash_0 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            [btnFlash_0.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size: 14]];
            btnFlash_0.layer.cornerRadius = 15.f;
            btnFlash_0.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            [btnFlash_0 addTarget:self action:@selector(bottomBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if(i == 1){
            btnFlash_1 =btn;
            btnFlash_1 = [[UIButton alloc] initWithFrame:CGRectMake(57*i+distance*i, 1, 57,30)];
            [btnFlash_1 setTitle:kJL_TXT("慢闪") forState:UIControlStateNormal];
            
            [buttonsView addSubview:btnFlash_1];
            btnFlash_1.tag = i;
            [btnFlash_1 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            [btnFlash_1.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size: 14]];
            btnFlash_1.layer.cornerRadius = 15.f;
            btnFlash_1.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            [btnFlash_1 addTarget:self action:@selector(bottomBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if(i == 2){
            btnFlash_2 =btn;
            btnFlash_2 = [[UIButton alloc] initWithFrame:CGRectMake(57*i+distance*i, 1, 57,30)];
            [btnFlash_2 setTitle:kJL_TXT("缓闪") forState:UIControlStateNormal];
            
            [buttonsView addSubview:btnFlash_2];
            btnFlash_2.tag = i;
            [btnFlash_2 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            [btnFlash_2.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size: 14]];
            btnFlash_2.layer.cornerRadius = 15.f;
            btnFlash_2.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            [btnFlash_2 addTarget:self action:@selector(bottomBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        if(i == 3){
            btnFlash_3 =btn;
            btnFlash_3 = [[UIButton alloc] initWithFrame:CGRectMake(57*i+distance*i, 1, 80,30)];
            [btnFlash_3 setTitle:kJL_TXT("音乐闪烁") forState:UIControlStateNormal];
            
            [buttonsView addSubview:btnFlash_3];
            btnFlash_3.tag = i;
            [btnFlash_3 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            [btnFlash_3.titleLabel setFont:[UIFont fontWithName:@"PingFang SC" size: 14]];
            btnFlash_3.layer.cornerRadius = 15.f;
            btnFlash_3.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            [btnFlash_3 addTarget:self action:@selector(bottomBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

-(void)noteDeviceChange:(NSNotification*)note{
    
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (tp == JLDeviceChangeTypeBleOFF) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)noteSystemInfo:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    [self updateUIFromFirework];
}

#pragma mark 固件---->App 从固件读取数据的状态
-(void)updateUIFromFirework{
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    
    //总开关的状态
    int state = -1;
    if(model.lightState == 2){
        state = 1;
    }else{
        state = model.lightState;
    }
    switchAll.on = state;
    
    if(switchAll.on == 0){
        //[DFUITools showText:kJL_TXT("请打开总开关") onView:self.view delay:1.0];
    }
    [self handleSwitch];
    
    //彩灯界面
    btnColor.backgroundColor = kDF_RGBA(model.lightRed, model.lightGreen, model.lightBlue, 1.0);
    colorPicker.selectionColor = kDF_RGBA(model.lightRed,model.lightGreen,model.lightBlue, 1.0);
    colorPicker.brightness = 0.5;
    
    //HSL
    float hue = model.lightHue;
    float sat = model.lightSat;
    float lightness = model.lightLightness;
    
    sliderSewen_0.value = hue/360;
    sliderSewen_1.value = sat/100;
    sliderSewen_2.value = lightness/100;
    
    //闪烁界面
    flashIndex = model.lightFlashIndex;
    [subTableView reloadData];

    freqenyIndex = model.lightFrequencyIndex;
    switch (freqenyIndex)
    {
        case 0:
        {
            [btnFlash_0 setTitleColor: kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
            btnFlash_0.backgroundColor = kColor_0000;
            
            [btnFlash_1 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_1.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_2 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_2.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_3 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_3.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
        }
            break;
        case 1:
        {
            [btnFlash_1 setTitleColor: kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
            btnFlash_1.backgroundColor = kColor_0000;
            
            [btnFlash_0 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_0.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_2 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_2.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_3 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_3.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
        }
            break;
        case 2:
        {
            [btnFlash_2 setTitleColor: kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
            btnFlash_2.backgroundColor = kColor_0000;
            
            [btnFlash_0 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_0.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_1 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_1.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_3 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_3.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
        }
            break;
        case 3:
        {
            [btnFlash_3 setTitleColor: kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
            btnFlash_3.backgroundColor = kColor_0000;
            
            [btnFlash_0 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_0.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_1 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_1.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
            
            [btnFlash_2 setTitleColor: kDF_RGBA(121, 121, 121, 1.0) forState:UIControlStateNormal];
            btnFlash_2.backgroundColor = kDF_RGBA(239, 239, 239, 1.0);
        }
            break;
        default:
            break;
    }
    
    //情景界面
    sceneIndex = model.lightSceneIndex;
    [collections reloadData];
}

#pragma mark App---->固件 发送命令给固件
-(void)sendMessageLightState:(int )lightState withLightMode:(int) lightMode{

    COLOR_HSL hsl = {360*(sliderSewen_0.value),100*(sliderSewen_1.value),100*(sliderSewen_2.value)};
    COLOR_RGB rgb = {0,0,0};
    HSLtoRGB(&hsl, &rgb);
    
    btnColor.backgroundColor = kDF_RGBA(rgb.red, rgb.green, rgb.blue, 1.0);
    addColor = kDF_RGBA(rgb.red, rgb.green, rgb.blue, 1.0);
    
    float hue = 360*(sliderSewen_0.value);
    float saturation = 100*(sliderSewen_1.value);
    float lightness = 100*(sliderSewen_2.value);
    [bleSDK.mBleEntityM.mCmdManager cmdSetState:lightState Mode:lightMode
                                            Red:rgb.red Green:rgb.green Blue:rgb.blue
                                      FlashInex:flashIndex FlashFreq:freqenyIndex SceneIndex:sceneIndex
                                            Hue:hue Saturation:saturation Lightness:lightness];
}

#pragma mark 处理屏幕点击事件
-(void)handleClickEvent:(UITapGestureRecognizer *)gesture
{
    [DFUITools showText:kJL_TXT("请打开总开关") onView:self.view delay:1.0];
}

#pragma mark 处理总开关关闭和打开的逻辑
-(void)handleSwitch{
    if(switchAll.on == 0){
        if(tapGesture == nil){
            tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickEvent:)];
        }
        if(panGestureRecognizer == nil){
            panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleClickEvent:)];
        }
        [subScrollView addGestureRecognizer:tapGesture];
        [subScrollView addGestureRecognizer:panGestureRecognizer];
        
        //彩灯界面
        colorPicker.userInteractionEnabled = NO;
        btnColect_0.userInteractionEnabled = NO;
        btnColect_1.userInteractionEnabled = NO;
        btnColect_2.userInteractionEnabled = NO;
        btnColect_3.userInteractionEnabled = NO;
        btnColect_4.userInteractionEnabled = NO;
        btnColect_5.userInteractionEnabled = NO;
        btnColect_6.userInteractionEnabled = NO;
        btnColect_7.userInteractionEnabled = NO;
        btnColect_8.userInteractionEnabled = NO;
        btnColect_9.userInteractionEnabled = NO;
        btnColect_10.userInteractionEnabled = NO;
        btnColect_11.userInteractionEnabled = NO;
        
        sliderSewen_0.userInteractionEnabled = NO;
        sliderSewen_1.userInteractionEnabled = NO;
        sliderSewen_2.userInteractionEnabled = NO;
        
        //闪烁界面
        subTableView.userInteractionEnabled = NO;
        btnFlash_0.userInteractionEnabled = NO;
        btnFlash_1.userInteractionEnabled = NO;
        btnFlash_2.userInteractionEnabled = NO;
        btnFlash_3.userInteractionEnabled = NO;
        
        //情景界面
        collections.userInteractionEnabled = NO;
        return;
    }else{
        if(tapGesture) [subScrollView removeGestureRecognizer:tapGesture];
        if(panGestureRecognizer) [subScrollView removeGestureRecognizer:panGestureRecognizer];
        
        //彩灯界面
        colorPicker.userInteractionEnabled = YES;
        btnColect_0.userInteractionEnabled = YES;
        btnColect_1.userInteractionEnabled = YES;
        btnColect_2.userInteractionEnabled = YES;
        btnColect_3.userInteractionEnabled = YES;
        btnColect_4.userInteractionEnabled = YES;
        btnColect_5.userInteractionEnabled = YES;
        btnColect_6.userInteractionEnabled = YES;
        btnColect_7.userInteractionEnabled = YES;
        btnColect_8.userInteractionEnabled = YES;
        btnColect_9.userInteractionEnabled = YES;
        btnColect_10.userInteractionEnabled = YES;
        btnColect_11.userInteractionEnabled = YES;
        
        sliderSewen_0.userInteractionEnabled = YES;
        sliderSewen_1.userInteractionEnabled = YES;
        sliderSewen_2.userInteractionEnabled = YES;
        
        //闪烁界面
        subTableView.userInteractionEnabled = YES;
        btnFlash_0.userInteractionEnabled = YES;
        btnFlash_1.userInteractionEnabled = YES;
        btnFlash_2.userInteractionEnabled = YES;
        btnFlash_3.userInteractionEnabled = YES;
        
        //情景界面
        collections.userInteractionEnabled = YES;
    }
}

#pragma mark 存储收藏灯光
-(void)saveLights{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:[colectionColors copy]];
    NSString *key = [NSString stringWithFormat:@"LIGHT_%@",bleSDK.mBleUUID];
    
    if (arrayData) [userDefaults setObject:arrayData forKey:key];
    [userDefaults synchronize];
}

#pragma mark 取出收藏灯光
-(NSArray *)getLights{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"LIGHT_%@",bleSDK.mBleUUID];
    NSData *arrayData = [userDefaults  objectForKey:key];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
    return array;
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kJL_MANAGER_SYSTEM_INFO Action:@selector(noteSystemInfo:) Own:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [JL_Tools remove:nil Own:self];
    [JL_Tools post:@"SHACK_RESET_NOTE" Object:nil];
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    flashIndex+=1;
    if (flashIndex>7) {
        flashIndex = 0;
    }
    [self sendMessageLightState:2 withLightMode:1];
    [subTableView reloadData];
}

@end
