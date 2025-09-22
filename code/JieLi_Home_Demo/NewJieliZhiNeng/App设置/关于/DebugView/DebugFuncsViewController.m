//
//  DebugFuncsViewController.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/10/17.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DebugFuncsViewController.h"
#import "JLShareLogViewController.h"
#import "CustomerCmdViewController.h"
#import "KvoManager.h"
#import <JL_AdvParse/JL_AdvParse.h>


@interface DebugFuncsViewController ()

@end

@implementation DebugFuncsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.itemArray setArray:@[@"share log",@"customer command",@"request EQ",@"彩屏舱"]];
    self.title = @"Debug Helper";
    [[KvoManager share] startListen];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    switch (indexPath.row) {
        case 0:{
            JLShareLogViewController *vc = [[JLShareLogViewController alloc] init];
            [self.navigationController pushViewController:vc animated:true];
        }break;
        case 1:{
            CustomerCmdViewController *vc = [[CustomerCmdViewController alloc] init];
            [self.navigationController pushViewController:vc animated:true];
        }break;
        case 2:{
//            [[KvoManager share] requestEq];
            JL_SystemEQ *eq = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mSystemEQ;
            [eq cmdGetSystemEQ:^(JL_CMDStatus status, JL_SystemEQ * _Nullable model) {
                
            }];
            JL_EntityM *mBleEntityM = [[JL_RunSDK sharedMe] mBleEntityM];
            JLDevicesAdv *adv = [JLDevicesAdv advertDataToModel:mBleEntityM.mAdvData];
            [adv logProperties];
        }break;
        case 3:{
            ColorfulBoxVC *vc = [[ColorfulBoxVC alloc] init];
            [self.navigationController pushViewController:vc animated:true];
        }break;
        default:
            break;
    }
}

-(void)backBtnAction{
    [self dismissViewControllerAnimated:true completion:nil];
}


@end
