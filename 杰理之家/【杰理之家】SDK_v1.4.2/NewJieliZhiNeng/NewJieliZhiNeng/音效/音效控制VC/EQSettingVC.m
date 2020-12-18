//
//  EQSettingVC.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/13.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "EQSettingVC.h"
#import "TopView.h"
#import "DeviceChangeView.h"
#import "AppSettingVC.h"
#import "SqliteManager.h"
#import "DeviceChangeModel.h"
#import "ToolViewNull.h"
#import "DeviceInfoVC.h"
#import "ElasticHandler.h"

#import "EqParamView.h"
#import "EQDefaultCache.h"
#import "EQReverberationVC.h"

static DeviceChangeView *devView;
static EqParamView     *eqView;

@interface EQSettingVC ()<EQSettingsDelegate>{
    //UIView          *bgView;
    
    TopView         *topView;
    ToolViewNull    *toolViewNull;
    DFTips          *loadingTp;
    //JL_BLEUsage     *JL_ug;
    
    float           sW;
    float           sH;
    
    JL_RunSDK       *bleSDK;
    NSString        *bleUUID;
}

@end



@implementation EQSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
    
    bleSDK = [JL_RunSDK sharedMe];
    bleUUID= bleSDK.mBleUUID;
}

-(void)viewWillAppear:(BOOL)animated{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self initUI];
    });
}

-(void)viewDidAppear:(BOOL)animated{
    [topView viewFirstLoad];
    if (bleSDK.mBleEntityM) {
        [self updateEQParamUI:nil];
    }
    
}

/*--- 初始化界面 ---*/
-(void) initUI{
    sW = [DFUITools screen_2_W];
    sH = [DFUITools screen_2_H];
    

    topView = [[TopView alloc] init];
    [topView viewFirstLoad];
    [self.view addSubview:topView];
    
    /*--- 工具卡片 ---*/
    toolViewNull = [[ToolViewNull alloc] init];
    toolViewNull.hidden = YES;
    [self.view addSubview:toolViewNull];
    
    __weak typeof(self) wSelf = self;
    [topView onBLK_Device:^{
        if (self->bleSDK.mBleMultiple.bleManagerState == CBManagerStatePoweredOff) {
            [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self.view delay:1.0];
            return;
        }
        devView = [[DeviceChangeView alloc] init];
        [devView onShow];

        [devView setDeviceChangeBlock:^(NSString *uuid,NSInteger index) {
            if (index != -1) {
                JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
                if (type == JLUuidTypeInUse) {
                    DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
                    vc.modalPresentationStyle = 0;
                    [wSelf presentViewController:vc animated:YES completion:nil];
                }
            }
        }];
    } BLK_Setting:^{
        AppSettingVC *vc = [[AppSettingVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }];

    CGRect rect = CGRectMake(12, kJL_HeightStatusBar+54, sW-24, sH-kJL_HeightStatusBar-kJL_HeightTabBar-70);
    eqView = [[EqParamView alloc] initWithFrame:rect];
    eqView.hidden = NO;
    eqView.delegate = self;
    [self.view addSubview:eqView];

    [eqView setEQParamBLK:^(uint8_t eqMode, NSArray * _Nullable eqArray) {
        [self->bleSDK.mBleEntityM.mCmdManager cmdSetSystemEQ:eqMode Params:eqArray];
    }];
    [self updateEQParamUI:nil];
    [eqView updateHighLowVol];
    [eqView highLowEnable];
}


/*--- 处理EQ的UISlider的逻辑变化 ---*/
-(void)updateEQParamUI:(NSNotification*)note{
    NSDictionary *dict = note.object;
    NSString *uuid = dict[kJL_MANAGER_KEY_UUID];
    JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
    
    if (type == JLUuidTypeInUse) {
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if(model.eqArray.count>0){
            [eqView setEQArray:model.eqArray EQMode:model.eqMode];
        }
    }
}


-(void)addNote{
    [JLModel_Device observeModelProperty:@"eqArray" Action:@selector(updateEQParamUI:) Own:self];
    [JLModel_Device observeModelProperty:@"eqDefaultArray" Action:@selector(updateEQParamUI:) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(deviceChangeNote:) Own:self];
    //[JL_Tools add:kJL_BLE_ERROR Action:@selector(noteTimeOut:) Own:self];
}

-(void)deviceChangeNote:(NSNotification *)note{
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeManualChange || tp == JLDeviceChangeTypeSomethingConnected) {
        if(model.eqArray.count>0){
            [eqView setEQArray:model.eqArray EQMode:model.eqMode];
        }
    }
    if (tp == JLDeviceChangeTypeInUseOffline) {
        NSArray *array = bleSDK.mBleMultiple.bleConnectedArr;
        if (array.count == 0) {
            [eqView setEQArray:@[@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0),@(0)] EQMode:JL_EQModeNORMAL];
            [eqView updateBtnWithMode:JL_EQModeNORMAL];
        }else{
            if(model.eqArray.count>0){
                [eqView setEQArray:model.eqArray EQMode:model.eqMode];
            }
        }
    }
   

}





-(void)noteTimeOut:(NSNotification *)note{
    int value = [[note object] intValue];
    NSString *text = kJL_TXT("连接错误");
    switch (value) {
        case 4005:
            text = kJL_TXT("未知错误");
            break;
            case 4006:
            text = kJL_TXT("连接失败");
            break;
            case 4007:
            text = kJL_TXT("连接超时");
            break;
            case 4008:
            text = kJL_TXT("特征值超时");
            break;
            case 4009:
            text = kJL_TXT("特征值超时");
            break;
        default:
            break;
    }
    [self startLoadingView:text Delay:1.0];
}

-(void)startLoadingView:(NSString*)text Delay:(NSTimeInterval)delay{
    [loadingTp hide:YES];
    [loadingTp removeFromSuperview];
    loadingTp = nil;
    
    UIWindow *win = [DFUITools getWindow];
    loadingTp = [DFUITools showHUDWithLabel:text
                                     onView:win
                                      alpha:0.6
                                      color:[UIColor blackColor]
                             labelTextColor:[UIColor whiteColor]//kDF_RGBA(36, 36, 36, 1.0)
                     activityIndicatorColor:[UIColor whiteColor]];
    [loadingTp hide:YES afterDelay:delay];
}

-(void)enterEQSettingsUI{
//    if(!bleSDK.mBleEntityM){
//        [DFUITools showText:kJL_TXT("请先连接设备") onView:self.view delay:1.0];
//        return;
//    }
    
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON Result:nil];
    EQReverberationVC *vc = [[EQReverberationVC alloc] init];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}
@end
