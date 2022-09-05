//
//  NetworkRadioVC.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/8.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "NetworkRadioVC.h"
#import "NetworkView.h"
#import "User_Http.h"
#import "UIImageView+WebCache.h"


#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>


#import "NetworkPlayer.h"
#import "MapLocationRequest.h"

#define MapApiKey @"0733d73d9ca8476dc29442f3d22fc4d9" //杰理之家
#define PiLinkMapApiKey @"7dc05b2a0e2fe8b2bdec91acb04d3a6c" //PiLink

@interface NetworkRadioVC ()<UIScrollViewDelegate>{
    float sW;
    float sH;
    DFTips                              *loadingTp;
    
    __weak IBOutlet NSLayoutConstraint  *topViewH;
    __weak IBOutlet NSLayoutConstraint  *btn1_c_x;
    __weak IBOutlet NSLayoutConstraint  *btn2_c_x;
    __weak IBOutlet NSLayoutConstraint  *btn3_c_x;
    __weak IBOutlet NSLayoutConstraint  *btn4_c_x;
    __weak IBOutlet NSLayoutConstraint  *lb5_y;
    __weak IBOutlet NSLayoutConstraint  *bottomViewH;
    
    __weak IBOutlet UIButton            *btn1;
    __weak IBOutlet UIButton            *btn2;
    __weak IBOutlet UIButton            *btn3;
    __weak IBOutlet UIButton            *btn4;

    __weak IBOutlet UIView              *topView;
    __weak IBOutlet UIView              *lbView3;
    __weak IBOutlet UIScrollView        *subScrollView;
    __weak IBOutlet UIView              *bottomView;
    __weak IBOutlet UIImageView         *bottomImage;
    __weak IBOutlet UIButton            *bottomBtnPP;
    __weak IBOutlet UIButton            *bottomBtnCollect;
    __weak IBOutlet UILabel             *titleName;
    DFLabel                             *bottomLabel;

    
    NetworkView                         *networkView_0;
    NetworkView                         *networkView_1;
    NetworkView                         *networkView_2;
    NetworkView                         *networkView_3;
    __weak IBOutlet UIButton            *btnEdit;
    __weak IBOutlet UIButton            *btnPlace;
    
    __weak IBOutlet UIView              *placeBgView;
    __weak IBOutlet UIView              *placeView;
    __weak IBOutlet UIImageView         *placeImage;
    NSInteger                           placeIndex;
    BOOL                                isPlace;
    BOOL                                isEdit;
    AMapLocationManager                 *locationManager;
}

@end

@implementation NetworkRadioVC
/*--- Http数据 ---*/
static NetworkPlayer *netPlayer;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self requestHttpData];
    [self readCollectionRadio];
    NSLog(@"update Player Status--->1");
    [self updatePlayerStatus];
    [self addNote];
}

-(void)setupUI{
    
    isPlace = NO;
    isEdit  = NO;
    
    sW = [UIScreen mainScreen].bounds.size.width;
    sH = [UIScreen mainScreen].bounds.size.height;
    
    netPlayer = [NetworkPlayer sharedMe];
    
    float gap = sW/4.0;
    topViewH.constant = kJL_HeightNavBar+42;
    bottomViewH.constant = kJL_HeightTabBar+10;
    btn1_c_x.constant = -gap*1.5;
    btn2_c_x.constant = -gap/2.0;
    btn3_c_x.constant = +gap/2.0;
    btn4_c_x.constant = +gap*1.5;
    lb5_y.constant    = -gap*1.5;
    lbView3.layer.cornerRadius = 1.5;
    lbView3.layer.masksToBounds = YES;
    lbView3.backgroundColor = kColor_0000;
    
    subScrollView.contentSize = CGSizeMake(sW*4.0, 0);
    subScrollView.pagingEnabled = YES;
    subScrollView.delegate = self;
    
    bottomView.layer.shadowColor  = kDF_RGBA(0, 0, 0, 0.3).CGColor;
    bottomView.layer.shadowOffset = CGSizeMake(0,6);
    bottomView.layer.shadowOpacity= 1;
    bottomView.layer.shadowRadius = 10;
    
    CGRect rect_lb = CGRectMake(65, 21, sW-265, 18);
    bottomLabel = [[DFLabel alloc] initWithFrame:rect_lb];
    bottomLabel.textColor = [UIColor blackColor];
    bottomLabel.font = [UIFont fontWithName:@"PingFang SC" size: 14];
    bottomLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
    bottomLabel.labelType = DFLeftRight;
    bottomLabel.textAlignment = NSTextAlignmentLeft;
    bottomLabel.text = kJL_TXT("unknow_music_name");
    [bottomView addSubview:bottomLabel];
    
    CGRect rect_0 = CGRectMake(0, 0, sW, sH-topViewH.constant-bottomViewH.constant-10.0);
    networkView_0 = [[NetworkView alloc] initWithFrame:rect_0];
    [subScrollView addSubview:networkView_0];
    
    CGRect rect_1 = CGRectMake(sW, 0, sW, sH-topViewH.constant-bottomViewH.constant-10.0);
    networkView_1 = [[NetworkView alloc] initWithFrame:rect_1];
    [subScrollView addSubview:networkView_1];
    
    CGRect rect_2 = CGRectMake(sW*2.0, 0, sW, sH-topViewH.constant-bottomViewH.constant-10.0);
    networkView_2 = [[NetworkView alloc] initWithFrame:rect_2];
    [subScrollView addSubview:networkView_2];
    
    CGRect rect_3 = CGRectMake(sW*3.0, 0, sW, sH-topViewH.constant-bottomViewH.constant-10.0);
    networkView_3 = [[NetworkView alloc] initWithFrame:rect_3];
    [subScrollView addSubview:networkView_3];
    
    
    [networkView_0 onNetworkViewBlock:^(NSInteger index) {
        NSLog(@"NetView0 index:%ld",(long)index);
        [netPlayer setPlayList:netPlayer.localRadioArray];
        [netPlayer didPlay:index];
    }];
    [networkView_1 onNetworkViewBlock:^(NSInteger index) {
        NSLog(@"NetView1 index:%ld",(long)index);
        [netPlayer setPlayList:netPlayer.nationRadioArray];
        [netPlayer didPlay:index];
    }];
    [networkView_2 onNetworkViewBlock:^(NSInteger index) {
        NSLog(@"NetView2 index:%ld",(long)index);
        [netPlayer setPlayList:netPlayer.provinceRadioArray];
        [netPlayer didPlay:index];
    }];
    [networkView_3 onNetworkViewBlock:^(NSInteger index) {
        NSLog(@"NetView3 index:%ld",(long)index);
        [netPlayer setPlayList:netPlayer.collectionRadioArray];
        [netPlayer didPlay:index];
    }];
    
    placeIndex = 0;
    placeView.layer.cornerRadius = 15.0;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(onDismiss)];
    [gr setNumberOfTapsRequired:1];
    [gr setNumberOfTouchesRequired:1];
    [placeBgView addGestureRecognizer:gr];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btn_place:)];
    [placeImage addGestureRecognizer:tapGesture];
    placeImage.userInteractionEnabled = YES;
    
    titleName.text = kJL_TXT("multi_media_net_radio");
    [btnEdit setTitle:kJL_TXT("freq_point_manage") forState:UIControlStateNormal];
    
    [btn1 setTitle:kJL_TXT("fm_type_local") forState:UIControlStateNormal];
    [btn2 setTitle:kJL_TXT("fm_type_country") forState:UIControlStateNormal];
    [btn3 setTitle:kJL_TXT("fm_type_province") forState:UIControlStateNormal];
    [btn4 setTitle:kJL_TXT("fm_type_mycollect") forState:UIControlStateNormal];
}

-(void)requestHttpData{
    
    NSLog(@"---> 设备定位 2");
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    [[MapLocationRequest shareInstanced] requestLocation:bleSDK.mBleEntityM];
                  
                   
    /*---- 缓存读取数据 ----*/
    if (netPlayer.provinceIDArray.count > 0) {
        
        /*--- 定位省份 ---*/
        NSString *txt = netPlayer.province;
        for (int i = 0; i < netPlayer.provinceIDArray.count; i++) {
            NSDictionary *dict = netPlayer.provinceIDArray[i];
            NSString *name = dict[@"name"];
            if ([txt isEqualToString:name]) {
                netPlayer.provinceID = [NSDictionary dictionaryWithDictionary:dict];

                [DFAction mainTask:^{
                    [self->btnPlace setTitle:netPlayer.provinceID[@"name"] forState:UIControlStateNormal];
                    [self updatePlaceData:i];//刷新省份UI
                    self->placeIndex = i;
                }];
                break;
            }
        }
        
        [DFAction mainTask:^{
            /*--- 本地电台 ---*/
            [self->networkView_0 setNetworkViewDataArray:netPlayer.localRadioArray];
            [[NetworkPlayer sharedMe] setPlayList:netPlayer.localRadioArray];
            NSLog(@"update Player Status--->00");
            [self updatePlayerStatus];
            
            /*--- 省市电台 ---*/
            [self->networkView_2 setNetworkViewDataArray:netPlayer.provinceRadioArray];
            
            /*--- 国家电台 ---*/
            [self->networkView_1 setNetworkViewDataArray:netPlayer.nationRadioArray];
        }];
        return;
    }
    
  
    
    locationManager = [[AMapLocationManager alloc] init];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [locationManager setPausesLocationUpdatesAutomatically:YES];
    [locationManager setLocationTimeout:3];
    [locationManager setReGeocodeTimeout:3];
    
    [self startLoadingView:kJL_TXT("search_radio") Delay:10.0];
    [JL_Tools subTask:^{
        /*--- 省份ID ---*/
        [[User_Http shareInstance] requestProvincialRadio:^(NSArray * _Nonnull info) {
            /* 【数据结构】
                 explain = "";
                 id = 1278133986986221569;
                 name = "\U4e91\U5357";
                 sn = 27;
                 updateTime = "2020-07-01 09:11:03";
                 uuid = "54ab5902-a311-4972-ba68-27bb788bf65d";
             */
            netPlayer.provinceIDArray = [NSArray arrayWithArray:info];
                        
            if (netPlayer.provinceIDArray.count > 0) {
                /*--- 定位省份 ---*/
                [self->locationManager requestLocationWithReGeocode:YES
                                                    completionBlock:^(CLLocation *location,
                                                                      AMapLocationReGeocode *regeocode,
                                                                      NSError *error) {
                    if (!error) {
                        NSLog(@"---> Province: %@",regeocode.province);
                        NSString *province = regeocode.province;
                        NSString *txt = [province stringByReplacingOccurrencesOfString:@"省" withString:@""];
                        netPlayer.province = txt;
                        
                        for (int i = 0; i < netPlayer.provinceIDArray.count; i++) {
                            NSDictionary *dict = netPlayer.provinceIDArray[i];
                            NSString *name = dict[@"name"];
                            if ([txt isEqualToString:name]) {
                                netPlayer.provinceID = [NSDictionary dictionaryWithDictionary:dict];

                                [DFAction mainTask:^{
                                    [self->btnPlace setTitle:netPlayer.provinceID[@"name"] forState:UIControlStateNormal];
                                    [self updatePlaceData:i];//刷新省份UI
                                    self->placeIndex = i;
                                }];
                                break;
                            }
                        }

                    }else{
                        NSDictionary *dict = netPlayer.provinceIDArray[0];
                        netPlayer.provinceID = [NSDictionary dictionaryWithDictionary:dict];

                        [DFAction mainTask:^{
                            [self->btnPlace setTitle:netPlayer.provinceID[@"name"] forState:UIControlStateNormal];
                            [self updatePlaceData:0];//刷新省份UI
                        }];
                    }

                    
                    /*--- 获取当前省份电台 ---*/
                    NSString *pv_id = [NSString stringWithFormat:@"%lld",[netPlayer.provinceID[@"id"] longLongValue]];
                    [[User_Http shareInstance] requestProvincialRadioList:pv_id Result:^(NSArray * _Nonnull info) {
                        /*
                             description = "";
                             explain = "";
                             icon = "http://cnvod.cnr.cn/audio2017/ondemand/img/1100/20190709/1562667945305.png";
                             id = 1278136977654984706;
                             name = "\U5317\U4eac\U4ea4\U901a\U5e7f\U64ad";
                             placeId = 1278133984025042946;
                             stream = "http://cnlive.cnr.cn/hls/bjjtgb.m3u8";
                             updateTime = "2020-07-01 09:22:56";
                             uuid = "76857685-9704-48f6-9299-314a38dcc0b0"; 
                         */
                        
                        if (info.count > 0) {
                            [DFAction mainTask:^{
                                [self closeLoadingView];
                                netPlayer.localRadioArray = [NSArray arrayWithArray:info];
                                [self->networkView_0 setNetworkViewDataArray:netPlayer.localRadioArray];
                                
                                /*--- 更新本地电台列表 ---*/
                                [[NetworkPlayer sharedMe] setPlayList:netPlayer.localRadioArray];
                                NSLog(@"update Player Status--->0");
                                [self updatePlayerStatus];
                                
                                netPlayer.provinceRadioArray = [NSArray arrayWithArray:info];
                                [self->networkView_2 setNetworkViewDataArray:netPlayer.provinceRadioArray];
                            }];
                        }
                    }];
                }];
            }
        }];
        
        /*--- 国家电台 ---*/
        [[User_Http shareInstance] requestNationalRadioList:^(NSArray * _Nonnull info) {
            if (info.count > 0) {
                [DFAction mainTask:^{
                    netPlayer.nationRadioArray = [NSArray arrayWithArray:info];
                    [self->networkView_1 setNetworkViewDataArray:netPlayer.nationRadioArray];
                }];
            }
        }];
    }];
}

-(void)readCollectionRadio{

    netPlayer.collectionRadioArray = [NSMutableArray new];
    
    NSString *radioJsonPath = [JL_Tools findPath:NSLibraryDirectory MiddlePath:@"" File:@"RADIO_COLLECT_JSON.txt"];
    if (radioJsonPath) {
        NSArray *arr = [JL_Tools JsonPath:radioJsonPath];
        for (NSDictionary *dic in arr) {
            NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [netPlayer.collectionRadioArray addObject:mDic];
        }
        NSLog(@"Read Collection Radios ---> %lu",(unsigned long)netPlayer.collectionRadioArray.count);
    }else{
        [JL_Tools findPath:NSLibraryDirectory MiddlePath:@"" File:@"RADIO_COLLECT_JSON.txt"];
        NSLog(@"Create Collection Radios.");
    }
    
    [self->networkView_3 setNetworkViewDataArray:netPlayer.collectionRadioArray];
}
-(void)saveCollectionRadio{
    if (netPlayer.collectionRadioArray.count>0) {
        NSString *path = [JL_Tools listPath:NSLibraryDirectory MiddlePath:@"" File:@"RADIO_COLLECT_JSON.txt"];
        NSString *allJson = [JL_Tools arrayToJson:netPlayer.collectionRadioArray];
        NSLog(@"Save Collection Radios ---> %lu",(unsigned long)netPlayer.collectionRadioArray.count);
        NSData *allData = [allJson dataUsingEncoding:NSUTF8StringEncoding];
        [JL_Tools writeData:allData fillFile:path];
    }
}


-(BOOL)isCollectedRadio:(NSDictionary*)info{
    BOOL isOn = NO;
    for (NSDictionary *infoCollected in netPlayer.collectionRadioArray) {
        long long id_collected = [infoCollected[@"id"] longLongValue];
        long long id_info = [info[@"id"] longLongValue];
        if (id_collected == id_info) {
            isOn = YES;
            break;
        }
    }
    return isOn;
}

-(void)removeCollectedRadio:(NSDictionary*)info{
    for (NSDictionary *infoCollected in netPlayer.collectionRadioArray) {
        long long id_collected = [infoCollected[@"id"] longLongValue];
        long long id_info = [info[@"id"] longLongValue];
        if (id_collected == id_info) {
            [netPlayer.collectionRadioArray removeObject:infoCollected];
            break;
        }
    }
}

- (IBAction)btn_back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btn_network:(UIButton *)sender {
    [subScrollView setContentOffset:CGPointMake(sW*sender.tag, 0) animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float x = scrollView.contentOffset.x;
    float scale = x/(3.0*sW);
    [self updateLbView3Center:scale];
    
    if (scale < 0.15f){
        btnEdit.hidden = YES;
        btnPlace.hidden= YES;
        placeImage.hidden= YES;
        [self updatePlaceUI:NO];
        [self updateBtnStyle:0x01];
    }
    if (scale >= 0.15f && scale < 0.50f){
        btnEdit.hidden = YES;
        btnPlace.hidden= YES;
        placeImage.hidden= YES;
        [self updatePlaceUI:NO];
        [self updateBtnStyle:0x02];
    }
    if (scale >= 0.50f && scale < 0.85f){
        btnEdit.hidden = YES;
        btnPlace.hidden= NO;
        placeImage.hidden= NO;
        [self updatePlaceUI:isPlace];
        [self updateBtnStyle:0x04];
    }
    if (scale >= 0.85f){
        btnEdit.hidden = NO;
        btnPlace.hidden= YES;
        placeImage.hidden= YES;
        [self updatePlaceUI:NO];
        [self updateBtnStyle:0x08];
    }
}

-(void)updateLbView3Center:(float)scale{
    float gap = sW/4.0;
    self->lbView3.center = CGPointMake(sW/2.0+scale*gap*3.0-gap*1.5, self->topViewH.constant-1.5);
}

-(void)updateBtnStyle:(uint8_t)bit{
    uint8_t bit0 = (bit>>0)&0x01;
    uint8_t bit1 = (bit>>1)&0x01;
    uint8_t bit2 = (bit>>2)&0x01;
    uint8_t bit3 = (bit>>3)&0x01;
    [DFUITools setButton:btn1 Color:bit0?[UIColor blackColor]:kDF_RGBA(154, 154, 154, 1.0)];
    [DFUITools setButton:btn2 Color:bit1?[UIColor blackColor]:kDF_RGBA(154, 154, 154, 1.0)];
    [DFUITools setButton:btn3 Color:bit2?[UIColor blackColor]:kDF_RGBA(154, 154, 154, 1.0)];
    [DFUITools setButton:btn4 Color:bit3?[UIColor blackColor]:kDF_RGBA(154, 154, 154, 1.0)];
}


- (IBAction)btn_place:(id)sender {
    if (netPlayer.provinceIDArray.count == 0) {
        [DFUITools showText:kJL_TXT("province_not_found") onView:self.view delay:1.0];
        return;
    }
    
    if (isPlace) {
        isPlace = NO;
    }else{
        isPlace = YES;
    }
    [self updatePlaceUI:isPlace];
}



-(void)updatePlaceUI:(BOOL)isShow{
    [UIView animateWithDuration:0.15 animations:^{
        if (isShow) {
            self->placeImage.image = [UIImage imageNamed:@"Theme.bundle/icon_up"];
            self->placeBgView.alpha = 1.0;
        }else{
            self->placeImage.image = [UIImage imageNamed:@"Theme.bundle/icon_down"];
            self->placeBgView.alpha = 0.0;
        }
    }];
}

-(void)updatePlaceData:(int)index{
    float gap = 10.0;
    float btn_h = 38;
    float btn_w = (sW-gap*5.0)/4.0;
    int num_hang = 0;
    int num_lie  = 0;
    
    [self cleanAllBtn];

    for (int i = 0; i < netPlayer.provinceIDArray.count; i++)
    {
        if (i%4==0) num_hang = i/4;
        num_lie = i%4;
        
        NSDictionary *info = netPlayer.provinceIDArray[i];
        
        UIButton *btn = [UIButton new];
        btn.bounds = CGRectMake(0, 0, btn_w, btn_h);
        btn.center = CGPointMake(gap+btn_w/2.0+num_lie*(gap+btn_w), 20.0+btn_h/2.0+num_hang*(gap+btn_h));
        [btn setTitle:info[@"name"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        btn.layer.cornerRadius = 2.5;
        btn.tag = i;
        [btn addTarget:self action:@selector(onBtnPlaceAction:)
                      forControlEvents:UIControlEventTouchUpInside];
        [placeView addSubview:btn];
        
        if (index == i) {
            [btn setTitleColor:kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
            btn.backgroundColor = kDF_RGBA(128, 91, 235, 1.0);
        }else{
            [btn setTitleColor:kDF_RGBA(76, 76, 76, 1.0) forState:UIControlStateNormal];
            btn.backgroundColor = kDF_RGBA(234, 236, 238, 1.0);
        }
    }
}

-(void)cleanAllBtn{
    for (UIView *view in placeView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)view;
            if (btn.tag >= 0) [btn removeFromSuperview];
        }
    }
}

-(void)onBtnPlaceAction:(UIButton*)btn{
    placeIndex = btn.tag;
    NSDictionary *placeInfo = netPlayer.provinceIDArray[placeIndex];
    netPlayer.province = placeInfo[@"name"];
    NSLog(@"Place ----> %@",placeInfo[@"name"]);
        
    [self updatePlaceData:(int)placeIndex];
    [btnPlace setTitle:placeInfo[@"name"] forState:UIControlStateNormal];
            
    /*--- 获取选中省份电台 ---*/
    [self startLoadingView:kJL_TXT("search_radio") Delay:10.0];
    NSString *pv_id = [NSString stringWithFormat:@"%lld",[placeInfo[@"id"] longLongValue]];
    [[User_Http shareInstance] requestProvincialRadioList:pv_id Result:^(NSArray * _Nonnull info) {
        if (info.count > 0) {
            [DFAction mainTask:^{
                [self closeLoadingView];
                [self btn_place:nil];
                
                netPlayer.provinceRadioArray = [NSArray arrayWithArray:info];
                [self->networkView_2 setNetworkViewDataArray:netPlayer.provinceRadioArray];
            }];
        }
    }];
}

- (IBAction)btn_isEdit:(id)sender {
    if (isEdit) {
        isEdit = NO;
        [btnEdit setTitle:kJL_TXT("freq_point_manage") forState:UIControlStateNormal];
    }else{
        isEdit = YES;
        [btnEdit setTitle:kJL_TXT("device_paired_finish") forState:UIControlStateNormal];
    }
    [self updateCollectionData:isEdit];
}

-(void)updateCollectionData:(BOOL)isShow{
    networkView_3.isDelete = isShow;
}

-(void)onDismiss{
    [self btn_place:nil];
}


- (IBAction)btn_pp:(id)sender {
    NetworkPlayer *netPlayer = [NetworkPlayer sharedMe];
//    DFNetPlayer_STATUS st = netPlayer.mNetPlayer.status;
    DFNetPlayer_STATUS st = [[CorePlayer shareInstanced] status];
    if (st == DFNetPlayer_STATUS_PLAY) {
        [netPlayer didPause];
    }else{
        [JL_Tools post:@"kUI_FUNCTION_ACTION" Object:@(9)];
        [netPlayer didContinue];
    }
}


- (IBAction)btn_collection:(id)sender {
    NetworkPlayer *netPlayer = [NetworkPlayer sharedMe];
    NSDictionary *playInfo = netPlayer.mNowInfo;
    
    BOOL isCollected = [self isCollectedRadio:playInfo];
    if (isCollected) {
        [self removeCollectedRadio:playInfo];
        [bottomBtnCollect setImage:[UIImage imageNamed:@"Theme.bundle/icon_collection"] forState:UIControlStateNormal];
    }else{
        NSDictionary *addInfo = [NSDictionary dictionaryWithDictionary:playInfo];
        [netPlayer.collectionRadioArray addObject:addInfo];
        [bottomBtnCollect setImage:[UIImage imageNamed:@"Theme.bundle/icon_collected"] forState:UIControlStateNormal];
    }
    [self->networkView_3 setNetworkViewDataArray:netPlayer.collectionRadioArray];
}


-(void)noteNetworkCellDelete:(NSNotification*)note{
    NSInteger index = [[note object] intValue];
    NSDictionary *oneDict = netPlayer.collectionRadioArray[index];
    if ([netPlayer.mNowInfo[@"id"] isEqualToString:oneDict[@"id"]]) {
        [bottomBtnCollect setImage:[UIImage imageNamed:@"Theme.bundle/icon_collection"] forState:UIControlStateNormal];
    }
    [netPlayer.collectionRadioArray removeObjectAtIndex:index];
    [self->networkView_3 setNetworkViewDataArray:netPlayer.collectionRadioArray];
}


//static NSString *bottomImageUrl = nil;
-(void)updatePlayerStatus{
    
//    NetworkPlayer *netPlayer = [NetworkPlayer sharedMe];
//    DFNetPlayer_STATUS st = netPlayer.mNetPlayer.status;
    DFNetPlayer_STATUS st = [[CorePlayer shareInstanced] status];
    if (st == DFNetPlayer_STATUS_PLAY) {
        [bottomBtnPP setImage:[UIImage imageNamed:@"Theme.bundle/icon_pause"]
                     forState:UIControlStateNormal];
    }else{
        [bottomBtnPP setImage:[UIImage imageNamed:@"Theme.bundle/icon_play"]
                     forState:UIControlStateNormal];
    }
    
    NSDictionary *playInfo = netPlayer.mNowInfo;
    if (playInfo) {
        NSString *url = playInfo[@"icon"];
        NSString *url_1 = [DFHttp encodeURL:url];
        NSString *name= playInfo[@"name"];
        UIImage *imagePlace = [UIImage imageNamed:@"Theme.bundle/img_placeholder"];
        
        bottomLabel.text = name;
        [DFAction delay:0.5 Task:^{
            [self->bottomImage sd_setImageWithURL:[NSURL URLWithString:url_1] placeholderImage:imagePlace];
        }];
        
        BOOL isCollected = [self isCollectedRadio:playInfo];
        if (isCollected) {
            [bottomBtnCollect setImage:[UIImage imageNamed:@"Theme.bundle/icon_collected"]
                              forState:UIControlStateNormal];
        }else{
            [bottomBtnCollect setImage:[UIImage imageNamed:@"Theme.bundle/icon_collection"]
                              forState:UIControlStateNormal];
        }
    }else{
        bottomLabel.text = kJL_TXT("unknow_music_name");
        bottomImage.image= [UIImage imageNamed:@"Theme.bundle/img_placeholder"];
        [bottomBtnCollect setImage:[UIImage imageNamed:@"Theme.bundle/icon_collection"]
                          forState:UIControlStateNormal];
    }
}

-(void)noteNetworkPlayerStatus:(NSNotification*)note{
    NSLog(@"update Player Status--->2");
    [self updatePlayerStatus];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeSomethingConnected ||
        type == JLDeviceChangeTypeBleOFF) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


-(void)addNote{
    [JL_Tools add:kNETWORK_PLAYER_STATUS
           Action:@selector(noteNetworkPlayerStatus:) Own:self];
    [JL_Tools add:kNETWORK_CELL_DELETE Action:@selector(noteNetworkCellDelete:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self saveCollectionRadio];
    [JL_Tools remove:kNETWORK_PLAYER_STATUS Own:self];
    [JL_Tools remove:kNETWORK_CELL_DELETE Own:self];
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)startLoadingView:(NSString*)text Delay:(NSTimeInterval)delay{
    [loadingTp removeFromSuperview];
    loadingTp = nil;

    UIWindow *win = [DFUITools getWindow];
    loadingTp = [DFUITools showHUDWithLabel:text
                                     onView:win
                                      color:[UIColor blackColor]
                             labelTextColor:[UIColor whiteColor]
                     activityIndicatorColor:[UIColor whiteColor]];
    [loadingTp hide:YES afterDelay:delay];
    [DFAction delay:delay-1.0 Task:^{
        self->loadingTp.labelText = kJL_TXT("not_found_radio");
    }];
}

-(void)closeLoadingView{
    [loadingTp hide:YES];
    [loadingTp removeFromSuperview];
    loadingTp = nil;
}




@end
