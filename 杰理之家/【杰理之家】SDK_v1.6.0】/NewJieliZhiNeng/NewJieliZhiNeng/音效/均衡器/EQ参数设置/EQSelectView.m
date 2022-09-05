//
//  EQSelectView.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/6/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "EQSelectView.h"
#import "EQCell.h"
#import "JL_RunSDK.h"
#import "JLUI_Cache.h"
#import "EQDefaultCache.h"

@interface EQSelectView()<UITableViewDelegate,UITableViewDataSource,LanguagePtl>{
    NSArray     *dataArray;
    UIView      *deviceView;
    UIView      *blackView;
    UIView      *touchView;
    UILabel     *titleLab;
    UIButton    *cancelBtn;
    float       sW;
    float       sH;
    UITableView *subTableView;
    //int mode;
    int         nowMode;
    EQSelectViewBlock eqBlk;
    
    JL_RunSDK   *bleSDK;
}

@end


@implementation EQSelectView


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addNote];
        
        bleSDK = [JL_RunSDK sharedMe];
        
        [[LanguageCls share] add:self];
        
        sW = [UIScreen mainScreen].bounds.size.width;
        sH = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(0, 0, sW, sH);
        self.backgroundColor = [UIColor clearColor];
        
        blackView = [[UIView alloc] init];
        blackView.frame = CGRectMake(0, 0, sW, sH);
        blackView.backgroundColor = [UIColor blackColor];
        blackView.alpha = 0.0;
        
        deviceView = [[UIView alloc] init];
        deviceView.frame = CGRectMake(0, self->sH, self->sW, 472.0);
        deviceView.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
        deviceView.layer.cornerRadius = 13;
        deviceView.alpha = 1.0;
        
        touchView = [UIView new];
        touchView.frame = CGRectMake(0, 0, sW, sH-472.0);
        touchView.backgroundColor = [UIColor clearColor];
        [blackView addSubview:touchView];
        
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(onDismiss)];
        [gr setNumberOfTapsRequired:1];
        [gr setNumberOfTouchesRequired:1];
        [touchView addGestureRecognizer:gr];
        
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        [win addSubview:blackView];
        [win addSubview:deviceView];
        
        titleLab = [[UILabel alloc] init];
        titleLab.frame = CGRectMake(sW/2-50/2,0,100,50);
        titleLab.numberOfLines = 1;
        [deviceView addSubview:titleLab];
        
        NSDictionary *aDic = @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 17],
                               NSForegroundColorAttributeName: [UIColor colorWithRed:35/255.0 green:35/255.0 blue:35/255.0 alpha:1.0]};
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("eq_preset") attributes:aDic];
        titleLab.attributedText = string;
        
        UIView *sepView = [[UIView alloc] init];
        sepView.frame = CGRectMake(0,titleLab.frame.origin.y+titleLab.frame.size.height,sW,0.5);
        sepView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
        [deviceView addSubview:sepView];
        
        subTableView = [[UITableView alloc] init];
        subTableView.frame = CGRectMake(0, 50, sW, 472.0-50);
        subTableView.backgroundColor = [UIColor clearColor];
        subTableView.tableFooterView =  [UIView new];
        subTableView.showsVerticalScrollIndicator = NO;
        subTableView.rowHeight  = 49.5;
        subTableView.dataSource = self;
        subTableView.delegate   = self;
        [deviceView addSubview:subTableView];
        subTableView.separatorInset = UIEdgeInsetsZero;
        subTableView.layoutMargins = UIEdgeInsetsZero;
        [subTableView setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
        
        dataArray = @[kJL_TXT("eq_normal"),kJL_TXT("eq_rock"),kJL_TXT("eq_pop"),kJL_TXT("eq_classical"),kJL_TXT("eq_jazz"),kJL_TXT("eq_country"),kJL_TXT("eq_user")];
        [subTableView reloadData];
        
        UIView *bottomView = [[UIView alloc] init];
        bottomView.frame = CGRectMake(0,subTableView.frame.origin.y+subTableView.frame.size.height,sW,0.5);
        bottomView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
        [deviceView addSubview:bottomView];
                
        CGRect rect_btn_0 = CGRectMake(0, 472.0-75.0, sW, 75);
        cancelBtn = [[UIButton alloc] initWithFrame:rect_btn_0];
        cancelBtn.backgroundColor = [UIColor whiteColor];
        [cancelBtn addTarget:self action:@selector(onOkBtn) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.titleLabel.text = kJL_TXT("jl_cancel");
        [cancelBtn setTitle:kJL_TXT("jl_cancel") forState:UIControlStateNormal];
        [cancelBtn setTitleColor:kDF_RGBA(72, 72, 72, 1.0) forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
        [deviceView addSubview:cancelBtn];
        [self updateUI];
    }
    return self;
}

-(void)updateUI{

    if(bleSDK.mBleEntityM){
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        self->nowMode = model.eqMode;
    }else{
        self->nowMode = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] mEqMode];
    }
    [self->subTableView reloadData];
}

-(void)calculateDefaultEQ{
    __weak typeof(self) wself = self;
    [JL_Tools subTask:^{
        NSLog(@"Calculate Default EQ Doing...");
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
        NSArray *eqDefaultArr = model.eqDefaultArray;
        for (JLModel_EQ *eqMd in eqDefaultArr) {
            if(eqMd.mEqArray.count>0){
                [[EQDefaultCache sharedInstance] saveEq:eqMd.mEqArray
                                        centerFrequency:model.eqFrequencyArray
                                               withName:eqMd.mMode];
            }
            [NSThread sleepForTimeInterval:0.1];
        }
        [JL_Tools mainTask:^{
            [wself updateUI];
        }];
        NSLog(@"Calculate Default EQ Finish!");
    }];
}

-(void)onOkBtn{
    [UIView animateWithDuration:0.1 animations:^{
        self->blackView.alpha = 0.0;
        self->deviceView.frame = CGRectMake(0, self->sH, self->sW, 472.0);
    } completion:^(BOOL finished) {
    }];
}

-(void)onShow{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    NSArray *eqDefaultArr = model.eqDefaultArray;
    BOOL shouldCal = NO;
    for (JLModel_EQ *eq in eqDefaultArr) {
        NSArray *array = [[EQDefaultCache sharedInstance] getPointArray:eq.mMode];
        if (array.count<1){
            shouldCal = YES;
            break;
        }
    }
    if (shouldCal == NO) {
        [UIView animateWithDuration:0.1 animations:^{
            self->blackView.alpha = 0.3;
            self->deviceView.frame = CGRectMake(0,self->sH-460,self->sW,472.0);
            [self updateUI];
        }];
    }else{
        [self calculateDefaultEQ];
    }
    
}

-(void)onDismiss{
    [UIView animateWithDuration:0.1 animations:^{
        self->blackView.alpha = 0.0;
        self->deviceView.frame = CGRectMake(0, self->sH, self->sW, 472.0);
    } completion:^(BOOL finished) {
        //[self removeFromSuperview];
    }];
}

#pragma mark <- tableView Delegate ->
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EQCell *cell = [tableView dequeueReusableCellWithIdentifier:[EQCell ID]];
    if (cell == nil) {
        cell = [[EQCell alloc] init];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.eqLabel.text = dataArray[indexPath.row];
    cell.eqLabel.textColor = [UIColor blackColor];
    [cell setEqLine:(int)indexPath.row];
    
    if(indexPath.row == nowMode){
        cell.eqImv.image = [UIImage imageNamed:@"Theme.bundle/list_icon_sel"];
    }else{
        cell.eqImv.image = [UIImage imageNamed:@"Theme.bundle/list_icon_nor"];
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self onDismiss];
    
    if (eqBlk) {
        nowMode = (int)indexPath.row;

        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if (model.eqType == JL_EQType10) {
            NSArray *eqCacheArr = [[JLCacheBox cacheUuid:bleSDK.mBleUUID] eqCacheArray_1];
            NSArray *arr = eqCacheArr[indexPath.row];
            eqBlk(nowMode,arr);
        }else{
            NSArray *eqDefaultArr = model.eqDefaultArray;
            for (JLModel_EQ *eqModel in eqDefaultArr) {
                if (eqModel.mMode == JL_EQModeCUSTOM) {
                    if (model.eqCustomArray.count > 0) {
                        eqBlk(nowMode,model.eqCustomArray);
                    }else{
                        eqBlk(nowMode,eqModel.mEqArray);
                    }
                    break;
                }
                
                if (eqModel.mMode == nowMode) {
                    eqBlk(nowMode,eqModel.mEqArray);
                    break;
                }
            }
        }
    }
    [tableView reloadData];
}



-(void)setEQSelectBLK:(EQSelectViewBlock)blk{
    eqBlk = blk;
}

-(void)noteEqUpdate:(NSNotification*)note{
    NSDictionary *dict = note.object;
    NSString *uuid = dict[kJL_MANAGER_KEY_UUID];
    JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
    
    if (type == JLUuidTypeInUse) {
        [self handleEQSlider];
    }
}

/*--- 处理EQ的UISlider的逻辑变化 ---*/
-(void)handleEQSlider{
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    nowMode = model.eqMode;
    [subTableView reloadData];
}

-(void)addNote{
    [JLModel_Device observeModelProperty:@"eqArray" Action:@selector(noteEqUpdate:) Own:self];
    [JL_Tools add:kJL_MANAGER_SYSTEM_INFO Action:@selector(noteEqUpdate:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

- (void)languageChange {
    NSDictionary *aDic = @{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 17],
                           NSForegroundColorAttributeName: [UIColor colorWithRed:35/255.0 green:35/255.0 blue:35/255.0 alpha:1.0]};
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("eq_preset") attributes:aDic];
    titleLab.attributedText = string;
    dataArray = @[kJL_TXT("eq_normal"),kJL_TXT("eq_rock"),kJL_TXT("eq_pop"),kJL_TXT("eq_classical"),kJL_TXT("eq_jazz"),kJL_TXT("eq_country"),kJL_TXT("eq_user")];
    [subTableView reloadData];
    cancelBtn.titleLabel.text = kJL_TXT("jl_cancel");
    [cancelBtn setTitle:kJL_TXT("jl_cancel") forState:UIControlStateNormal];
}

@end

