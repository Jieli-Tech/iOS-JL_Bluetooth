//
//  EqParamView.m
//  TestUIDemo
//
//  Created by 杰理科技 on 2020/6/1.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "EqParamView.h"
#import "DFTitleScrollView.h"
#import "DFSliderView.h"
#import "BezierView.h"
#import "JLUI_Effect.h"
#import "JLUI_Cache.h"
#import "JL_RunSDK.h"
#import "EQSelectView.h"
#import "EFCircularSlider.h"
#import "EQDrawView.h"

static EQSelectView *eqSelectView = nil;


@interface EqParamView(){
    float sW;
    float sH;
    DFTitleScrollView   *titleScrollView;
    DFSliderView        *sliderView;
    BezierView          *bzView;
    EQParamBlock        blockParam;
    EQDrawView          *eqDrawView;
    
    UIButton            *btnEQ; //EQ选择
    UIButton            *btnRest; //EQ重置
    UIButton            *btnSettings; //EQ高级设置
    
    EFCircularSlider    *circularSlider;
    NSArray             *dataArray;
    
    JL_RunSDK           *bleSDK;
    NSString            *bleUUID;
}

@end



@implementation EqParamView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addNote];
        
        bleSDK = [JL_RunSDK sharedMe];
        bleUUID= bleSDK.mBleUUID;
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.shadowColor  = kDF_RGBA(205, 230, 251, 0.2).CGColor;
        self.layer.shadowOffset = CGSizeMake(0,1);
        self.layer.shadowOpacity= 1;
        self.layer.shadowRadius = 8;
        self.layer.cornerRadius = 13;
        
        sW = frame.size.width;
        sH = frame.size.height;
                
        //JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        
        eqSelectView = [[EQSelectView alloc] init];
        [eqSelectView setEQSelectBLK:^(uint8_t eqMode, NSArray * _Nullable eqArray) {
            if (self->blockParam) {
                if (self->bleSDK.mBleEntityM) {
                    self->blockParam(eqMode,eqArray);
                }
                JLModel_Device *model0 = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
                NSLog(@"model:%@",model0);
                [self->sliderView setSliderEqArray:eqArray EqFrequecyArray:model0.eqFrequencyArray EqType:model0.eqType];
                [self->eqDrawView setUpEqArrayAll:eqArray centerFrequency:model0.eqFrequencyArray withType:eqMode];
                //[[JLUI_Cache sharedInstance] setMEqMode:eqMode];
                [[JLCacheBox cacheUuid:self->bleUUID] setMEqMode:eqMode];
                [self updateBtnWithMode:eqMode];
            }
        }];
        
        circularSlider = [[EFCircularSlider alloc] initByFrame:CGRectMake(10, 10,sW-20.0, 180)];
        [self addSubview:circularSlider];
        
        CGRect rect_1 = CGRectMake(10,circularSlider.max_h+10, sW-10.0, sH-circularSlider.max_h+10-45.0-80.0);
        sliderView = [[DFSliderView alloc] initWithFrame:rect_1];
        [sliderView setEqType:0];
        [self addSubview:sliderView];
        
        CGRect rect_wave = CGRectMake(0, sH-120.0, sW, 55);
        eqDrawView = [[EQDrawView alloc] initWithFrame:rect_wave];
        [self addSubview:eqDrawView];
        
        [sliderView outputEqArray:^(NSArray * _Nonnull eqArray) {
            JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
            if (self->blockParam) {
                if(self->bleSDK.mBleEntityM){
                    self->blockParam(JL_EQModeCUSTOM,eqArray);
                }
                NSLog(@"setUpEqArray custom");
                if (model.eqType == JL_EQType10) {
                    [[JLCacheBox cacheUuid:self->bleUUID] setEqCustomArray_1:eqArray];
                }else{
                    [[JLCacheBox cacheUuid:self->bleUUID] setEqCustomArray:eqArray];
                }
                
                [self->eqDrawView setUpEqArrayAll:eqArray centerFrequency:model.eqFrequencyArray withType:JL_EQModeCUSTOM];
                
                [[JLCacheBox cacheUuid:self->bleUUID] setMEqMode:JL_EQModeCUSTOM];
                [self updateBtnWithMode:JL_EQModeCUSTOM];
            }
        } ChangeUI:^(NSArray * _Nonnull eqArray, int value, int index) {
            //NSLog(@"EQ Change --------------> %d %d",value,index);
            JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
            [self->eqDrawView setUpCenterFrequency:model.eqFrequencyArray EqArray:eqArray withNum:value withIndex:index];
        }];
        
        NSArray *eqArr = @[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
        NSLog(@"setUpEqArray 2222");
        [eqDrawView setUpEqArray:eqArr];
        
        CGRect rect_btn_0 = CGRectMake(18.0, sH-55.0, sW/3.0-15, 40.0);
        btnEQ = [[UIButton alloc] initWithFrame:rect_btn_0];
        btnEQ.backgroundColor = [UIColor whiteColor];
        btnEQ.layer.cornerRadius = 6.0;
        btnEQ.layer.borderWidth  = 1.0;
        btnEQ.layer.borderColor  = kDF_RGBA(179, 179, 179, 1.0).CGColor;
        [btnEQ addTarget:self action:@selector(onEQBtn) forControlEvents:UIControlEventTouchUpInside];
        btnEQ.titleLabel.text = @"自定义";
        [btnEQ setTitle:@"自定义" forState:UIControlStateNormal];
        
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        
        if(model.karaokeEQType == JL_KaraokeEQTypeYES){
            [btnEQ setTitleColor:kDF_RGBA(148, 148, 148, 1.0) forState:UIControlStateNormal];
            [btnEQ setImage:[UIImage imageNamed:@"Theme.bundle/eq_no_enable_icon_up"] forState:UIControlStateNormal];
            [btnEQ setUserInteractionEnabled:NO];
        }
        if(model.karaokeEQType == JL_KaraokeEQTypeNO){
            [btnEQ setTitleColor:kDF_RGBA(35, 35, 35, 1.0) forState:UIControlStateNormal];
            [btnEQ setImage:[UIImage imageNamed:@"Theme.bundle/eq_icon_up"] forState:UIControlStateNormal];
            [btnEQ setUserInteractionEnabled:YES];
        }
        btnEQ.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
        [self addSubview:btnEQ];
        
        CGRect rect_btn_1 = CGRectMake(rect_btn_0.origin.x+rect_btn_0.size.width+16, sH-55.0, 0.7*(sW/3.0), 40.0);
        btnRest = [[UIButton alloc] initWithFrame:rect_btn_1];
        btnRest.backgroundColor = [UIColor whiteColor];
        btnRest.layer.cornerRadius = 6.0;
        btnRest.layer.borderWidth  = 1.0;
        btnRest.layer.borderColor  = kDF_RGBA(179, 179, 179, 1.0).CGColor;
        [btnRest addTarget:self action:@selector(onRestBtn) forControlEvents:UIControlEventTouchUpInside];
        btnRest.titleLabel.text = kJL_TXT("重置");
        [btnRest setTitle:kJL_TXT("重置") forState:UIControlStateNormal];
        if(model.karaokeEQType == JL_KaraokeEQTypeYES){
            [btnRest setTitleColor:kDF_RGBA(148, 148, 148, 1.0) forState:UIControlStateNormal];
            [btnRest setUserInteractionEnabled:NO];
        }
        if(model.karaokeEQType == JL_KaraokeEQTypeNO){
            [btnRest setTitleColor:kColor_0000 forState:UIControlStateNormal];
            [btnRest setUserInteractionEnabled:YES];
        }

        btnRest.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
        [self addSubview:btnRest];
        
        CGRect rect_btn_2 = CGRectMake(rect_btn_1.origin.x+rect_btn_1.size.width+16, sH-55.0, sW/3.0-15, 40.0);
        btnSettings = [[UIButton alloc] initWithFrame:rect_btn_2];
        btnSettings.backgroundColor = [UIColor whiteColor];
        btnSettings.layer.cornerRadius = 6.0;
        btnSettings.layer.borderWidth  = 1.0;
        btnSettings.layer.borderColor  = kDF_RGBA(179, 179, 179, 1.0).CGColor;
        [btnSettings addTarget:self action:@selector(onSettingsBtn) forControlEvents:UIControlEventTouchUpInside];
        btnSettings.titleLabel.text = kJL_TXT("高级设置");
        [btnSettings setTitle:kJL_TXT("高级设置") forState:UIControlStateNormal];
        if(model.karaokeEQType == JL_KaraokeEQTypeYES){
            [btnSettings setTitleColor:kDF_RGBA(148, 148, 148, 1.0) forState:UIControlStateNormal];
            [btnSettings setUserInteractionEnabled:NO];
        }
        if(model.karaokeEQType == JL_KaraokeEQTypeNO){
            [btnSettings setTitleColor:kDF_RGBA(35, 35, 35, 1.0) forState:UIControlStateNormal];
            [btnSettings setUserInteractionEnabled:YES];
        }
        btnSettings.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14];
        [self addSubview:btnSettings];
        
        [JLUI_Effect addShadowOnView:self];
        
        dataArray = @[kJL_TXT("自然"),kJL_TXT("摇滚"),kJL_TXT("流行"),kJL_TXT("经典"),kJL_TXT("爵士"),kJL_TXT("乡村"),kJL_TXT("自定义")];
        [self updateBtnWithMode:model.eqMode];
        [self setEQArray:model.eqArray EQMode:model.eqMode];
    }
    return self;
}



-(void)noteSystemInfo:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;

    BOOL isID3_push = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_PUSH];
    if(isID3_push == NO){
        [self updateHighLowVol];
    }
    
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    [self updateBtnWithMode:model.eqMode];
}

-(void)noteUpdateEQ:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;

    [self updateHighLowVol];
    
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    [self updateBtnWithMode:model.eqMode];
}

#pragma mark 更新高低音
-(void)updateHighLowVol{
    
    [JL_Tools mainTask:^{
        JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        
        if(model.karaokeEQType == JL_KaraokeEQTypeYES){
            //获取主音量的值
            self->circularSlider.volSlider.value = 0;
            self->circularSlider.volLabel.text = @"0";
            
            //获取低音的值
            self->circularSlider.bassSlider.value = -12;
            self->circularSlider.bassLabel.text = @"-12";
            //获取高音的值
            self->circularSlider.trebleSlider.value = -12;
            self->circularSlider.trebleLabel.text = @"-12";
        }
        if(model.karaokeEQType == JL_KaraokeEQTypeNO){
            //获取低音的值
            self->circularSlider.bassSlider.value = (CGFloat)model.pitchLow;
            self->circularSlider.bassLabel.text = [NSString stringWithFormat:@"%.00f", self->circularSlider.bassSlider.value];
//            //获取主音量的值
//            self->circularSlider.volSlider.value = (CGFloat)model.currentVol;
//            self->circularSlider.volLabel.text = [NSString stringWithFormat:@"%.00f", self->circularSlider.volSlider.value];
            //获取高音的值
            self->circularSlider.trebleSlider.value = (CGFloat)model.pitchHigh;
            self->circularSlider.trebleLabel.text = [NSString stringWithFormat:@"%.00f", self->circularSlider.trebleSlider.value];
        }
    }];
}

#pragma mark 监听高低音可用的状态
-(void)highLowEnable{
    JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    CGPoint start = CGPointMake(200, 100);
    CGPoint end = CGPointMake(0, 100);
        
    if(model.karaokeEQType == JL_KaraokeEQTypeYES){
        self->circularSlider.volSlider.userInteractionEnabled = NO;
        [self->circularSlider.volLabel  setTextColor: [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
        [self->circularSlider.volSlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0]
                                                                              secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0]
                                                                          colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
        [self->circularSlider.volSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_01_dis"]];
        [self->circularSlider.volSlider setThumbWidth:50];
        
        
        //获取主音量的值
        self->circularSlider.volSlider.value = 0;
        self->circularSlider.volLabel.text = @"0";
        
        self->circularSlider.bassSlider.userInteractionEnabled = NO;
        self->circularSlider.trebleSlider.userInteractionEnabled = NO;
        [self->circularSlider.bassSlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0]
                                                                               secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0]
                                                                           colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
        [self->circularSlider.trebleSlider setGradientColorForHighlightedTrackWithFirstColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0]
                                                                                 secondColor:[UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0]
                                                                             colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
        
        [self->circularSlider.bassLabel  setTextColor: [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
        [self->circularSlider.trebleLabel  setTextColor:[UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0]];
        [self->circularSlider.bassSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_01_dis"]];
        [self->circularSlider.trebleSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_01_dis"]];
        
        [self->circularSlider.bassSlider setThumbWidth:50];
        [self->circularSlider.trebleSlider setThumbWidth:50];
        
        //获取低音的值
        self->circularSlider.bassSlider.value = -12;
        self->circularSlider.bassLabel.text = @"-12";
        
        //获取高音的值
        self->circularSlider.trebleSlider.value = -12;
        self->circularSlider.trebleLabel.text = @"-12";
    }
    if(model.karaokeEQType == JL_KaraokeEQTypeNO){
        self->circularSlider.bassSlider.userInteractionEnabled = YES;
        self->circularSlider.volSlider.userInteractionEnabled = YES;
        self->circularSlider.trebleSlider.userInteractionEnabled = YES;
        [self->circularSlider.bassSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001
                                                                               secondColor:kColor_0002
                                                                           colorsLocations:CGPointMake(0.3, 1.0)
                                                                                startPoint:start andEndPoint:end];
        [self->circularSlider.volSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001
                                                                              secondColor:kColor_0002
                                                                          colorsLocations:CGPointMake(0.3, 1.0)
                                                                               startPoint:start andEndPoint:end];
        [self->circularSlider.trebleSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001
                                                                                 secondColor:kColor_0002
                                                                             colorsLocations:CGPointMake(0.3, 1.0)
                                                                                  startPoint:start andEndPoint:end];
        [self->circularSlider.bassLabel  setTextColor:[UIColor blackColor]];
        [self->circularSlider.volLabel  setTextColor:[UIColor blackColor]];
        [self->circularSlider.trebleLabel  setTextColor:[UIColor blackColor]];
        [self->circularSlider.bassSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_01"]];
        [self->circularSlider.volSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_01"]];
        [self->circularSlider.trebleSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_01"]];
        
        //获取低音的值
        self->circularSlider.bassSlider.value = (CGFloat)model.pitchLow;
        self->circularSlider.bassLabel.text = [NSString stringWithFormat:@"%.00f", self->circularSlider.bassSlider.value];
//        //获取主音量的值
//        self->circularSlider.volSlider.value = (CGFloat)model.currentVol;
//        self->circularSlider.volLabel.text = [NSString stringWithFormat:@"%.00f", self->circularSlider.volSlider.value];
        //获取高音的值
        self->circularSlider.trebleSlider.value = (CGFloat)model.pitchHigh;
        self->circularSlider.trebleLabel.text = [NSString stringWithFormat:@"%.00f", self->circularSlider.trebleSlider.value];
        [self->circularSlider.bassSlider setThumbWidth:80];
        [self->circularSlider.volSlider setThumbWidth:80];
        [self->circularSlider.trebleSlider setThumbWidth:80];
    }
}

-(void)setEQParamBLK:(EQParamBlock)blkParam{
    blockParam = blkParam;
}


-(void)setEQArray:(NSArray*)eqArray EQMode:(uint8_t)eqMode{
    if (eqArray.count > 0) {
        
        JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if (model.eqType == JL_EQType10) {
            NSArray *defaultArr = @[@(32),@(64),@(125),@(250),@(500),@(1000),@(2000),@(4000),@(8000),@(16000)];
            [sliderView setSliderEqArray:eqArray EqFrequecyArray:defaultArr EqType:model.eqType];
            [self->eqDrawView setUpEqArrayAll:eqArray centerFrequency:defaultArr withType:eqMode];
        }else{
            
            if (model.eqFrequencyArray.count>0) {
                [sliderView setSliderEqArray:eqArray EqFrequecyArray:model.eqFrequencyArray EqType:model.eqType];
                [self->eqDrawView setUpEqArrayAll:eqArray centerFrequency:model.eqFrequencyArray withType:eqMode];
                
            }
        }
    }
}

-(void)onEQBtn{
    [DFAction mainTask:^{
        [eqSelectView onShow];
    }];
}

-(void)onRestBtn{
    NSArray *zoreArr = nil;
    JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];

    if (model.eqType == JL_EQType10) {
        zoreArr = @[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)];
    }else{
        NSMutableArray *mArr = [NSMutableArray new];
        for (int i = 0 ; i < model.eqArray.count; i++) {
            [mArr addObject:@(0)];
        }
        zoreArr = mArr;
    }
    
    NSLog(@"setUpEqArray 0000");
    if (model.eqType == JL_EQType10) {
        NSArray *defaultArr = @[@(32),@(64),@(125),@(250),@(500),@(1000),@(2000),@(4000),@(8000),@(16000)];
        [sliderView setSliderEqArray:zoreArr EqFrequecyArray:defaultArr EqType:model.eqType];
    }else{
        [sliderView setSliderEqArray:zoreArr EqFrequecyArray:model.eqFrequencyArray EqType:model.eqType];
    }
    [eqDrawView setUpEqArrayAll:zoreArr centerFrequency:model.eqFrequencyArray withType:JL_EQModeCUSTOM];
    
    if (bleSDK.mBleEntityM) {
        [bleSDK.mBleEntityM.mCmdManager cmdSetSystemEQ:JL_EQModeCUSTOM Params:zoreArr];
    }else{        
        if (model.eqType == JL_EQType10) {
            [[JLCacheBox cacheUuid:self->bleUUID] setEqCustomArray_1:zoreArr];
        }else{
            [[JLCacheBox cacheUuid:self->bleUUID] setEqCustomArray:zoreArr];
        }
    }
}

-(void)onSettingsBtn{
    if ([_delegate respondsToSelector:@selector(enterEQSettingsUI)]) {
        [self.delegate enterEQSettingsUI];
    }
}

#pragma mark 监测蓝牙的各种状态
-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline) {
        [DFAction mainTask:^{
            [eqSelectView onDismiss];
        }];
    }
    
    if (tp == JLDeviceChangeTypeBleOFF) {
        [DFAction mainTask:^{
            [eqSelectView onDismiss];
        }];
    }
    if (tp == JLDeviceChangeTypeManualChange || tp == JLDeviceChangeTypeSomethingConnected) {
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        [self updateBtnWithMode:model.eqMode];
        [self updateHighLowVol];
    }
    [self highLowEnable];
    
    JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    if(model.karaokeEQType == JL_KaraokeEQTypeYES){
        [btnSettings setTitleColor:kDF_RGBA(148, 148, 148, 1.0) forState:UIControlStateNormal];
        [btnSettings setUserInteractionEnabled:NO];
    }
    if(model.karaokeEQType == JL_KaraokeEQTypeNO){
        [btnSettings setTitleColor:kDF_RGBA(35, 35, 35, 1.0) forState:UIControlStateNormal];
        [btnSettings setUserInteractionEnabled:YES];
    }
    
    if(model.karaokeEQType == JL_KaraokeEQTypeYES){
        [btnRest setTitleColor:kDF_RGBA(148, 148, 148, 1.0) forState:UIControlStateNormal];
        [btnRest setUserInteractionEnabled:NO];
    }
    if(model.karaokeEQType == JL_KaraokeEQTypeNO){
        [btnRest setTitleColor:kColor_0000 forState:UIControlStateNormal];
        [btnRest setUserInteractionEnabled:YES];
    }
    
    if(model.karaokeEQType == JL_KaraokeEQTypeYES){
        [btnEQ setTitleColor:kDF_RGBA(148, 148, 148, 1.0) forState:UIControlStateNormal];
        [btnEQ setImage:[UIImage imageNamed:@"Theme.bundle/eq_no_enable_icon_up"] forState:UIControlStateNormal];
        [btnEQ setUserInteractionEnabled:NO];
    }
    if(model.karaokeEQType == JL_KaraokeEQTypeNO){
        [btnEQ setTitleColor:kDF_RGBA(35, 35, 35, 1.0) forState:UIControlStateNormal];
        [btnEQ setImage:[UIImage imageNamed:@"Theme.bundle/eq_icon_up"] forState:UIControlStateNormal];
        [btnEQ setUserInteractionEnabled:YES];
    }
    
    [self setEQArray:model.eqArray EQMode:model.eqMode];
}





-(void)updateBtnWithMode:(JL_EQMode)mode{
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    
    if(mode != JL_EQModeCUSTOM){
        if(model.karaokeEQType == JL_KaraokeEQTypeYES){
            [self->btnRest setTitleColor:kDF_RGBA(148, 148, 148, 1.0) forState:UIControlStateNormal];
            [self->btnRest setUserInteractionEnabled:NO];
        }
        if(model.karaokeEQType == JL_KaraokeEQTypeNO){
            [self->btnRest setTitleColor:kDF_RGBA(136, 136, 136, 1.0) forState:UIControlStateNormal];
            [self->btnRest setUserInteractionEnabled:YES];
        }
        self->btnRest.enabled = NO;
    }
    if(mode == JL_EQModeCUSTOM){
        if(model.karaokeEQType == JL_KaraokeEQTypeYES){
            [self->btnRest setTitleColor:kDF_RGBA(148, 148, 148, 1.0) forState:UIControlStateNormal];
            [self->btnRest setUserInteractionEnabled:NO];
        }
        if(model.karaokeEQType == JL_KaraokeEQTypeNO){
            [self->btnRest setTitleColor:kColor_0000 forState:UIControlStateNormal];
            [self->btnRest setUserInteractionEnabled:YES];
        }
        self->btnRest.enabled = YES;
    }
    [btnEQ setTitle:dataArray[mode] forState:UIControlStateNormal];
    
    if([kJL_GET hasPrefix:@"zh"]){
        if(btnEQ.titleLabel.text.length ==3){
            if([UIScreen mainScreen].bounds.size.width ==320.0){
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 65, 0, 0)];
            }
            if([UIScreen mainScreen].bounds.size.width ==375.0){
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 80, 0, 0)];
            }
            if([UIScreen mainScreen].bounds.size.width>375.0){
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 90, 0, 0)];
            }
        }else{
            if([UIScreen mainScreen].bounds.size.width ==320.0){
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 55, 0, 0)];
            }else{
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 70, 0, 0)];
            }
        }
    }else{
        if(btnEQ.titleLabel.text.length ==4){
            if([UIScreen mainScreen].bounds.size.width ==320.0){
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 60, 0, 0)];
            }else{
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 80, 0, 0)];
            }
        }else if(btnEQ.titleLabel.text.length >7){
            if([UIScreen mainScreen].bounds.size.width ==320.0){
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 70, 0, 0)];
            }else{
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 90, 0, 0)];
            }
        }else{
            if([UIScreen mainScreen].bounds.size.width ==320.0){
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 70, 0, 0)];
            }else{
                [btnEQ setImageEdgeInsets:UIEdgeInsetsMake(0, 85, 0, 0)];
            }
        }
    }

    [btnEQ setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
}

-(void)noteCurrentVol{
    JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    //获取主音量的值
    self->circularSlider.volSlider.value = (CGFloat)model.currentVol;
    self->circularSlider.volLabel.text = [NSString stringWithFormat:@"%.00f", self->circularSlider.volSlider.value];
}

-(void)addNote{
    [JLModel_Device observeModelProperty:@"currentVol" Action:@selector(noteCurrentVol) Own:self];
    [JL_Tools add:kJL_MANAGER_SYSTEM_INFO Action:@selector(noteSystemInfo:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JLModel_Device observeModelProperty:@"eqArray" Action:@selector(noteUpdateEQ:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}
@end
