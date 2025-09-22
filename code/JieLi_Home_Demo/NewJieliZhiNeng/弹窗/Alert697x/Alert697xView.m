//
//  Alert697xView.m
//  Alert697x
//
//  Created by EzioChan on 2020/5/29.
//  Copyright © 2020 Ezio. All rights reserved.
//

#import "Alert697xView.h"
#import "Alert697xTools.h"
#import "SqliteManager.h"
#import "ElasticHandler.h"
#import "JL_RunSDK.h"
#import "JLUI_Cache.h"
#import "JLCacheBox.h"

NSString *kUI_JL_ELSATICVIEW_BTN = @"UI_JL_ELSATICVIEW_BTN";

#define MaxShowTime  20

@interface Alert697xView()<LanguagePtl>{
    __weak IBOutlet UIView *bgView;
    //匹配上了0x02
    __weak IBOutlet UIView *connectOKView;
    __weak IBOutlet UILabel *titleLab;
    __weak IBOutlet UIImageView *leftEngineC;
    __weak IBOutlet UIImageView *rightEngineC;
    __weak IBOutlet UIImageView *cabinEngineC;
    __weak IBOutlet UILabel *leftLabC;
    __weak IBOutlet UILabel *rightLabC;
    __weak IBOutlet UILabel *cabinLabC;
    __weak IBOutlet UIButton *checkBtnC;
    __weak IBOutlet UIButton *finishBtnC;
    __weak IBOutlet UIImageView *leftHeadSetImgv;
    __weak IBOutlet UIImageView *rightHeadSetImgv;
    __weak IBOutlet UIImageView *cabinImgv;
    
    //左右耳标志
    __weak IBOutlet UIImageView *leftIcon;
    __weak IBOutlet UIImageView *rightIcon;
    
    //居中耳机
    __weak IBOutlet UIImageView *centerHeadSetImgv;
    __weak IBOutlet UIImageView *centerAllEngineC;
    __weak IBOutlet UILabel *centerAllLab;
    
    //提示语
    __weak IBOutlet UILabel *tipsLab;
    __weak IBOutlet NSLayoutConstraint *bottomHight;
    
    //按钮布局
    __weak IBOutlet NSLayoutConstraint *checkBtnW;
    __weak IBOutlet NSLayoutConstraint *checkBtnCenter;
    __weak IBOutlet NSLayoutConstraint *finishBtnW;
    __weak IBOutlet NSLayoutConstraint *finishBtnCenter;
    
    
    
    DFTips *loadingTp;
    
    NSTimer *showTimer;
    int nowNumber;
    NSDictionary *netDict;
    NSDictionary *imgDict;
    BOOL canShow;//用来控制在动画期间，不允许再弹出
    BOOL canDismiss;//用来控制在动画期间，不允许消失
    BOOL canBeShow;//用来控制dismiss之后一段时间不能弹窗
    BOOL isLoadingImage;
    
    ElasticHandler * elasticHanlder;
    JL_RunSDK *bleSDK;
    JL_EntityM *relinkEntity;
}

@end

@implementation Alert697xView

- (instancetype)init
{
    self = [super init];
    self = [[NSBundle mainBundle] loadNibNamed:@"Alert697xView" owner:nil options:nil][0];
    if (self) {
        bleSDK = [JL_RunSDK sharedMe];
        [[LanguageCls share] add:self];
        elasticHanlder = [ElasticHandler sharedInstance];
        
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        [self initWithAllUI];
        //whoISConnect = 0;
        canShow = YES;
        canDismiss = YES;
        canBeShow = YES;
        //connectToOthers = -1;
        
        [JL_Tools add:kJL_BLE_M_OFF Action:@selector(noteEntityDisconnected2:) Own:self];
        [JL_Tools add:kJL_BLE_M_ENTITY_DISCONNECTED Action:@selector(noteEntityDisconnected:) Own:self];
        [JL_Tools add:kUI_JL_DEVICE_SHOW_OTA Action:@selector(dismissView) Own:self];
        [JL_Tools add:kJL_BLE_M_ENTITY_CONNECTED Action:@selector(handleWithConnected:) Own:self];
        [JL_Tools add:@"JL_ENTITY_RELINK" Action:@selector(noteEntityRelink:) Own:self];
    }
    return self;
}

-(void)initWithAllUI{
    
    CGFloat rad = 15;
    if (CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) ||
        CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) ||
        CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size))
    {//iphoneX,xr,xs max
        rad = 34;
    }
    int w = [UIScreen mainScreen].bounds.size.width;
    if (w == 320) {
        checkBtnCenter.constant = -70;
        checkBtnW.constant = 110;
        finishBtnW.constant = 110;
        finishBtnCenter.constant = 70;
    }
    UITapGestureRecognizer *tapges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didShouldDismiss)];
    [bgView addGestureRecognizer:tapges];
    bgView.alpha = 0.0;
    
    connectOKView.layer.cornerRadius = rad;
    connectOKView.layer.masksToBounds = YES;
    
    [checkBtnC setTitle:kJL_TXT("device_review") forState:UIControlStateNormal];
    checkBtnC.layer.borderColor = [UIColor colorWithRed:212/255.0 green:213/255.0 blue:218.0/255.0 alpha:1].CGColor;
    checkBtnC.layer.borderWidth = 1;
    [checkBtnC setBackgroundColor:[UIColor whiteColor]];
    checkBtnC.layer.cornerRadius = 7.5;
    checkBtnC.layer.masksToBounds = YES;
    
    [finishBtnC setTitle:kJL_TXT("device_paired_finish") forState:UIControlStateNormal];
    finishBtnC.layer.cornerRadius = 7.5;
    finishBtnC.layer.masksToBounds = YES;
    finishBtnC.backgroundColor = [UIColor colorWithRed:235/255.0 green:237/255.0 blue:239/255.0 alpha:1.0];
    
    self.hidden = YES;
}

//MARK: - 主从切换时弹窗处理
-(void)noteEntityRelink:(NSNotification*)note{
    relinkEntity = [note object];
}


#pragma mark Tap手势取消
-(void)didShouldDismiss{
    JL_EntityM *entity = [elasticHanlder nowEntity];
    [elasticHanlder setToBlackList:entity];
    [self dismissView];
}

#pragma mark 关闭按钮取消
- (IBAction)closeBtnAction:(id)sender {
    kJLLog(JLLOG_DEBUG,@"----> Close Action."); 
    JL_EntityM *entity = [elasticHanlder nowEntity];
    [elasticHanlder setToBlackList:entity];
    [self dismissView];
}

#pragma mark 详情按钮取消
- (IBAction)checkBtnAction:(id)sender {
    JL_EntityM *entity = [elasticHanlder nowEntity];
    NSString *uuid = entity.mPeripheral.identifier.UUIDString;
    JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
    
    //UIWindow *win = [DFUITools getWindow];
    
    /*--- 正在配置 ---*/
    if (type == JLUuidTypePreparing) {
        kJLLog(JLLOG_DEBUG,@"----> 【详情】配置中... 3");
        //[DFUITools showText:@"设备配置中,请稍后..." onView:win delay:1.0];
        [self dismissView];
    }
    
    /*--- 正在使用的设备 ---*/
    if (type == JLUuidTypeInUse) {
        /*--- 跳去详情界面 ---*/
        kJLLog(JLLOG_DEBUG,@"----> 【详情】跳去详情界面 2");
        [self dismissView];
        [JL_Tools post:kUI_JL_ELSATICVIEW_BTN Object:nil];
    }
    
    /*--- 需要OTA ---*/
    if (type == JLUuidTypeNeedOTA) {
        /*--- 跳去详情界面 ---*/
        kJLLog(JLLOG_DEBUG,@"----> 【详情】需要OTA升级 1");
        //[DFUITools showText:@"需要升级." onView:win delay:1.0];
        [self dismissView];
    }
    
    if (type == JLUuidTypeConnected) {
        [self dismissView];
    }
    
    
    /*--- 未连接的设备 ---*/
    if (type == JLUuidTypeDisconnected) {
        /*--- 去连接设备 ---*/
        kJLLog(JLLOG_DEBUG,@"---> 【详情】连接设备：%@",entity.mItem);
        [self startLoadingView:kJL_TXT("device_connecting") Delay:15];
        
        __weak typeof(self) wSelf = self;
        [bleSDK connectEntity:entity Result:^(JL_EntityM_Status status) {
            
            /*--- 加入黑名单 ---*/
            [[ElasticHandler sharedInstance] setToBlackList:entity];
            
            [JL_Tools mainTask:^{
                NSString *txt = [JL_RunSDK textEntityStatus:status];
                [wSelf setLoadingText:txt Delay:1.0];
                
                if (status == JL_EntityM_StatusPaired) {
                    
                    /*--- 跳去详情界面 ---*/
                    kJLLog(JLLOG_DEBUG,@"----> 【详情】跳去详情界面 0");
                    [JL_Tools post:kUI_JL_ELSATICVIEW_BTN Object:nil];
                }
                [wSelf dismissView];
            }];
        }];
    }
}

#pragma mark 完成按钮取消
- (IBAction)finishBtnAction:(id)sender {
    
    JL_EntityM *entity = [elasticHanlder nowEntity];
    NSString *uuid = entity.mPeripheral.identifier.UUIDString;
    JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
    
    //UIWindow *win = [DFUITools getWindow];
    
    /*--- 正在配置 ---*/
    if (type == JLUuidTypePreparing) {
        kJLLog(JLLOG_DEBUG,@"----> 【完成】配置中... 3");
        //[DFUITools showText:@"设备配置中,请稍后..." onView:win delay:1.0];
        [self dismissView];
    }
    
    /*--- 正在使用的设备 ---*/
    if (type == JLUuidTypeInUse) {
        kJLLog(JLLOG_DEBUG,@"----> 【完成】2");
        [self dismissView];
    }
    
    if (type == JLUuidTypeConnected) {
        [self dismissView];
    }
    
    /*--- 需要OTA ---*/
    if (type == JLUuidTypeNeedOTA) {
        /*--- 跳去详情界面 ---*/
        kJLLog(JLLOG_DEBUG,@"----> 【完成】需要OTA升级 1");
        //[DFUITools showText:@"需要升级." onView:win delay:1.0];
        [self dismissView];
    }
    
    /*--- 未连接的设备 ---*/
    if (type == JLUuidTypeDisconnected) {
        /*--- 去连接设备 ---*/
        kJLLog(JLLOG_DEBUG,@"---> 【完成】连接设备：%@",entity.mItem);
        [self startLoadingView:kJL_TXT("device_connecting") Delay:15];
        
        if (![JL_RunSDK isConnectedEdr:entity]){
            [self startLoadingView:kJL_TXT("connectable_devies") Delay:2];
            return;
        }
        
        __weak typeof(self) wSelf = self;
        
        [bleSDK connectEntity:entity Result:^(JL_EntityM_Status status) {
            
            /*--- 加入黑名单 ---*/
            [[ElasticHandler sharedInstance] setToBlackList:entity];
            
            
            [JL_Tools mainTask:^{
                NSString *txt = [JL_RunSDK textEntityStatus:status];
                [wSelf setLoadingText:txt Delay:1.0];
                
                if (status == JL_EntityM_StatusPaired) {
                    /*--- 跳去详情界面 ---*/
                    kJLLog(JLLOG_DEBUG,@"---->【完成】0");
                }
                [wSelf dismissView];
            }];
        }];
    }
}

-(void)showAnimation{
    if (!canShow) return;//如果在消失期间出现了这个，那就不允许出来
    //isBoundOut = YES;
    canDismiss = NO;
    self.hidden = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self->bgView.alpha = 0.6;
        
        CGRect frame = CGRectMake(6, [UIScreen mainScreen].bounds.size.height-self->connectOKView.frame.size.height-12, self->connectOKView.frame.size.width, self->connectOKView.frame.size.height);
        self->connectOKView.frame = frame;
        //self->bgView.backgroundColor = [UIColor colorWithRed:1/255.0 green:1/255.0 blue:1/255.0 alpha:0.6];
        
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->canDismiss = YES;
        
    });
}
-(void)dismissAnimation{
    canShow = NO;
    canBeShow = NO;
    //isBoundOut = NO;
    
    [UIView animateWithDuration:0.25 animations:^{
        self->bgView.alpha = 0.0;
        
        CGRect frame = CGRectMake(6, [UIScreen mainScreen].bounds.size.height, self->connectOKView.frame.size.width, self->connectOKView.frame.size.height);
        self->connectOKView.frame = frame;
        //self->bgView.backgroundColor = [UIColor clearColor];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->canShow = YES;;
        self.hidden = YES;
        [self hiddenAllView];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->canBeShow = YES;
    });
}

-(void)startLoadingView:(NSString*)text Delay:(NSTimeInterval)delay{
    
    [loadingTp removeFromSuperview];
    loadingTp = nil;
    
    UIWindow *win = [DFUITools getWindow];
    loadingTp = [DFUITools showHUDWithLabel:text
                                     onView:win
                                      alpha:0.8
                                      color:[UIColor blackColor]
                             labelTextColor:[UIColor whiteColor]//kDF_RGBA(36, 36, 36, 1.0)
                     activityIndicatorColor:[UIColor whiteColor]];
    [loadingTp hide:YES afterDelay:delay];
}

-(void)setLoadingText:(NSString*)text Delay:(NSTimeInterval)delay{
    loadingTp.labelText = text;
    [loadingTp hide:YES afterDelay:delay];
    [JL_Tools delay:delay+0.5 Task:^{
        [self->loadingTp removeFromSuperview];
        self->loadingTp = nil;
    }];
}


#pragma mark <- 获取图片 ->
-(void)reloadNetImage:(JL_EntityM *)entity Result:(JL_IMAGE_LOAD_BK)result{
    __weak typeof(self) wself = self;
    
    NSString *uid = entity.mVID;
    NSString *pid = entity.mPID;
    if (uid.length == 0) uid = @"0000";
    if (pid.length == 0) pid = @"0000";
    NSNumber *vidNumber = [NSNumber numberWithLong:strtoul(uid.UTF8String, 0, 16)];
    NSString *vidStr = [vidNumber stringValue];
    
    
    NSNumber *pidNumber = [NSNumber numberWithLong:strtoul(pid.UTF8String, 0, 16)];
    NSString *pidStr = [pidNumber stringValue];

 
    
    [JL_Tools mainTask:^{
        [self setDefaultImage:entity];
        kJLLog(JLLOG_DEBUG,@"---->Show Default Image.0");
    }];
    
    self->imgDict = nil;
    self->netDict = nil;
        
    NSArray *itemArr = @[@"PRODUCT_LOGO",@"DOUBLE_HEADSET",
                         @"LEFT_DEVICE_CONNECTED",@"RIGHT_DEVICE_CONNECTED",
                         @"CHARGING_BIN_IDLE"];
    [entity.mCmdManager cmdRequestDeviceImageVid:vidStr Pid:pidStr
                                       ItemArray:itemArr Result:^(NSMutableDictionary * _Nullable dict) {
        [JL_Tools mainTask:^{
            if (dict) {
                NSData *data = dict[@"PRODUCT_MESSAGE"][@"IMG"];
                self->imgDict = dict;
                self->netDict = [DFTools jsonWithData:data];
                [wself setAllImage:dict WithUuid:entity.mPeripheral.identifier.UUIDString];
                kJLLog(JLLOG_DEBUG,@"---->Show Device Image!");
            }else{
                [wself setDefaultImage:entity];
                kJLLog(JLLOG_DEBUG,@"---->Show Default Image.1");
            }
            if (result) {result();}
        }];
    }];
}

-(void)setDefaultImage:(JL_EntityM*)entity{
    self->leftHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_earphone_left"];
    self->rightHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_earphone_right"];
    self->cabinImgv.image = [UIImage imageNamed:@"Theme.bundle/img_chargingbin"];
    
    if (entity.mType == JL_DeviceTypeSoundBox) self->centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_speaker"];
    if (entity.mType == JL_DeviceTypeTWS){
        self->centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_earphone_empty"];
        if (entity.mProtocolType == PTLVersion) {
            self->centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_neckearphone"];
        }
    }
    if (entity.mType == JL_DeviceTypeSoundCard) self->centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_mic"];
    if (entity.mType == JL_DeviceTypeChargingBin){
        centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/chargingBin_Large"];
    }
}


-(void)saveProductImage:(NSData*)data UUID:(NSString*)uuid Name:(NSString*)name{
    if (data.length == 0) return;
    
    NSString *imageName = [NSString stringWithFormat:@"%@_%@",name,uuid];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory
                             MiddlePath:@"" File:imageName];
    if (path) {
        [JL_Tools writeData:data fillFile:path];
    }else{
        NSString *newPath = [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:imageName];
        [JL_Tools writeData:data fillFile:newPath];
    }
}


-(void)setAllImage:(NSDictionary *)dict WithUuid:(NSString*)uuid{
    
    NSDictionary *proDict = dict[@"PRODUCT_LOGO"];
    if (proDict) {
        //[[JLUI_Cache sharedInstance] setProductData:proDict[@"IMG"]];
        [[JLCacheBox cacheUuid:uuid] setProductData:proDict[@"IMG"]];
        [self saveProductImage:proDict[@"IMG"] UUID:uuid Name:@"PRODUCT_LOGO"];
    }
    
    NSDictionary *doubleDict = dict[@"DOUBLE_HEADSET"];
    if (doubleDict) {
        //[[JLUI_Cache sharedInstance] setLeftData:doubleDict[@"IMG"]];
        [[JLCacheBox cacheUuid:uuid] setLeftData:doubleDict[@"IMG"]];
        [self saveProductImage:doubleDict[@"IMG"] UUID:uuid Name:@"DOUBLE_HEADSET"];
        centerHeadSetImgv.image = [UIImage imageWithData:doubleDict[@"IMG"]];
        //kJLLog(JLLOG_DEBUG,@"---->centerHeadSetImgv 0");
    }
    
    NSDictionary *leftDict = dict[@"LEFT_DEVICE_CONNECTED"];
    if (leftDict) {
        //[[JLUI_Cache sharedInstance] setLeftData:leftDict[@"IMG"]];
        [[JLCacheBox cacheUuid:uuid] setLeftData:leftDict[@"IMG"]];
        [self saveProductImage:leftDict[@"IMG"] UUID:uuid Name:@"LEFT_DEVICE_CONNECTED"];
        leftHeadSetImgv.image = [UIImage imageWithData:leftDict[@"IMG"]];
    }
    NSDictionary *rightDict = dict[@"RIGHT_DEVICE_CONNECTED"];
    if (rightDict) {
        //[[JLUI_Cache sharedInstance] setRightData:rightDict[@"IMG"]];
        
        [[JLCacheBox cacheUuid:uuid] setRightData:rightDict[@"IMG"]];
        [self saveProductImage:rightDict[@"IMG"] UUID:uuid Name:@"RIGHT_DEVICE_CONNECTED"];
        
        rightHeadSetImgv.image = [UIImage imageWithData:rightDict[@"IMG"]];
    }
    NSDictionary *cabinDict = dict[@"CHARGING_BIN_IDLE"];
    if (cabinDict) {
        //[[JLUI_Cache sharedInstance] setChargingBinData:cabinDict[@"IMG"]];
        [[JLCacheBox cacheUuid:uuid] setChargingBinData:cabinDict[@"IMG"]];
        [self saveProductImage:cabinDict[@"IMG"] UUID:uuid Name:@"CHARGING_BIN_IDLE"];
        cabinImgv.image = [UIImage imageWithData:cabinDict[@"IMG"]];
    }
}

#pragma mark <- 计时器 ->
-(void)startTimer{
    [showTimer invalidate];
    showTimer = nil;
    nowNumber = 0;
    showTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                               selector:@selector(showTimerAction)
                                               userInfo:nil repeats:YES];
    [showTimer fire];
}
-(void)showTimerAction{
    nowNumber+=1;
    if (nowNumber > MaxShowTime) {
        [self closeTimer];
        
        JL_EntityM *nowEntity = [elasticHanlder nowEntity];
        [elasticHanlder setToBlackList:nowEntity];
        [self dismissView];
    }
}
-(void)closeTimer{
    [showTimer invalidate];
    showTimer = nil;
    nowNumber = 0;
}

#pragma mark <- 刷新状态 ->
//刷新UI
-(void)refresh:(JL_EntityM *)entity{
    if (isLoadingImage == YES) {
        //kJLLog(JLLOG_DEBUG,@"Loading Device Images...");
        return;
    }

    BOOL isBlack = [elasticHanlder isInBlackList:entity];
    if (isBlack == YES) {
        //在黑名单中不弹窗。
        return;
    }
    
    
    JL_EntityM *nowEntity = [elasticHanlder nowEntity];
    NSString *nowUUID = nowEntity.mPeripheral.identifier.UUIDString;
    NSString *oneUUID = entity.mPeripheral.identifier.UUIDString;
    
    if (![nowUUID isEqualToString:oneUUID] && nowEntity) {
        //kJLLog(JLLOG_DEBUG,@"弹窗不处理 -----> %@",nowEntity.mItem);
        return;
    }
    
    if ([nowUUID isEqualToString:oneUUID] && nowEntity) {
        if(nowEntity.mCmdManager.mTwsManager.supports.isSupportDragWithMore){
            //一拖二，不显示已连接后的电量推送
            kJLLog(JLLOG_DEBUG,@"一拖二，不显示已连接后的电量推送");
            [self dismissAnimation];
            return;
        }
    }
    
    //kJLLog(JLLOG_DEBUG,@"nowUUID:%@",nowUUID);
    if (!canBeShow) return;//延时禁止弹窗
    kJLLog(JLLOG_DEBUG,@"JL_Entity Found --->[%p] %@ sence:%d seq:%d edr:%@",entity,entity.mItem,entity.mScene,entity.mSeq,entity.mEdr);
    
    if (nowEntity == nil) {//这里判断是否已经开启了窗口，如果是第一次开启，那就添加一个连接成功的监听
        if (entity.mScene == 0) return;//第一次搜到0状态不处理
        [elasticHanlder setNowEntity:entity];
        
        isLoadingImage = YES;
        
        __weak typeof(self) wSelf = self;
        [self reloadNetImage:entity Result:^{
            self->isLoadingImage = NO;
            
            kJLLog(JLLOG_DEBUG,@"JL_Entity Show  --->[%p] %@ sence:%d seq:%d",entity,entity.mItem,entity.mScene,entity.mSeq);
            if (self->relinkEntity){
                [wSelf reconnectByDeviceBoardcast:entity];//尝试连接设备
            }
            //[JL_Tools mainTask:^{
            [wSelf showAnimation];
            [wSelf updateEntityView:entity];
            //}];
        }];
    }else{
        [elasticHanlder setNowEntity:entity];
        
        [self updateEntityView:entity];
        
        //每次收到一包新的广播包就清零计时器
        [self startTimer];
    }
}

-(void)updateEntityView:(JL_EntityM*)entity{
    //设备名字
    titleLab.text = entity.mItem;
    
    //0:普通AI音箱 1:蓝牙对耳 2:数码充电仓
    //uint8_t mType = entity.mType;
    
    if (entity.mScene == 0x00) {
        //弹窗消失
    }
    if (entity.mScene == 0x01) {
        //提示去手动连接
        [self connectEDRLayout:entity];
    }
    if (entity.mScene == 0x02) {
        [self connectedEDROrNotShow:entity];
    }
    if (entity.mScene == 0x03) {
        [self connectingBack:entity];
    }
    if (entity.mScene == 0x04) {
        [self canNotConnect:entity];
    }
}



-(void)dismissView{
    isRelinkBoardcast = NO;
    
    JL_EntityM *nowEntity = [elasticHanlder nowEntity];
    
    if (!nowEntity) {
        self.hidden = YES;
        return;
    }
    if (!canDismiss) {
        self.hidden = YES;
        return;
    }
    [self closeTimer];
    
    [JL_Tools remove:kJL_MANAGER_HEADSET_ADV Own:self];
    if (nowEntity.mBLE_IS_PAIRED == YES) {
        //[nowEntity.mCmdManager cmdHeatsetAdvEnable:NO];
        //kJLLog(JLLOG_DEBUG,@"---> Close Heatset Adv Enable【NO】");
    }
    
    [elasticHanlder setNowEntity:nil];
    netDict = nil;
    
    
    [self dismissAnimation];
}

-(void)handleWithConnected:(NSNotification *)note{
    CBPeripheral *pl = [note object];
    NSString *uuid = pl.identifier.UUIDString;
    if (relinkEntity){
        if ([uuid isEqualToString:relinkEntity.mPeripheral.identifier.UUIDString]){
            relinkEntity = nil;
        }
    }
}

#pragma mark <- 需要手动连接经典蓝牙 ->
/// 手动去连接蓝牙，2.0 没有连接
/// @param entity eitity
-(void)connectEDRLayout:(JL_EntityM *)entity{
    [self hideAllUIComponent];
    NSDictionary *dict = [JL_BLEMultiple outputEdrInfo];
    NSString *address1 = dict[@"ADDRESS"];
    if ([entity.mEdr isEqualToString:address1]) {//是自己当前所连接着的
        [self connectedByMe:entity];
    }else{
        if (entity.mType == JL_DeviceTypeChargingBin){
            [self connectedByMe:entity];
            return;
        }
        if (entity.mType == JL_DeviceTypeSoundBox ||
            entity.mType == JL_DeviceTypeSoundCard){
            centerHeadSetImgv.hidden = NO;
        }
        if (entity.mType == JL_DeviceTypeTWS) {
            cabinImgv.hidden = NO;
            leftHeadSetImgv.hidden = NO;
            rightHeadSetImgv.hidden = NO;
            if (entity.mProtocolType == PTLVersion) {
                cabinImgv.hidden = YES;
                leftHeadSetImgv.hidden = YES;
                rightHeadSetImgv.hidden = YES;
                centerHeadSetImgv.hidden = NO;
            }
            [self connectedByMe:entity];
        }
//        tipsLab.hidden = NO;
//        tipsLab.text = kJL_TXT("user_connect_edr");
    }
}


#pragma mark <- 经典蓝牙已经连上了，需要判断当前连接着的是不是自己 ->
-(void)connectedEDROrNotShow:(JL_EntityM *)entity{
    NSDictionary *dict = [JL_BLEMultiple outputEdrInfo];
    NSString *address1 = dict[@"ADDRESS"];
    if ([entity.mEdr isEqualToString:address1]) {//是自己当前所连接着的
        [self connectedByMe:entity];
    }else{
        [self connectingBack:entity];
    }
}

///自己连上的EDR和BLE 显示
-(void)connectedByMe:(JL_EntityM *)entity{
    
    [self setUpEngine:entity];
    [self hideAllUIComponent];
    
    if (entity.mType == JL_DeviceTypeSoundBox ||
        entity.mType == JL_DeviceTypeSoundCard ||
        entity.mType == JL_DeviceTypeChargingBin) {
        centerAllLab.hidden = NO;
        centerAllEngineC.hidden = NO;
        centerHeadSetImgv.hidden = NO;
        
        checkBtnC.hidden = NO;
        finishBtnC.hidden = NO;
    }
    
    if (entity.mType == JL_DeviceTypeTWS) {
        leftEngineC.hidden = NO;
        leftLabC.hidden = NO;
        leftHeadSetImgv.hidden = NO;
        
        rightEngineC.hidden = NO;
        rightLabC.hidden = NO;
        rightHeadSetImgv.hidden = NO;
        
        cabinEngineC.hidden = NO;
        cabinLabC.hidden = NO;
        cabinImgv.hidden = NO;
        
        checkBtnC.hidden = NO;
        finishBtnC.hidden = NO;
        
        //左右耳取出了
        if (entity.isCharging_L == NO && entity.isCharging_R==NO ) {
            
            leftEngineC.hidden = YES;
            leftIcon.hidden = YES;
            leftLabC.hidden = YES;
            leftHeadSetImgv.hidden = YES;
            
            rightIcon.hidden = YES;
            rightEngineC.hidden = YES;
            rightLabC.hidden = YES;
            rightHeadSetImgv.hidden = YES;
            
            cabinEngineC.hidden = YES;
            cabinLabC.hidden = YES;
            cabinImgv.hidden = YES;
            
            centerAllLab.hidden = NO;
            centerAllEngineC.hidden = NO;
            centerHeadSetImgv.hidden = NO;
        }
        
        if(entity.mProtocolType == PTLVersion){//挂脖耳机处理
            leftEngineC.hidden = YES;
            leftIcon.hidden = YES;
            leftLabC.hidden = YES;
            leftHeadSetImgv.hidden = YES;
            
            rightIcon.hidden = YES;
            rightEngineC.hidden = YES;
            rightLabC.hidden = YES;
            rightHeadSetImgv.hidden = YES;
            
            cabinEngineC.hidden = YES;
            cabinLabC.hidden = YES;
            cabinImgv.hidden = YES;
            
            centerAllLab.hidden = NO;
            centerAllEngineC.hidden = NO;
            centerHeadSetImgv.hidden = NO;
        }
    }
}

#pragma mark <- 连接中状态处理 ->
-(void)connectingBack:(JL_EntityM *)entity{
    
    [self setUpEngine:entity];
    [self hideAllUIComponent];
    
    if ([[SqliteManager sharedInstance] isExit:entity]) {//是否已连接过
        
        if (entity.mType == JL_DeviceTypeSoundBox ||
            entity.mType == JL_DeviceTypeSoundCard ||
            entity.mType == JL_DeviceTypeChargingBin) {
            centerAllLab.hidden = NO;
            centerAllEngineC.hidden = NO;
            centerHeadSetImgv.hidden = NO;
            
            checkBtnC.hidden = NO;
            finishBtnC.hidden = NO;
        }
        
        if (entity.mType == JL_DeviceTypeTWS) {
            leftEngineC.hidden = NO;
            leftLabC.hidden = NO;
            leftHeadSetImgv.hidden = NO;
            
            rightEngineC.hidden = NO;
            rightLabC.hidden = NO;
            rightHeadSetImgv.hidden = NO;
            
            cabinEngineC.hidden = NO;
            cabinLabC.hidden = NO;
            cabinImgv.hidden = NO;
            
            //左右耳取出了
            if (entity.isCharging_L == NO && entity.isCharging_R == NO ) {
                leftIcon.hidden = YES;
                leftEngineC.hidden = YES;
                leftLabC.hidden = YES;
                leftHeadSetImgv.hidden = YES;
                
                rightIcon.hidden = YES;
                rightEngineC.hidden = YES;
                rightLabC.hidden = YES;
                rightHeadSetImgv.hidden = YES;
                
                cabinEngineC.hidden = YES;
                cabinLabC.hidden = YES;
                cabinImgv.hidden = YES;
                
                centerAllLab.hidden = NO;
                centerAllEngineC.hidden = NO;
                centerHeadSetImgv.hidden = NO;
            }
            
            if(entity.mProtocolType == PTLVersion){//挂脖耳机处理
                leftEngineC.hidden = YES;
                leftIcon.hidden = YES;
                leftLabC.hidden = YES;
                leftHeadSetImgv.hidden = YES;
                
                rightIcon.hidden = YES;
                rightEngineC.hidden = YES;
                rightLabC.hidden = YES;
                rightHeadSetImgv.hidden = YES;
                
                cabinEngineC.hidden = YES;
                cabinLabC.hidden = YES;
                cabinImgv.hidden = YES;
                
                centerAllLab.hidden = NO;
                centerAllEngineC.hidden = NO;
                centerHeadSetImgv.hidden = NO;
            }
            
            checkBtnC.hidden = NO;
            finishBtnC.hidden = NO;
        }
        
    }else{
        
        if (entity.mType == JL_DeviceTypeSoundBox ||
            entity.mType == JL_DeviceTypeSoundCard||
            entity.mType == JL_DeviceTypeChargingBin) {
            centerHeadSetImgv.hidden = NO;
            tipsLab.hidden = NO;
            tipsLab.text = kJL_TXT("请确保音箱处于可配对状态");
        }
        
        if (entity.mType == JL_DeviceTypeTWS) {
            leftHeadSetImgv.hidden = NO;
            rightHeadSetImgv.hidden = NO;
            cabinImgv.hidden = NO;
            
            tipsLab.hidden = NO;
            NSString *showText = kJL_TXT("make_sure_headset_paired");
            if (netDict) {
                NSDictionary *dict = netDict[@"device"];
                int type = [dict[@"has_charging_bin"] intValue];
                if (type == 1) {
                    showText = kJL_TXT("long_click_cancel_pair");
                }else{
                    showText = kJL_TXT("make_sure_headset_paired");
                }
            }
            tipsLab.text = showText;
            if(entity.mProtocolType == PTLVersion){
                leftHeadSetImgv.hidden = YES;
                rightHeadSetImgv.hidden = YES;
                cabinImgv.hidden = YES;
                centerHeadSetImgv.hidden = NO;
                showText = kJL_TXT("make_sure_headset_paired");
                tipsLab.text = showText;
            }
        }
    }
}

#pragma mark <- 设备不可以连接0x04 ->
-(void)canNotConnect:(JL_EntityM *)entity{
    [self hideAllUIComponent];
    
    if (entity.mType == JL_DeviceTypeSoundBox ||
        entity.mType == JL_DeviceTypeSoundCard ||
        entity.mType == JL_DeviceTypeChargingBin) {
        centerHeadSetImgv.hidden = NO;
    }
    
    if (entity.mType == JL_DeviceTypeTWS) {
        leftHeadSetImgv.hidden = NO;
        rightHeadSetImgv.hidden = NO;
        cabinImgv.hidden = NO;
    }
    tipsLab.hidden = NO;
    tipsLab.text = kJL_TXT("device_cannot_use_reset_please");
    
}


#pragma mark <- 电量显示 ->
-(void)setUpEngine:(JL_EntityM *)entity{
    titleLab.text = entity.mItem;

    if (entity.mType == JL_DeviceTypeSoundBox){
        NSDictionary *dict1 = imgDict[@"PRODUCT_LOGO"];
        NSData *imgData = dict1[@"IMG"];
        if (imgData.length > 0) {
            centerHeadSetImgv.image = [UIImage imageWithData:imgData];
            //kJLLog(JLLOG_DEBUG,@"---->centerHeadSetImgv 1");
        }else{
            centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_speaker"];
            //kJLLog(JLLOG_DEBUG,@"---->centerHeadSetImgv 2");
        }
        centerAllEngineC.image = [Alert697xTools getPowerImg:entity.mPower_L];
        centerAllLab.text = [NSString stringWithFormat:@"%d%%",entity.mPower_L];
        if (entity.isCharging_L == YES) {
            centerAllEngineC.image = [Alert697xTools getPowerImg:-1];
        }
    }
    
    if (entity.mType == JL_DeviceTypeTWS ) {
        //左耳电量
        leftEngineC.image = [Alert697xTools getPowerImg:entity.mPower_L];
        leftLabC.text = [NSString stringWithFormat:@"%d%%",entity.mPower_L];
        if (entity.isCharging_L == YES) {
            leftEngineC.image = [Alert697xTools getPowerImg:-1];
        }
        
        //右耳电量
        rightEngineC.image = [Alert697xTools getPowerImg:entity.mPower_R];
        rightLabC.text = [NSString stringWithFormat:@"%d%%",entity.mPower_R];
        if (entity.isCharging_R == YES) {
            rightEngineC.image = [Alert697xTools getPowerImg:-1];
        }
        
        //充电仓电量
        cabinEngineC.image = [Alert697xTools getPowerImg:entity.mPower_C];
        cabinLabC.text = [NSString stringWithFormat:@"%d%%",entity.mPower_C];
        if (entity.isCharging_C == YES) {
            cabinEngineC.image = [Alert697xTools getPowerImg:-1];
        }
        
        //左右耳取出了
        if (entity.isCharging_L == NO && entity.isCharging_R==NO ) {
            int k = 0;
            int left = entity.mPower_L;
            int right = entity.mPower_R;
            if ( left != 0 &&  right!= 0) {
                k = entity.mPower_L > entity.mPower_R ? entity.mPower_R:entity.mPower_L;
                //centerHeadSetImgv.image = [UIImage imageNamed:@"icon_elastic_erji"];
                NSDictionary *dict1 = imgDict[@"DOUBLE_HEADSET"];
                NSData *imgData = dict1[@"IMG"];
                if (imgData.length>0) {
                    centerHeadSetImgv.image = [UIImage imageWithData:imgData];
                }else{
                    centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_earphone_empty"];
                }
            }else{
                if (right == 0) {
                    NSDictionary *lefttDict = imgDict[@"LEFT_DEVICE_CONNECTED"];
                    NSData *imgData = lefttDict[@"IMG"];
                    
                    if (imgData.length>0) {
                        centerHeadSetImgv.image = [UIImage imageWithData:imgData];
                    }else{
                        centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_earphone_left"];
                    }
                    k = entity.mPower_L;
                }
                if (left == 0) {
                    NSDictionary *rightDict = imgDict[@"RIGHT_DEVICE_CONNECTED"];
                    NSData *imgData = rightDict[@"IMG"];
                    
                    if (imgData.length>0) {
                        centerHeadSetImgv.image = [UIImage imageWithData:imgData];
                    }else{
                        centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_earphone_right"];
                    }
                    k = entity.mPower_R;
                }
            }
            centerAllLab.text = [NSString stringWithFormat:@"%d%%",k];
            centerAllEngineC.image = [Alert697xTools getPowerImg:k];
        }
        
        if(entity.mProtocolType == PTLVersion){//挂脖耳机处理
            NSDictionary *dict1 = imgDict[@"PRODUCT_LOGO"];
            NSData *imgData = dict1[@"IMG"];
            if (imgData.length > 0) {
                centerHeadSetImgv.image = [UIImage imageWithData:imgData];
            }else{
                centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_neckearphone"];
            }
            centerAllEngineC.image = [Alert697xTools getPowerImg:entity.mPower_L];
            centerAllLab.text = [NSString stringWithFormat:@"%d%%",entity.mPower_L];
            if (entity.isCharging_L == YES) {
                centerAllEngineC.image = [Alert697xTools getPowerImg:-1];
            }
        }
        
    }
    
    if (entity.mType == JL_DeviceTypeSoundCard){
        NSDictionary *dict1 = imgDict[@"PRODUCT_LOGO"];
        NSData *imgData = dict1[@"IMG"];
        if (imgData.length > 0) {
            centerHeadSetImgv.image = [UIImage imageWithData:imgData];
            //kJLLog(JLLOG_DEBUG,@"---->centerHeadSetImgv 1");
        }else{
            centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/img_mic"];
            //kJLLog(JLLOG_DEBUG,@"---->centerHeadSetImgv 2");
        }
        centerAllEngineC.image = [Alert697xTools getPowerImg:entity.mPower_L];
        centerAllLab.text = [NSString stringWithFormat:@"%d%%",entity.mPower_L];
        if (entity.isCharging_L == YES) {
            centerAllEngineC.image = [Alert697xTools getPowerImg:-1];
        }
    }
    
    if (entity.mType == JL_DeviceTypeChargingBin){
        NSDictionary *dict1 = imgDict[@"PRODUCT_LOGO"];
        NSData *imgData = dict1[@"IMG"];
        if (imgData.length > 0) {
            centerHeadSetImgv.image = [UIImage imageWithData:imgData];
            //kJLLog(JLLOG_DEBUG,@"---->centerHeadSetImgv 1");
        }else{
            centerHeadSetImgv.image = [UIImage imageNamed:@"Theme.bundle/chargingBin_Large"];
            //kJLLog(JLLOG_DEBUG,@"---->centerHeadSetImgv 2");
        }
        centerAllEngineC.image = [Alert697xTools getPowerImg:entity.mPower_C];
        centerAllLab.text = [NSString stringWithFormat:@"%d%%",entity.mPower_C];
        if (entity.isCharging_C == YES) {
            centerAllEngineC.image = [Alert697xTools getPowerImg:-1];
        }
    }
    
}

#pragma mark <- 窗口隐藏所有控件 ->
-(void)hiddenAllView{
    
    leftIcon.hidden = YES;
    rightIcon.hidden = YES;
    checkBtnC.hidden = YES;
    finishBtnC.hidden = YES;
    centerAllLab.hidden = YES;
    centerAllEngineC.hidden = YES;
    centerHeadSetImgv.hidden = YES;
    leftEngineC.hidden = YES;
    rightEngineC.hidden = YES;
    leftLabC.hidden = YES;
    rightLabC.hidden = YES;
    cabinEngineC.hidden = YES;
    cabinLabC.hidden = YES;
    
    cabinImgv.hidden = NO;
    leftHeadSetImgv.hidden = NO;
    rightHeadSetImgv.hidden = NO;
    tipsLab.hidden = YES;
    
}

-(void)hideAllUIComponent{
    leftIcon.hidden = YES;
    rightIcon.hidden = YES;
    checkBtnC.hidden = YES;
    finishBtnC.hidden = YES;
    centerAllLab.hidden = YES;
    centerAllEngineC.hidden = YES;
    centerHeadSetImgv.hidden = YES;
    leftEngineC.hidden = YES;
    rightEngineC.hidden = YES;
    leftLabC.hidden = YES;
    rightLabC.hidden = YES;
    cabinEngineC.hidden = YES;
    cabinLabC.hidden = YES;
    cabinImgv.hidden = YES;
    leftHeadSetImgv.hidden = YES;
    rightHeadSetImgv.hidden = YES;
    tipsLab.hidden = YES;
}

#pragma mark <--- 根据广播包重连 --->
static BOOL isRelinkBoardcast = NO;
-(void)reconnectByDeviceBoardcast:(JL_EntityM *)entity{
    
    //    BOOL isRelink = [JL_Manager cmdOtaIsRelinking];
    //    if (isRelink == YES) {
    //        kJLLog(JLLOG_DEBUG,@"OTA 正在回连，不处理弹窗连接.");
    //        return;
    //    }
    
    
    CBManagerState st = bleSDK.mBleMultiple.bleManagerState;
    if (st == CBManagerStatePoweredOff) {
        return;
    }
    
    if (entity.mScene == 0x00) {//等于0状态（弹窗消失）不去连接
        return;
    }
    __weak typeof(self) wSelf = self;
    
    NSArray *sqlArray = [[SqliteManager sharedInstance] checkOutAll];
    
    for (DeviceObjc *item in sqlArray) {
        if ([entity.mPeripheral.identifier.UUIDString isEqualToString:item.uuid]) {
            
            
            if (![JL_RunSDK isConnectedEdr:entity]){
                continue;
            }
            
            
            isRelinkBoardcast = YES;
            
            kJLLog(JLLOG_DEBUG,@"------> 弹窗主动回连: %@",entity.mItem);
            [self closeTimer];
            [JL_Tools mainTask:^{
                [self startLoadingView:kJL_TXT("device_connecting") Delay:15];
            }];
            
            
            
            [self->bleSDK connectEntity:entity Result:^(JL_EntityM_Status status) {
                
                /*--- 加入黑名单 ---*/
                [[ElasticHandler sharedInstance] setToBlackList:entity];
                
                if (status == JL_EntityM_StatusPaired) {
                    
                    [JL_Tools add:kJL_MANAGER_HEADSET_ADV Action:@selector(noteHeadsetInfo:) Own:self];
                    //[entity.mCmdManager cmdHeatsetAdvEnable:YES];
                    //kJLLog(JLLOG_DEBUG,@"---> Open Heatset adv Enable【YES】");
                }
                if (status == JL_EntityM_StatusMasterChanging) {
                    kJLLog(JLLOG_DEBUG,@"正在主从切换...停止弹窗连接。");
                }
                
                
                [JL_Tools mainTask:^{
                    NSString *txt = [JL_RunSDK textEntityStatus:status];
                    [wSelf setLoadingText:txt Delay:1.0];
                    
                    if (status != JL_EntityM_StatusPaired) {
                        [wSelf dismissView];
                    }
                }];
            }];
            break;
        }
    }
    
}



-(void)noteHeadsetInfo:(NSNotification*)note{
    NSDictionary *info = note.object;
    NSString *uuid = info[kJL_MANAGER_KEY_UUID];
    NSDictionary *dict = info[kJL_MANAGER_KEY_OBJECT];
    
    NSString *nowUuid = bleSDK.mBleUUID;
    if ([uuid isEqual:nowUuid]) {
        __weak typeof(self) wSelf = self;
        
        [JL_Tools mainTask:^{
            self->bleSDK.mBleEntityM.mPower_C = [dict[@"POWER_C"] intValue];
            self->bleSDK.mBleEntityM.mPower_L = [dict[@"POWER_L"] intValue];
            self->bleSDK.mBleEntityM.mPower_R = [dict[@"POWER_R"] intValue];
            self->bleSDK.mBleEntityM.isCharging_C = [dict[@"ISCHARGING_C"] boolValue];
            self->bleSDK.mBleEntityM.isCharging_L = [dict[@"ISCHARGING_L"] boolValue];
            self->bleSDK.mBleEntityM.isCharging_R = [dict[@"ISCHARGING_R"] boolValue];
            [wSelf connectedByMe:self->bleSDK.mBleEntityM];
        }];
    }
}

-(void)noteEntityDisconnected:(NSNotification*)note{
    JL_EntityM *nowEntity = [elasticHanlder nowEntity];
    if (nowEntity == nil) return;
    
    CBPeripheral *pl = note.object;
    NSString *uuid = pl.identifier.UUIDString;
    
    if ([uuid isEqual:nowEntity.mPeripheral.identifier.UUIDString]) {
        kJLLog(JLLOG_DEBUG,@"---> 断开连接关闭弹窗.");
        [self dismissView];
    }
}

-(void)noteEntityDisconnected2:(NSNotification*)note{
    int num = [[note object] intValue];
    if (num == 0) {    
        [self dismissView];
    }
}

-(void)noteBleOff:(NSNotification*)note{
    [JL_Tools mainTask:^{
        kJLLog(JLLOG_DEBUG,@"---> BLE OFF 关闭弹窗.");
        [self dismissView];
    }];
}

-(void)languageChange{
    [checkBtnC setTitle:kJL_TXT("device_review") forState:UIControlStateNormal];
    [finishBtnC setTitle:kJL_TXT("device_paired_finish") forState:UIControlStateNormal];
}


@end
