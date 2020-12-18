//
//  ToolViewFMTX.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/3.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "ToolViewFMTX.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "FMPickView.h"

@interface ToolViewFMTX()<FMPickViewDelegate>{
    __weak IBOutlet UIView  *subView;
    __weak IBOutlet UILabel *fmLabel;
    float sW;
}

@end

@implementation ToolViewFMTX

static FMPickView *fmView = nil;

- (instancetype)init
{
    self = [DFUITools loadNib:@"ToolViewFMTX"];
    if (self) {
        sW = [DFUITools screen_2_W];
        self.frame = CGRectMake(0, kJL_HeightStatusBar+44, sW, 200);
        [JLUI_Effect addShadowOnView:subView];


        fmView = [[FMPickView alloc] initWithFrame:CGRectMake(20.0, 80, sW-40.0, 60)
                                        StartPoint:87 EndPoint:108];
        [fmView setFMPoint:875];
        fmView.delegate = self;
        [self addSubview:fmView];
        
        [self updateFmtxUI:875];
    }
    return self;
}


#pragma mark FMPickViewDelegate
static long fmPoint_last = 0;
-(void)onFMPickView:(FMPickView *)view didChange:(NSInteger)fmPoint{
    NSLog(@"FM change: %ld",(long)fmPoint);
    [self updateFmtxUI:fmPoint];
    
    /*--- 震动体验 ---*/
    if (fmPoint_last != fmPoint) {
        AudioServicesPlaySystemSound(1519);
        fmPoint_last = fmPoint;
    }
}

-(void)onFMPickView:(FMPickView *)view didSelect:(NSInteger)fmPoint{
    NSLog(@"FM Select: %ld",(long)fmPoint);
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    if (model.currentFunc == JL_FunctionCodeFMTX) {
        [entity.mCmdManager cmdSetFMTX:fmPoint];
    }
}

-(void)updateFmtxUI:(uint16_t)fmPoint{
    float fp = (float)fmPoint/10.0;
    fmLabel.text = [NSString stringWithFormat:@"%.1f",fp];
//    NSString *txt = [NSString stringWithFormat:@"%.1f",fp];
//    [fmBtn setTitle:txt forState:UIControlStateNormal];
}

- (IBAction)btn_input_Fm:(id)sender{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"发射频点" message:nil
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



@end
