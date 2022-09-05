//
//  DevicesCardView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DevicesCardView.h"
#import "HeadSetStatusView.h"
#import "JL_RunSDK.h"
#import "DeviceInfoTools.h"


@interface DevicesCardView (){
    HeadSetStatusView *leftView;
    HeadSetStatusView *rightView;
    HeadSetStatusView *chargeView;
    HeadSetStatusView *soundBoxView;
    HeadSetStatusView *shengKaView;

    UIImageView *noneView;
    UILabel *noneLab;
    JL_RunSDK *bleSDK;
}
@end

@implementation DevicesCardView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self stepUI];
        [self addNote];
    }
    return self;
}

-(void)addNote{
    [JL_Tools add:kJL_MANAGER_HEADSET_ADV Action:@selector(handleHeadsetInfo:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:kJL_MANAGER_HEADSET_ADV Own:self];
}

-(void)stepUI{
    bleSDK = [JL_RunSDK sharedMe];
    
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height;
    
    noneView = [[UIImageView alloc] initWithFrame:CGRectMake(w/2-64.0, h/2-42.0, 128.0, 84.0)];
    noneView.contentMode = UIViewContentModeCenter;
    noneView.image = [UIImage imageNamed:@"Theme.bundle/product_img_empty_01"];
    [self addSubview:noneView];
    
    noneLab = [[UILabel alloc] initWithFrame:CGRectMake(w/2-60.0, h-40.0, 120.0, 25.0)];
    noneLab.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1.0];
    noneLab.textAlignment = NSTextAlignmentCenter;
    noneLab.font = [UIFont systemFontOfSize:15];
    noneLab.text = kJL_TXT("none_data");
    [self addSubview:noneLab];
    
    NSDictionary *dic = @{@"power":@"100",@"charing":@"0"};
    leftView = [[HeadSetStatusView alloc] initWithFrame:CGRectMake(self.frame.size.width/4-57.0, 20.0, 55, 115)];
    leftView.type = HeadSetType_L;
    leftView.powerDict = dic;
    [self addSubview:leftView];
    leftView.hidden = YES;
    
    rightView = [[HeadSetStatusView alloc] initWithFrame:CGRectMake(self.frame.size.width/4-57.0+80.0, 20.0, 55, 115.0)];
    rightView.type = HeadSetType_R;
    rightView.powerDict = dic;
    [self addSubview:rightView];
    rightView.hidden = YES;
    
    chargeView = [[HeadSetStatusView alloc] initWithFrame:CGRectMake(w/2+55.0, 20.0, 55, 115.0)];
    chargeView.type = HeadSetType_C;
    chargeView.powerDict = dic;
    [self addSubview:chargeView];
    chargeView.hidden = YES;
    
    soundBoxView = [[HeadSetStatusView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-27, 20.0, 55.0, 115.0)];
    soundBoxView.type = HeadSetType_BOX;
    soundBoxView.powerDict = dic;
    [self addSubview:soundBoxView];
    soundBoxView.hidden = YES;
    
    shengKaView = [[HeadSetStatusView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-27, 20.0, 55.0, 115.0)];
    shengKaView.type = HeadSetType_SHENGKA;
    shengKaView.powerDict = dic;
    [self addSubview:shengKaView];
    shengKaView.hidden = YES;

    [leftView configUuid:bleSDK.mBleEntityM.mUUID];
    [rightView configUuid:bleSDK.mBleEntityM.mUUID];
    [chargeView configUuid:bleSDK.mBleEntityM.mUUID];
    [soundBoxView configUuid:bleSDK.mBleEntityM.mUUID];
    [shengKaView configUuid:bleSDK.mBleEntityM.mUUID];
}

-(void)configPowerStatus:(NSDictionary *__nullable)dict{
    if (dict.allKeys.count == 0) {
        noneLab.hidden = NO;
        noneView.hidden = NO;
        leftView.hidden = YES;
        rightView.hidden = YES;
        chargeView.hidden = YES;
        soundBoxView.hidden = YES;
        shengKaView.hidden = YES;
        return;
    }

    
    NSString *uuid = bleSDK.mBleEntityM.mUUID;
    JL_DeviceType type = bleSDK.mBleEntityM.mType;
    if (type == JL_DeviceTypeSoundBox) {
        noneLab.hidden    = YES;
        noneView.hidden   = YES;
        leftView.hidden   = YES;
        rightView.hidden  = YES;
        chargeView.hidden = YES;
        shengKaView.hidden = YES;
        soundBoxView.hidden = NO;

        CGRect soundBoxRect = CGRectMake(self.frame.size.width/2-27, 20.0, 55.0, 115.0);
        soundBoxView.frame = soundBoxRect;

        NSDictionary *dic = @{@"power":dict[@"POWER_L"]?:@(0),@"charing":dict[@"ISCHARGING_L"]?:@(0)};
        soundBoxView.powerDict = dic;
        [soundBoxView configUuid:uuid];
        
        return;
    }
    if (type == JL_DeviceTypeTWS) {
        noneLab.hidden    = YES;
        noneView.hidden   = YES;
        leftView.hidden   = NO;
        rightView.hidden  = NO;
        chargeView.hidden = NO;
        soundBoxView.hidden = YES;

        
        int powL = [dict[@"POWER_L"] intValue];
        int powR = [dict[@"POWER_R"] intValue];
        int chongBin = [dict[@"POWER_C"] intValue];

        CGRect leftRect = CGRectMake(self.frame.size.width/4-57.0, 20.0, 55, 115);
        CGRect rightRect = CGRectMake(self.frame.size.width/4-57.0+80.0, 20.0, 55, 115.0);
        CGRect chargeRect = CGRectMake(self.frame.size.width/2+55.0, 20.0, 55, 115.0);
        if (powL!=0 && powR!=0 && chongBin!=0) {//左右仓都在
            leftRect = CGRectMake(self.frame.size.width/4-57.0, 20.0, 55, 115);
            rightRect = CGRectMake(self.frame.size.width/4-57.0+80.0, 20.0, 55, 115.0);
            chargeRect = CGRectMake(self.frame.size.width/2+55.0, 20.0, 55, 115.0);
            chargeView.hidden = NO;
            leftView.hidden = NO;
            rightView.hidden = NO;
        }else if (powL!=0 && powR!=0 && chongBin == 0) {//左右都在
            //左右耳都在
            leftRect = CGRectMake(self.frame.size.width/2-62.0, 20.0, 55.0, 115.0);
            rightRect = CGRectMake(self.frame.size.width/2-57.0+70.0, 20.0, 55.0, 115.0);
            chargeView.hidden = YES;
            leftView.hidden = NO;
            rightView.hidden = NO;
        }else if (powL!=0 && powR == 0 && chongBin == 0) {//左在
            chargeView.hidden = YES;
            leftView.hidden = NO;
            rightView.hidden = YES;
            leftRect = CGRectMake(self.frame.size.width/2-27, 20.0, 55.0, 115.0);
        }else if (powL==0 && powR != 0 && chongBin == 0) {//右在
            chargeView.hidden = YES;
            leftView.hidden = YES;
            rightView.hidden = NO;
            rightRect = CGRectMake(self.frame.size.width/2-27, 20.0, 55.0, 115.0);
        }else if (powL==0 && powR == 0 && chongBin != 0) {//充电舱在
            chargeRect = CGRectMake(self.frame.size.width/2-27, 20.0, 55.0, 115.0);
            chargeView.hidden = NO;
            leftView.hidden = YES;
            rightView.hidden = YES;
        }else if (powL!=0 && powR == 0 && chongBin != 0) {//左和仓在//左+仓
            leftRect = CGRectMake(self.frame.size.width/2-57.0+15.0, 20.0, 55.0, 115.0);
            chargeRect = CGRectMake(self.frame.size.width/2+55.0, 20.0, 55, 115.0);
            chargeView.hidden = NO;
            leftView.hidden = NO;
            rightView.hidden = YES;
        }else if (powL==0 && powR != 0 && chongBin != 0) {//右和仓在
            rightRect = CGRectMake(self.frame.size.width/2-57.0+15.0, 20.0, 55.0, 115.0);
            chargeRect = CGRectMake(self.frame.size.width/2+55.0, 20.0, 55, 115.0);
            chargeView.hidden = NO;
            leftView.hidden = YES;
            rightView.hidden = NO;
        }
        chargeView.frame = chargeRect;
        leftView.frame = leftRect;
        rightView.frame = rightRect;
        
        if (powL != 0) {
            NSDictionary *dic = @{@"power":dict[@"POWER_L"]?:@(0),@"charing":dict[@"ISCHARGING_L"]?:@(0)};
            leftView.powerDict = dic;
            [leftView configUuid:uuid];
        }
        if (powR != 0) {
            NSDictionary *dic = @{@"power":dict[@"POWER_R"]?:@(0),@"charing":dict[@"ISCHARGING_R"]?:@(0)};
            rightView.powerDict = dic;
            [rightView configUuid:uuid];
        }
        if (chongBin != 0) {
            NSDictionary *dic = @{@"power":dict[@"POWER_C"]?:@(0),@"charing":dict[@"ISCHARGING_C"]?:@(0)};
            chargeView.powerDict = dic;
            [chargeView configUuid:uuid];
        }
        return;
    }
    if (type == JL_DeviceTypeSoundCard) {
        noneLab.hidden    = YES;
        noneView.hidden   = YES;
        leftView.hidden   = YES;
        rightView.hidden  = YES;
        chargeView.hidden = YES;
        soundBoxView.hidden = YES;
        shengKaView.hidden = NO;

        CGRect shengKaViewRect = CGRectMake(self.frame.size.width/2-27, 20.0, 55.0, 115.0);
        shengKaView.frame = shengKaViewRect;

        NSDictionary *dic = @{@"power":dict[@"POWER_L"]?:@(0),@"charing":dict[@"ISCHARGING_L"]?:@(0)};
        shengKaView.powerDict = dic;
        [shengKaView configUuid:uuid];
        
        return;
    }
}


-(void)handleHeadsetInfo:(NSNotification *)note{
    
    NSDictionary *info = note.object;
    NSString *uuid = info[kJL_MANAGER_KEY_UUID];
    JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
    
    if (type == JLUuidTypeInUse) {
        NSDictionary *dict = info[kJL_MANAGER_KEY_OBJECT];
        [self configPowerStatus:dict];
    }
}


@end
