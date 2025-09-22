//
//  EFCircularSlider.m
//  CustomCircularSlider
//
//  Created by kaka on 2020/6/2.
//  Copyright © 2020 I&N. All rights reserved.
//

#import "EFCircularSlider.h"
#import "JL_RunSDK.h"
#import "JLUI_Cache.h"
#import "JLCacheBox.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

@implementation EFCircularSlider{
    CTCallCenter *callCenter;
    UILabel *bassLabelStr;
    UILabel *volLabelStr;
    UILabel *trebleLabelStr;
    
    UIImageView *bassCircleImv;
    UIImageView *volCircleImv;
    UIImageView *trebleCircleImv;
    
    UIImageView *bassLow;
    UIImageView *volLow;
    UIImageView *trebleLow;
    
    UIImageView *bassHigh;
    UIImageView *volHigh;
    UIImageView *trebleHigh;
    
    float sW;
    float sH;
    
    MPVolumeView *volumeView;
    CGFloat cVol;
    int clickFlag; //0:低音 1：主音量 2：高音
    
    JL_RunSDK   *bleSDK;
    NSString    *bleUUID;
}


-(id)initByFrame:(CGRect)rect{
    self = [super initWithFrame:rect];
    if (self) {
        self.frame = rect;
        sW = rect.size.width;
        sH = rect.size.height;
        [[LanguageCls share] add:self];
        [self addNote];
        [self initUI];
        [self handleCall];
    }
    return self;
}

#define kCircle_Gap  20
#define kCircle_h    10

-(void)initUI{
    
    float all_w = sW-kCircle_Gap*2.0;
    float max_w = all_w/(1.0+0.88+0.88);
    float min_w = max_w*0.88;
    
    bleSDK = [JL_RunSDK sharedMe];
    bleUUID= bleSDK.mBleUUID;
    
    [[JLCacheBox cacheUuid:bleUUID] setCallPhoneFlag:NO];

    // 低音
    _bassSlider = [[IACircularSlider alloc] initWithFrame:CGRectMake(0, 10.0+kCircle_h, min_w, min_w)];
    [self addSubview:_bassSlider];
    
    _bassSlider.trackHighlightedTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _bassSlider.thumbTintColor = [UIColor whiteColor];
    _bassSlider.trackTintColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
    _bassSlider.thumbHighlightedTintColor = [UIColor whiteColor];
    _bassSlider.trackWidth = 7;
    _bassSlider.thumbWidth = 25;
    _bassSlider.minimumValue = -12;
    _bassSlider.maximumValue = +12;
    _bassSlider.startAngle = 0.7*M_PI;
    _bassSlider.endAngle = 0.3*M_PI;
    _bassSlider.clockwise = YES;
    _bassSlider.type = 0;
    [_bassSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_01"]];
    [_bassSlider setThumbWidth:80];
    CGPoint start = CGPointMake(200, 100);
    CGPoint end = CGPointMake(0, 100);
    
    [_bassSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start andEndPoint:end];
    [_bassSlider addTarget:self action:@selector(handleBassValue:) forControlEvents:UIControlEventValueChanged];
    
    bassCircleImv = [[UIImageView alloc] initWithFrame:CGRectMake(6, 16+kCircle_h, min_w-6*2.0, min_w-6*2.0)];
    bassCircleImv.image = [UIImage imageNamed:@"Theme.bundle/eq_bg_circle"];
    bassCircleImv.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:bassCircleImv];
    
    _bassLabel = [[UILabel alloc] init];
    [_bassLabel setFrame:CGRectMake(bassCircleImv.frame.size.width/2-50/2, bassCircleImv.frame.size.height/2-50/2, 50, 50)];
    [_bassLabel setTextAlignment:NSTextAlignmentCenter];
    [_bassLabel setBackgroundColor:[UIColor clearColor]];
    [_bassLabel  setTextColor:[UIColor blackColor]];
    [_bassLabel setFont:FontMedium(16.f)];
    [bassCircleImv addSubview:_bassLabel];
    
    bassLow = [[UIImageView alloc] initWithFrame:CGRectMake(15, min_w+10.0+kCircle_h, 10.0, 10.0)];
    bassLow.image = [UIImage imageNamed:@"Theme.bundle/mul_reduce"];
    bassLow.contentMode = UIViewContentModeCenter;
    [self addSubview:bassLow];
    
    bassHigh = [[UIImageView alloc] initWithFrame:CGRectMake(min_w-38.0+kCircle_h, min_w+10.0+kCircle_h, 10.0, 10.0)];
    bassHigh.image = [UIImage imageNamed:@"Theme.bundle/mul_plus"];
    bassHigh.contentMode = UIViewContentModeCenter;
    [self addSubview:bassHigh];
    
    bassLabelStr = [[UILabel alloc] init];
    bassLabelStr.frame = CGRectMake(bassCircleImv.frame.size.width/2-40, min_w+30.0+kCircle_h,80,40);
    bassLabelStr.numberOfLines = 0;
    bassLabelStr.textAlignment = NSTextAlignmentCenter;
    [self addSubview:bassLabelStr];
    
    NSMutableAttributedString *bassLabelString = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("volume_bass") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    
    bassLabelStr.attributedText = bassLabelString;
    
    
    //主音量
    _volSlider = [[IACircularSlider alloc] initWithFrame:CGRectMake(sW/2.0-max_w/2.0, 0+kCircle_h, max_w, max_w)];
    [self addSubview:_volSlider];
    
    _volSlider.trackHighlightedTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _volSlider.thumbTintColor = [UIColor whiteColor];
    _volSlider.trackTintColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
    _volSlider.thumbHighlightedTintColor = [UIColor whiteColor];
    _volSlider.trackWidth = 7;
    _volSlider.thumbWidth = 25;
    _volSlider.minimumValue = 0;
        
    
    if (bleSDK.mBleEntityM.mType == JL_DeviceTypeTWS) { //耳机
        _volSlider.maximumValue = 16;
    }else{
        JLModel_Device *devel = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if(devel.karaokeEQType == JL_KaraokeEQTypeYES){
            if(devel) _volSlider.maximumValue = 1;
        }
        if(devel.karaokeEQType == JL_KaraokeEQTypeNO){
            if(devel.maxVol==0){
                if(devel) _volSlider.maximumValue = 31;
            }else{
                if(devel) _volSlider.maximumValue = devel.maxVol;
            }
        }
    }
    _volSlider.startAngle = 0.7*M_PI;
    _volSlider.endAngle = 0.3*M_PI;
    _volSlider.clockwise = YES;
    _volSlider.type = 0;
    [_volSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_02"]];
    [_volSlider setThumbWidth:80];
    CGPoint start_vol = CGPointMake(200, 100);
    CGPoint end_vol = CGPointMake(0, 100);
    
    [_volSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start_vol andEndPoint:end_vol];
    [_volSlider addTarget:self action:@selector(hanbleVolValue:) forControlEvents:UIControlEventValueChanged];
    
    volCircleImv = [[UIImageView alloc] initWithFrame:CGRectMake(sW/2.0-(max_w-17)/2.0, 17/2.0+kCircle_h, max_w-17.0, max_w-17.0)];
    volCircleImv.image = [UIImage imageNamed:@"Theme.bundle/eq_bg_circle"];
    volCircleImv.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:volCircleImv];
    
    _volLabel = [[UILabel alloc] init];
    [_volLabel setFrame:CGRectMake(volCircleImv.frame.size.width/2-50/2, volCircleImv.frame.size.height/2-50/2, 50, 50)];
    [_volLabel setTextAlignment:NSTextAlignmentCenter];
    [_volLabel setBackgroundColor:[UIColor clearColor]];
    [_volLabel  setTextColor:[UIColor blackColor]];
    [_volLabel setFont:FontMedium(16.f)];
    [volCircleImv addSubview:_volLabel];
    
    volLow = [[UIImageView alloc] initWithFrame:CGRectMake(sW/2.0-(max_w-17)/2.0+10, max_w+kCircle_h, 10.0, 10.0)];
    volLow.image = [UIImage imageNamed:@"Theme.bundle/mul_reduce"];
    volLow.contentMode = UIViewContentModeCenter;
    [self addSubview:volLow];
    
    volHigh = [[UIImageView alloc] initWithFrame:CGRectMake(sW/2.0+(max_w)/2.0-30.0, max_w+kCircle_h, 10.0, 10.0)];
    volHigh.image = [UIImage imageNamed:@"Theme.bundle/mul_plus"];
    volHigh.contentMode = UIViewContentModeCenter;
    [self addSubview:volHigh];
    
    volLabelStr = [[UILabel alloc] init];
    volLabelStr.frame = CGRectMake(volCircleImv.frame.origin.x+volCircleImv.frame.size.width/2-21-20, min_w+30.0+kCircle_h,80,40);
    volLabelStr.numberOfLines = 0;
    [self addSubview:volLabelStr];
    
    NSMutableAttributedString *volLabelString = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("volume_main") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    volLabelStr.textAlignment = NSTextAlignmentCenter;
    volLabelStr.attributedText = volLabelString;
    volLabelStr.adjustsFontSizeToFitWidth = YES;
    
    
    //高音
    _trebleSlider = [[IACircularSlider alloc] initWithFrame:CGRectMake(sW-min_w, 10+kCircle_h, min_w, min_w)];
    [self addSubview:_trebleSlider];
    
    _trebleSlider.trackHighlightedTintColor = [UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0];
    _trebleSlider.thumbTintColor = [UIColor whiteColor];
    _trebleSlider.trackTintColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
    _trebleSlider.thumbHighlightedTintColor = [UIColor whiteColor];
    _trebleSlider.trackWidth = 7;
    _trebleSlider.thumbWidth = 25;
    _trebleSlider.minimumValue = -12;
    _trebleSlider.maximumValue = +12;
    _trebleSlider.startAngle = 0.7*M_PI;
    _trebleSlider.endAngle = 0.3*M_PI;
    _trebleSlider.clockwise = YES;
    _trebleSlider.type = 0;
    [_trebleSlider setThumbImage:[UIImage imageNamed:@"Theme.bundle/eq_slider_01"]];
    [_trebleSlider setThumbWidth:80];
    CGPoint start_treble = CGPointMake(200, 100);
    CGPoint end_treble = CGPointMake(0, 100);
    
    [_trebleSlider setGradientColorForHighlightedTrackWithFirstColor:kColor_0001 secondColor:kColor_0002 colorsLocations:CGPointMake(0.3, 1.0) startPoint:start_treble andEndPoint:end_treble];
    [_trebleSlider addTarget:self action:@selector(handleTrebleValue:) forControlEvents:UIControlEventValueChanged];
    
    trebleCircleImv = [[UIImageView alloc] initWithFrame:CGRectMake(sW-min_w+6, 16+kCircle_h, min_w-6*2.0, min_w-6*2.0)];
    trebleCircleImv.image = [UIImage imageNamed:@"Theme.bundle/eq_bg_circle"];
    trebleCircleImv.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:trebleCircleImv];
    
    _trebleLabel = [[UILabel alloc] init];
    [_trebleLabel setFrame:CGRectMake(trebleCircleImv.frame.size.width/2-50/2, trebleCircleImv.frame.size.height/2-50/2, 50, 50)];
    [_trebleLabel setTextAlignment:NSTextAlignmentCenter];
    [_trebleLabel setBackgroundColor:[UIColor clearColor]];
    [_trebleLabel  setTextColor:[UIColor blackColor]];
    [_trebleLabel setFont:FontMedium(16.f)];
    [trebleCircleImv addSubview:_trebleLabel];
    
    trebleLow = [[UIImageView alloc] initWithFrame:CGRectMake(sW-min_w+15.0, min_w+10.0+kCircle_h, 10.0, 10.0)];
    trebleLow.image = [UIImage imageNamed:@"Theme.bundle/mul_reduce"];
    trebleLow.contentMode = UIViewContentModeCenter;
    [self addSubview:trebleLow];
    
    trebleHigh = [[UIImageView alloc] initWithFrame:CGRectMake(sW-25.0, min_w+10.0+kCircle_h, 10.0, 10.0)];
    trebleHigh.image = [UIImage imageNamed:@"Theme.bundle/mul_plus"];
    trebleHigh.contentMode = UIViewContentModeCenter;
    [self addSubview:trebleHigh];
    
    trebleLabelStr = [[UILabel alloc] init];
   
    trebleLabelStr.frame = CGRectMake(trebleCircleImv.frame.origin.x+trebleCircleImv.frame.size.width/2-12-25, min_w+30.0+kCircle_h,80,40);
    trebleLabelStr.numberOfLines = 0;
    trebleLabelStr.textAlignment = NSTextAlignmentCenter;
    [self addSubview:trebleLabelStr];
    
    NSMutableAttributedString *trebleLabelString = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("volume_height") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    
    trebleLabelStr.attributedText = trebleLabelString;
    
    self.max_h = CGRectGetMaxY(volLabelStr.frame);
    
    [self updateFirstVol];
}

#pragma mark 设置低音
-(void)handleBassValue:(IACircularSlider*)slider{
    clickFlag = 0;
    NSString *bassStr = [NSString stringWithFormat:@"%.00f", slider.value];
    if(![bassStr isEqualToString:@"-0"]){
        _bassLabel.text = bassStr;
    }
}

#pragma mark 设置主音量
-(void)hanbleVolValue:(IACircularSlider*)slider{
    clickFlag = 1;
    _volLabel.text = [NSString stringWithFormat:@"%.00f", slider.value];

    if (bleSDK.mBleEntityM.mType == JL_DeviceTypeTWS) { //耳机
        // 获取系统音量
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        
        UISlider *volumeViewSlider= nil;
        
        for (UIView *view in [volumeView subviews]){
            
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                
                volumeViewSlider = (UISlider*)view;
                
                break;
            }
        }
        float val = (slider.value/16);
        [self setVolume:val];
    }else{  //音箱
        
        cVol = slider.value;
        self->_volSlider.value = cVol;
        self->_volLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)cVol];
        
        [[JLCacheBox cacheUuid:bleUUID] setP_Cvol:cVol];
    }
}

#pragma mark 设置高音
-(void)handleTrebleValue:(IACircularSlider*)slider{
    clickFlag = 2;
    NSString *trebleStr = [NSString stringWithFormat:@"%.00f", slider.value];
    if(![trebleStr isEqualToString:@"-0"]){
        _trebleLabel.text = trebleStr;
    }
}

/*
 * 设置音量
 */
- (void)setVolume:(float)value {
    
    UISlider *volumeSlider = [self volumeSlider];
    self.volumeView.showsRouteButton = YES;
    self.volumeView.showsVolumeSlider = YES;
    [self.volumeView sizeToFit];
    [self.volumeView setFrame:CGRectMake(-1000, -1000, 10, 10)];
    [volumeSlider setValue:value animated:NO];
}

- (MPVolumeView *)volumeView {
    if (!volumeView) {
        volumeView = [[MPVolumeView alloc] init];
        volumeView.hidden = NO;
        [self addSubview:volumeView];
    }
    return volumeView;
}
/*
 * 遍历控件，拿到UISlider
 */
- (UISlider *)volumeSlider {
    UISlider* volumeSlider = nil;
    for (UIView *view in [self.volumeView subviews]) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeSlider = (UISlider *)view;
            break;
        }
    }
    return volumeSlider;
}

#pragma 手势抬起事件
-(void)endTouch{
    [JL_Tools mainTask:^{
        
        if(self->clickFlag ==0 ||self->clickFlag ==2){ //高低音
            [self->bleSDK.mBleEntityM.mCmdManager.mChargingBinManager cmdSetLowPitch:[self->_bassLabel.text intValue]
                                                       HighPitch:[self->_trebleLabel.text intValue]];
        }
        if (self->bleSDK.mBleEntityM.mType != JL_DeviceTypeTWS && self->clickFlag == 1) { //音箱主音量
            [self->bleSDK.mBleEntityM.mCmdManager.mSystemVolume cmdSetSystemVolume:self->cVol
                                                                            Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                
                JL_CMDStatus state = status;
                if(state == JL_CMDStatusFail){
                     //[DFUITools showText:kJL_TXT("settings_failed") onView:self delay:1.0];
                }
            }];
            [[JLCacheBox cacheUuid:self->bleUUID] setP_Cvol:self->cVol];
        }
    }];
}


#pragma mark 更新音量
-(void)updateFirstVol{
    
    if (self->bleSDK.mBleEntityM.mType == JL_DeviceTypeTWS) { //耳机
        self->_volSlider.value = (16*[[AVAudioSession sharedInstance] outputVolume]);
        self->_volLabel.text = [NSString stringWithFormat:@"%.00f", self->_volSlider.value];
    }else{  //音箱
        NSInteger cvol = [[JLCacheBox cacheUuid:self->bleUUID] P_Cvol];
        self->_volSlider.value = cvol;
        self->_volLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)cvol];
    }
    
}

-(void)getMaxVol:(NSNotification *)note{

    if (self->bleSDK.mBleEntityM.mType == JL_DeviceTypeTWS) { //耳机
        _volSlider.maximumValue = 16;
    }else{
        JLModel_Device *devel = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if(devel.karaokeEQType == JL_KaraokeEQTypeYES){
            if(devel) _volSlider.maximumValue = 1;
        }
        if(devel.karaokeEQType == JL_KaraokeEQTypeNO){
            if(devel) _volSlider.maximumValue = devel.maxVol;
        }
    }
    
    [self updateFirstVol];
}

-(void)handleCall{
    callCenter = [[CTCallCenter alloc] init];
    callCenter.callEventHandler = ^(CTCall * call) {
        if ([call.callState isEqualToString:CTCallStateDisconnected]) {// Call has been disconnected
            //kJLLog(JLLOG_DEBUG,@"电话 --- 断开连接");
            [[JLCacheBox cacheUuid:self->bleUUID] setCallPhoneFlag:NO];
        }
        else if ([call.callState isEqualToString:CTCallStateConnected]) {// Call has just been connected
            //kJLLog(JLLOG_DEBUG,@"电话 --- 接通");
            [[JLCacheBox cacheUuid:self->bleUUID] setCallPhoneFlag:YES];
        }
        else if ([call.callState isEqualToString:CTCallStateIncoming]) {// Call is incoming
            //kJLLog(JLLOG_DEBUG,@"电话 --- 待接通");
            [[JLCacheBox cacheUuid:self->bleUUID] setCallPhoneFlag:YES];
        }
        else if ([call.callState isEqualToString:CTCallStateDialing]) {// Call is Dialing
            //kJLLog(JLLOG_DEBUG,@"电话 --- 拨号中");
            [[JLCacheBox cacheUuid:self->bleUUID] setCallPhoneFlag:YES];
        }
    };
}
-(void)noteSystemInfo:(NSNotification*)note{
    BOOL isOK = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOK == NO) return;
    
    if (bleSDK.mBleEntityM.mType != JL_DeviceTypeTWS) { //音箱
        
        JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if(model){
            //设备音量
            [[JLCacheBox cacheUuid:self->bleUUID] setP_Cvol:model.currentVol];
            [[JLCacheBox cacheUuid:self->bleUUID] setP_Mvol:model.maxVol];
            
            self->_volSlider.value = model.currentVol;
            self->_volLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.currentVol];
        }
        
    }
}

-(void)deviceChangeNote:(NSNotification *)note{
    JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    if(model){
        if (bleSDK.mBleEntityM.mType != JL_DeviceTypeTWS) { //音箱
            
            //设备音量
            [[JLCacheBox cacheUuid:self->bleUUID] setP_Cvol:model.currentVol];
            [[JLCacheBox cacheUuid:self->bleUUID] setP_Mvol:model.maxVol];
            
            self->_volSlider.value = model.currentVol;
            self->_volLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.currentVol];
            
        }
        [self getMaxVol:nil];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_EFCIRCULAR_END_TOUCH Action:@selector(endTouch) Own:self];
   
    [JL_Tools add:kJL_MANAGER_SYSTEM_INFO Action:@selector(noteSystemInfo:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(deviceChangeNote:) Own:self];
    [self listenSystemVolume];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume"];
}

- (void)languageChange {
    
    NSMutableAttributedString *bassLabelString = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("volume_bass") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    
    bassLabelStr.attributedText = bassLabelString;
    
    NSMutableAttributedString *volLabelString = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("volume_main") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    
    volLabelStr.attributedText = volLabelString;
    
    NSMutableAttributedString *trebleLabelString = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("volume_height") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1.0]}];
    
    trebleLabelStr.attributedText = trebleLabelString;
}


-(void)listenSystemVolume{
    [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew context:nil];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if (bleSDK.mBleEntityM.mType == JL_DeviceTypeTWS) { //耳机
        float val = [change[@"new"] floatValue];
        _volSlider.value = val*16;
        _volLabel.text = [NSString stringWithFormat:@"%.00f", val*16];
    }
    
}


@end
