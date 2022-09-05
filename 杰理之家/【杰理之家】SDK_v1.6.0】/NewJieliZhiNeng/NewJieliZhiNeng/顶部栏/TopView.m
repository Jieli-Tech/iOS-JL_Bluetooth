//
//  TopView.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "TopView.h"
#import "JL_RunSDK.h"

@interface TopView (){
    TopBlock_1 block_1;
    TopBlock_2 block_2;
    __weak IBOutlet UIView *bgView;
    __weak IBOutlet UIImageView *image_1;
    __weak IBOutlet UIImageView *lb_1;
    __weak IBOutlet UIButton *btn_2;
}

@end

@implementation TopView


- (instancetype)init
{
    self = [DFUITools loadNib:@"TopView"];
    if (self) {
        float sw = [UIScreen mainScreen].bounds.size.width;
        self.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+140);

        [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
        
        bgView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+140);
        image_1.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+140);
        image_1.image = [UIImage imageNamed:@"Theme.bundle/Mul_bg_3"];
        
        self.btnDevice.frame = CGRectMake(15, kJL_HeightStatusBar+3, 200, 44);
        self.lbText.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+24+11-10);
        
        lb_1.center = CGPointMake(124-20, kJL_HeightStatusBar+21+14.5-10);
        btn_2.center = CGPointMake(sw-30, kJL_HeightStatusBar+13+22-10);
        [DFUITools setButton:self.btnDevice Text:kJL_TXT("unconnected_device")];
    }
    return self;
}

- (void)onBLK_Device:(TopBlock_1)blk_1 BLK_Setting:(TopBlock_2)blk_2{
    block_1 = blk_1;
    block_2 = blk_2;
}
- (IBAction)btn_device:(id)sender {
    if (block_1) { block_1();}
}
- (IBAction)btn_setting:(id)sender {
    if (block_2) { block_2();}
}

-(void)viewFirstLoad{
    [self noteDeviceChange:nil];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JL_BLEMultiple *bleMultiple = [[JL_RunSDK sharedMe] mBleMultiple];
    if (bleMultiple.bleConnectedArr.count>0) {
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        if (entity) {
            [self updateTopText:entity.mItem];
            [self updateTopImage:entity.mType];
        }else{
            lb_1.center = CGPointMake(124-20, kJL_HeightStatusBar+21+14.5-10);
            [DFUITools setButton:self.btnDevice Text:kJL_TXT("设备待升级")];
            [DFUITools setButton:self.btnDevice Image:@"nil"];
        }
    }else{
        lb_1.center = CGPointMake(124-20, kJL_HeightStatusBar+21+14.5-10);
        [DFUITools setButton:self.btnDevice Text:kJL_TXT("unconnected_device")];
        [DFUITools setButton:self.btnDevice Image:@"nil"];
    }
}

-(void)updateTopText:(NSString*)text{
    UIFont *font = [UIFont systemFontOfSize:14];
    NSDictionary *attribute = @{NSFontAttributeName:font};
    CGRect retSize = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 30)
                                        options:NSStringDrawingTruncatesLastVisibleLine |
                                                NSStringDrawingUsesLineFragmentOrigin |
                                                NSStringDrawingUsesFontLeading
                                                attributes:attribute context:nil];

    
    
    [DFUITools setButton:self.btnDevice Text:text];
    lb_1.center = CGPointMake(retSize.size.width+50, kJL_HeightStatusBar+21+14.5-10);
}

-(void)updateTopImage:(JL_DeviceType)mType{
    JL_EntityM *model = [[JL_RunSDK sharedMe] mBleEntityM];
    if (mType == JL_DeviceTypeSoundBox) {
        [DFUITools setButton:self.btnDevice Image:@"Theme.bundle/icon_speaker"];
    }else if (mType == JL_DeviceTypeTWS) {
        [DFUITools setButton:self.btnDevice Image:@"Theme.bundle/Mul_icon_ear_nor"];
        
        //等于版本3时，为挂脖耳机
        if (model.mProtocolType == PTLVersion) {
            [DFUITools setButton:self.btnDevice Image:@"Theme.bundle/Mul_icon_ear3_nor"];
        }
    }else if (mType == JL_DeviceTypeSoundCard) {
        [DFUITools setButton:self.btnDevice Image:@"Theme.bundle/icon_my_mic"];
    }else{
        [DFUITools setButton:self.btnDevice Image:@"Theme.bundle/Mul_icon_ear_nor"];
    }
}




@end
