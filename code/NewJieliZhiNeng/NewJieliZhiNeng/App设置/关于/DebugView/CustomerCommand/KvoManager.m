//
//  KvoManager.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/1/6.
//  Copyright © 2023 杰理科技. All rights reserved.
//

#import "KvoManager.h"
#import "JL_RunSDK.h"

@implementation KvoManager

+(instancetype)share{
    static KvoManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KvoManager alloc] init];
    });
    return manager;
}



-(void)startListen{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAction:) name:nil object:nil];
    //当前连接着的entity
//    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    
    //获取真值的方式监听
//    JLModel_Device *dev = [entity.mCmdManager getDeviceModel];
    
//    [dev addObserver:self forKeyPath:@"eqArray" options:NSKeyValueObservingOptionNew context:nil];
//    [dev addObserver:self forKeyPath:@"eqMode" options:NSKeyValueObservingOptionNew context:nil];
//    [dev addObserver:self forKeyPath:@"mAncModeCurrent" options:NSKeyValueObservingOptionNew context:nil];
//
    [JLModel_Device observeModelProperty:@"eqMode" Action:@selector(addEqMode:) Own:self];
    
}

-(void)requestEq{
    //当前连接着的entity
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdGetSystemInfo:JL_FunctionCodeCOMMON SelectionBit:0x10 Result:^(JL_CMDStatus status, uint8_t sn, NSData * _Nullable data) {
        
    }];
}


-(void)notificationAction:(NSNotification *)note{
    
    if([note.name isEqualToString:@"EQ_MODE_CHANGE"]){
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        JLModel_Device *dev = [entity.mCmdManager outputDeviceModel];
        NSLog(@"dev:%d,dev.eqArray:%@",dev.eqMode,dev.eqArray);
    }

}


-(void)addEqMode:(NSNotification *)note{
    NSLog(@"addNote:%@",note.object);
}




-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
//    if([keyPath isEqualToString:@"eqArray"]){
//        NSLog(@"%@",change[NSKeyValueChangeNewKey]);
//    }
//    if([keyPath isEqualToString:@"eqMode"]){
//        NSLog(@"%@",change);
//    }
//    if([keyPath isEqualToString:@"mAncModeCurrent"]){
//        NSLog(@"%@",change);
//    }
    JLModel_Device *device = object;
    NSLog(@"device.eqModel:%d",device.eqMode);
    NSLog(@"device.eqArray:%@",device.eqArray);
}



@end
