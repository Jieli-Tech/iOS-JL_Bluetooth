//
//  KaraokeEQView.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/11/12.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "KaraokeEQView.h"
#import "JL_RunSDK.h"
#import "DFSliderView.h"

#define kUI_Radius 10.0

@interface KaraokeEQView(){

    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIView  *mSubView;
    DFSliderView            *mSliderView;
    JL_RunSDK               *bleSDK;
    
    NSArray                 *defaultArr;
    NSArray                 *eqArr;
    
    float                   sW;
    float                   sH;
}
@end

@implementation KaraokeEQView

- (instancetype)initByFrame:(CGRect)frame
{
    self = [DFUITools loadNib:@"KaraokeEQView"];
    if (self) {
        self.frame = frame;
        sW = frame.size.width;
        sH = frame.size.height;
        
        bleSDK = [JL_RunSDK sharedMe];
        
        titleLabel.text = kJL_TXT("sound_card_eq_title");
        self.alpha = 0.0;
        mSubView.layer.cornerRadius = kUI_Radius;
        mSubView.layer.masksToBounds= YES;
        mSubView.frame = CGRectMake(0, sH, sW, 580.0);
        
        CGRect rect_1 = CGRectMake(10, 70, sW-10.0, 580.0-70.0-80.0);
        mSliderView = [[DFSliderView alloc] initWithFrame:rect_1];
        [mSliderView setBottomColor:[UIColor clearColor]];
        [mSliderView setEqType:1];
        [mSubView addSubview:mSliderView];
        
        defaultArr = @[@(100),@(500),@(1000),@(4000),@(8000)];
        eqArr = @[@(0),@(0),@(0),@(0),@(0)];
        
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        if (model.mKaraokeMicFrequencyArray.count > 0) defaultArr = model.mKaraokeMicFrequencyArray;
        if (model.mKaraokeMicEQArray.count > 0)        eqArr      = model.mKaraokeMicEQArray;
        [mSliderView setSliderEqArray:eqArr EqFrequecyArray:defaultArr EqType:JL_EQTypeMutable];
        
        [mSliderView outputEqArray:^(NSArray * _Nonnull eqArray) {
            kJLLog(JLLOG_DEBUG,@"Mic EQ Change ---> %@",eqArray);
            [self->bleSDK.mBleEntityM.mCmdManager.mSoundCardManager cmdSetKaraoke:self->bleSDK.mBleEntityM.mCmdManager micEQ:eqArray result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
                
            }];
        } ChangeUI:nil];
        
        
        UIButton *topBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,self->sH-580.0+kUI_Radius)];
        [topBtn addTarget:self action:@selector(dismissMe) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:topBtn];
        topBtn.backgroundColor = [UIColor clearColor];
        
        [JLModel_Device observeModelProperty:@"mKaraokeMicEQArray" Action:@selector(noteKaraokeEQ:) Own:self];
    }
    return self;
}

-(void)showMe{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
        self->mSubView.frame = CGRectMake(0, self->sH-580.0+kUI_Radius, self->sW, 580.0);
    }];
}

-(void)dismissMe{
    [JLModel_Device removeModelProperty:@"mKaraokeMicEQArray" Own:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self->mSubView.frame = CGRectMake(0, self->sH, self->sW, 580.0);
    } completion:^(BOOL finished) {
        self.alpha = 0.0;
        [self->mSliderView outputEqArray:nil ChangeUI:nil];
        [self removeFromSuperview];
    }];
}

- (IBAction)btn_close:(id)sender {
    [self dismissMe];
}

- (IBAction)btn_reset:(id)sender {
    NSMutableArray *newEqArr = [NSMutableArray new];
    for (int i = 0 ; i < eqArr.count; i++) {
        [newEqArr addObject:@(0)];
    }
    if (newEqArr.count > 0) eqArr = newEqArr;
    
    [mSliderView setSliderEqArray:eqArr EqFrequecyArray:defaultArr EqType:JL_EQTypeMutable];
    
    JL_ManagerM *manager = [bleSDK.mBleEntityM mCmdManager];
    JL_SoundCardManager *sc = [bleSDK.mBleEntityM.mCmdManager mSoundCardManager];
    [sc cmdSetKaraoke:manager micEQ:eqArr result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        
    }];
}

-(void)noteKaraokeEQ:(NSNotification*)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO) return;
    
    JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
    if (model.mKaraokeMicFrequencyArray.count > 0) defaultArr = model.mKaraokeMicFrequencyArray;
    if (model.mKaraokeMicEQArray.count > 0)        eqArr      = model.mKaraokeMicEQArray;
    [mSliderView setSliderEqArray:eqArr EqFrequecyArray:defaultArr EqType:JL_EQTypeMutable];
}

@end
