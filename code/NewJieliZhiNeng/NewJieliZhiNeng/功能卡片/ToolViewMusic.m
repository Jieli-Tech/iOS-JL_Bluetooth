//
//  ToolViewMusic.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "ToolViewMusic.h"
#import "JLUI_Effect.h"
#import "JLUI_Cache.h"
#import "JL_RunSDK.h"
#import "NetworkPlayer.h"

typedef void(^ID3_ACTION)(void);

typedef enum : NSUInteger {
    MusicModeLoopAll,
    MusicModeLoopDevice,
    MusicModeLoopOne,
    MusicModeRandomDevice,
    MusicModeLoopFolder,
} DEV_MODE;

@interface ToolViewMusic(){
    
    __weak IBOutlet UIView *subView;
    __weak IBOutlet UIButton *btnMode;
    __weak IBOutlet UIButton *btnLast;
    __weak IBOutlet UIButton *btnPP;
    __weak IBOutlet UIButton *btnNext;
    __weak IBOutlet UIButton *btnList;
    __weak IBOutlet UILabel *lbID3;
    
    //本地音乐
    NSString            *time_start;
    NSString            *time_end;
    double              progress_local;
    DFAudioPlayer_MODE  local_mode;
    DEV_MODE            dev_Mode;
    
    JL_RunSDK           *bleSDK;
}
@end

@implementation ToolViewMusic

- (instancetype)init
{
    self = [DFUITools loadNib:@"ToolViewMusic"];
    if (self) {
        bleSDK = [JL_RunSDK sharedMe];
        
        float sW = [UIScreen mainScreen].bounds.size.width;
        self.frame = CGRectMake(0, kJL_HeightStatusBar+44, sW, 200);
        [JLUI_Effect addShadowOnView:subView];
        
        float gap = (sW-28)/6.0;
        float btn_y = self.frame.size.height-60.0;
        btnMode.center = CGPointMake(gap*0.7,btn_y);
        btnLast.center = CGPointMake(gap*1.8,btn_y);
        btnNext.center = CGPointMake(gap*4.2,btn_y);
        btnList.center = CGPointMake(gap*5.3,btn_y);
        
        UIImage *image = [UIImage imageNamed:@"Theme.bundle/mul_slider"];
        [self.mProgressView setThumbImage:image forState:UIControlStateNormal];
        [self.mProgressView setThumbImage:image forState:UIControlStateHighlighted];
        [self.mProgressView setMinimumTrackTintColor:kColor_0000];

        CGRect rect_lb_0 = CGRectMake(50, 10, sW-128, 18);
        self.mSonyName_0 = [[DFLabel alloc] initWithFrame:rect_lb_0];
        self.mSonyName_0.textColor = [UIColor blackColor];
        self.mSonyName_0.font = [UIFont systemFontOfSize:13.0];
        self.mSonyName_0.labelType = DFLeftRight;
        self.mSonyName_0.textAlignment = NSTextAlignmentCenter;
        [subView addSubview:self.mSonyName_0];
        
        CGRect rect_lb_1 = CGRectMake(50, 32, sW-128, 20);
        self.mSonyName_1 = [[DFLabel alloc] initWithFrame:rect_lb_1];
        self.mSonyName_1.textColor = [UIColor blackColor];
        self.mSonyName_1.font = [UIFont systemFontOfSize:13.0];
        self.mSonyName_1.labelType = DFLeftRight;
        self.mSonyName_1.textAlignment = NSTextAlignmentCenter;
        [subView addSubview:self.mSonyName_1];
        
        CGRect rect_lb_2 = CGRectMake(50, 57, sW-128, 18);
        self.mSonyName_2 = [[DFLabel alloc] initWithFrame:rect_lb_2];
        self.mSonyName_2.textColor = [UIColor blackColor];
        self.mSonyName_2.animationDelay = 1.0;
        self.mSonyName_2.font = [UIFont systemFontOfSize:13.0];
        self.mSonyName_2.labelType = DFLeftRight;
        self.mSonyName_2.textAlignment = NSTextAlignmentCenter;
        [subView addSubview:self.mSonyName_2];
        

        [self showID3UI:NO];

        
        [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_ST:NO];
        [self addNote];
        
        [JL_Tools delay:0.5 Task:^{
            [self updateFirstUI];
        }];
    }
    return self;
}


-(void)showID3UI:(BOOL)isShow{
    if (isShow) {
        self->lbID3.hidden = NO;
        self->btnMode.hidden = YES;
        self->btnList.hidden = YES;
        self.mSonyName_0.hidden = NO;
        self.mSonyName_1.hidden = NO;
        self.mSonyName_2.hidden = NO;
        self.mSonyName_1.font = [UIFont systemFontOfSize:13.0];
        [JL_Tools post:@"kUI_FUNCTION_ACTION" Object:@(0)];
    }else{
        self->lbID3.hidden = YES;
        self->btnMode.hidden = NO;
        self->btnList.hidden = NO;
        self.mSonyName_0.hidden = YES;
        self.mSonyName_1.hidden = NO;
        self.mSonyName_2.hidden = YES;
        self.mSonyName_1.font = [UIFont systemFontOfSize:17.0];
    }
}

-(void)updateFirstUI{
    NSLog(@"----------------------> updateFirstUI");
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeBT){
        [DFAction timingStop:myTimer];
        [self updatePhoneMusicInfo];
    }
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        isMusicInfo = YES;
        [self.mProgressView setUserInteractionEnabled:YES];
        [self updateDeviceState];
    }
}


-(void)noteFirstUpdateCardMusicInfo:(NSNotification*)note{
    NSLog(@"---> Note First Update CardMusic Info.");
    [DFAction mainTask:^{
        isMusicInfo = YES;
        [self.mProgressView setUserInteractionEnabled:YES];
        [self updateDeviceState];
    }];
}



#pragma mark 选择音乐类型
static BOOL isMusicInfo = YES;
-(void)chooseDiffMusic{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeBT){
        [DFAction timingStop:myTimer];
        DFAudioPlayer *player = [DFAudioPlayer sharedMe];
        if (player.mState == DFAudioPlayer_PLAYING) {
            [self updatePhoneMusicInfo];
        }
    }
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        
        BOOL isOK =  [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isLoadMusicInfo];
        if (isOK == NO) {
            NSLog(@"连接中...暂不获取获取音乐信息.");
            return;
        }
        
        if (isMusicInfo == NO) return;
        [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeMUSIC
                        SelectionBit:0xffffffff
                              Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data)
        {
            [DFAction mainTask:^{
                isMusicInfo = YES;
                [self.mProgressView setUserInteractionEnabled:YES];
                [self updateDeviceState];
            }];
        }];
    }
}





#pragma mark 获取手机音乐的开始时间、总时间、进度条的值

-(void)notePlayerProgress:(NSNotification*)note{
    NSDictionary *dict = [note object];
    time_start = dict[@"TIME_NOW"];
    time_end = dict[@"TIME_END"];
    progress_local = [dict[@"PROGRESS"] doubleValue];
    
    //处理最后一首歌,在顺序播放模式下，拖动进度条，改变播放状态的逻辑。
    DFAudioPlayer *currentPlayer = [DFAudioPlayer currentPlayer];
    if(currentPlayer.mMode == DFAudioPlayer_ROUND &&
       currentPlayer.mType == DFAudioPlayer_TYPE_NET
       && currentPlayer.mState==DFAudioPlayer_STOP){
        if(progress_local < 0.95f)[currentPlayer setMState:DFAudioPlayer_PAUSE];
    }
    [self update_progress];
    [self updatePhoneMusicInfo];
    
    
    BOOL isIpodInfo = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isLoadIpodInfo];
    if (isIpodInfo == YES) {
        [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsLoadIpodInfo:NO];
        return;
    }
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    BOOL isID3_push = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_PUSH];
    if (isID3_push == YES) {
        NSLog(@"UI关闭ID3信息。100");
        [entity.mCmdManager.mChargingBinManager cmdID3_PushEnable:NO];
        [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PUSH:NO];
        [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_ST:NO];
        [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PLAY:NO];
        [self showID3UI:NO];
    }
}

#pragma mark 监听手机音乐的开始时间、总时间、进度条的值
-(void)update_progress{
    [DFAction mainTask:^{
        self->_mTimeStart.text = self->time_start;
        self->_mTimeEnd.text = self->time_end;
        self->_mProgressView.value = self->progress_local;
    }];
}


#pragma mark 手机音乐赋值
-(void)updatePhoneMusicInfo{
    
    [self showID3UI:NO];
    
    DFAudioPlayer *nowPlayer = [DFAudioPlayer currentPlayer];
    local_mode = nowPlayer.mMode;
    
    if (nowPlayer.mList.count == 0 ) {
        [self.mProgressView setUserInteractionEnabled:NO];
    }else{
        [self.mProgressView setUserInteractionEnabled:YES];
    }
    
    /*--- 进度跟新 ---*/
    [self update_progress];
    
    /*--- PP Btn ---*/
    local_mode = nowPlayer.mMode;
    
    BOOL isID3_ST = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_ST];
    if (isID3_ST == NO) {
        /*--- PP Btn ---*/
        if (nowPlayer.mState == DFAudioPlayer_PLAYING) {
            [DFUITools setButton:btnPP Image:@"Theme.bundle/mul_icon_pause_nor"];
        }else{
            [DFUITools setButton:btnPP Image:@"Theme.bundle/mul_icon_play_nor"];
        }
    }
    
    
    /*--- Mode Btn ---*/
    DFAudioPlayer_MODE mode = nowPlayer.mMode;
    if (mode == DFAudioPlayer_ALL_LOOP){
        [DFUITools setButton:btnMode Image:@"Theme.bundle/mul_icon_circlelist_nor"];
    }
    if (mode == DFAudioPlayer_ONE_LOOP) {
        [DFUITools setButton:btnMode Image:@"Theme.bundle/mul_icon_circle_nor"];
    }
    if (mode == DFAudioPlayer_RANDOM) {
        [DFUITools setButton:btnMode Image:@"Theme.bundle/mul_icon_random_nor"];
    }
    if (mode == DFAudioPlayer_ROUND) {
        [DFUITools setButton:btnMode Image:@"Theme.bundle/mul_icon_sequential_nor"];
    }
    
    /*--- Song name ---*/
    _mSonyName_1.text = nowPlayer.mNowItem.mTitle;
}

#pragma mark 更新手机音乐的状态
-(void)notePlayerState:(NSNotification*)note{
    [DFAction mainTask:^{
        /*---- 为了解决ID3信息混乱 ----*/
//        DFAudioPlayer *player = [DFAudioPlayer sharedMe];
//        if (player.mState == DFAudioPlayer_PLAYING) {
//            type_id3_1 = 0;
//            type_id3_2 = 0;
//            type_id3_3 = 0;
//            id3_time = 0;
//        }
        [self updatePhoneMusicInfo];
    }];
}



#pragma mark 设备音乐赋值
-(void)updateDeviceMusicInfo{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
        
    /*--- 播放模式 ---*/
    UInt8 plcu= model.playMode;
    [self updatePlayModeUI:plcu];
    if(model.fileName.length>0){
        /*--- 歌曲名字 ---*/
        self->_mSonyName_1.text = model.fileName;
    }
        
    /*--- 播放状态 ---*/
    [self updatePlayStatusUI:model.playStatus];
}

-(void)updatePlayStatusUI:(UInt8)play_st{
    /*--- 播放 ---*/
    if (play_st == JL_MusicStatusPlay) {
        [DFUITools setButton:btnPP Image:@"Theme.bundle/mul_icon_pause_nor"];
        [DFAction timingContinue:myTimer];
    }else{
        /*--- 暂停 ---*/
        [DFUITools setButton:btnPP Image:@"Theme.bundle/mul_icon_play_nor"];
        [DFAction timingPause:myTimer];
    }
}

-(void)updatePlayModeUI:(UInt8)plcu
{
    dev_Mode = MusicModeLoopAll;
    if (plcu == 0x01) dev_Mode = MusicModeLoopAll;
    if (plcu == 0x02) dev_Mode = MusicModeLoopDevice;
    if (plcu == 0x03) dev_Mode = MusicModeLoopOne;
    if (plcu == 0x04) dev_Mode = MusicModeRandomDevice;
    if (plcu == 0x05) dev_Mode = MusicModeLoopFolder;
    [self setDevMusicMode:dev_Mode];
}

-(void)setDevMusicMode:(DEV_MODE)mode{
    if (mode == MusicModeLoopAll) {
        [DFUITools setButton:btnMode Image:@"Theme.bundle/mul_icon_circlelist_nor"];
    }
    if (mode == MusicModeLoopDevice) {
        [DFUITools setButton:btnMode Image:@"Theme.bundle/mul_icon_sdlist_nor"];
    }
    if (mode == MusicModeLoopOne) {
        [DFUITools setButton:btnMode Image:@"Theme.bundle/mul_icon_circle_nor"];
    }
    if (mode == MusicModeRandomDevice) {
        [DFUITools setButton:btnMode Image:@"Theme.bundle/mul_icon_random_nor"];
    }
    if (mode == MusicModeLoopFolder) {
        [DFUITools setButton:btnMode Image:@"Theme.bundle/mul_icon_filelist_nor"];
    }
}

- (IBAction)actionMode:(id)sender {
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeBT){
        BOOL isEdr = [self isEdrOK];
        if (isEdr == NO) return;
        
        DFAudioPlayer *nowPlayer = [DFAudioPlayer currentPlayer];
        local_mode++;
        if (local_mode > DFAudioPlayer_ROUND) {
            local_mode = DFAudioPlayer_ALL_LOOP;
        }
        [nowPlayer setMMode:local_mode];
        [self updatePhoneMusicInfo];
    }
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        UInt8 plcu= model.playMode;
        
        /*--- 切换【全部循环】 ---*/
        if (plcu == JL_MusicModeLoopAll) {
            [entity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                            Command:JL_FCmdMusicMODE
                             Extend:JL_MusicModeLoopAll
                             Result:nil];
            return;
        }
        
        /*--- 切换【单设备循环】 ---*/
        if (plcu == JL_MusicModeLoopDevice) {
            [entity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                            Command:JL_FCmdMusicMODE
                             Extend:JL_MusicModeLoopDevice
                             Result:nil];
            return;
        }
        
        /*--- 切换【单曲循环】 ---*/
        if (plcu == JL_MusicModeLoopOne) {
            [entity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                            Command:JL_FCmdMusicMODE
                             Extend:JL_MusicModeLoopOne
                             Result:nil];
            return;
        }
        /*--- 切换【单设备随机】 ---*/
        if (plcu == JL_MusicModeRandomDevice) {
            [entity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                            Command:JL_FCmdMusicMODE
                             Extend:JL_MusicModeRandomDevice
                             Result:nil];
            return;
        }
        /*--- 切换【文件夹循环】 ---*/
        if (plcu == JL_MusicModeLoopFolder) {
            [entity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                            Command:JL_FCmdMusicMODE
                             Extend:JL_MusicModeLoopFolder
                             Result:nil];
            return;
        }
    }
}

-(void)setID3_Enable:(BOOL)enable Action:(ID3_ACTION)action{
    BOOL isID3_push = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_PUSH];
    if (isID3_push == !enable) {
        [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PUSH:enable];
        if (enable) {
            NSLog(@"UI开启ID3信息。22");
        }else{
            NSLog(@"UI关闭ID3信息。22");
        }
        if (action) { action();}
        [DFAction delay:0.3 Task:^{
            [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mChargingBinManager cmdID3_PushEnable:enable];
        }];
    }else{
        if (action) { action();}
    }
}

- (IBAction)actionLast:(id)sender {
    
    /*--- 关闭网络电台 ---*/
    [[NetworkPlayer sharedMe] didStop];
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeBT){
        BOOL isEdr = [self isEdrOK];
        if (isEdr == NO) return;
        
        BOOL isID3_ST = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_ST];
        if (isID3_ST == NO) {
            isWaitPuase = NO;
            [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PLAY:NO];
            
            __weak typeof(self) wSelf = self;
            DFAudioPlayer *nowPlayer = [DFAudioPlayer currentPlayer];
            [self setID3_Enable:NO Action:^{
                [nowPlayer didBefore];
                [wSelf updatePhoneMusicInfo];
            }];
        }else{
            isWaitCutSong = YES;
            [entity.mCmdManager.mChargingBinManager cmdID3_Before];
        }
    }
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        [entity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                        Command:JL_FCmdMusicPREV
                         Extend:0x00
                         Result:nil];
    }
}


-(BOOL)isEdrOK{
    /*--- 判断有无连经典蓝牙 ---*/
    NSDictionary *info = [JL_BLEMultiple outputEdrInfo];
    NSString *addr = info[@"ADDRESS"];
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    if (![addr isEqualToString:entity.mEdr]) {
        UIWindow *win = [DFUITools getWindow];
        [DFUITools showText:kJL_TXT("connect_match_edr") onView:win delay:1.0];
        return NO;
    }
    return YES;
}


static BOOL isWaitPuase = NO;
static BOOL isWaitCutSong = NO;
- (IBAction)actionPP:(id)sender {

    /*--- 关闭网络电台 ---*/
    [[NetworkPlayer sharedMe] didStop];
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeBT){
        [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsTFType:NO];
        BOOL isEdr = [self isEdrOK];
        if (isEdr == NO) return;
        
        BOOL isID3_ST = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_ST];
        if (isID3_ST == NO) {
            __weak typeof(self) wSelf = self;
            DFAudioPlayer *nowPlayer = [DFAudioPlayer currentPlayer];
            
            if (nowPlayer.mState == DFAudioPlayer_PLAYING ||
                nowPlayer.mState == DFAudioPlayer_PENDING)
            {
                [nowPlayer didPause];
                [wSelf updatePhoneMusicInfo];
                
                [entity.mCmdManager.mChargingBinManager cmdID3_PushEnable:YES];
                isWaitPuase = YES;
                
            }else{
                isWaitPuase = NO;
                
                NSUInteger maxVol = model.maxVol;
                if (maxVol == 0) maxVol = 25;
                float val = (((float)model.currentVol)/((float)maxVol));
                

                if(local_mode == DFAudioPlayer_ROUND &&
                    nowPlayer.mType == DFAudioPlayer_TYPE_NET &&
                    nowPlayer.mState== DFAudioPlayer_STOP){
                    
                    
                    [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PLAY:NO];
                    
                    [self setID3_Enable:NO Action:^{
                        [nowPlayer didRepeat];
                        [wSelf updatePhoneMusicInfo];
                    }];
                }else{
                    [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PLAY:NO];

                    [self setID3_Enable:NO Action:^{
                        /*--- 耳机用系统音量 ---*/
                        if (entity.mType != JL_DeviceTypeTWS ) {
                            NSLog(@"------------------------> %.1f",val);
                            nowPlayer.mPlayer.volume = val;
                        }else{
                            nowPlayer.mPlayer.volume = [DFAudioPlayer getPhoneVolume];
                        }
                        [nowPlayer didContinue];
                        [wSelf updatePhoneMusicInfo];
                    }];
                }
            }
        }else{
            /*--- 提前更新ID3 PP按钮图标 ---*/
            if (model.ID3_Status == 1) { //播放
                [entity.mCmdManager.mChargingBinManager setID3_Status:1];
            }else{ //暂停
                [entity.mCmdManager.mChargingBinManager setID3_Status:0];
            }
            [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PLAY:YES];

            [entity.mCmdManager.mChargingBinManager cmdID3_PP];
        }
    }
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        self->btnPP.userInteractionEnabled = YES;
    
        UInt8 pl = model.playStatus;
        if (pl == JL_MusicStatusPlay) {
            //[DFUITools setButton:btnPP Image:@"Theme.bundle/mul_icon_play_nor"];
            [entity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                                    Command:JL_FCmdMusicPP
                                     Extend:JL_MusicStatusPause
                                     Result:nil];
        }else{
            //[DFUITools setButton:btnPP Image:@"Theme.bundle/mul_icon_pause_nor"];
            [entity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                                    Command:JL_FCmdMusicPP
                                     Extend:JL_MusicStatusPlay
                                     Result:nil];
        }
    }
}
-(void)noteNetPlayerPause:(NSNotification*)note{
    [self updatePhoneMusicInfo];
    [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mChargingBinManager cmdID3_PushEnable:YES];
    isWaitPuase = YES;
}




- (IBAction)actionNext:(id)sender {
    
    /*--- 关闭网络电台 ---*/
    [[NetworkPlayer sharedMe] didStop];
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeBT){
        BOOL isEdr = [self isEdrOK];
        if (isEdr == NO) return;
        
        BOOL isID3_ST = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_ST];
        if (isID3_ST == NO) {
            isWaitPuase = NO;

            [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PLAY:NO];

            __weak typeof(self) wSelf = self;
            DFAudioPlayer *nowPlayer = [DFAudioPlayer currentPlayer];
            [self setID3_Enable:NO Action:^{
                [nowPlayer didNext];
                [wSelf updatePhoneMusicInfo];
            }];
        }else{
            isWaitCutSong = YES;
            [entity.mCmdManager.mChargingBinManager cmdID3_Next];
        }
    }
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        [entity.mCmdManager cmdFunction:JL_FunctionCodeMUSIC
                                Command:JL_FCmdMusicNEXT
                                 Extend:0x00
                                 Result:nil];
    }
}
- (IBAction)actionList:(id)sender {
    if ([_delegate respondsToSelector:@selector(enterList:)]) {
        [_delegate enterList:btnList];
    }
}

static NSDate *progress_date = nil;
- (IBAction)actionSongDown:(UISlider *)sender {
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        _mProgressView.userInteractionEnabled = YES;
    }else{
        _mProgressView.userInteractionEnabled = YES;
    }

    [JL_Tools post:@"MUSIC_PROGRESS_START" Object:nil];
}

-(NSTimeInterval)gapOfDateA:(NSDate*)dateA DateB:(NSDate*)dateB{
    NSTimeInterval gap = [dateA timeIntervalSinceDate:dateB];
    return gap;
}

//static int progress_sec = 0;
- (IBAction)actionSongProgress:(id)sender {
    [JL_Tools post:@"MUSIC_PROGRESS_END" Object:nil];
    
//    NSDate *date = [NSDate new];
//    NSTimeInterval time_gap = [DFTime gapOfDateA:date DateB:progress_date];
//    if (time_gap < 1.0f) {
//        NSLog(@"----> 操作过猛.");
//        return;
//    }
//    progress_date = [NSDate new];
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeBT){
        BOOL isID3_ST = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_ST];

        if (isID3_ST == NO) {
            DFAudioPlayer *nowPlayer = [DFAudioPlayer currentPlayer];
            DFAudioPlayer_TYPE tp = [DFAudioPlayer currentType];
            
            if (tp != DFAudioPlayer_TYPE_NET) {

                NSLog(@"Musci progress : %.2f",_mProgressView.value);

                float realTime = _mProgressView.value * nowPlayer.mNowItem.mTime;
                nowPlayer.mPlayer.currentTime = realTime;
                _mTimeStart.text=[self timeFormatted:realTime];
                return;
            }
        }
    }
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        NSString *songProgressStr = [NSString stringWithFormat:@"%f",_mProgressView.value];
        float pg = [songProgressStr floatValue];
        
        float f_tott = (float)sv_tott;
        float f_curt = (float)sv_curt;
        float current = (f_curt/f_tott);
                
        
        [JL_Tools mainTask:^{
            [DFAction timingStop:myTimer];
            isProgress = NO;
            [entity.mCmdManager cmdGetSystemInfoResult_1];
            
            if(pg-current<0){
                [entity.mCmdManager.mMusicControlManager cmdFastPlay:JL_FCmdMusicFastBack
                                         Second:(uint16_t)fabsf((pg * f_tott - f_curt))
                                         Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data)  {
                    //progress_sec = (int)(f_tott*pg);
                    //NSLog(@"---------------> To Progress Second: %d",progress_sec);

                    if (sv_tott > 60*60) {
                        [JL_Tools delay:0.6 Task:^{
                            NSLog(@"----> delay get music progess 0");
                            [self getDeviceMusicProgress];
                        }];
                    }else{
                        [self getDeviceMusicProgress];
                    }
                }];
            }
            if(pg-current>0){
                [entity.mCmdManager.mMusicControlManager cmdFastPlay:JL_FCmdMusicFastPlay
                                         Second:(uint16_t)(pg * f_tott - f_curt)
                                                              Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                    //progress_sec = (int)(f_tott*pg);
                    //NSLog(@"---------------> To Progress Second: %d",progress_sec);

                    if (sv_tott > 60*60) {
                        [JL_Tools delay:0.6 Task:^{
                            NSLog(@"----> delay get music progess 1");
                            [self getDeviceMusicProgress];
                        }];
                    }else{
                        [self getDeviceMusicProgress];
                    }
                }];
            }
        }];
    }
}

-(void)getDeviceMusicProgress{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeMUSIC
                            SelectionBit:0x00000001
                                  Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data)
    {
        [DFAction mainTask:^{
            isProgress = YES;
            [self updateDeviceState];
        }];
    }];
}


- (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

#pragma mark 更新设备音乐的播放时间
static uint32_t sv_tott = 0;
static uint32_t sv_curt = 0;
static BOOL isProgress = YES;
-(void)updateProgressTOTT:(uint32_t)n_tott CURT:(uint32_t)n_curt{
    if (isProgress == NO) return;
    
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];

    uint32_t tott = 0; uint32_t curt = 0;
    if (n_tott) tott = n_tott;
    if (n_curt) curt = n_curt;
    NSString *s_tott = [DFTime stringFromSec:tott];
    NSString *s_curt = [DFTime stringFromSec:curt];
    
    /*--- Song time ---*/
    _mTimeStart.text = s_curt;
    _mTimeEnd.text = s_tott;
    
    /*--- Song progress ---*/
    float f_tott = (float)tott;
    float f_curt = (float)curt;
    _mProgressView.value = (f_curt/f_tott);
    
    /*--- 暂存进度 ---*/
    sv_tott = tott;
    sv_curt = curt;
    NSLog(@"update device music -----> %d",sv_curt);
    
    //播放状态才启动自动计数
    [self startMyTimer];
    [DFAction timingPause:myTimer];
    
    if (model.playStatus == JL_MusicStatusPlay) [DFAction timingContinue:myTimer];
}
static NSTimer *myTimer = nil;
-(void)startMyTimer{
    [DFAction timingStop:myTimer];
    myTimer = nil;
    myTimer = [DFAction timingStart:@selector(timerDo)
                             target:self Time:1.0];
}

-(void)timerDo{
    sv_curt++;
    
    NSString *s_tott = [DFTime stringFromSec:sv_tott];
    NSString *s_curt = [DFTime stringFromSec:sv_curt];
    _mTimeStart.text = s_curt;
    _mTimeEnd.text = s_tott;
    //[JL_Tools post:@"CURRENT_TIME" Object:@(sv_curt)];
    
    float f_tott = (float)sv_tott;
    float f_curt = (float)sv_curt;
    //JLDeviceModel *devel = [JL_Manager outputDeviceModel];
    //if(devel.currentFunc == JL_FunctionCodeMUSIC){
        _mProgressView.value = (f_curt/f_tott);
    //}
}

#pragma mark 设备状态更新刷新界面
 
-(void)updateDeviceState{

    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if(model.currentFunc == JL_FunctionCodeBT){
        BOOL isID3_ST = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_ST];
        if (isID3_ST == NO) {
            [DFAction timingStop:myTimer];
            [self updatePhoneMusicInfo];
        }else{
            [self showID3UI:YES];
        }
    }
    if(model.currentFunc == JL_FunctionCodeMUSIC){
        [self showID3UI:NO];
        [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsTFType:YES];
        [self.mProgressView setUserInteractionEnabled:YES];
        [self updateDeviceMusicInfo];
        [self updateProgressTOTT:model.tolalTime CURT:model.currentTime];
    }
}

-(void)noteSystemInfo:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if(isOk == NO) return;
    
    [self updateDeviceState];
}


-(void)noteCardArray:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *devel = [entity.mCmdManager outputDeviceModel];
    NSArray *cardArray = devel.cardArray;
    
    if (cardArray.count == 0) {
        [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_ST:NO];
        [DFAction timingStop:myTimer];
        [self updatePhoneMusicInfo];
    }
}


-(void)updateID3MusicInfo:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    
    
    //第三方音乐，关闭设备音乐的定时器.
    [DFAction timingStop:myTimer];
    
    /*--- ID3 在BT模式生效---*/
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    uint8_t fun_current = deviceModel.currentFunc;
    if (fun_current != JL_FunctionCodeBT) return;

    BOOL isID3_first = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_FIRST];
    if (isID3_first == NO) return;
    
    BOOL isID3_push = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_PUSH];
    if (isID3_push == NO) return;
    
    
    
    [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_ST:YES];
    [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PLAY:YES];

    NSLog(@"----------> showID3UI 2222");
    [self showID3UI:YES];
    NSString *name_0 = [NSString stringWithFormat:@"%@",deviceModel.ID3_Title];
    NSString *name_1 = [NSString stringWithFormat:@"%@",deviceModel.ID3_Artist];
    NSString *name_2 = [NSString stringWithFormat:@"%@",deviceModel.ID3_AlBum];
        
    if (name_0.length > 0) _mSonyName_0.text = name_0;
    if (name_1.length > 0) _mSonyName_1.text = name_1;
    if (name_2.length > 0) _mSonyName_2.text = name_2;
    
    double a_time = ((double)deviceModel.ID3_Time);
    double c_time = ((double)deviceModel.ID3_CurrentTime)/1000.0;
    
    _mTimeStart.text = [DFTime stringFromSec:(uint32_t)c_time];
    _mTimeEnd.text = [DFTime stringFromSec:(uint32_t)a_time];
    _mProgressView.value = c_time/a_time;
}



-(void)updateID3MusicStatus:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    
    
    /*--- ID3 在BT模式生效---*/
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    uint8_t fun_current = deviceModel.currentFunc;
    if (fun_current != JL_FunctionCodeBT) return;
    
    if (isWaitPuase == YES && deviceModel.ID3_Status == 0) { //暂停
        isWaitPuase = NO;
        [DFAction delay:3.0 Task:^{
            //[self showID3UI:YES];
            //[[JLCacheBox cacheUuid:bleUUID] setIsID3_ST:YES];
            [[JLCacheBox cacheUuid:self->bleSDK.mBleUUID] setIsID3_PUSH:YES];
            [DFUITools setButton:self->btnPP Image:@"Theme.bundle/mul_icon_play_nor"];
            NSLog(@"UI开启ID3信息。88");
        }];
    }
    
    BOOL isID3_first = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_FIRST];
    if (isID3_first == NO) return;

    BOOL isID3_push = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_PUSH];
    if (isID3_push == NO) return;

    
    //NSLog(@"playStatus:%d",model.ID3_Status);
    if (deviceModel.ID3_Status == 1) { //播放
        NSLog(@"mul_icon_play_nor......3");
        [DFUITools setButton:btnPP Image:@"Theme.bundle/mul_icon_pause_nor"];
    }else{
        NSLog(@"mul_icon_pause_nor......3");
        [DFUITools setButton:btnPP Image:@"Theme.bundle/mul_icon_play_nor"];
        
        NSUInteger str_0 = deviceModel.ID3_Title.length;
        NSUInteger str_1 = deviceModel.ID3_Artist.length;
        NSUInteger str_2 = deviceModel.ID3_AlBum.length;
        int  time_0 = deviceModel.ID3_Time;
        

        /*--- 第三方音乐APP被杀 ---*/
        if ((str_0 == 0 || str_0 == 1) &&
            (str_1 == 0 || str_1 == 1) &&
            (str_2 == 0 || str_2 == 1) &&
            time_0 == 0) {
            _mSonyName_1.text = kJL_TXT("none_id3_music_data");
        }
    }
}

-(void)updateID3MusicPuase:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if(isOk == NO) return;;
    
    /*--- ID3 在BT模式生效---*/
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *deviceModel = [entity.mCmdManager outputDeviceModel];
    uint8_t fun_current = deviceModel.currentFunc;
    if (fun_current != JL_FunctionCodeBT) return;
    
    if (isWaitPuase == YES) {
        isWaitPuase = NO;

        [DFAction delay:1.0 Task:^{
            NSLog(@"----------> showID3UI 3333");
            [self showID3UI:YES];
            [[JLCacheBox cacheUuid:self->bleSDK.mBleUUID] setIsID3_ST:YES];
            [[JLCacheBox cacheUuid:self->bleSDK.mBleUUID] setIsID3_PUSH:YES];
            NSLog(@"mul_icon_pause_nor......3");
            [DFUITools setButton:self->btnPP Image:@"Theme.bundle/mul_icon_play_nor"];
            NSLog(@"UI开启ID3信息。99");
        }];
    }
    BOOL isID3_ST = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_ST];
    if (isID3_ST && isWaitCutSong == YES) {
        isWaitCutSong = NO;
        NSLog(@"mul_icon_play_nor......4");
        [DFUITools setButton:self->btnPP Image:@"Theme.bundle/mul_icon_pause_nor"];
    }
}

-(void)noteShowId3:(NSNotification*)note{
    //第三方音乐，关闭设备音乐的定时器.
    [DFAction timingStop:myTimer];
    NSLog(@"----------> showID3UI 1111");
    [self showID3UI:YES];

    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    NSString *name_0 = [NSString stringWithFormat:@"%@",model.ID3_Title];
    NSString *name_1 = [NSString stringWithFormat:@"%@",model.ID3_Artist];
    NSString *name_2 = [NSString stringWithFormat:@"%@",model.ID3_AlBum];
        
    double a_time = ((double)model.ID3_Time);
    double c_time = ((double)model.ID3_CurrentTime)/1000.0;
    
    if (name_0.length > 0) _mSonyName_0.text = name_0;
    if (name_1.length > 0) _mSonyName_1.text = name_1;
    if (name_2.length > 0) _mSonyName_2.text = name_2;

    _mTimeStart.text = [DFTime stringFromSec:(uint32_t)c_time];
    _mTimeEnd.text = [DFTime stringFromSec:(uint32_t)a_time];
    _mProgressView.value = c_time/a_time;
    
    if (model.ID3_Status == 1) { //播放
        NSLog(@"mul_icon_pause_nor......2"); //暂停
        [DFUITools setButton:btnPP Image:@"Theme.bundle/mul_icon_pause_nor"];
    }else{
        NSLog(@"mul_icon_play_nor......2");
        [DFUITools setButton:btnPP Image:@"Theme.bundle/mul_icon_play_nor"];
    }
}


-(void)noteBleChangeMaster:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    
    BOOL isID3_ST = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] isID3_ST];

    if (isID3_ST == YES) {
        NSLog(@"主从切换，恢复ID3音乐信息.");
        [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mChargingBinManager cmdID3_PushEnable:YES];
    }
}


#pragma mark 更新手机音乐被系统打断
-(void)notePlayerInterruption:(NSNotification*)note{
    DFAudioPlayer *nowPlayer = [DFAudioPlayer currentPlayer];
    if (nowPlayer.mState == DFAudio_ST_PLAYING) {
        [DFAudioPlayer didPauseLast];
        NSLog(@"中断正在播放的手机音乐.");
        NSLog(@"UI开启ID3信息。77");
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if(model.mCallType == JL_CALLType_OFF){
            [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PUSH:YES];
            [bleSDK.mBleEntityM.mCmdManager.mChargingBinManager cmdID3_PushEnable:YES];
        }
       
        
        [DFAction delay:0.5 Task:^{
            NSLog(@"---> 手机音乐被打断，获取ID3信息。");
            [self->bleSDK.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeBT Result:nil];
        }];
        
    }else{
        
    }

}

-(void)notePlayerInterruptionEnd:(NSNotification*)note{

    
}

-(void)notePlayerInterruptionEndFlag:(NSNotification*)note{
    __weak typeof(self) wSelf = self;
    DFAudioPlayer_STATE st = [DFAudioPlayer didLastState];

    
    NSInteger flag = [note.object intValue];
    if (flag == 0) {
        NSLog(@"----> 被类似抖音APP的打断.");
        if (st == DFAudioPlayer_PLAYING) {
            [JL_Tools delay:0.5 Task:^{
                [[JLCacheBox cacheUuid:self->bleSDK.mBleUUID] setIsID3_ST:NO];
                UIApplication *app = [UIApplication sharedApplication];
                if (app.applicationState == UIApplicationStateActive) {
                    NSLog(@"---> 手机音乐被打断结束，正在恢复播放。");
                    [[JLCacheBox cacheUuid:self->bleSDK.mBleUUID] setIsID3_PLAY:NO];
                    [DFAudioPlayer didContinueLast];
                    [wSelf updatePhoneMusicInfo];
                }else{
                    NSLog(@"---> 手机音乐被打断结束，APP住处与后台，无法恢复播放。");
                    [DFAudioPlayer didAllPause];
                }
            }];
        }
    }
    
    if (flag == 1) {
        NSLog(@"----> 被手机通话打断.");
        if (st == DFAudioPlayer_PLAYING) {
            NSLog(@"---> 手机音乐被打断结束，正在恢复播放。");
            [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_ST:NO];
            [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PLAY:NO];
            [DFAudioPlayer didContinueLast];
            [wSelf updatePhoneMusicInfo];
        }
    }
}

-(void)noteAppActive:(NSNotification*)note{
    if (bleSDK.mBleEntityM) {
        NSLog(@"App Active reload..");
        [self chooseDiffMusic];
    }
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeSomethingConnected ||
        type == JLDeviceChangeTypeBleOFF) {
        [[DFAudioPlayer sharedMe] didPause];
        [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mChargingBinManager cmdID3_PushEnable:YES];
    }
    if (type == JLDeviceChangeTypeInUseOffline) {
        isWaitPuase = NO;
    }
    if (type == JLDeviceChangeTypeManualChange) {
        /*--- 关闭网络电台 ---*/
        [[NetworkPlayer sharedMe] didStop];
        
        DFAudioPlayer *nowPlayer = [DFAudioPlayer currentPlayer];
        [nowPlayer didPause];
    }
    
    if (bleSDK.mBleEntityM) {
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if (model.currentFunc == JL_FunctionCodeMUSIC) {
            [bleSDK.mBleEntityM.mCmdManager cmdGetSystemInfo:JL_FunctionCodeMUSIC
                                                      Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                [self updateDeviceState];
            }];
        }else{
            [self updateDeviceState];
        }
    }
}

-(void)noteEdrChange:(NSNotification*)note{
    if (bleSDK.mBleEntityM == nil) return;
    
    NSDictionary *dict = note.object;
    NSString *edr = dict[@"ADDRESS"];
    if (dict == nil || ![edr isEqual:bleSDK.mBleEntityM.mEdr]) {
        NSLog(@"---> 经典蓝牙没有对应当前设备.");
        //UIWindow *win = [DFUITools getWindow];
        [JL_Tools mainTask:^{
            [DFUITools showText:kJL_TXT("connect_match_edr") onView:self delay:1.0];
        }];
        
        if ([[CorePlayer shareInstanced] status] == DFNetPlayer_STATUS_PLAY) {
            [[CorePlayer shareInstanced] didPause];
            [self noteNetPlayerPause:nil];
        }
        
        __weak typeof(self) wSelf = self;
        DFAudioPlayer *nowPlayer = [DFAudioPlayer currentPlayer];
        
        if (nowPlayer.mState == DFAudioPlayer_PLAYING ||
            nowPlayer.mState == DFAudioPlayer_PENDING)
        {
            //[nowPlayer didPause];
            [wSelf updatePhoneMusicInfo];
            
            [bleSDK.mBleEntityM.mCmdManager.mChargingBinManager cmdID3_PushEnable:YES];
            isWaitPuase = YES;
        }
    }
}



-(void)addNote{
    [JL_Tools add:UIApplicationWillEnterForegroundNotification Action:@selector(noteAppActive:) Own:self];
    
    //手机音乐
    [JL_Tools add:@"TOBE_NEXT_LOCAL_MUSIC"     Action:@selector(actionNext:)   Own:self];
    [JL_Tools add:kDFAudioPlayer_NOTE          Action:@selector(notePlayerState:)   Own:self];
    [JL_Tools add:kDFAudioPlayer_PROGRESS      Action:@selector(notePlayerProgress:)Own:self];
    [JL_Tools add:kDFAudioPlayer_PLAYER_INTERRUPTION Action:@selector(notePlayerInterruption:) Own:self];
    [JL_Tools add:kDFAudioPlayer_PLAYER_INTERRUPTION_END Action:@selector(notePlayerInterruptionEnd:) Own:self];
    [JL_Tools add:kDFAudioPlayer_PLAYER_INTERRUPTION_END_FLAG Action:@selector(notePlayerInterruptionEndFlag:) Own:self];
    
    [JL_Tools add:kJL_MANAGER_SYSTEM_INFO Action:@selector(noteSystemInfo:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    
    [JL_Tools add:kUI_JL_SHOW_ID3 Action:@selector(noteShowId3:) Own:self];
    [JL_Tools add:@"JL_ENTITY_CHANGE_MASTER" Action:@selector(noteBleChangeMaster:) Own:self];

    [JL_Tools add:kJL_MANAGER_ID3_Title Action:@selector(updateID3MusicInfo:) Own:self];
    [JL_Tools add:kJL_MANAGER_ID3_Artist Action:@selector(updateID3MusicInfo:) Own:self];
    [JL_Tools add:kJL_MANAGER_ID3_Album Action:@selector(updateID3MusicInfo:) Own:self];
    
    [JL_Tools add:kJL_MANAGER_ID3_Title Action:@selector(updateID3MusicPuase:) Own:self];
    [JL_Tools add:kJL_MANAGER_ID3_Artist Action:@selector(updateID3MusicPuase:) Own:self];
    [JL_Tools add:kJL_MANAGER_ID3_Album Action:@selector(updateID3MusicPuase:) Own:self];

    [JLModel_Device observeModelProperty:@"ID3_CurrentTime" Action:@selector(updateID3MusicInfo:) Own:self];
    [JLModel_Device observeModelProperty:@"ID3_Status" Action:@selector(updateID3MusicStatus:) Own:self];
    [JLModel_Device observeModelProperty:@"cardArray" Action:@selector(noteCardArray:) Own:self];

    
    [JL_Tools add:@"kUI_NETPLAYER_PAUSE" Action:@selector(noteNetPlayerPause:) Own:self];
    [JL_Tools add:kUI_JL_CARD_MUSIC_INFO Action:@selector(noteFirstUpdateCardMusicInfo:) Own:self];
    
    [JL_Tools add:kJL_BLE_M_EDR_CHANGE Action:@selector(noteEdrChange:) Own:self];
}


-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

@end
