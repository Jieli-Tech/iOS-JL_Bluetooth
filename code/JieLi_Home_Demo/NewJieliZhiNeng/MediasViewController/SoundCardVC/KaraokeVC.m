//
//  KaraokeVC.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/11/10.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "KaraokeVC.h"
#import "JL_RunSDK.h"
#import "KaraokeEQView.h"
#import "DanyinView.h"
#import "KalaokView.h"
#import "BianShenView.h"
#import "OtherView.h"
#import "KalaokModel.h"
#import "JLUI_Cache.h"
#import "JLCacheBox.h"
#import "UIImageView+WebCache.h"

@interface KaraokeVC ()<JLSoundCardMgrDelegate>{
    __weak IBOutlet NSLayoutConstraint  *topView_H;
    __weak IBOutlet UIButton            *btn_00;
    __weak IBOutlet UIButton            *btn_01;
    __weak IBOutlet UIButton            *btn_02;
    __weak IBOutlet UIButton            *btn_03;
    __weak IBOutlet UIButton            *btn_04;
    __weak IBOutlet UIButton            *btn_05;
    __weak IBOutlet UILabel             *label_kala;
    __weak IBOutlet UIImageView         *bianshenImv;
    __weak IBOutlet UILabel             *bianshenLabel;
    __weak IBOutlet UIButton            *micEQ;
    
    __weak IBOutlet NSLayoutConstraint  *btn_00_W;
    __weak IBOutlet NSLayoutConstraint  *btn_01_W;
    __weak IBOutlet NSLayoutConstraint  *btn_02_W;
    __weak IBOutlet NSLayoutConstraint  *btn_03_W;
    __weak IBOutlet NSLayoutConstraint  *btn_04_W;
    __weak IBOutlet NSLayoutConstraint  *btn_05_W;
    
    __weak IBOutlet NSLayoutConstraint  *btn_10_W;
    __weak IBOutlet NSLayoutConstraint  *btn_11_W;
    __weak IBOutlet NSLayoutConstraint  *btn_12_W;
    __weak IBOutlet NSLayoutConstraint  *btn_13_W;
    __weak IBOutlet NSLayoutConstraint  *btn_14_W;
    __weak IBOutlet NSLayoutConstraint  *btn_15_W;
    __weak IBOutlet NSLayoutConstraint  *btn_16_W;
    __weak IBOutlet NSLayoutConstraint  *btn_17_W;
    
    
    __weak IBOutlet NSLayoutConstraint  *lb_10_W;
    __weak IBOutlet NSLayoutConstraint  *lb_11_W;
    __weak IBOutlet NSLayoutConstraint  *lb_12_W;
    __weak IBOutlet NSLayoutConstraint  *lb_13_W;
    __weak IBOutlet NSLayoutConstraint  *lb_14_W;
    __weak IBOutlet NSLayoutConstraint  *lb_15_W;
    __weak IBOutlet NSLayoutConstraint  *lb_16_W;
    __weak IBOutlet NSLayoutConstraint  *lb_17_W;
    
    __weak IBOutlet UISlider            *slider_0;
    __weak IBOutlet UISlider            *slider_1;
    __weak IBOutlet UISlider            *slider_2;
    
    __weak IBOutlet UILabel             *lb_0;
    __weak IBOutlet UILabel             *lb_1;
    __weak IBOutlet UILabel             *lb_2;
    
    KaraokeEQView   *karaokeEQView;
    DanyinView      *danYinView;
    JL_RunSDK       *bleSDK;
    
    float           sW;
    float           sH;
    
    UIScrollView *scrollView;
    //变声
    UIImageView *mBianshenImv;
    UILabel     *mBianshenLabel;
    
    //其他
    UIImageView *otherImv;
    UILabel     *otherLabel;
    
    //气氛
    UIImageView *qifenImv;
    UILabel     *qifenLabel;
    
    
    BianShenView *bianShenView;
    OtherView    *mOtherView;
    KalaokView   *kalaokView;
    
    //参数
    UIImageView *canshuImv;
    UILabel     *canshuLabel;
    
    UILabel *label_1;
    UILabel *label_2;
    UILabel *label_3;
    UILabel *label_4;
    UILabel *label_5;
    UILabel *label_6;
    UILabel *label_7;
    
    UISlider *mySlier_1;
    UISlider *mySlier_2;
    UISlider *mySlier_3;
    UISlider *mySlier_4;
    UISlider *mySlier_5;
    UISlider *mySlier_6;
    UISlider *mySlier_7;
    
    NSArray *canShuArray;
    NSArray *canShuIndexArray;
    NSArray *canShuEnableArray;
    NSArray *canShuMaxArray;
    
    NSArray *mDataArray;
    
    BOOL hasEq;
    BOOL isNet;
    BOOL sliderFlag;
}

@end

@implementation KaraokeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
    
    label_kala.text = kJL_TXT("multi_media_sound_card");
    hasEq = NO;
    isNet = NO;
    sliderFlag = NO;
    AFNetworkReachabilityStatus st = [[JLUI_Cache sharedInstance] networkStatus];
    if (st == AFNetworkReachabilityStatusReachableViaWWAN ||
        st == AFNetworkReachabilityStatusReachableViaWiFi ) {
        isNet = YES;
    }else{
        isNet = NO;
    }
    
    bleSDK = [JL_RunSDK sharedMe];
    
    sW = [UIScreen mainScreen].bounds.size.width;
    sH = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (scrollView == nil) {
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+10, width, height-kJL_HeightNavBar-10)];
        [self.view addSubview:scrollView];
    }
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    scrollView.backgroundColor = kDF_RGBA(255, 255, 255, 1.0);
    
    topView_H.constant = kJL_HeightNavBar;
    [self setKalaOKData:self.requestNetFlag];
    JL_ManagerM *manager = [bleSDK.mBleEntityM mCmdManager];
    manager.mSoundCardManager.delegate = self;
}

-(void)setupUI{
    float btn_W = (sW-4*20.0)/3.0;
    btn_00_W.constant = btn_W;
    btn_01_W.constant = btn_W;
    btn_02_W.constant = btn_W;
    btn_03_W.constant = btn_W;
    btn_04_W.constant = btn_W;
    btn_05_W.constant = btn_W;
    
    if(hasEq){
        micEQ.hidden = NO;
    }else{
        micEQ.hidden = YES;
    }
    
    if(mDataArray == nil){
        return;
    }
    for(int i = 0;i<mDataArray.count;i++){
        KalaokModel *model =mDataArray[i];
        
        if(model.mId == 0){  //变声
            if(mBianshenImv == nil){
                mBianshenImv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 22,22)];
            }
            
            if([model.icon_url containsString:@("https")]){
                mBianshenImv.image = [UIImage imageNamed:@"Theme.bundle/icon_voice_nol.png"];
                [self downloadImageWithUrl:model.icon_url withImageView:mBianshenImv];
            }else{
                if(isNet == NO){
                    mBianshenImv.image = [UIImage imageNamed:@"Theme.bundle/icon_voice_nol.png"];
                }
                if(isNet == YES){
                    mBianshenImv.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",model.icon_url]];
                }
            }
            
            mBianshenImv.contentMode = UIViewContentModeScaleToFill;
            [scrollView addSubview:mBianshenImv];
            
            if(mBianshenLabel == nil){
                mBianshenLabel = [[UILabel alloc] init];
            }
            mBianshenLabel.frame = CGRectMake(mBianshenImv.frame.origin.x+mBianshenImv.frame.size.width+8,20,144,21);
            mBianshenLabel.numberOfLines = 0;
            
            if([kJL_GET hasPrefix:@"zh"]){
                mBianshenLabel.text = model.zh_name;
            }else{
                mBianshenLabel.text = model.en_name;
            }
            [scrollView addSubview:mBianshenLabel];
            
            NSArray *bianShengList = model.mList;
            
            if(bianShengList.count==0){
                return;
            }
            
            NSMutableArray *bianShengMulList = [NSMutableArray new];
            for (NSDictionary *dic in bianShengList) {
                bianShengMulList = dic[@"list"];
            }
            NSArray *dianYinList = bianShengMulList;
            
            if(dianYinList.count==0){
                return;
            }
            
            if(model.column){
                NSInteger bianShengKMaxRowCount;
                NSInteger bianShengkItemCountPerRow;
                
                if(model.row){
                    bianShengKMaxRowCount = model.row;
                }else{
                    bianShengKMaxRowCount = bianShengList.count/model.column;
                }
                bianShengkItemCountPerRow = model.column;
                
                CGRect bianShenRect = CGRectMake(8,mBianshenImv.frame.size.height+mBianshenImv.frame.origin.y+18,scrollView.frame.size.width-2*8, 38*bianShengKMaxRowCount+15);
                if(bianShenView == nil){
                    bianShenView = [[BianShenView alloc] initWithFrame:bianShenRect];
                }
                bianShenView.bianShenArray = bianShengList;
                bianShenView.dianYinArray = dianYinList;
                [bianShenView setKMaxRowCount:bianShengKMaxRowCount WithItemCountPerRow:bianShengkItemCountPerRow];
                [scrollView addSubview:bianShenView];
            }
            
            [bianShenView onBianShenViewBlock:^(NSInteger tag) {
                
                JL_ManagerM *manager = [self->bleSDK.mBleEntityM mCmdManager];
                [manager.mSoundCardManager cmdSetKalaok:manager Index:tag Value:0 result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                    
                }];
            }];
            
            [bianShenView onBianShenViewGroupBlock:^(BOOL group) {
                if(group){
                    CGRect rect = CGRectMake(0, 0, self->sW, self->sH);
                    self->danYinView = [[DanyinView alloc] initWithFrame:rect];
                    [self->danYinView loadDanyinList:dianYinList];
                    [self.view addSubview:self->danYinView];
                    [self->danYinView showMe];
                }
            }];
        }
        if(model.mId == 1){ //气氛
            if(qifenImv == nil){
                if(mOtherView == nil){
                    qifenImv = [[UIImageView alloc] initWithFrame:CGRectMake(20, bianShenView.frame.size.height+bianShenView.frame.origin.y+28, 22,22)];
                }else if(mBianshenImv == nil && mOtherView ==nil){
                    qifenImv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 22,22)];
                }else{
                    qifenImv = [[UIImageView alloc] initWithFrame:CGRectMake(20, mOtherView.frame.size.height+mOtherView.frame.origin.y+28.5, 22,22)];
                }
            }
            
            if([model.icon_url containsString:@("https")]){
                qifenImv.image = [UIImage imageNamed:@"Theme.bundle/icon_effect_nol.png"];
                [self downloadImageWithUrl:model.icon_url withImageView:qifenImv];
            }else{
                if(isNet == NO){
                    qifenImv.image = [UIImage imageNamed:@"Theme.bundle/icon_effect_nol.png"];
                }
                if(isNet == YES){
                    qifenImv.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",model.icon_url]];
                }
            }
            qifenImv.contentMode = UIViewContentModeScaleToFill;
            [scrollView addSubview:qifenImv];
            
            if(qifenLabel == nil){
                qifenLabel = [[UILabel alloc] init];
            }
            if(mOtherView == nil){
                qifenLabel.frame = CGRectMake(qifenImv.frame.origin.x+qifenImv.frame.size.width+8,bianShenView.frame.size.height+bianShenView.frame.origin.y+28.5,144,21);
            }else if(mBianshenImv == nil && mOtherView ==nil){
                qifenLabel.frame = CGRectMake(qifenImv.frame.origin.x+qifenImv.frame.size.width+8,20,144,21);
            }else{
                qifenLabel.frame = CGRectMake(qifenImv.frame.origin.x+qifenImv.frame.size.width+8,mOtherView.frame.size.height+mOtherView.frame.origin.y+28.5,144,21);
            }
            qifenLabel.numberOfLines = 0;
            if([kJL_GET hasPrefix:@"zh"]){
                qifenLabel.text = model.zh_name;
            }else{
                qifenLabel.text = model.en_name;
            }
            [scrollView addSubview:qifenLabel];
            
            NSArray *qifenList = model.mList;
            if(model.column){
                NSInteger qiFenKMaxRowCount;
                NSInteger qiFenkItemCountPerRow;
                
                if(model.row){
                    qiFenKMaxRowCount = model.row;
                }else{
                    qiFenKMaxRowCount = qifenList.count/model.column;
                }
                qiFenkItemCountPerRow = model.column;
                CGRect mQiFenRect = CGRectMake(-8,qifenImv.frame.size.height+qifenImv.frame.origin.y+20.5, scrollView.frame.size.width, 107.5*qiFenKMaxRowCount);
                if(kalaokView!=nil){
                    [kalaokView removeFromSuperview];
                }
                if(kalaokView == nil){
                    kalaokView = [[KalaokView alloc] initWithFrame:mQiFenRect];
                }
                kalaokView.qiFenArray = model.mList;
                [kalaokView setKMaxRowCount:qiFenKMaxRowCount WithItemCountPerRow:qiFenkItemCountPerRow];
                [scrollView addSubview:kalaokView];
            }
        }
        if(model.mId == 2){ //Mic参数
            if(canshuImv == nil){
                if(kalaokView == nil && mOtherView!=nil){
                    canshuImv = [[UIImageView alloc] initWithFrame:CGRectMake(20, mOtherView.frame.size.height+mOtherView.frame.origin.y+50, 22,22)];
                }else if(kalaokView == nil && mOtherView == nil && bianShenView!=nil){
                    canshuImv = [[UIImageView alloc] initWithFrame:CGRectMake(20, bianShenView.frame.size.height+bianShenView.frame.origin.y+50, 22,22)];
                }else if(kalaokView == nil && mOtherView == nil && bianShenView==nil){
                    canshuImv = [[UIImageView alloc] initWithFrame:CGRectMake(20,20,22,22)];
                }else{
                    canshuImv = [[UIImageView alloc] initWithFrame:CGRectMake(20, kalaokView.frame.size.height+kalaokView.frame.origin.y+50, 22,22)];
                }
            }
            
            if([model.icon_url containsString:@("https")]){
                canshuImv.image = [UIImage imageNamed:@"Theme.bundle/icon_settle_nol.png"];
                [self downloadImageWithUrl:model.icon_url withImageView:canshuImv];
            }else{
                if(isNet == NO){
                    canshuImv.image = [UIImage imageNamed:@"Theme.bundle/icon_settle_nol.png"];
                }
                if(isNet == YES){
                    canshuImv.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",model.icon_url]];
                }
            }
            canshuImv.contentMode = UIViewContentModeScaleToFill;
            [scrollView addSubview:canshuImv];
            
            if(canshuLabel == nil){
                canshuLabel = [[UILabel alloc] init];
            }
            if(kalaokView == nil && mOtherView!=nil){
                canshuLabel.frame = CGRectMake(canshuImv.frame.origin.x+canshuImv.frame.size.width+8,mOtherView.frame.size.height+mOtherView.frame.origin.y+50,144,21);
            }else if(kalaokView == nil && mOtherView == nil && bianShenView!=nil){
                canshuLabel.frame = CGRectMake(canshuImv.frame.origin.x+canshuImv.frame.size.width+8,bianShenView.frame.size.height+bianShenView.frame.origin.y+50,144,21);
            }else if(kalaokView == nil && mOtherView == nil && bianShenView==nil){
                canshuLabel.frame = CGRectMake(canshuImv.frame.origin.x+canshuImv.frame.size.width+8,20,144,21);
            }else{
                canshuLabel.frame = CGRectMake(canshuImv.frame.origin.x+canshuImv.frame.size.width+8,kalaokView.frame.size.height+kalaokView.frame.origin.y+50,144,21);
            }
            canshuLabel.numberOfLines = 0;
            if([kJL_GET hasPrefix:@"zh"]){
                canshuLabel.text = model.zh_name;
            }else{
                canshuLabel.text = model.en_name;
            }
            [scrollView addSubview:canshuLabel];
            
            
            NSMutableArray *array = [NSMutableArray new];
            NSMutableArray *mIndexArray = [NSMutableArray new];
            NSMutableArray *mEnableArray = [NSMutableArray new];
            NSMutableArray *mMaxArray = [NSMutableArray new];
            for (NSDictionary *dic in model.mList) {
                NSString *name;
                if([kJL_GET hasPrefix:@"zh"]){
                    name = dic[@"title"][@"zh"];
                }else{
                    name = dic[@"title"][@"en"];
                }
                [array addObject:name];
                if(dic[@"index"]!=nil){
                    [mIndexArray addObject:dic[@"index"]];
                }
                if(dic[@"enable"]){
                    [mEnableArray addObject:dic[@"enable"]];
                }
                if(dic[@"max"]!=nil){
                    [mMaxArray addObject:dic[@"max"]];
                }
            }
            
            canShuArray = array;
            canShuIndexArray = mIndexArray;
            canShuEnableArray = mEnableArray;
            canShuMaxArray = mMaxArray;
            
            if(canShuArray.count>0 && canShuIndexArray.count>0&&canShuEnableArray.count>0 && canShuMaxArray.count>0){
                if(label_1 == nil){
                    label_1 = [[UILabel alloc] init];
                }
                label_1.frame = CGRectMake(20,canshuImv.frame.size.height+canshuImv.frame.origin.y+17.5,144,16);
                label_1.numberOfLines = 0;
                [label_1 setFont:[UIFont fontWithName:@"System" size:14]];
                [label_1 setTextColor:kDF_RGBA(36, 36, 36, 1.0)];
                
                if(canShuArray[0]!=nil){
                    if([kJL_GET hasPrefix:@"zh"]){
                        if([canShuArray[0] isEqualToString:@"麦音量"]){
                            [label_1 setText:kJL_TXT("麦音量")];
                        }
                    }else{
                        [label_1 setText:canShuArray[0]];
                    }
                    [scrollView addSubview:label_1];
                }
                
                if(mySlier_1 == nil){
                    mySlier_1=[[UISlider alloc]initWithFrame:CGRectMake(label_1.frame.origin.x+label_1.frame.size.width/2+15,canshuImv.frame.size.height+canshuImv.frame.origin.y+17.5,sW-mySlier_1.frame.origin.x-112-15,15)];
                }
                mySlier_1.minimumValue = 0;
                mySlier_1.value = 0;
                mySlier_1.tag = (long)[canShuIndexArray[0] integerValue];
                
                mySlier_1.maximumTrackTintColor = kDF_RGBA(225, 225, 225, 1);
                mySlier_1.minimumTrackTintColor = kColor_0000;
                [mySlier_1 setThumbImage:[UIImage imageNamed:@"Theme.bundle/slider_kalaok_nol"] forState:UIControlStateNormal];
                
                if(canShuMaxArray[0]!=nil){
                    mySlier_1.maximumValue = [canShuMaxArray[0] floatValue];
                    [scrollView addSubview:mySlier_1];
                }
                
                [mySlier_1 addTarget:self action:@selector(btn_Canshu:) forControlEvents:UIControlEventTouchUpInside];
                
                if(label_2 ==nil){
                    label_2 = [[UILabel alloc] init];
                }
                label_2.frame = CGRectMake(20,label_1.frame.size.height+label_1.frame.origin.y+26.5,144,16);
                label_2.numberOfLines = 0;
                [label_2 setFont:[UIFont fontWithName:@"System" size:14]];
                [label_2 setTextColor:kDF_RGBA(36, 36, 36, 1.0)];
                
                if(canShuArray[1]!=nil){
                    [label_2 setText:canShuArray[1]];
                    [scrollView addSubview:label_2];
                }
                
                if(mySlier_2 == nil){
                    mySlier_2=[[UISlider alloc]initWithFrame:CGRectMake(label_2.frame.origin.x+label_2.frame.size.width/2+15,label_1.frame.size.height+label_1.frame.origin.y+26.5,sW-mySlier_2.frame.origin.x-112-15,15)];
                }
                mySlier_2.minimumValue = 0;
                mySlier_2.value = 0;
                mySlier_2.tag = (long)[canShuIndexArray[1] integerValue];
                
                mySlier_2.maximumTrackTintColor = kDF_RGBA(225, 225, 225, 1);
                mySlier_2.minimumTrackTintColor = kColor_0000;
                
                [mySlier_2 setThumbImage:[UIImage imageNamed:@"Theme.bundle/slider_kalaok_nol"] forState:UIControlStateNormal];
                
                if(canShuMaxArray[1]!=nil){
                    mySlier_2.maximumValue = [canShuMaxArray[1] floatValue];
                    [scrollView addSubview:mySlier_2];
                }
                
                [mySlier_2 addTarget:self action:@selector(btn_Canshu:) forControlEvents:UIControlEventTouchUpInside];
                
                if(label_3 == nil){
                    label_3= [[UILabel alloc] init];
                }
                label_3.frame = CGRectMake(20,label_2.frame.size.height+label_2.frame.origin.y+26.5,144,16);
                label_3.numberOfLines = 0;
                [label_3 setFont:[UIFont fontWithName:@"System" size:14]];
                [label_3 setTextColor:kDF_RGBA(36, 36, 36, 1.0)];
                
                if(canShuArray[2]!=nil){
                    if([kJL_GET hasPrefix:@"zh"]){
                        if([canShuArray[2] isEqualToString:@"混响"]){
                            [label_3 setText:kJL_TXT("eq_advanced_reverberation")];
                        }
                    }else{
                        [label_3 setText:canShuArray[2]];
                    }
                    [scrollView addSubview:label_3];
                }
                
                if(mySlier_3 == nil){
                    mySlier_3=[[UISlider alloc]initWithFrame:CGRectMake(label_3.frame.origin.x+label_3.frame.size.width/2+15,label_2.frame.size.height+label_2.frame.origin.y+26.5,sW-mySlier_3.frame.origin.x-112-15,15)];
                }
                mySlier_3.minimumValue = 0;
                mySlier_3.value = 0;
                mySlier_3.tag = (long)[canShuIndexArray[2] integerValue];
                
                mySlier_3.maximumTrackTintColor = kDF_RGBA(225, 225, 225, 1);
                mySlier_3.minimumTrackTintColor = kColor_0000;
                
                [mySlier_3 setThumbImage:[UIImage imageNamed:@"Theme.bundle/slider_kalaok_nol"] forState:UIControlStateNormal];
                [scrollView addSubview:mySlier_3];
                
                if(canShuMaxArray[2]!=nil){
                    mySlier_3.maximumValue = [canShuMaxArray[2] floatValue];
                    [scrollView addSubview:mySlier_3];
                }
                
                [mySlier_3 addTarget:self action:@selector(btn_Canshu:) forControlEvents:UIControlEventTouchUpInside];
                
                if(label_4 == nil){
                    label_4= [[UILabel alloc] init];
                }
                label_4.frame = CGRectMake(20,label_3.frame.size.height+label_3.frame.origin.y+26.5,144,16);
                label_4.numberOfLines = 0;
                [label_4 setFont:[UIFont fontWithName:@"System" size:14]];
                [label_4 setTextColor:kDF_RGBA(36, 36, 36, 1.0)];
                
                if(canShuArray[3]!=nil){
                    if([kJL_GET hasPrefix:@"zh"]){
                        if([canShuArray[3] isEqualToString:@"高音"]){
                            [label_4 setText:kJL_TXT("volume_height")];
                        }
                    }else{
                        [label_4 setText:canShuArray[3]];
                    }
                    [scrollView addSubview:label_4];
                }
                
                if(mySlier_4 == nil){
                    mySlier_4=[[UISlider alloc]initWithFrame:CGRectMake(label_4.frame.origin.x+label_4.frame.size.width/2+15,label_3.frame.size.height+label_3.frame.origin.y+26.5,sW-mySlier_4.frame.origin.x-112-15,15)];
                }
                mySlier_4.minimumValue = 0;
                mySlier_4.value = 0;
                mySlier_4.tag = (long)[canShuIndexArray[3] integerValue];
                
                mySlier_4.maximumTrackTintColor = kDF_RGBA(225, 225, 225, 1);
                mySlier_4.minimumTrackTintColor = kColor_0000;
                
                [mySlier_4 setThumbImage:[UIImage imageNamed:@"Theme.bundle/slider_kalaok_nol"] forState:UIControlStateNormal];
                
                if(canShuMaxArray[3]!=nil){
                    mySlier_4.maximumValue = [canShuMaxArray[3] floatValue];
                    [scrollView addSubview:mySlier_4];
                }
                
                [mySlier_4 addTarget:self action:@selector(btn_Canshu:) forControlEvents:UIControlEventTouchUpInside];
                
                if(label_5 == nil){
                    label_5= [[UILabel alloc] init];
                }
                label_5.frame = CGRectMake(20,label_4.frame.size.height+label_4.frame.origin.y+26.5,144,16);
                label_5.numberOfLines = 0;
                [label_5 setFont:[UIFont fontWithName:@"System" size:14]];
                [label_5 setTextColor:kDF_RGBA(36, 36, 36, 1.0)];
                if(canShuArray[4]!=nil){
                    if([kJL_GET hasPrefix:@"zh"]){
                        if([canShuArray[4] isEqualToString:@"低音"]){
                            [label_5 setText:kJL_TXT("volume_bass")];
                        }
                    }else{
                        [label_5 setText:canShuArray[4]];
                    }
                    [scrollView addSubview:label_5];
                }
                
                if(mySlier_5 == nil){
                    mySlier_5=[[UISlider alloc]initWithFrame:CGRectMake(label_5.frame.origin.x+label_5.frame.size.width/2+15,label_4.frame.size.height+label_4.frame.origin.y+26.5,sW-mySlier_5.frame.origin.x-112-15,15)];
                }
                mySlier_5.minimumValue = 0;
                mySlier_5.value = 0;
                mySlier_5.tag = (long)[canShuIndexArray[4] integerValue];
                
                mySlier_5.maximumTrackTintColor = kDF_RGBA(225, 225, 225, 1);
                mySlier_5.minimumTrackTintColor = kColor_0000;
                
                [mySlier_5 setThumbImage:[UIImage imageNamed:@"Theme.bundle/slider_kalaok_nol"] forState:UIControlStateNormal];
                
                if(canShuMaxArray[4]!=nil){
                    mySlier_5.maximumValue = [canShuMaxArray[4] floatValue];
                    [scrollView addSubview:mySlier_5];
                }
                
                [mySlier_5 addTarget:self action:@selector(btn_Canshu:) forControlEvents:UIControlEventTouchUpInside];
                
                if(label_6 == nil){
                    label_6= [[UILabel alloc] init];
                }
                label_6.frame = CGRectMake(20,label_5.frame.size.height+label_5.frame.origin.y+26.5,144,16);
                label_6.numberOfLines = 0;
                [label_6 setFont:[UIFont fontWithName:@"System" size:14]];
                [label_6 setTextColor:kDF_RGBA(36, 36, 36, 1.0)];
                if(canShuArray[5]!=nil){
                    [label_6 setText:canShuArray[5]];
                    [scrollView addSubview:label_6];
                }
                
                if(mySlier_6 == nil){
                    mySlier_6=[[UISlider alloc]initWithFrame:CGRectMake(label_6.frame.origin.x+label_6.frame.size.width/2+15,label_5.frame.size.height+label_5.frame.origin.y+26.5,sW-mySlier_6.frame.origin.x-112-15,15)];
                }
                mySlier_6.minimumValue = 0;
                mySlier_6.value = 0;
                mySlier_6.tag = (long)[canShuIndexArray[5] integerValue];
                
                mySlier_6.maximumTrackTintColor = kDF_RGBA(225, 225, 225, 1);
                mySlier_6.minimumTrackTintColor = kColor_0000;
                
                [mySlier_6 setThumbImage:[UIImage imageNamed:@"Theme.bundle/slider_kalaok_nol"] forState:UIControlStateNormal];
                if(canShuMaxArray[5]!=nil){
                    mySlier_6.maximumValue = [canShuMaxArray[5] floatValue];
                    [scrollView addSubview:mySlier_6];
                }
                [mySlier_6 addTarget:self action:@selector(btn_Canshu:) forControlEvents:UIControlEventTouchUpInside];
                
                if(label_7 == nil){
                    label_7= [[UILabel alloc] init];
                }
                label_7.frame = CGRectMake(20,label_6.frame.size.height+label_6.frame.origin.y+26.5,144,16);
                label_7.numberOfLines = 0;
                [label_7 setFont:[UIFont fontWithName:@"System" size:14]];
                [label_7 setTextColor:kDF_RGBA(36, 36, 36, 1.0)];
                if(canShuArray[6]!=nil){
                    [label_7 setText:canShuArray[6]];
                    [scrollView addSubview:label_7];
                }
                
                if(mySlier_7 == nil){
                    mySlier_7=[[UISlider alloc]initWithFrame:CGRectMake(label_7.frame.origin.x+label_7.frame.size.width/2+15,label_6.frame.size.height+label_6.frame.origin.y+26.5,sW-mySlier_7.frame.origin.x-112-15,15)];
                }
                mySlier_7.minimumValue = 0;
                mySlier_7.value = 0;
                mySlier_7.tag = (long)[canShuIndexArray[6] integerValue];
                
                mySlier_7.maximumTrackTintColor = kDF_RGBA(225, 225, 225, 1);
                mySlier_7.minimumTrackTintColor = kColor_0000;
                
                [mySlier_7 setThumbImage:[UIImage imageNamed:@"Theme.bundle/slider_kalaok_nol"] forState:UIControlStateNormal];
                if(canShuMaxArray[6]!=nil){
                    mySlier_7.maximumValue = [canShuMaxArray[6] floatValue];
                    [scrollView addSubview:mySlier_7];
                }
                [mySlier_7 addTarget:self action:@selector(btn_Canshu:) forControlEvents:UIControlEventTouchUpInside];
                
                //判断UISlider是否可用
                if((mySlier_1!=nil) && (mySlier_1.isHidden == NO) && ([canShuEnableArray[0] boolValue])){
                    [mySlier_1 setUserInteractionEnabled:YES];
                }
                if((mySlier_1!=nil) && (mySlier_1.isHidden == NO) && ([canShuEnableArray[0] boolValue] == NO)){
                    [mySlier_1 setUserInteractionEnabled:YES];
                }
                
                if((mySlier_2!=nil) && (mySlier_2.isHidden == NO) && ([canShuEnableArray[1] boolValue])){
                    [mySlier_2 setUserInteractionEnabled:YES];
                }
                if((mySlier_2!=nil) && (mySlier_2.isHidden == NO) && ([canShuEnableArray[1] boolValue] == NO)){
                    [mySlier_2 setUserInteractionEnabled:YES];
                }
                
                if((mySlier_3!=nil) && (mySlier_3.isHidden == NO) && ([canShuEnableArray[2] boolValue])){
                    [mySlier_3 setUserInteractionEnabled:YES];
                }
                if((mySlier_3!=nil) && (mySlier_3.isHidden == NO) && ([canShuEnableArray[2] boolValue] == NO)){
                    [mySlier_3 setUserInteractionEnabled:YES];
                }
                
                if((mySlier_4!=nil) && (mySlier_4.isHidden == NO) && ([canShuEnableArray[3] boolValue])){
                    [mySlier_4 setUserInteractionEnabled:YES];
                }
                if((mySlier_4!=nil) && (mySlier_4.isHidden == NO) && ([canShuEnableArray[3] boolValue] == NO)){
                    [mySlier_4 setUserInteractionEnabled:YES];
                }
                
                if((mySlier_5!=nil) && (mySlier_5.isHidden == NO) && ([canShuEnableArray[4] boolValue])){
                    [mySlier_5 setUserInteractionEnabled:YES];
                }
                if((mySlier_5!=nil) && (mySlier_5.isHidden == NO) && ([canShuEnableArray[4] boolValue] == NO)){
                    [mySlier_5 setUserInteractionEnabled:YES];
                }
                
                if((mySlier_6!=nil) && (mySlier_6.isHidden == NO) && ([canShuEnableArray[5] boolValue])){
                    [mySlier_6 setUserInteractionEnabled:YES];
                }
                if((mySlier_6!=nil) && (mySlier_6.isHidden == NO) && ([canShuEnableArray[5] boolValue] == NO)){
                    [mySlier_6 setUserInteractionEnabled:YES];
                }
                
                if((mySlier_7!=nil) && (mySlier_7.isHidden == NO) && ([canShuEnableArray[6] boolValue])){
                    [mySlier_7 setUserInteractionEnabled:YES];
                }
                if((mySlier_7!=nil) && (mySlier_7.isHidden == NO) && ([canShuEnableArray[6] boolValue] == NO)){
                    [mySlier_7 setUserInteractionEnabled:YES];
                }
            }
        }
        if(model.mId == 3){  //其他
            if(otherImv == nil){
                if(mBianshenImv == nil){
                    otherImv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 22,22)];
                }else{
                    otherImv = [[UIImageView alloc] initWithFrame:CGRectMake(20, bianShenView.frame.size.height+bianShenView.frame.origin.y+28, 22,22)];
                }
            }
            
            if([model.icon_url containsString:@("https")]){
                otherImv.image = [UIImage imageNamed:@"Theme.bundle/icon_others_nol.png"];
                [self downloadImageWithUrl:model.icon_url withImageView:otherImv];
            }else{
                if(isNet == NO){
                    otherImv.image = [UIImage imageNamed:@"Theme.bundle/icon_others_nol.png"];
                }
                if(isNet == YES){
                    otherImv.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",model.icon_url]];
                }
            }
            otherImv.contentMode = UIViewContentModeScaleToFill;
            [scrollView addSubview:otherImv];
            
            otherLabel = [[UILabel alloc] init];
            if(bianShenView == nil){
                otherLabel.frame = CGRectMake(otherImv.frame.origin.x+otherImv.frame.size.width+8,20,144,21);
            }else{
                otherLabel.frame = CGRectMake(otherImv.frame.origin.x+otherImv.frame.size.width+8,bianShenView.frame.size.height+bianShenView.frame.origin.y+28,144,21);
            }
            otherLabel.numberOfLines = 0;
            if([kJL_GET hasPrefix:@"zh"]){
                otherLabel.text = model.zh_name;
            }else{
                otherLabel.text =  model.en_name;
            }
            [scrollView addSubview:otherLabel];
            
            NSArray *otherList = model.mList;
            if(model.column){
                NSInteger otherKMaxRowCount;
                NSInteger otherkItemCountPerRow;
                
                if(model.row){
                    otherKMaxRowCount = model.row;
                }else{
                    otherKMaxRowCount = otherList.count/model.column;
                }
                otherkItemCountPerRow = model.column;
                
                CGRect mOtherViewRect = CGRectMake(8,otherImv.frame.size.height+otherImv.frame.origin.y+18,scrollView.frame.size.width-2*8, 38*otherKMaxRowCount+15);
                mOtherView = [[OtherView alloc] initWithFrame:mOtherViewRect];
                mOtherView.otherArray = model.mList;
                [mOtherView onOtherViewBlock:^(NSInteger tag) {

                    JL_ManagerM *manager = [self->bleSDK.mBleEntityM mCmdManager];
                    [manager.mSoundCardManager cmdSetKalaok:manager Index:tag Value:0 result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                        
                    }];
                }];
                [mOtherView setKMaxRowCount:otherKMaxRowCount WithItemCountPerRow:otherkItemCountPerRow];
                [scrollView addSubview:mOtherView];
            }
        }
    }
    
    scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 20+bianshenImv.frame.size.height+18+bianShenView.frame.size.height+28+otherImv.frame.size.height
                                        +18+mOtherView.frame.size.height+28.5+qifenImv.frame.size.height
                                        +20.5+kalaokView.frame.size.height+50+canshuImv.frame.size.height
                                        +17.5+label_1.frame.size.height+26.5+
                                        label_2.frame.size.height+26.5+label_3.frame.size.height+
                                        26.5+label_4.frame.size.height+26.5+label_5.frame.size.height
                                        +26.5+label_6.frame.size.height+26.5+label_7.frame.size.height+32);
    scrollView.showsVerticalScrollIndicator = NO;
}

- (IBAction)btn_back:(id)sender {
    if(scrollView!=nil){
        [scrollView removeFromSuperview];
        scrollView = nil;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btn_micEQ:(id)sender {
    CGRect rect = CGRectMake(0, 0, sW, sH);
    karaokeEQView = [[KaraokeEQView alloc] initByFrame:rect];
    [self.view addSubview:karaokeEQView];
    
    [karaokeEQView showMe];
}

- (void)btn_Canshu:(UISlider *)sender {
    sliderFlag = YES;
    uint8_t index   = (uint8_t)sender.tag;
    uint16_t value =  (uint16_t)sender.value;
    
    JL_ManagerM *manager = [bleSDK.mBleEntityM mCmdManager];
    [manager.mSoundCardManager cmdSetKalaok:manager Index:index Value:value result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        
    }];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if (tp == JLDeviceChangeTypeInUseOffline ||
        tp == JLDeviceChangeTypeBleOFF) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



-(void)addNote{
    
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)viewDidDisappear:(BOOL)animated{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)requestLocalJson{
    NSString *path = [JL_Tools find:@"sound_card_json.txt"];
    NSData *localData = [NSData dataWithContentsOfFile:path];
    NSDictionary *dic = [DFTools jsonWithData:localData];
    [self loadJson:dic];
}

-(void)loadJson:(NSDictionary *) dic{
    hasEq = dic[@"hasEq"];
    NSMutableArray *tempArray = [NSMutableArray new];
    NSArray *functionArray = dic[@"function"];
    for (int i = 0; i < functionArray.count; i++) {
        KalaokModel *myModel = [KalaokModel new];
        NSDictionary *data = functionArray[i];
        myModel.mId = [data[@"id"] integerValue];
        myModel.zh_name = data[@"title"][@"zh"];
        myModel.en_name = data[@"title"][@"en"];
        myModel.type = data[@"type"];
        myModel.icon_url = data[@"icon_url"];
        myModel.column = [data[@"column"] integerValue];
        myModel.row = [data[@"row"] integerValue];
        myModel.paging = [data[@"paging"] boolValue];
        myModel.mList = data[@"list"];
        
        [tempArray addObject:myModel];
    }
    mDataArray = [tempArray copy];
}


-(void)setKalaOKData:(BOOL )requestNetFlag{
    if(requestNetFlag == YES){
        hasEq = [[JLCacheBox cacheUuid:self->bleSDK.mBleUUID] hasKalaokEQ];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *key = [NSString stringWithFormat:@"SHENGKA_%@",bleSDK.mBleUUID];
        NSData *arrayData = [userDefaults  objectForKey:key];
        self->mDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
    }else{
        [self requestLocalJson];
    }
    
    [self setupUI];
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON Result:nil];
}

//异步线程加载网络下载图片 ——> 回到主线程更新UI
-(void)downloadImageWithUrl:(NSString *)imageDownloadURLStr withImageView:(UIImageView *) imageView{
    //以便在block中使用
    __block UIImage *image = [[UIImage alloc] init];
    //图片下载链接
    NSURL *imageDownloadURL = [NSURL URLWithString:imageDownloadURLStr];
    
    //将图片下载在异步线程进行
    //创建异步线程执行队列
    dispatch_queue_t asynchronousQueue = dispatch_queue_create("imageDownloadQueue", NULL);
    //创建异步线程
    dispatch_async(asynchronousQueue, ^{
        //网络下载图片  NSData格式
        NSError *error;
        NSData *imageData = [NSData dataWithContentsOfURL:imageDownloadURL options:NSDataReadingMappedIfSafe error:&error];
        if (imageData) {
            image = [UIImage imageWithData:imageData];
        }
        //回到主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageView setImage:image];
        });
    });
}


//MARK: - handle jlsoundcard
-(void)jlsoundCardMicFrequency:(NSArray *)frequencyArray{
    
}

-(void)jlsoundCardMask:(uint64_t)mask values:(NSArray<JLSoundCardIndexValue *> *)items{
    
    for (JLSoundCardIndexValue *item in items) {
        for (UIView *sl in scrollView.subviews) {
            if ([sl isKindOfClass:[UISlider class]]) {
                UISlider *sub_sl = (UISlider *) sl;
                if (sub_sl.tag == item.index) {
                    sub_sl.value = item.value;
                }
            }
        }
    }
        
}

- (void)jlsoundCardMicEQ:(NSArray *)eqArray{
    
}

@end
