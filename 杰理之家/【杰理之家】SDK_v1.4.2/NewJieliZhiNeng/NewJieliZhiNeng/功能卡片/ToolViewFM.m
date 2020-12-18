//
//  ToolViewFM.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "ToolViewFM.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "FMPickView.h"
#import "FmManageView.h"
#import "FmSearchView.h"
#import "UIImage+GIF.h"

@interface ToolViewFM()<FMPickViewDelegate>{
    __weak IBOutlet UIView  *subView;
    __weak IBOutlet UILabel *fmLabel;
    __weak IBOutlet UIButton*fmBtn;
    __weak IBOutlet UIButton*btn_PP;
    __weak IBOutlet UIButton*btnMore;
    __weak IBOutlet UIButton *searchBtn;
    
    FmManageView            *fmManagerView;
    UIAlertController       *actionSheet;
    
    float sW;
    float sH;
    JL_RunSDK              *bleSDK;
    UIView                  *bgView;
    
    UIImageView *imageGif;
    UIView *fmScrollView;
    UISwipeGestureRecognizer *swipeLeft;
    UISwipeGestureRecognizer *swipeRight;
    UITapGestureRecognizer   *stopSearchRecognizer;
}
@end

@implementation ToolViewFM

static FMPickView       *fmView = nil;
static NSMutableArray   *fmCollectArray;
static NSInteger        fmCurrent;

- (instancetype)init
{
    self = [DFUITools loadNib:@"ToolViewFM"];
    if (self) {
        sW = [DFUITools screen_2_W];
        sH = [DFUITools screen_2_H];

        bleSDK = [JL_RunSDK sharedMe];
        
        bgView = [UIView new];
        bgView.frame = CGRectMake(0, 0, sW, sH);
        bgView.backgroundColor = kDF_RGBA(0, 0, 0, 0.2);
        bgView.alpha = 0.0;
        
        self.frame = CGRectMake(0, kJL_HeightStatusBar+44, sW, 200);
        [JLUI_Effect addShadowOnView:subView];
        
        fmCurrent = 875;
        fmCollectArray = [NSMutableArray new];

        fmView = [[FMPickView alloc] initWithFrame:CGRectMake(20.0, 60, sW-40.0, 60)
                                        StartPoint:87 EndPoint:108];
        [fmView setFMPoint:875];
        fmView.delegate = self;
        [self addSubview:fmView];
        
        fmScrollView = [[UIView alloc] initWithFrame:CGRectMake(20.0, 60, sW-40.0, 80)];
        [self addSubview:fmScrollView];
        fmScrollView.backgroundColor = [UIColor clearColor];
        
        fmScrollView.hidden = YES;
        
        if(swipeLeft == nil){
            swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handelClick)];
        }
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [fmScrollView addGestureRecognizer:swipeLeft];

        if(swipeRight == nil){
            swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handelClick)];
        }
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [fmScrollView addGestureRecognizer:swipeRight];
        
        CGRect rect = CGRectMake(15, 170.0, sW-30.0, 20.0);
        fmManagerView = [[FmManageView alloc] initWithFrame:rect];
        fmManagerView.hidden = YES;
        [self addSubview:fmManagerView];
                
        __weak typeof(self) weakSelf = self;
        typeof(weakSelf) __strong strongSelf = weakSelf;
        
        [fmManagerView setFmManagerSelect:^(uint16_t fmSelect) {
            JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
            JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
            if (model.currentFunc == JL_FunctionCodeFM) {
                if(self->imageGif.hidden == NO){
                    [DFUITools showText:kJL_TXT("正在搜台中") onView:strongSelf delay:1.0];
                    return;
                }
                [entity.mCmdManager cmdFm:JL_FCmdFMFrequencySelect
                           Saerch:0x00 Channel:0x00
                        Frequency:fmSelect Result:nil];
            }
        } Delete:^(uint16_t fmDelete) {
            for (JLModel_FM *md in fmCollectArray) {
                if (md.fmFrequency == fmDelete) {
                    [fmCollectArray removeObject:md];
                    break;
                }
            }
            [strongSelf saveFMPoints];
        }];
        [fmLabel setTextColor:kColor_0000];

        imageGif = [[UIImageView alloc] initWithFrame:CGRectMake(15, 9, 30, 30)];
        imageGif.contentMode = UIViewContentModeScaleToFill;
        [subView addSubview:imageGif];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"search_fm" ofType:@"gif"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        UIImage *image = [UIImage sd_animatedGIFWithData:data];
        imageGif.image = image;
        
        imageGif.userInteractionEnabled = YES;
         
        if(stopSearchRecognizer == nil){
            stopSearchRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnStopSearch:)];
        }
        [imageGif addGestureRecognizer:stopSearchRecognizer];
        
        imageGif.hidden = YES;
        searchBtn.hidden = NO;
        
        [self updateFmtxUI:875];
        [self addNote];
    }
    return self;
}

-(void)setOnVC:(UIViewController *)onVC{
    NSLog(@"------> setOnVC");
    _onVC = onVC;
    [self.onVC.view addSubview:bgView];
}

#pragma mark FMPickViewDelegate
static long fmPoint_last = 0;
-(void)onFMPickView:(FMPickView *)view didChange:(NSInteger)fmPoint{
    /*--- 震动体验 ---*/
    if (fmPoint_last != fmPoint) {
        [self updateFmtxUI:fmPoint];
        AudioServicesPlaySystemSound(1519);
        fmPoint_last = fmPoint;
    }
}

-(void)onFMPickView:(FMPickView *)view didSelect:(NSInteger)fmPoint{
    NSLog(@"FM Select: %ld",(long)fmPoint);
    fmCurrent = fmPoint;
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if (model.currentFunc == JL_FunctionCodeFM) {
        [entity.mCmdManager cmdFm:JL_FCmdFMFrequencySelect
                   Saerch:0x00 Channel:0x00
                Frequency:fmPoint Result:nil];
    }
}

-(void)updateFmtxUI:(uint16_t)fmPoint{
    if (fmPoint<875) {
        NSLog(@"---> set FmPoint:%d",fmPoint);
        return;
    }
    float fp = (float)fmPoint/10.0;
    fmLabel.text = [NSString stringWithFormat:@"%.1f",fp];

//    NSString *txt = [NSString stringWithFormat:@"%.1f",fp];
//    [fmBtn setTitle:txt forState:UIControlStateNormal];
}

- (IBAction)btn_lastPoint:(id)sender {
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if (model.currentFunc == JL_FunctionCodeFM) {
        if(self->imageGif.hidden == NO){
            [DFUITools showText:kJL_TXT("正在搜台中") onView:self delay:1.0];
            return;
        }
        [entity.mCmdManager cmdFm:JL_FCmdFMChannelBefore
                   Saerch:0x00 Channel:0x00
                Frequency:0x00 Result:nil];
    }
}

- (IBAction)btn_tap_before:(id)sender {
    [DFUITools setButton:btn_PP Image:@"Theme.bundle/mul_icon_paly"];
    
    if(imageGif.hidden == NO){
        [DFUITools showText:kJL_TXT("正在搜台中") onView:self delay:1.0];
        return;
    }
    
    if(imageGif.hidden == YES){
        imageGif.hidden = NO;
        searchBtn.hidden = YES;
        fmScrollView.hidden = NO;
    }

    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
//    if (model.currentFunc == JL_FunctionCodeFM) {
//        [entity.mCmdManager cmdFm:JL_FCmdFMPonitBefore
//                   Saerch:0x00 Channel:0x00
//                Frequency:0x00 Result:nil];
//    }
    if (model.currentFunc == JL_FunctionCodeFM) {
        [entity.mCmdManager cmdFm:JL_FCmdFMSearch
                           Saerch:JL_FMSearchForward
                          Channel:0x00 Frequency:0x00 Result:nil];
    }
}

- (IBAction)btn_tap_pp:(id)sender {
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if (model.currentFunc == JL_FunctionCodeFM) {
        if(self->imageGif.hidden == NO){
            [DFUITools showText:kJL_TXT("正在搜台中") onView:self delay:1.0];
            return;
        }
        [entity.mCmdManager cmdFm:JL_FCmdFMPP
                   Saerch:0x00 Channel:0x00
                Frequency:0x00 Result:nil];
    }
}
- (IBAction)btn_nextPoint:(id)sender {
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if (model.currentFunc == JL_FunctionCodeFM) {
        if(self->imageGif.hidden == NO){
            [DFUITools showText:kJL_TXT("正在搜台中") onView:self delay:1.0];
            return;
        }
        [entity.mCmdManager cmdFm:JL_FCmdFMChannelNext
                   Saerch:0x00 Channel:0x00
                Frequency:0x00 Result:nil];
    }
}

- (IBAction)btn_tap_next:(id)sender {
    [DFUITools setButton:btn_PP Image:@"Theme.bundle/mul_icon_paly"];
    
    if(imageGif.hidden == NO){
        [DFUITools showText:kJL_TXT("正在搜台中") onView:self delay:1.0];
        return;
    }
    
    if(imageGif.hidden == YES){
        imageGif.hidden = NO;
        searchBtn.hidden = YES;
        fmScrollView.hidden = NO;
    }
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
//    if (model.currentFunc == JL_FunctionCodeFM) {
//        [entity.mCmdManager cmdFm:JL_FCmdFMPonitNext
//                   Saerch:0x00 Channel:0x00
//                Frequency:0x00 Result:nil];
//    }
    if (model.currentFunc == JL_FunctionCodeFM) {
        [entity.mCmdManager cmdFm:JL_FCmdFMSearch
                           Saerch:JL_FMSearchBackward
                          Channel:0x00 Frequency:0x00 Result:nil];
    }
}

#pragma mark 停止全搜台扫描事件
- (void)btnStopSearch:(UIGestureRecognizer *)gestureRecognizer {
    BOOL isOK = [DFAction setMinExecutionGap:0.2];
    if (isOK == NO) return;
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    
    if(imageGif.hidden == NO){
        imageGif.hidden = YES;
        searchBtn.hidden = NO;
        fmScrollView.hidden = YES;
        
        if (model.currentFunc == JL_FunctionCodeFM) {
            [entity.mCmdManager cmdFm:JL_FCmdFMSearch
                               Saerch:JL_FMSearchStop
                              Channel:0x00 Frequency:0x00 Result:nil];
        }
    }
}

#pragma mark 开始全搜台扫描事件
- (IBAction)btn_to_search:(UIButton *)sender {
    BOOL isOK = [DFAction setMinExecutionGap:0.2];
    if (isOK == NO) return;
    
    [DFUITools setButton:btn_PP Image:@"Theme.bundle/mul_icon_paly"];
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    
    if(imageGif.hidden == YES){
        imageGif.hidden = NO;
        searchBtn.hidden = YES;
        fmScrollView.hidden = NO;
        
        if (model.currentFunc == JL_FunctionCodeFM) {
            [entity.mCmdManager cmdFm:JL_FCmdFMSearch
                               Saerch:JL_FMSearchALL
                              Channel:0x00 Frequency:0x00 Result:nil];
        }
    }
    
//    [FmSearchView showMeWithBlock:^(NSInteger index) {
//        NSLog(@"--->Search View Select Index: %ld",(long)index);
//
//        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
//        JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
//        if (index == 0) {
//            if (model.currentFunc == JL_FunctionCodeFM) {
//                [entity.mCmdManager cmdFm:JL_FCmdFMSearch
//                           Saerch:JL_FMSearchALL
//                          Channel:0x00 Frequency:0x00 Result:nil];
//            }
//        }
//        if (index == 1) {
//            if (model.currentFunc == JL_FunctionCodeFM) {
//                [entity.mCmdManager cmdFm:JL_FCmdFMSearch
//                           Saerch:JL_FMSearchForward
//                          Channel:0x00 Frequency:0x00 Result:nil];
//            }
//        }
//        if (index == 2) {
//            if (model.currentFunc == JL_FunctionCodeFM) {
//                [entity.mCmdManager cmdFm:JL_FCmdFMSearch
//                           Saerch:JL_FMSearchBackward
//                          Channel:0x00 Frequency:0x00 Result:nil];
//            }
//        }
//    }];
}
- (IBAction)btn_to_Add:(id)sender {
    if (fmCurrent < 875) return;
    if (fmCurrent > 1080) return;
    
    int flag = 0;
    for (JLFMModel *md in fmCollectArray) {
        if (md.fmFrequency == fmCurrent) {
            flag = 1;
            break;
        }
    }
    if (flag == 0) {
        JLModel_FM *md = [JLModel_FM new];
        md.fmChannel  = (uint8_t)(fmCurrent/10.0f);
        md.fmFrequency= fmCurrent;
        [fmCollectArray addObject:md];
        
        NSSortDescriptor *fmFrequency = [NSSortDescriptor sortDescriptorWithKey:@"fmFrequency"
                                                             ascending:YES];
        [fmCollectArray sortUsingDescriptors:@[fmFrequency]];
        
        [self saveFMPoints];
        [FmSearchView showMeCollectedView:YES];

        [self showFmCollections];
    }else{
        NSLog(@"已收藏.");
        [FmSearchView showMeCollectedView:NO];
    }
}


- (IBAction)btn_input_Fm:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"频点" message:nil
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    [actionSheet addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeDecimalPad;
    }];
    UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    UIAlertAction *btnConfirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = actionSheet.textFields[0];
        NSString *txt = [textField.text stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSLog(@"---> 频点确定: %@",txt);

        int point = [txt intValue];
        [fmView setFMPoint:point];
    }];
    [btnCancel setValue:kDF_RGBA(152, 152, 152, 1.0) forKey:@"_titleTextColor"];
    [actionSheet addAction:btnCancel];
    [actionSheet addAction:btnConfirm];
    [self.onVC presentViewController:actionSheet animated:YES completion:nil];
}




static BOOL isShowManager = NO;
- (IBAction)btn_more:(id)sender {
    
    if (isShowManager) {
        isShowManager = NO;
    }else{
        isShowManager = YES;
    }
    if (isShowManager) {
        [self showFmCollections];
    }else{
        [self dismissFmCollections];
    }
}


-(void)showFmCollections{
    [UIView animateWithDuration:0.20 animations:^{
        self->bgView.alpha = 1.0;
    }];
    [btnMore setImage:[UIImage imageNamed:@"Theme.bundle/mul_icon_up"] forState:UIControlStateNormal];

    fmManagerView.hidden = NO;
    CGSize size = [fmManagerView setFmArray:fmCollectArray CurrentFM:fmCurrent];
    self.frame = CGRectMake(0, kJL_HeightStatusBar+44, self->sW, 220+size.height);
}

-(void)dismissFmCollections{
    [UIView animateWithDuration:0.20 animations:^{
        self->bgView.alpha = 0.0;
    }];
    [btnMore setImage:[UIImage imageNamed:@"Theme.bundle/mul_icon_down"] forState:UIControlStateNormal];
    
    fmManagerView.hidden = YES;
    self.frame = CGRectMake(0, kJL_HeightStatusBar+44, self->sW, 200);
}
-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        [self dismissFmCollections];
    }
}


-(void)noteFmStatus:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    
    NSDictionary *dict = note.object;
    NSInteger fmst = [dict[kJL_MANAGER_KEY_OBJECT] intValue];
    [self updateUI_FmStatus:fmst];
}

-(void)updateUI_FmStatus:(UInt8)fmst{
    if (fmst == 0x00) {
        [DFUITools setButton:btn_PP Image:@"Theme.bundle/mul_icon_paly"];
    }
    if (fmst == 0x01) {
        imageGif.hidden = YES;
        searchBtn.hidden = NO;
        fmScrollView.hidden = YES;
        
        [DFUITools setButton:btn_PP Image:@"Theme.bundle/mul_icon_pause"];
    }
}

-(void)noteCurrentFm:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    
    [self updateUI_FmPoint:model.currentFm.fmFrequency];
}

-(void)updateUI_FmPoint:(uint16_t)fmFrequency{
    fmCurrent = fmFrequency;
    [fmView setFMPoint:fmFrequency];
    NSMutableArray *array = [[self getFMPoints] mutableCopy];
    if(array.count >0){
        fmCollectArray = array;
    }
    [fmManagerView setFmArray:fmCollectArray CurrentFM:fmFrequency];
    [self updateFmtxUI:fmFrequency];
}


-(void)noteFmUpdate:(NSNotification*)note{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    
    [self updateUI_FmStatus:model.fmStatus];
    [self updateUI_FmPoint:model.currentFm.fmFrequency];
}

#pragma mark 存储收藏频点
-(void)saveFMPoints{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:[fmCollectArray copy]];
    NSString *key = [NSString stringWithFormat:@"FM_%@",bleSDK.mBleUUID];
    if (arrayData) [userDefaults setObject:arrayData forKey:key];
    [userDefaults synchronize];
}

#pragma mark 取出收藏频点
-(NSArray *)getFMPoints{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"FM_%@",bleSDK.mBleUUID];
    NSData *arrayData = [userDefaults  objectForKey:key];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
    return array;
}

-(void)handelClick{
    if(imageGif.hidden == NO){
        [DFUITools showText:kJL_TXT("正在搜台中") onView:self delay:1.0];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:kUI_JL_FM_INFO Action:@selector(noteFmUpdate:) Own:self];
    [JLModel_Device observeModelProperty:@"currentFm"
                                 Action:@selector(noteCurrentFm:)
                                    Own:self];
    [JLModel_Device observeModelProperty:@"fmStatus"
                                 Action:@selector(noteFmStatus:)
                                    Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
    if(swipeLeft){
        [fmScrollView removeGestureRecognizer:swipeLeft];
    }
    if(swipeRight){
        [fmScrollView removeGestureRecognizer:swipeRight];
    }
    if(stopSearchRecognizer){
        [imageGif removeGestureRecognizer:stopSearchRecognizer];
    }
}
@end
