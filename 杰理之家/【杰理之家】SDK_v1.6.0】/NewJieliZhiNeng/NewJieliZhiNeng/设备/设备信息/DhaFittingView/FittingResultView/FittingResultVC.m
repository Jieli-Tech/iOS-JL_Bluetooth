//
//  FittingResultVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/2.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "FittingResultVC.h"
#import "GainsAvgView.h"
#import "DhaChartView.h"
#import "DhaWriteTipsView.h"
#import "DhaSqlite.h"
#import "DhaWarningView.h"


@interface FittingResultVC ()<DhaWritePtl>{
    GainsAvgView *gainView;
    DhaChartView *chartView;
    DhaWriteTipsView *writeTipsView;
    UIView *centerView;
    UIButton *writeBtn;
    JLDhaFitting *fitting;
    DhaWarningView *warningView;
    JLModel_Device *devModel;
    BOOL isExistDha;
}

@end

@implementation FittingResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stepUI];
    [self initData];
}

-(void)stepUI{
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F8FAFC"];
    
    self.title = self.titleString;
    
    warningView = [DhaWarningView new];
    warningView.hidden = YES;
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [window addSubview:warningView];
    
    gainView = [[GainsAvgView alloc] initWithFrame:CGRectZero];
    gainView.leftDb = 26;
    gainView.rightDb = 60;
    [self.view addSubview:gainView];
    
    centerView = [UIView new];
    [JLUI_Effect addShadowOnView:centerView];
    centerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:centerView];
    
    chartView = [[DhaChartView alloc] initWithFrame:CGRectZero];
    [centerView addSubview:chartView];
    
    writeBtn = [UIButton new];
    [writeBtn setBackgroundColor:[UIColor colorFromHexString:@"#805BEB"]];
    [writeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [writeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    writeBtn.titleLabel.font = FontMedium(15);
    [writeBtn addTarget:self action:@selector(writeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [writeBtn setTitle:kJL_TXT("Written_to_the_device") forState:UIControlStateNormal];
    writeBtn.layer.cornerRadius = 24;
    writeBtn.layer.masksToBounds = YES;
    [self.view addSubview:writeBtn];
    
    writeTipsView = [[DhaWriteTipsView alloc] initWithFrame:CGRectZero];
    writeTipsView.hidden = YES;
    writeTipsView.delegate = self;
    [window addSubview:writeTipsView];
    
    [warningView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(window.mas_top).offset(0);
        make.left.equalTo(window.mas_left).offset(0);
        make.right.equalTo(window.mas_right).offset(0);
        make.bottom.equalTo(window.mas_bottom).offset(0);
    }];
    
    [gainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kJL_HeightNavBar+16);
        make.left.equalTo(self.view.mas_left).offset(0);
        make.right.equalTo(self.view.mas_right).offset(0);
        make.bottom.equalTo(centerView.mas_top).offset(-16);
        make.height.offset(105);
    }];
    
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(gainView.mas_bottom).offset(16);
        make.left.equalTo(self.view.mas_left).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.bottom.equalTo(writeBtn.mas_top).offset(-30);
        make.height.offset(365);
    }];
    
    [chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_top).offset(10);
        make.left.equalTo(centerView.mas_left).offset(0);
        make.right.equalTo(centerView.mas_right).offset(0);
        make.bottom.equalTo(centerView.mas_bottom).offset(-10);
    }];
    
    [writeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_bottom).offset(30);
        make.left.equalTo(self.view.mas_left).offset(16);
        make.right.equalTo(self.view.mas_right).offset(-16);
        make.height.offset(48);
    }];
    
    [writeTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(window.mas_top).offset(0);
        make.left.equalTo(window.mas_left).offset(0);
        make.right.equalTo(window.mas_right).offset(0);
        make.bottom.equalTo(window.mas_bottom).offset(0);
    }];

}

-(void)initData{
    fitting = [JLDhaFitting new];
    if ([self.fitResultSql.type isEqualToString:DoubleFitter]) {
        FittingMgr *left = self.results.firstObject;
        FittingMgr *right = self.results[1];
        DhaHandlerModel *dhamd = [left checkoutNowList];
        DhaHandlerModel *dhamd1 = [right checkoutNowList];
        [chartView.chartsView setMaxIndex:dhamd.maxIndex];
        chartView.chartsView.shouldTag = -1;
        [chartView.chartsView setXAxisList:dhamd.freqList];
        [chartView.chartsView setLineArrays:dhamd.barValues Array2:dhamd1.barValues];
        gainView.leftDb = dhamd.meanValue;
        gainView.rightDb = dhamd1.meanValue;
        self.title = kJL_TXT("dha_fitting_result_both");
    }
    
    if ([self.fitResultSql.type isEqualToString:LeftFitter]) {
        FittingMgr *left = self.results.firstObject;
        DhaHandlerModel *dhamd = [left checkoutNowList];
        [chartView.chartsView setMaxIndex:dhamd.maxIndex];
        chartView.chartsView.shouldTag = -1;
        [chartView.chartsView setXAxisList:dhamd.freqList];
        [chartView.chartsView setLineArrays:dhamd.barValues Array2:nil];
        [gainView resetByLeft:dhamd.meanValue Type:DhaChannel_left];
        chartView.leftLabl.hidden = YES;
        chartView.rightLabl.textColor = [UIColor colorFromHexString:@"#4E89F4"];
        chartView.rightLabl.text = [NSString stringWithFormat:@"● %@",kJL_TXT("Left_ear")];
        self.title = kJL_TXT("dha_fitting_result_left");
    }
    
    if ([self.fitResultSql.type isEqualToString:RightFitter]) {
        FittingMgr *left = self.results.firstObject;
        DhaHandlerModel *dhamd = [left checkoutNowList];
        [chartView.chartsView setMaxIndex:dhamd.maxIndex];
        chartView.chartsView.shouldTag = -1;
        [chartView.chartsView setXAxisList:dhamd.freqList];
        [chartView.chartsView setLineArrays:dhamd.barValues Array2:nil];
        [gainView resetByLeft:dhamd.meanValue Type:DhaChannel_right];
        chartView.leftLabl.hidden = YES;
        self.title = kJL_TXT("dha_fitting_result_right");
    }
    
    if (self.fitResultSql.autoID != -1){
        self.title = self.fitResultSql.recordName;
    }
    isExistDha = NO;
    
}

-(void)backBtnAction{
    if (self.exitNumber == 1) {
        [self.navigationController popViewControllerAnimated:true];
    }else{
#if UseSaveCache
        warningView.hidden = NO;
        [warningView dhaMessage:kJL_TXT("dha_fitting_exit_save_tips") cancel:kJL_TXT("dha_don_save") confirm:kJL_TXT("dha_save") action:^(DhaAlertSelectType type) {
            if (type == DhaAlertSelectType_Cancel) {
                
            }else{
                if (!self.fitResultSql) {
                    NSLog(@"error for fitResultSql is Null");
                    return;
                }
                NSDateFormatter *fm = [NSDateFormatter new];
                fm.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                self.fitResultSql.recordName = [fm stringFromDate:self.fitResultSql.recordDate];
                self.fitResultSql.isFinish = YES;
                [[DhaSqlite share] update:self.fitResultSql];
            }
            self->warningView.hidden = YES;
            NSInteger index = [[self.navigationController viewControllers]indexOfObject:self];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-self.exitNumber]animated:YES];
        }];
#else
        NSInteger index = [[self.navigationController viewControllers]indexOfObject:self];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-self.exitNumber]animated:YES];
#endif
    }
}



//MARK: - Save Alert delegate
- (void)dhaWrite:(NSString *)name saveToDb:(BOOL)save{
    writeTipsView.hidden = YES;

    NSMutableArray *newArray = [NSMutableArray new];
    for (FittingMgr *item in self.results) {
        for (DhaFittingData *item2 in item.dhaList) {
            [newArray addObject:item2];
        }
    }
    JL_ManagerM *mgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    
    
    Dialog().wTypeSet(DialogTypeAuto)
    //设置宽度
        .wWidthSet(158)
        .wHeightSet(100)
        .wImageNameSet(@"Theme.bundle/icon_success_nol.png")
        .wMessageSet(kJL_TXT("Dha_writeSaveOK"))
        .wMainBackColorSet([UIColor whiteColor])
        .wDisappelSecondSet(1)
        .wMessageColorSet([UIColor darkTextColor])
        .wStart();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->isExistDha) {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            NSInteger index = [[self.navigationController viewControllers]indexOfObject:self];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-self.exitNumber]animated:YES];
        }
    });
    
    [fitting auxiSaveGainsList:newArray Manager:mgr Type:[self getType] Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        
        
    }];
    
    if (!save) {
        
        return;
    }
    
    if (!self.fitResultSql) {
        NSLog(@"error for fitResultSql is Null");
        return;
    }
    self.fitResultSql.recordName = name;
    self.fitResultSql.isFinish = YES;
    [[DhaSqlite share] update:self.fitResultSql];

}

-(void)writeBtnAction{
    writeTipsView.hidden = NO;
    NSDateFormatter *fm = [NSDateFormatter new];
    fm.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    if (self.fitResultSql) {
        writeTipsView.showText = self.fitResultSql.recordName;
    }else{
        writeTipsView.showText = [fm stringFromDate:[NSDate new]];
    }
    if (self.fitResultSql.autoID != -1 && !_isCache){
        [writeTipsView noNeedSave];
    }
    
    
}

-(DhaFittingType)getType{
    if( [self.fitResultSql.type isEqualToString:DoubleFitter]){
        return DhaFittingType_All;
    }
    if( [self.fitResultSql.type isEqualToString:LeftFitter]){
        return DhaFittingType_left;
    }
    if( [self.fitResultSql.type isEqualToString:RightFitter]){
        return DhaFittingType_right;
    }
    return DhaFittingType_All;
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.exitNumber == 4) {
        if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
          self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
  
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
    if (self.exitNumber == 4) {
        if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        };
    }
}


-(void)goBackToRoot{
    isExistDha = YES;
}



@end
