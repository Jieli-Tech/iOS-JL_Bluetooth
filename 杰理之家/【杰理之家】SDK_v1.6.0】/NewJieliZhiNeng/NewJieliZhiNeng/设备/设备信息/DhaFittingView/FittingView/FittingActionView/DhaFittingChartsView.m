//
//  DhaFittingChartsView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/1.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DhaFittingChartsView.h"
#import "SegmengCtrlView.h"
#import "JLUI_Effect.h"
#import "DhaChartView.h"


#define GainValue 10

@interface DhaFittingChartsView ()<SegmengCtrlViewDelegate>{
    
    UIView *centerView;
    SegmengCtrlView *segmentView;
    DhaChartView *chartView;
    UIButton *backBtn;
    
    UIButton *hearOKBtn;
    UIButton *hearFailBtn;
    
    
    FittingMgr *leftFitter;
    FittingMgr *rightFitter;
    FittingMgr *mainFitter;
    
    JLDhaFitting *dhaManager;
    
    DhaChannel channel;
    
    BOOL canBeSend;
}
@end

@implementation DhaFittingChartsView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        canBeSend = true;
        
        centerView = [UIView new];
        centerView.backgroundColor = [UIColor whiteColor];
        [JLUI_Effect addShadowOnView:centerView];
        centerView.layer.masksToBounds = YES;
        [self addSubview:centerView];
        
        segmentView = [[SegmengCtrlView alloc] initWithFrame:CGRectZero];
        segmentView.delegate = self;
        [centerView addSubview:segmentView];
        
        chartView = [[DhaChartView alloc] initWithFrame:CGRectZero];
        chartView.leftLabl.hidden = YES;
        chartView.rightLabl.hidden = YES;
        [self addSubview:chartView];
        
        
        backBtn = [UIButton new];
        [backBtn setTitle:kJL_TXT("back") forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor colorFromHexString:@"#727272"] forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [backBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_return_Dha"] forState:UIControlStateNormal];
        backBtn.titleLabel.font = FontMedium(14);
        [backBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,0.0,15)];
        [centerView addSubview:backBtn];
        
        hearFailBtn = [UIButton new];
        [hearFailBtn setTitle:kJL_TXT("cant_hear") forState:UIControlStateNormal];
        [hearFailBtn setTitleColor:[UIColor colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        [hearFailBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [hearFailBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_no"] forState:UIControlStateNormal];
        [hearFailBtn setBackgroundColor:[UIColor colorFromHexString:@"#EB5B5B"]];
        [hearFailBtn addTarget:self action:@selector(hearFailedBtnAction) forControlEvents:UIControlEventTouchUpInside];
        hearFailBtn.layer.cornerRadius = 20;
        hearFailBtn.layer.masksToBounds = YES;
        hearFailBtn.titleLabel.font = FontMedium(15);
        [hearFailBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,0.0, 15)];
        [self addSubview:hearFailBtn];
        
        
        hearOKBtn = [UIButton new];
        [hearOKBtn setTitle:kJL_TXT("hear") forState:UIControlStateNormal];
        [hearOKBtn setTitleColor:[UIColor colorFromHexString:@"#FFFFFF"] forState:UIControlStateNormal];
        [hearOKBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [hearOKBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_yes"] forState:UIControlStateNormal];
        [hearOKBtn setBackgroundColor:[UIColor colorFromHexString:@"#805BEB"]];
        [hearOKBtn addTarget:self action:@selector(hearOKBtnAction) forControlEvents:UIControlEventTouchUpInside];
        hearOKBtn.layer.cornerRadius = 20;
        hearOKBtn.layer.masksToBounds = YES;
        hearOKBtn.titleLabel.font = FontMedium(15);
        [hearOKBtn setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0,0.0, 15)];
        [self addSubview:hearOKBtn];
        
        [self stepUI];
        
        dhaManager = [[JLDhaFitting alloc] init];
        
    }
    return self;
}

-(void)stepUI{
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(16);
        make.left.equalTo(self.mas_left).offset(16);
        make.right.equalTo(self.mas_right).offset(-16);
        make.height.offset(450);
    }];
    [segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_top).offset(16);
        make.left.equalTo(centerView.mas_left).offset(16);
        make.right.equalTo(centerView.mas_right).offset(-16);
        make.height.offset(38);
    }];
    
    [chartView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(segmentView.mas_bottom).offset(16);
        make.left.equalTo(centerView.mas_left).offset(0);
        make.right.equalTo(centerView.mas_right).offset(0);
        make.bottom.equalTo(backBtn.mas_top).offset(0);
    }];
    
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.width.offset(120);
        make.height.offset(40);
        make.bottom.equalTo(centerView.mas_bottom).offset(-6);
    }];
    
    [hearFailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_bottom).offset(24);
        make.left.equalTo(self.mas_left).offset(16);
        make.right.equalTo(hearOKBtn.mas_left).offset(-18);
        make.height.offset(40);
        make.width.equalTo(hearOKBtn.mas_width);
    }];
    
    [hearOKBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_bottom).offset(24);
        make.left.equalTo(hearFailBtn.mas_right).offset(18);
        make.right.equalTo(self.mas_right).offset(-16);
        make.height.offset(40);
        make.width.equalTo(hearFailBtn.mas_width);
    }];
    
}

-(void)hiddenSegment{
    segmentView.hidden = YES;
    [centerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(16);
        make.left.equalTo(self.mas_left).offset(16);
        make.right.equalTo(self.mas_right).offset(-16);
        make.height.offset(392);
    }];
    [chartView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(centerView.mas_top).offset(16);
        make.left.equalTo(centerView.mas_left).offset(0);
        make.right.equalTo(centerView.mas_right).offset(0);
        make.bottom.equalTo(backBtn.mas_top).offset(0);
    }];
    chartView.leftLabl.hidden = YES;
    chartView.rightLabl.hidden = NO;
    if (self.dhaType == DHAEarTypeLeft) {
        chartView.rightLabl.textColor = [UIColor colorFromHexString:@"#4E89F4"];
        chartView.rightLabl.text = [NSString stringWithFormat:@"● %@",kJL_TXT("Left_ear")];
    }
    
}

-(void)setDhaSqlFitter:(DhaFittingSql *)dhaSqlFitter{
    
    self.isFitting = YES;
    _dhaSqlFitter = dhaSqlFitter;
    
    NSArray *targetArray = [dhaSqlFitter beFitterMgr];
    if ([dhaSqlFitter.type isEqualToString:DoubleFitter]) {
        _dhaType = DHAEarTypeBoth;
        leftFitter = targetArray.firstObject;
        rightFitter = targetArray.lastObject;
        if (dhaSqlFitter.isFinish) {
            mainFitter = rightFitter;
            channel = DhaChannel_right;
            [segmentView setBtnTo:1];
            DhaHandlerModel *dhamd = [mainFitter checkoutNowList];
            [chartView.chartsView setMaxIndex:dhamd.maxIndex];
            chartView.chartsView.shouldTag = dhamd.shouldTag;
            [chartView.chartsView setXAxisList:dhamd.freqList];
            [chartView.chartsView setBarValues:dhamd.barValues];
        }else{
            if (rightFitter.fittingIndex == 0) {
                mainFitter = leftFitter;
                channel = DhaChannel_left;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self->segmentView setBtnTo:0];
                });
            }else{
                mainFitter = rightFitter;
                channel = DhaChannel_right;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self->segmentView setBtnTo:1];
                });
            }
            [self sendAndReLoadUI:50];
        }
    }
    
    if ([dhaSqlFitter.type isEqualToString:LeftFitter]) {
        _dhaType = DHAEarTypeLeft;
        leftFitter = targetArray.firstObject;
        if (!dhaSqlFitter.isFinish) {
            mainFitter = leftFitter;
            channel = DhaChannel_left;
            DhaHandlerModel *dhamd = [mainFitter checkoutNowList];
            [chartView.chartsView setMaxIndex:dhamd.maxIndex];
            chartView.chartsView.shouldTag = dhamd.shouldTag;
            [chartView.chartsView setXAxisList:dhamd.freqList];
            [chartView.chartsView setBarValues:dhamd.barValues];
        }else{
            [self sendAndReLoadUI:50];
        }
        [self hiddenSegment];
    }
    if ([dhaSqlFitter.type isEqualToString:RightFitter]) {
        _dhaType = DHAEarTypeRight;
        rightFitter = targetArray.firstObject;
        if (!dhaSqlFitter.isFinish) {
            mainFitter = rightFitter;
            channel = DhaChannel_right;
            DhaHandlerModel *dhamd = [mainFitter checkoutNowList];
            [chartView.chartsView setMaxIndex:dhamd.maxIndex];
            chartView.chartsView.shouldTag = dhamd.shouldTag;
            [chartView.chartsView setXAxisList:dhamd.freqList];
            [chartView.chartsView setBarValues:dhamd.barValues];
        }else{
            [self sendAndReLoadUI:50];
        }
        [self hiddenSegment];
    }
}

-(void)setDhaType:(DHAEarType)dhaType{
    _dhaType = dhaType;
    
}


-(void)beginFitting{
    
    self.isFitting = YES;
#if (DHAUITest == 0)
    JL_ManagerM *manager = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    JLModel_Device *model = [manager outputDeviceModel];
    DhaFittingInfo *info = model.dhaFitInfo;
#elif (DHAUITest == 1)
    DhaFittingInfo *info = [DhaFittingInfo new];
    info.ch_num = 6;
    info.ch_freq = @[@(250),@(500),@(1000),@(2000),@(4000),@(6000)];
    info.version = 1;
#endif
    
    if (self.dhaType == DHAEarTypeBoth) {
        leftFitter = [[FittingMgr alloc] initWithInfo:info channel:DhaChannel_left];
        rightFitter = [[FittingMgr alloc] initWithInfo:info channel:DhaChannel_right];
        mainFitter = leftFitter;
        channel = DhaChannel_left;
    }
    
    if (self.dhaType == DHAEarTypeLeft) {
        leftFitter = [[FittingMgr alloc] initWithInfo:info channel:DhaChannel_left];
        mainFitter = leftFitter;
        channel = DhaChannel_left;
        [self hiddenSegment];
    }
    
    if (self.dhaType == DHAEarTypeRight) {
        rightFitter = [[FittingMgr alloc] initWithInfo:info channel:DhaChannel_right];
        mainFitter = rightFitter;
        channel = DhaChannel_right;
        [self hiddenSegment];
    }
    
    [self sendAndReLoadUI:50.0];
    
}

-(void)saveToSql{
   
    [self makeSqlObj];
    
    [[DhaSqlite share] update:self.dhaSqlFitter];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DHA_SQL_UPDATE" object:nil];
}



//MARK: - 内部

-(void)makeSqlObj{
    
    NSMutableArray *list = [NSMutableArray new];
    NSDate *nowDate = [NSDate new];
    NSMutableArray *newArray = [NSMutableArray new];
   
    
    for (DhaFittingData *item in mainFitter.dhaList) {
        NSNumber *number = [NSNumber numberWithInteger:item.freq];
        [newArray addObject:number];
    }
    if (self.dhaSqlFitter == nil) {
        self.dhaSqlFitter = [DhaFittingSql new];
        NSDateFormatter *fm = [NSDateFormatter new];
        fm.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        self.dhaSqlFitter.recordName = [fm stringFromDate:nowDate];
    }
    self.dhaSqlFitter.type = [self getDhaType];
   
    self.dhaSqlFitter.recordDate = nowDate;
    
    self.dhaSqlFitter.isFinish = NO;
    if (self.dhaType == DHAEarTypeBoth) {
        DhaHandlerModel *dhamd = [leftFitter checkoutNowList];
        for (NSNumber *item in dhamd.barValues) {
            [list addObject:item];
        }
        DhaHandlerModel *dhamd1 = [rightFitter checkoutNowList];
        for (NSNumber *item in dhamd1.barValues) {
            [list addObject:item];
        }
    }
    if (self.dhaType == DHAEarTypeLeft) {
        DhaHandlerModel *dhamd = [leftFitter checkoutNowList];
        for (NSNumber *item in dhamd.barValues) {
            [list addObject:item];
            NSLog(@"gains:%@",item);
        }
    }
    if (self.dhaType == DHAEarTypeRight) {
        DhaHandlerModel *dhamd1 = [rightFitter checkoutNowList];
        for (NSNumber *item in dhamd1.barValues) {
            [list addObject:item];
        }
    }
    
    self.dhaSqlFitter.recordList = list;
    self.dhaSqlFitter.recordFreqList = newArray;
    self.dhaSqlFitter.devUuid = [[JL_RunSDK sharedMe] mBleEntityM].mUUID;
}

-(NSString *)getDhaType{
    if (self.dhaType == DHAEarTypeBoth) {
        return DoubleFitter;
    }else if (self.dhaType == DHAEarTypeLeft){
        return LeftFitter;
    }else{
        return RightFitter;
    }
}
-(void)sendAndReLoadUI:(float)gain{
    DhaFittingData *infoData = [mainFitter getNowModel];
    infoData.gain = gain;
    [self fittingAction:infoData];
    NSLog(@"freq:%d,infoData.gain:%f",infoData.freq,infoData.gain);
    DhaHandlerModel *dhamd = [mainFitter checkoutNowList];
    [chartView.chartsView setMaxIndex:dhamd.maxIndex];
    chartView.chartsView.shouldTag = dhamd.shouldTag;
    [chartView.chartsView setXAxisList:dhamd.freqList];
    [chartView.chartsView setBarValues:dhamd.barValues];
}

-(void)fittingAction:(DhaFittingData* )dataInfo{
    JL_ManagerM *cmd = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    [dhaManager auxiCheckByStep:dataInfo Manager:cmd Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        NSLog(@"验配：channecl:%d freq:%d gains:%.2f",dataInfo.channel,dataInfo.freq,dataInfo.gain);
        if (status == JL_CMDStatusNoResponse) {
                Dialog()
                .wToastPositionSet(DialogToastBottom)
                .wTypeSet(DialogTypeToast)
                .wMessageSet(kJL_TXT("msg_read_file_err_reading"))
                .wMainOffsetXSet(30);
        }
        self->canBeSend = true;
    }];
    
}


-(void)handleWithFitting:(float)gain Finish:(BOOL)isFinish{
    if (isFinish) {
        [[FittingCheck share] reset];
        if([mainFitter nextModel]){
            [self sendAndReLoadUI:50.0];
        }else{
            if (self.dhaType == DHAEarTypeBoth) {
                if (channel == DhaChannel_left) {
                    channel = DhaChannel_right;
                    [segmentView setBtnTo:1];
                    mainFitter = rightFitter;
                    [self sendAndReLoadUI:50.0];
                }else{
                    //Finish ALl
                    NSLog(@"配完了");
                    [self makeSqlObj];
                    if ([_delegate respondsToSelector:@selector(dhaFittingFinish:)]) {
                        [_delegate dhaFittingFinish:@[leftFitter,rightFitter]];
                    }
                }
            }else{
                NSLog(@"配完了");
                [self makeSqlObj];
                NSMutableArray *resultArray = [NSMutableArray new];
                if (self.dhaType == DHAEarTypeLeft) {
                    [resultArray addObject:leftFitter];
                }
                if (self.dhaType == DHAEarTypeRight) {
                    [resultArray addObject:rightFitter];
                }
                if ([_delegate respondsToSelector:@selector(dhaFittingFinish:)]) {
                    [_delegate dhaFittingFinish:resultArray];
                }
            }
        }
    }else{
        [self sendAndReLoadUI:gain];
    }
}

-(void)backBtnAction{

    [mainFitter getNowModel].gain = 0.0;
    [[FittingCheck share] reset];
    if([mainFitter previousModel]){
        [self sendAndReLoadUI:50.0];
    }else{
        if (self.dhaType == DHAEarTypeBoth) {
            if (channel == DhaChannel_right) {
                channel = DhaChannel_left;
                mainFitter = leftFitter;
                [segmentView setBtnTo:0];
                [self sendAndReLoadUI:50.0];
            }else{
                [DFUITools showText:@"已经是首个了" onView:self delay:1];
                [self sendAndReLoadUI:50.0];
            }
        }else{
            [DFUITools showText:@"已经是首个了" onView:self delay:1];
            [self sendAndReLoadUI:50.0];
        }
    }
}

-(void)hearOKBtnAction{
    if (canBeSend == false) return;
    FittingResult *result = [[FittingCheck share] changeWithSt:YES];
    [self handleWithFitting:result.gain Finish:result.isFinish];
    canBeSend = false;
}

-(void)hearFailedBtnAction{
    if (canBeSend == false) return;
    FittingResult *result = [[FittingCheck share] changeWithSt:NO];
    [self handleWithFitting:result.gain Finish:result.isFinish];
    canBeSend = false;
}


//MARK: - Segment

-(void)segmengDidTouchBtn:(int)index{
    DhaHandlerModel *dhamd;
    if (index == 0) {
        dhamd = [leftFitter checkoutNowList];
        if(channel == DhaChannel_left){
            backBtn.hidden = NO;
            hearOKBtn.hidden = NO;
            hearFailBtn.hidden = NO;
            
        }else{
            dhamd.shouldTag = -1;
            backBtn.hidden = YES;
            hearOKBtn.hidden = YES;
            hearFailBtn.hidden = YES;
        }
    }else{
        dhamd = [rightFitter checkoutNowList];
        if(channel == DhaChannel_right){
            backBtn.hidden = NO;
            hearOKBtn.hidden = NO;
            hearFailBtn.hidden = NO;
        }else{
            dhamd.shouldTag = -1;
            backBtn.hidden = YES;
            hearOKBtn.hidden = YES;
            hearFailBtn.hidden = YES;
        }
    }

    [chartView.chartsView setMaxIndex:dhamd.maxIndex];
    chartView.chartsView.shouldTag = dhamd.shouldTag;
    [chartView.chartsView setXAxisList:dhamd.freqList];
    [chartView.chartsView setBarValues:dhamd.barValues];
}




@end
