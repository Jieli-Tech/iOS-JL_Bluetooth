//
//  DeviceChangeCell.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DeviceChangeCell.h"
#import "JL_RunSDK.h"

@interface DeviceChangeCell(){
    UIView *bgview;
}
@end

@implementation DeviceChangeCell

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        float sW = [DFUITools screen_2_W];
        self.backgroundColor = [UIColor clearColor];
        
        bgview = [[UIView alloc] init];
        bgview.frame = CGRectMake(14,7.5,sW-28.0,55);
        bgview.backgroundColor = [UIColor whiteColor];
        bgview.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.2).CGColor;
        bgview.layer.shadowOffset = CGSizeMake(0,1);
        bgview.layer.shadowOpacity = 1;
        bgview.layer.shadowRadius = 8;
        bgview.layer.borderWidth = 1;
        bgview.layer.borderColor = kDF_RGBA(122, 83, 233, 1.0).CGColor;
        bgview.layer.cornerRadius = 5;
        [self.contentView addSubview:bgview];
        
        self.mImageView = [[UIImageView alloc] init];
        self.mImageView.frame = CGRectMake(5.0, 10.0, 38, 38);
        [bgview addSubview:self.mImageView];
        
        self.mLabelName = [[UILabel alloc] init];
        self.mLabelName.frame = CGRectMake(53,18,200,20);
        self.mLabelName.numberOfLines = 0;
        self.mLabelName.textColor = kDF_RGBA(36, 36, 36, 1.0);
        self.mLabelName.font = [UIFont systemFontOfSize:14];
        [bgview addSubview:self.mLabelName];
        self.mLabelName.text = @"AC693.BT";
        
        CGFloat length = [self getWidthWithString:kJL_TXT("未连接") font:[UIFont systemFontOfSize:13]];
        
        self.activeView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(bgview.frame.size.width-length-12-20-25, 25.5, 20, 20)];
        [self.activeView startAnimating];
        [self addSubview:self.activeView];
        
        self.mLabelStatus = [[UILabel alloc] init];
        self.mLabelStatus.frame = CGRectMake(bgview.frame.size.width-length-12-30,20,length,15);
        self.mLabelStatus.numberOfLines = 0;
        self.mLabelStatus.textColor = kDF_RGBA(27, 192, 23, 1.0);
        self.mLabelStatus.font = [UIFont systemFontOfSize:13];
        self.mLabelStatus.textAlignment = NSTextAlignmentRight;
        [bgview addSubview:self.mLabelStatus];

        self.mLabelStatus.text = kJL_TXT("已连接");
        
        UIButton *infoBtn = [UIButton new];
        infoBtn.frame = CGRectMake(bgview.frame.size.width-25, 20, 30, 30);
        [infoBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_news"] forState:UIControlStateNormal];
        [self addSubview:infoBtn];
        
        [infoBtn addTarget:self action:@selector(actionInfoBtn)
          forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)setUuid:(NSString *)uuid{
    _uuid = uuid;
    
    /*--- 连接状态 ---*/
    JLUuidType type = [JL_RunSDK getStatusUUID:uuid];
    /*--- 未连接 ---*/
    if (type == JLUuidTypeDisconnected) {
        CGFloat length = [self getWidthWithString:kJL_TXT("未连接") font:[UIFont systemFontOfSize:13]];
        self.mLabelStatus.frame = CGRectMake(bgview.frame.size.width-length-12-30,20,length,15);
        self.mLabelStatus.textColor = [UIColor colorWithRed:95.0/255.0 green:95.0/255.0 blue:95.0/255.0 alpha:1.0];
        self.mLabelStatus.text = kJL_TXT("未连接");
        bgview.layer.borderColor = [UIColor clearColor].CGColor;
    }
    
    /*--- 需要OTA升级 ---*/
    if (type == JLUuidTypeNeedOTA) {
        CGFloat length = [self getWidthWithString:kJL_TXT("需要升级") font:[UIFont systemFontOfSize:13]]+6.0;
        self.mLabelStatus.frame = CGRectMake(bgview.frame.size.width-length-12-30,20,length,15);
        self.mLabelStatus.textColor = [UIColor redColor];
        self.mLabelStatus.text = kJL_TXT("需要升级");
        bgview.layer.borderColor = kColor_0000.CGColor;//[UIColor colorWithRed:255.0/255.0 green:222.0/255.0 blue:52.0/255.0 alpha:1.0].CGColor;
    }
    
    /*--- 已连接 ---*/
    if (type == JLUuidTypeConnected) {
        CGFloat length = [self getWidthWithString:kJL_TXT("已连接") font:[UIFont systemFontOfSize:13]];
        self.mLabelStatus.frame = CGRectMake(bgview.frame.size.width-length-12-30,20,length,15);
        self.mLabelStatus.textColor = [UIColor colorWithRed:27/255.0 green:192.0/255.0 blue:23.0/255.0 alpha:1.0];
        self.mLabelStatus.text = kJL_TXT("已连接");
        bgview.layer.borderColor = kColor_0000.CGColor;//[UIColor colorWithRed:27/255.0 green:192.0/255.0 blue:23.0/255.0 alpha:1.0].CGColor;
    }
    
    /*--- 配置中 ---*/
    if (type == JLUuidTypePreparing) {
        CGFloat length = [self getWidthWithString:kJL_TXT("配置中...") font:[UIFont systemFontOfSize:13]]+6.0;
        self.mLabelStatus.frame = CGRectMake(bgview.frame.size.width-length-12-30,20,length,13);
        self.mLabelStatus.textColor = [UIColor colorWithRed:31.0/255.0 green:150.0/255.0 blue:243.0/255.0 alpha:1.0];
        self.mLabelStatus.text = kJL_TXT("配置中...");
        bgview.layer.borderColor = kColor_0000.CGColor;//[UIColor colorWithRed:31.0/255.0 green:150.0/255.0 blue:243.0/255.0 alpha:1.0].CGColor;
    }
    
    /*--- 正在使用 ---*/
    if (type == JLUuidTypeInUse) {
        CGFloat length = [self getWidthWithString:kJL_TXT("正在使用") font:[UIFont systemFontOfSize:13]]+6.0;
        self.mLabelStatus.frame = CGRectMake(bgview.frame.size.width-length-12-30,20,length,15);
        self.mLabelStatus.textColor = [UIColor colorWithRed:31.0/255.0 green:150.0/255.0 blue:243.0/255.0 alpha:1.0];
        self.mLabelStatus.text = kJL_TXT("正在使用");
        bgview.layer.borderColor = kColor_0000.CGColor;//[UIColor colorWithRed:31.0/255.0 green:150.0/255.0 blue:243.0/255.0 alpha:1.0].CGColor;
    }

}

-(void)setCellIsConnect:(BOOL)isOk{
    self.isConnect = isOk;
    CGFloat length = [self getWidthWithString:kJL_TXT("已连接") font:[UIFont systemFontOfSize:13]];
    self.mLabelStatus.frame = CGRectMake(bgview.frame.size.width-length-12-30,20,length,15);
    if (isOk) {
        bgview.layer.borderColor = kColor_0000.CGColor;
        self.mLabelStatus.textColor = kDF_RGBA(27, 192, 23, 1.0);
        self.mLabelStatus.text = kJL_TXT("已连接");
    }else{
        bgview.layer.borderColor = [UIColor clearColor].CGColor;
        self.mLabelStatus.textColor = kDF_RGBA(163, 163, 163, 1.0);
        self.mLabelStatus.text = kJL_TXT("未连接");
    }
}
- (void)setIsWorking:(BOOL)isWorking{
    _isWorking = isWorking;
    if (self.isConnect && self.isWorking) {
        CGFloat length = [self getWidthWithString:kJL_TXT("正在使用") font:[UIFont systemFontOfSize:13]];
        self.mLabelStatus.frame = CGRectMake(bgview.frame.size.width-length-12-30,20,length,15);
        bgview.layer.borderColor = kColor_0000.CGColor;
        self.mLabelStatus.textColor = kDF_RGBA(31, 150, 243, 1.0);
        self.mLabelStatus.text = kJL_TXT("正在使用");
    }
}


-(double)getWidthWithString:(NSString*)str font:(UIFont*)font{
    NSDictionary *dict = @{NSFontAttributeName:font};
    CGSize detailSize = [str sizeWithAttributes:dict];
    return detailSize.width;
}

-(void)actionInfoBtn{
    
    if ([[JL_RunSDK sharedMe] mBleMultiple].bleManagerState == CBManagerStatePoweredOff) {
        [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self delay:1.0];
        return;
    }
    if ([_delegate respondsToSelector:@selector(onDeviceInfoBtnTag:)]) {
        [_delegate onDeviceInfoBtnTag:_mTag];
    }
}



@end
