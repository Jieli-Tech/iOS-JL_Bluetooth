//
//  DeviceCell_2.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/9/28.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DeviceCell_2.h"
#import "DeviceInfoTools.h"

NSString *kUI_DEVICE_CELL_LOCAL = @"UI_DEVICE_CELL_LOCAL";
NSString *kUI_DEVICE_CELL_DELETE = @"UI_DEVICE_CELL_DELETE";
NSString *kUI_DEVICE_CELL_LONGPRESS = @"UI_DEVICE_CELL_LONGPRESS";

@interface DeviceCell_2()<LanguagePtl>{
    
    __weak IBOutlet UIView *subBgView;
    
    __weak IBOutlet UIImageView *subImage_0;
    __weak IBOutlet UIImageView *subImage_1;
    __weak IBOutlet UIImageView *subImage_2;
    
    __weak IBOutlet NSLayoutConstraint *subImage_0_H;
    __weak IBOutlet NSLayoutConstraint *subImage_1_H;
    __weak IBOutlet NSLayoutConstraint *subImage_2_H;
    
    
    __weak IBOutlet UILabel *subLb_0;
    __weak IBOutlet UILabel *subLb_1;
    __weak IBOutlet UILabel *subLb_2;
    __weak IBOutlet NSLayoutConstraint *subLb_0_W;
    __weak IBOutlet NSLayoutConstraint *subLb_1_W;
    __weak IBOutlet NSLayoutConstraint *subLb_2_W;
    
    __weak IBOutlet NSLayoutConstraint *subLb_0_H;
    __weak IBOutlet NSLayoutConstraint *subLb_1_H;
    __weak IBOutlet NSLayoutConstraint *subLb_2_H;
    
    
    __weak IBOutlet UIImageView *subImage_L;
    __weak IBOutlet UIImageView *subImage_R;
    __weak IBOutlet NSLayoutConstraint *subImage_L_H;
    __weak IBOutlet NSLayoutConstraint *subImage_R_H;
    
    
    __weak IBOutlet UIImageView *subImage_P0;
    __weak IBOutlet UIImageView *subImage_P1;
    __weak IBOutlet UIImageView *subImage_P2;
    __weak IBOutlet NSLayoutConstraint *subImage_P0_H;
    __weak IBOutlet NSLayoutConstraint *subImage_P1_H;
    __weak IBOutlet NSLayoutConstraint *subImage_P2_H;
    
    
    __weak IBOutlet UILabel *subLb_P0;
    __weak IBOutlet UILabel *subLb_P1;
    __weak IBOutlet UILabel *subLb_P2;
    __weak IBOutlet NSLayoutConstraint *subLb_P0_H;
    __weak IBOutlet NSLayoutConstraint *subLb_P1_H;
    __weak IBOutlet NSLayoutConstraint *subLb_P2_H;
    
    
    __weak IBOutlet UIButton *subImage_Local;
    __weak IBOutlet UILabel *subLb_ST;
    __weak IBOutlet UIButton *subBtn_Del;
    UIImageView *subImv;
    UILabel *subLb_Using;
}

@end

@implementation DeviceCell_2

- (void)awakeFromNib {
    [super awakeFromNib];
    [[LanguageCls share] add:self];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)init
{
    self = [DFUITools loadNib:@"DeviceCell_2"];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        //[JLUI_Effect addShadowOnView_2:subBgView];
        
        subBgView.backgroundColor = kDF_RGBA(255, 255, 255, 1);
        subBgView.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.2).CGColor;
        subBgView.layer.shadowOffset = CGSizeMake(0,1);
        subBgView.layer.shadowOpacity = 1;
        subBgView.layer.shadowRadius = 8;
        subBgView.layer.cornerRadius = 10;
        
        subLb_ST.layer.cornerRadius = 4;
        subLb_ST.layer.masksToBounds = YES;
        
//        subLb_Using.layer.cornerRadius = 4;
//        subLb_Using.layer.masksToBounds = YES;
        
        subImv = [[UIImageView alloc] init];
        subImv.frame = CGRectMake(self.frame.size.width/2-100/2-10,8,100,24);
        subImv.image =  [UIImage imageNamed:@"Theme.bundle/product_tag_use"];
        subImv.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:subImv];
        
        subLb_Using = [[UILabel alloc] init];
      
        subLb_Using.frame = CGRectMake(0,24/2-11.5/2,subImv.frame.size.width,15);
        subLb_Using.textAlignment = NSTextAlignmentCenter;
        [subImv addSubview:subLb_Using];
        subLb_Using.font =  [UIFont fontWithName:@"PingFangSC-Regular" size: 12];
        subLb_Using.text = kJL_TXT("device_status_using_1");
        subLb_Using.textColor = kDF_RGBA(68, 142, 255, 1.0);
        
        UILongPressGestureRecognizer *lg = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                         action:@selector(longPressAction:)];
        lg.minimumPressDuration = 0.5;
        [self addGestureRecognizer:lg];
        
        [self updatePostion_0];
    }
    return self;
}

-(void)updatePostion_0{
    subImage_0_H.constant = -55.0;
    subImage_1_H.constant = 0;
    subImage_2_H.constant = +55.0;
    
    subLb_0_H.constant = -55.0;
    subLb_1_H.constant = 0;
    subLb_2_H.constant = +55.0;
    
    subImage_L_H.constant = -55.0;
    subImage_R_H.constant = 0;
    
    subImage_P0_H.constant = -55.0;
    subImage_P1_H.constant = 0;
    subImage_P2_H.constant = +55.0;

    subLb_P0_H.constant = -55.0;
    subLb_P1_H.constant = 0;
    subLb_P2_H.constant = +55.0;
    
}

-(void)updatePostion_1{
    subImage_2.hidden  = YES;
    subLb_2.hidden     = YES;
    
    subImage_P2.hidden = YES;
    subLb_P2.hidden    = YES;
    
    subImage_0_H.constant = -25.0;
    subImage_1_H.constant = +30.0;
    subImage_2_H.constant = +35.0;
    
    subLb_0_H.constant = -25.0;
    subLb_1_H.constant = +30.0;
    subLb_2_H.constant = +35.0;
    
    subImage_L_H.constant = -25.0;
    subImage_R_H.constant = +30.0;
    
    subImage_P0_H.constant = -25.0;
    subImage_P1_H.constant = +30.0;
    subImage_P2_H.constant = +35.0;

    subLb_P0_H.constant = -25.0;
    subLb_P1_H.constant = +30.0;
    subLb_P2_H.constant = +35.0;
}

-(void)updatePostion_2:(BOOL)isL{
    subImage_1.hidden  = YES;
    subImage_2.hidden  = YES;
    
    subLb_1.hidden     = YES;
    subLb_2.hidden     = YES;
    
    subImage_P1.hidden = YES;
    subImage_P2.hidden = YES;
    
    subLb_P1.hidden    = YES;
    subLb_P2.hidden    = YES;
    
    subImage_0_H.constant = 0;
    subImage_1_H.constant = +30.0;
    subImage_2_H.constant = +35.0;
    
    subLb_0_H.constant = -0;
    subLb_1_H.constant = +30.0;
    subLb_2_H.constant = +35.0;
    
    if (isL) {
        subImage_L_H.constant = 0;
        subImage_R_H.constant = +30.0;
        
        subImage_R.hidden = YES;
    }else{
        subImage_L_H.constant = +30.0;
        subImage_R_H.constant = 0;
        
        subImage_L.hidden = YES;
    }

    
    subImage_P0_H.constant = 0;
    subImage_P1_H.constant = +30.0;
    subImage_P2_H.constant = +35.0;

    subLb_P0_H.constant = 0;
    subLb_P1_H.constant = +30.0;
    subLb_P2_H.constant = +35.0;
}


-(void)setMSubObject:(DeviceObjc *)mSubObject{
    
    _mSubObject = mSubObject;
    
    JL_DeviceType type = _mSubObject.type;
    NSString *uuid = _mSubObject.uuid;
    JLUuidType uuidType = [JL_RunSDK getStatusUUID:uuid];
        
    /*--- 图标，名字，电量 ---*/
    if (type == JL_DeviceTypeTWS) {
        subImage_0.hidden = NO;
        subImage_1.hidden = NO;
        subImage_2.hidden = NO;
        
        subLb_0.hidden = NO;
        subLb_1.hidden = NO;
        subLb_2.hidden = NO;
        
        subImage_L.hidden = NO;
        subImage_R.hidden = NO;
        
        subImage_P0.hidden = NO;
        subImage_P1.hidden = NO;
        subImage_P2.hidden = NO;
        subLb_P0.hidden = NO;
        subLb_P1.hidden = NO;
        subLb_P2.hidden = NO;

        if (uuidType == JLUuidTypeDisconnected ||
            uuidType == JLUuidTypeNeedOTA) {
            if(mSubObject.mProtocolType == PTLVersion){
                [self setImageView:subImage_1 DeviceUuid:uuid Image:@"PRODUCT_LOGO" Default:@"img_earphone03"];
            }else{
                [self setImageView:subImage_1 DeviceUuid:uuid Image:@"CHARGING_BIN_IDLE" Default:@"product_img_chargingbin"];
            }
            
            subLb_1.text = [NSString stringWithFormat:@"%@",_mSubObject.name];
            NSLog(@"name:%@,%d",_mSubObject.name,subLb_1.isHidden);
            subLb_1_W.constant = [self getWidthText:subLb_1.text];
            
            subImage_0.hidden = YES;
            subImage_2.hidden = YES;
            
            subLb_0.hidden = YES;
            subLb_2.hidden = YES;
            
            subImage_L.hidden = YES;
            subImage_R.hidden = YES;
            
            subImage_P0.hidden = YES;
            subImage_P1.hidden = YES;
            subImage_P2.hidden = YES;
            
            subLb_P0.hidden = YES;
            subLb_P1.hidden = YES;
            subLb_P2.hidden = YES;
        }else{
            [self setImageView:subImage_0 DeviceUuid:uuid Image:@"LEFT_DEVICE_CONNECTED" Default:@"product_img_earphone_02"];
            [self setImageView:subImage_1 DeviceUuid:uuid Image:@"RIGHT_DEVICE_CONNECTED" Default:@"product_img_earphone_01"];
            [self setImageView:subImage_2 DeviceUuid:uuid Image:@"CHARGING_BIN_IDLE" Default:@"product_img_chargingbin"];

            subLb_0.text = [NSString stringWithFormat:@"%@ %@",_mSubObject.name,kJL_TXT("left")];
            subLb_1.text = [NSString stringWithFormat:@"%@ %@",_mSubObject.name,kJL_TXT("right")];
            subLb_2.text = [NSString stringWithFormat:@"%@ %@",_mSubObject.name,kJL_TXT("charging_txt")];

            subLb_0_W.constant = [self getWidthText:subLb_0.text];
            subLb_1_W.constant = [self getWidthText:subLb_1.text];
            subLb_2_W.constant = [self getWidthText:subLb_2.text];
            
            if (mSubObject.mProtocolType == PTLVersion) {
                [self updatePostion_2:YES];
                [self setImageView:subImage_0 DeviceUuid:uuid Image:@"PRODUCT_LOGO" Default:@"img_earphone03"];
                subLb_0.text = [NSString stringWithFormat:@"%@",_mSubObject.name];
                subImage_L.hidden = true;
                subLb_0_W.constant = [self getWidthText:subLb_0.text];
            }
            
        }
    }else{
        subImage_0.hidden = YES;
        subImage_1.hidden = NO;
        subImage_2.hidden = YES;
        
        subLb_0.hidden = YES;
        subLb_1.hidden = NO;
        subLb_2.hidden = YES;
        
        subImage_L.hidden = YES;
        subImage_R.hidden = YES;
        
        subImage_P0.hidden = YES;
        subImage_P1.hidden = NO;
        subImage_P2.hidden = YES;
        subLb_P0.hidden = YES;
        subLb_P1.hidden = NO;
        subLb_P2.hidden = YES;

        if(type == JL_DeviceTypeSoundCard){ //声卡
            [self setImageView:subImage_1 DeviceUuid:uuid
                         Image:@"PRODUCT_LOGO"
                       Default:@"img_mic"];
        }else{ //音箱
            [self setImageView:subImage_1 DeviceUuid:uuid
                         Image:@"PRODUCT_LOGO"
                       Default:@"product_img_speaker"];
        }
        
        subLb_1.text = _mSubObject.name;
        subLb_1_W.constant = [self getWidthText:subLb_1.text];
        
        if (uuidType == JLUuidTypeDisconnected ||
            uuidType == JLUuidTypeNeedOTA) {
            subImage_P1.hidden = YES;
            subLb_P1.hidden = YES;
        }
    }
    subLb_ST.hidden       = YES;
    subImv.hidden         = YES;
    subLb_Using.hidden    = YES;
    subBtn_Del.hidden     = YES;
    subImage_Local.hidden = YES;
    
    /*--- 删除设备 ---*/
    if (self.isDelete) {
        if (uuidType == JLUuidTypeDisconnected) {
            subBtn_Del.hidden = NO;
        }else{
            subBtn_Del.hidden = YES;
        }
    }else{
        subBtn_Del.hidden  = YES;
    }
    
    /*--- 查找设备 ---*/
    if ([_mSubObject.findDevice isEqual:@"1"]) {
        subImage_Local.hidden = NO;
    }else{
        subImage_Local.hidden = YES;
    }
    
    /*--- 连接状态标志 ---*/
    if (uuidType == JLUuidTypeInUse) {
        subImv.hidden = NO;
        subLb_Using.hidden = NO;
        subLb_Using.text = kJL_TXT("device_status_using_1");
    }
    if (uuidType == JLUuidTypePreparing) {
        subImv.hidden = NO;
        subLb_Using.hidden = NO;
        subLb_Using.text = kJL_TXT("configing2");
    }
    if (uuidType == JLUuidTypeNeedOTA) {
        subImv.hidden = YES;
        subLb_Using.hidden = YES;
        subLb_ST.hidden = NO;
        subLb_ST.text = kJL_TXT("need_upgrade");
        subLb_ST.textColor = [UIColor redColor];
        
        subImage_P0.hidden = YES;
        subImage_P1.hidden = YES;
        subImage_P2.hidden = YES;
        subLb_P0.hidden = YES;
        subLb_P1.hidden = YES;
        subLb_P2.hidden = YES;
    }
    if (uuidType == JLUuidTypeDisconnected) {
        subImv.hidden = YES;
        subLb_Using.hidden = YES;
        subLb_ST.hidden = NO;
        subLb_ST.text = kJL_TXT("device_status_unconnected");
        subLb_ST.textColor = kDF_RGBA(95, 95, 95, 1.0);
        
        subImage_P0.hidden = YES;
        subImage_P1.hidden = YES;
        subImage_P2.hidden = YES;
        subLb_P0.hidden = YES;
        subLb_P1.hidden = YES;
        subLb_P2.hidden = YES;
    }
    
    NSDictionary *dict = self.mPowerDict[uuid];
    if (dict) {
        if (type == JL_DeviceTypeTWS) {
            int pw_L = [dict[@"POWER_L"] intValue];
            int pw_R = [dict[@"POWER_R"] intValue];
            int pw_C = [dict[@"POWER_C"] intValue];
            
            NSDictionary *pDict_L = @{@"POWER":dict[@"POWER_L"]?:@(0),@"CHARING":dict[@"ISCHARGING_L"]?:@(0)};
            NSDictionary *pDict_R = @{@"POWER":dict[@"POWER_R"]?:@(0),@"CHARING":dict[@"ISCHARGING_R"]?:@(0)};
            NSDictionary *pDict_C = @{@"POWER":dict[@"POWER_C"]?:@(0),@"CHARING":dict[@"ISCHARGING_C"]?:@(0)};
            
            if (pw_L > 0 && pw_R > 0 && pw_C > 0) {
                [self updatePostion_0];
                subImage_P0.image = [self powerTypeWithDict:pDict_L];
                subImage_P1.image = [self powerTypeWithDict:pDict_R];
                subImage_P2.image = [self powerTypeWithDict:pDict_C];
                subLb_P0.text = [NSString stringWithFormat:@"%@%%",dict[@"POWER_L"]];
                subLb_P1.text = [NSString stringWithFormat:@"%@%%",dict[@"POWER_R"]];
                subLb_P2.text = [NSString stringWithFormat:@"%@%%",dict[@"POWER_C"]];
            }else{
                if (pw_L > 0 && pw_R > 0) {
                    [self updatePostion_1];
                    subImage_P0.image = [self powerTypeWithDict:pDict_L];
                    subImage_P1.image = [self powerTypeWithDict:pDict_R];
                    subLb_P0.text = [NSString stringWithFormat:@"%@%%",dict[@"POWER_L"]];
                    subLb_P1.text = [NSString stringWithFormat:@"%@%%",dict[@"POWER_R"]];
                }else{
                    if (pw_L > 0) {
                        [self updatePostion_2:YES];
                        subImage_P0.image = [self powerTypeWithDict:pDict_L];
                        if (dict[@"POWER_L"]) subLb_P0.text = [NSString stringWithFormat:@"%@%%",dict[@"POWER_L"]];
                        
                        subLb_0.text = [NSString stringWithFormat:@"%@ 左",_mSubObject.name];
                        subLb_0_W.constant = [self getWidthText:subLb_0.text];
                        [self setImageView:subImage_0 DeviceUuid:uuid Image:@"LEFT_DEVICE_CONNECTED" Default:@"product_img_earphone_02"];
                        
                    }else{
                        [self updatePostion_2:NO];
                        subImage_P0.image = [self powerTypeWithDict:pDict_R];
                        subLb_P0.text = [NSString stringWithFormat:@"%@%%",dict[@"POWER_R"]];
                        
                        subLb_0.text = [NSString stringWithFormat:@"%@ 右",_mSubObject.name];
                        subLb_0_W.constant = [self getWidthText:subLb_0.text];
                        [self setImageView:subImage_0 DeviceUuid:uuid Image:@"RIGHT_DEVICE_CONNECTED" Default:@"product_img_earphone_01"];
                        
                    }
                }
            }
            //挂脖耳机
            if(mSubObject.mProtocolType == PTLVersion){
                
                [self setImageView:subImage_0 DeviceUuid:uuid
                             Image:@"PRODUCT_LOGO"
                           Default:@"img_earphone03"];
                if (dict[@"POWER_L"]) subLb_P0.text = [NSString stringWithFormat:@"%@%%",dict[@"POWER_L"]];
                subLb_0.text = [NSString stringWithFormat:@"%@",_mSubObject.name];
                subImage_L.hidden = true;
                subLb_0_W.constant = [self getWidthText:subLb_0.text];
                
            }
            
        }else{
            [self updatePostion_0];
            
            NSDictionary *pDict = @{@"POWER":dict[@"POWER_L"]?:@(0),@"CHARING":dict[@"ISCHARGING_L"]?:@(0)};
            subImage_P1.image = [self powerTypeWithDict:pDict];
            subLb_P1.text = [NSString stringWithFormat:@"%@%%",dict[@"POWER_L"]];
        }
    }
    
}


+(float)cellHeightWithModel:(DeviceObjc*)model PowerDict:(NSMutableDictionary*)powerDict{
    
    NSDictionary *dict = powerDict[model.uuid];
    JL_DeviceType type = model.type;
    if (type == JL_DeviceTypeTWS) {
        int pw_L = [dict[@"POWER_L"] intValue];
        int pw_R = [dict[@"POWER_R"] intValue];
        int pw_C = [dict[@"POWER_C"] intValue];
        
        //挂脖耳机
        if(model.mProtocolType == PTLVersion){
            return 110;
        }

        NSString *uuid = model.uuid;
        JLUuidType type= [JL_RunSDK getStatusUUID:uuid];
        if (type == JLUuidTypeDisconnected ||
            type == JLUuidTypeNeedOTA) {
            return 110;
        }else{
            if (dict == nil) return 220;
            if (pw_L > 0 && pw_R > 0 && pw_C > 0) {
                return 220;
            }else{
                if (pw_L > 0 && pw_R > 0) {
                    return 160;
                }else{
                    return 110;
                }
            }
        }
        
    }else{
        return 110;
    }
}


-(void)setImageView:(UIImageView*)imageView
         DeviceUuid:(NSString*)uuid
              Image:(NSString*)image
            Default:(NSString*)def{
    NSData *imgData = [self getEarphoneImageUUID:uuid Name:image];
    if(imgData == nil){
        NSString *txt = [NSString stringWithFormat:@"Theme.bundle/%@",def];
        imageView.image = [UIImage imageNamed:txt];
    }else{
        imageView.image = [UIImage imageWithData:imgData];
    }
}

- (void)longPressAction:(UILongPressGestureRecognizer *)sender{
     if (sender.state == UIGestureRecognizerStateBegan) {
         AudioServicesPlaySystemSound(1519);
         [JL_Tools post:kUI_DEVICE_CELL_LONGPRESS Object:nil];
     }
}

- (IBAction)btn_Delete:(id)sender {
    [JL_Tools post:kUI_DEVICE_CELL_DELETE Object:@(_mIndex)];
}

- (IBAction)btn_Local:(id)sender {
    [JL_Tools post:kUI_DEVICE_CELL_LOCAL Object:@(_mIndex)];
}


-(NSData *)getEarphoneImageUUID:(NSString*)uuid Name:(NSString*)name{
    NSString *imageName = [NSString stringWithFormat:@"%@_%@",name,uuid];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory
                             MiddlePath:@"" File:imageName];
    NSData *data = nil;
    if (path) {
        data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    }
    return data;
}
-(UIImage*)OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;   //返回的就是已经改变的图片
}

-(float)getWidthText:(NSString*)text{
    UIFont *font = [UIFont systemFontOfSize:14];
    NSDictionary *attribute = @{NSFontAttributeName:font};
    CGRect retSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 30)
                                        options:NSStringDrawingTruncatesLastVisibleLine |
                                                NSStringDrawingUsesLineFragmentOrigin |
                                                NSStringDrawingUsesFontLeading
                                                attributes:attribute context:nil];
    return retSize.size.width;
}




+(NSString*)ID{
    return @"DEVICECELL_2";
}


-(UIImage *)powerTypeWithDict:(NSDictionary *)dict{
    int power = [dict[@"POWER"] intValue];
    BOOL charing = [dict[@"CHARING"] boolValue];
    UIImage *image;
    //电量为0到20
    if(power>0 && power<=20){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_0"];
    }
    //电量为21到35
    if(power>20 && power<=35){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_1"];
    }
    //电量为36到50
    if(power>35 && power<=50){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_2"];
    }
    //电量为51到75
    if(power>50 && power<=75){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_3"];
    }
    //电量为76到100
    if(power>75 && power<=100){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_4"];
    }
    //充电中
    if(charing == YES){
        image = [UIImage imageNamed:@"Theme.bundle/product_icon_cell_5"];
    }
    return image;
}

-(void)languageChange{
    
}

@end
