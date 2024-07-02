//
//  DeviceChangeView.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DeviceChangeView.h"
#import "DeviceChangeCell.h"
#import "JL_RunSDK.h"
#import "ElasticHandler.h"
#import "SqliteManager.h"
#import "JLUI_Cache.h"

@interface DeviceChangeView()<UITableViewDelegate,
                              UITableViewDataSource,
                              DeviceChangeCellDelegate>{
    float       sW;
    float       sH;
    UIView      *deviceView;
    UIView      *blackView;
    float       devView_H;
    float       devView_tall;

    UITableView *subTableView;
    DeviceChangeBlock blk;
    DeviceObjc *selected;

}
@end

@implementation DeviceChangeView

- (instancetype)init
{
    self = [super init];
    if (self) {

        sW = [UIScreen mainScreen].bounds.size.width;
        sH = [UIScreen mainScreen].bounds.size.height;
        self.frame = CGRectMake(0, 0, sW, sH);
        self.backgroundColor = [UIColor clearColor];

        devView_tall = 120;
        devView_H = devView_tall+70*4;

        blackView = [[UIView alloc] init];
        blackView.frame = CGRectMake(0, devView_H-50, sW, sH-devView_H+50);
        blackView.backgroundColor = [UIColor blackColor];
        blackView.alpha = 0.0;
        
        deviceView = [[UIView alloc] init];
        deviceView.frame = CGRectMake(0,-devView_H,sW,devView_H);
        deviceView.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
        deviceView.layer.cornerRadius = 12;
        deviceView.alpha = 1.0;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0,10+kJL_HeightStatusBar,sW,22);
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("my_devices") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
        label.attributedText = string;
        [deviceView addSubview:label];

        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        [self addSubview:blackView];
        [self addSubview:deviceView];
        [win addSubview:self];
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(onDismiss)];
        [gr setNumberOfTapsRequired:1];
        [gr setNumberOfTouchesRequired:1];
        [blackView addGestureRecognizer:gr];
        
        subTableView = [[UITableView alloc] init];
        subTableView.frame = CGRectMake(0, 84.0, sW, devView_H-devView_tall);
        subTableView.backgroundColor = [UIColor clearColor];
        subTableView.tableFooterView = [UIView new];
        subTableView.separatorColor = [UIColor clearColor];
        subTableView.showsVerticalScrollIndicator = NO;
        subTableView.rowHeight  = 70.0;
        subTableView.dataSource = self;
        subTableView.delegate   = self;
        [deviceView addSubview:subTableView];
        
        [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
        [JL_Tools add:kUI_JL_DEVICE_PREPARING Action:@selector(noteDevicePreparing:) Own:self];
        [self refreshArray];
        [self updateFirstPosition:self.dataArray];
    }
    return self;
}

-(void)onShow{
    [UIView animateWithDuration:0.18 animations:^{
        self->deviceView.frame = CGRectMake(0, -12.0, self->sW, self->devView_H);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            self->blackView.alpha = 0.3;
        }];
    }];
}

-(void)onDismiss{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
    [UIView animateWithDuration:0.07 animations:^{
        self->blackView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.18 animations:^{
            self->deviceView.frame = CGRectMake(0, -self->devView_H, self->sW, self->devView_H);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
}


-(void)noteDeviceChange:(NSNotification *)note{
    selected = nil;
    [self refreshArray];
    [subTableView reloadData];
}

-(void)noteDevicePreparing:(NSNotification*)note{
    [self noteDeviceChange:nil];
}

-(void)refreshArray{
    NSArray *array = [[SqliteManager sharedInstance] checkOutAll];
    
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    NSMutableArray *arr_0 = [NSMutableArray new];
    NSMutableArray *arr_1 = [NSMutableArray new];
    NSMutableArray *arr_2 = [NSMutableArray new];
    NSMutableArray *arr_3 = [NSMutableArray new];
    NSMutableArray *arr_4 = [NSMutableArray new];
    
    for (DeviceObjc *objc in array) {
        JLUuidType type = [JL_RunSDK getStatusUUID:objc.uuid];
        if (type == JLUuidTypeInUse) {
            [arr_0 addObject:objc];
        }
        if (type == JLUuidTypePreparing) {
            [arr_1 addObject:objc];
        }
        //if (type == JLUuidTypeConnected) {
        //    [arr_2 addObject:objc];
        //}
        if (type == JLUuidTypeNeedOTA) {
            [arr_3 addObject:objc];
        }
        if (type == JLUuidTypeDisconnected) {
            [arr_4 addObject:objc];
        }
    }
    
    /*--- 已连接的设备 ---*/
    NSArray *linkedUuidArr = [JL_RunSDK getLinkedArray];
    for (NSString *uuid in linkedUuidArr) {
        for (DeviceObjc *objc in array) {
            if ([uuid isEqual:objc.uuid]) {
                [arr_2 addObject:objc];
                break;
            }
        }
    }
    [newArray addObjectsFromArray:arr_0];
    [newArray addObjectsFromArray:arr_1];
    [newArray addObjectsFromArray:arr_2];
    [newArray addObjectsFromArray:arr_3];
    [newArray addObjectsFromArray:arr_4];
    self.dataArray = newArray;

    [subTableView reloadData];
}


#pragma mark <- tableView Delegate ->
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *IDCell = @"DCCell";
    DeviceChangeCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil) {
        cell = [[DeviceChangeCell alloc] init];
    }
    DeviceObjc *model = self.dataArray[indexPath.row];
    cell.mImageView.image = [self getProductImageUUID:model.uuid Type:model.type protocol:model.mProtocolType]; 
    cell.mLabelName.text = model.name;
    cell.uuid = model.uuid;
    cell.mTag = indexPath.row;
    cell.delegate = self;
//    BOOL isConnect = NO;
//    BOOL isWorking = NO;
//    for (JL_EntityM *entity in [[JL_RunSDK sharedMe] mBleMultiple].bleConnectedArr) {
//        isConnect = [entity.mPeripheral.identifier.UUIDString isEqualToString:model.uuid];
//        if (isConnect) {
//            break;
//        }
//    }
//    if ([[[JL_RunSDK sharedMe] mBleEntityM].mPeripheral.identifier.UUIDString isEqualToString:model.uuid]) {
//        isWorking = YES;
//    }
    
    if ([model isEqual:selected]) {
        cell.activeView.hidden = NO;
    }else{
        [cell.activeView stopAnimating];
        cell.activeView.hidden = YES;
    }
//    [cell setCellIsConnect:isConnect];
//    cell.isWorking = isWorking;
    return cell;
}

-(UIImage *)getProductImageUUID:(NSString*)uuid Type:(int)type protocol:(int)ptl{
    NSString *imageName = [NSString stringWithFormat:@"PRODUCT_LOGO_%@",uuid];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory
                             MiddlePath:@"" File:imageName];
    UIImage *image = nil;
    if (path) {
        NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
        image = [UIImage imageWithData:data];
    }else{
        image = [self imageType:type protocol:ptl];
    }
    return image;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DeviceObjc *model = self.dataArray[indexPath.row];
    selected = model;
    [tableView reloadData];
    
    /*--- 连接状态 ---*/
    JLUuidType type = [JL_RunSDK getStatusUUID:model.uuid];

    /*--- 未连接 ---*/
    if (type == JLUuidTypeDisconnected) {
           
        JL_BLEMultiple *multiple = [[JL_RunSDK sharedMe] mBleMultiple];
        JL_EntityM *entity = [multiple makeEntityWithUUID:model.uuid];
        NSLog(@"---> 下拉顶栏，连接设备：%@",model.name);
        
        [multiple connectEntity:entity Result:^(JL_EntityM_Status status) {
            if (status == JL_EntityM_StatusPaired) {
                //插入连接历史记录数据库
                [[SqliteManager sharedInstance] installWithDevice:entity];
                //[entity.mCmdManager cmdHeatsetAdvEnable:NO];
            }
            [JL_Tools mainTask:^{
                self->selected = nil;
                [tableView reloadData];
                [self onDismiss];

                UIWindow *win = [DFUITools getWindow];
                NSString *txt = [JL_RunSDK textEntityStatus:status];
                [DFUITools showText:txt onView:win delay:1.0];

                //[self blockWithUUid:entity.mUUID];
            }];
        }];
        return;
    }
       
    /*--- 已连接 ---*/
    if (type == JLUuidTypeConnected) {
        /*--- 激活设备 ---*/
        [JL_RunSDK setActiveUUID:model.uuid];
        return;
    }
    [self onDismiss];
       
//       /*--- 正在使用 ---*/
//       if (type == JLUuidTypeInUse) {
//           DeviceInfoVC *vc = [[DeviceInfoVC alloc] init];
//           vc.deviceObjc = objc;
//           vc.headsetDict = bleDeviceDict;
//           vc.modalPresentationStyle = 0;
//           [self presentViewController:vc animated:YES completion:nil];
//       }
       
//       /*--- 需要OTA升级 ---*/
//       if (type == JLUuidTypeNeedOTA) {
//           UpgradeVC *vc = [[UpgradeVC alloc] init];
//           vc.otaEntity  = [JL_RunSDK getEntity:objc.uuid];
//           vc.rootNumber = 1;
//           vc.modalPresentationStyle = 0;
//           [self presentViewController:vc animated:YES completion:nil];
//       }
    
}

//-(void)blockWithUUid:(NSString *)uuid{
//    if (blk) {
//        [DFUITools showClearLayerDelay:3.0];
//        blk(uuid,-1);
//    }
//}

-(void)setDeviceChangeBlock:(DeviceChangeBlock)block{
    blk = block;
}

-(void)dealloc{
    blk = nil;
}


-(UIImage *)imageType:(int)type protocol:(int)ptl{
    switch (type) {
        case 0:
            return [UIImage imageNamed:@"Theme.bundle/img_soundbox"];
            break;
        case 1:{
            if (ptl == PTLVersion) {//处理挂脖耳机
                if([[JLUI_Cache sharedInstance] productData] == nil){
                    return  [UIImage imageNamed:@"Theme.bundle/img_earphone03"];
                }else{
                    return [UIImage imageWithData:[[JLUI_Cache sharedInstance] productData]];
                }
            }
            if([[JLUI_Cache sharedInstance] productData] == nil){
                return  [UIImage imageNamed:@"Theme.bundle/img_earphone"];
            }else{
                return [UIImage imageWithData:[[JLUI_Cache sharedInstance] productData]];
            }
        }break;
            
        default:
            break;
    }
    return  [UIImage imageNamed:@"img_earphone"];
}

-(void)setArrayData:(NSArray *)array{
    [self updateFirstPosition:array];
    [subTableView reloadData];
}

-(void)updateFirstPosition:(NSArray*)array{
    if (self.dataArray.count == 0)return;
    NSInteger ct = self.dataArray.count;
    if (ct >= 4) {
        devView_H = devView_tall+70*4;
        blackView.frame = CGRectMake(0, devView_H-50, sW, sH-devView_H+50.0);
        deviceView.frame = CGRectMake(0,-devView_H,sW,devView_H);
        subTableView.frame = CGRectMake(0, 84.0, sW, devView_H-devView_tall);
    }else{
        devView_H = devView_tall+70*ct;
        blackView.frame = CGRectMake(0, devView_H-50, sW, sH-devView_H+50.0);
        deviceView.frame = CGRectMake(0,-devView_H,sW,devView_H);
        subTableView.frame = CGRectMake(0, 84.0, sW, devView_H-devView_tall);
    }
}


-(void)onDeviceInfoBtnTag:(NSInteger)tag{
    DeviceObjc *model = self.dataArray[tag];
    
    /*--- 连接状态 ---*/
    JLUuidType type = [JL_RunSDK getStatusUUID:model.uuid];
    
    /*--- 正在使用---*/
    if (type == JLUuidTypeInUse ) {
        [self onDismiss];
        if (blk) { blk(model.uuid,tag);}
        return;
    }
    
    if (type == JLUuidTypeConnected ) {
        UIWindow *win = [DFUITools getWindow];
        [DFUITools showText:kJL_TXT("device_not_using") onView:win delay:1.0];
        return;
    }
}

@end
