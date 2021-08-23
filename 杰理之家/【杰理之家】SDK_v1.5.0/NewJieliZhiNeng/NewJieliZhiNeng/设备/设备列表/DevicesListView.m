//
//  DevicesListView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DevicesListView.h"
#import "DevicesCell.h"
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "SqliteManager.h"
#import "DeviceInfoTools.h"

@interface DevicesListView()<UICollectionViewDelegate,UICollectionViewDataSource,DeviceCellDelegate>{
    UITapGestureRecognizer *dismissTapAction;
    NSTimer *testtimer;
    int testNumber;
}

@property (nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic,strong)NSArray *dataArray;
@property(nonatomic,strong)UIImageView *centerImgv;
@property(nonatomic,strong)UILabel *noDeviceLab;

@end

@implementation DevicesListView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        float sW = frame.size.width;
        float sH = frame.size.height;
        _centerImgv = [[UIImageView alloc] initWithFrame:CGRectMake(sW/2-104, sH/2-72-20, 208, 144)];
        _centerImgv.image = [UIImage imageNamed:@"Theme.bundle/product_img_empty2"];
        [self addSubview:_centerImgv];
        
        _noDeviceLab = [[UILabel alloc] initWithFrame:CGRectMake(sW/2-104.0, sH/2-72-20+144+20.0, 208, 25)];
        _noDeviceLab.text = kJL_TXT("暂无设备，请先连接设备");
        _noDeviceLab.textColor = [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0];
        _noDeviceLab.textAlignment = NSTextAlignmentCenter;
        _noDeviceLab.font = [UIFont systemFontOfSize:14.0];
        [self addSubview:_noDeviceLab];
        _noDeviceLab.hidden = YES;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemW = (sW-15 )/ 2;
        CGFloat itemH = itemW;
        layout.itemSize = CGSizeMake(itemW, itemH);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 15;
        layout.minimumInteritemSpacing = 15;
        
        CGRect rect = CGRectMake(0, 0, sW, sH);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        
        UINib *nib = [UINib nibWithNibName:@"DevicesCell" bundle:nil];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:@"DevicesCell"];
        [self addSubview:_collectionView];
        
        //[DFNotice add:kUI_JL_DEVICE_SQLITE Action:@selector(refreshStatus) Own:self];
        
        dismissTapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelDeleteAction)];
    }
    return self;
}



-(void)refreshStatus{
//    NSArray *newArray = [[SqliteManager sharedInstance] checkOutAll];
    [[SqliteManager sharedInstance] checkOutDevices:^(NSArray * _Nullable array) {
        if (array) {
            [self setArrayData:array];
        }
    }];
    
}




-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DevicesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DevicesCell" forIndexPath:indexPath];
    DeviceObjc *model = _dataArray[indexPath.row];
    cell.deviceNameLab.text = model.name;
    cell.deviceImgv.image = [self getProductImageUUID:model.uuid Type:model.type];

    cell.contentView.layer.masksToBounds = YES;

    cell.layer.shadowColor = kDF_RGBA(205, 230, 251, 0.2).CGColor;
    cell.layer.shadowOffset = CGSizeMake(0, 2);
    cell.layer.shadowRadius = 6.5f;
    cell.layer.shadowOpacity = 1.0f;
    cell.layer.masksToBounds = NO;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.contentView.layer.cornerRadius].CGPath;
    
    /*--- 连接状态 ---*/
    JLUuidType type = [JL_RunSDK getStatusUUID:model.uuid];
    /*--- 未连接 ---*/
    if (type == JLUuidTypeDisconnected) {
        cell.connectStatusLab.textColor = [UIColor colorWithRed:95.0/255.0 green:95.0/255.0 blue:95.0/255.0 alpha:1.0];
        cell.connectStatusLab.text = kJL_TXT("• 未连接");
    }
    /*--- 已连接 ---*/
    if (type == JLUuidTypeConnected) {
        cell.connectStatusLab.textColor = [UIColor colorWithRed:27/255.0 green:192.0/255.0 blue:23.0/255.0 alpha:1.0];
        cell.connectStatusLab.text = kJL_TXT("• 已连接");
    }
    
    /*--- 正在配置 ---*/
    if (type == JLUuidTypePreparing) {
        cell.connectStatusLab.textColor = [UIColor colorWithRed:31.0/255.0 green:150.0/255.0 blue:243.0/255.0 alpha:1.0];
        cell.connectStatusLab.text = kJL_TXT("• 配置中...");
    }
    
    /*--- 正在使用 ---*/
    if (type == JLUuidTypeInUse) {
        cell.connectStatusLab.textColor = [UIColor colorWithRed:31.0/255.0 green:150.0/255.0 blue:243.0/255.0 alpha:1.0];
        cell.connectStatusLab.text = kJL_TXT("• 正在使用");
    }
    /*--- 需要OTA升级 ---*/
    if (type == JLUuidTypeNeedOTA) {
        cell.connectStatusLab.textColor = [UIColor colorWithRed:255.0/255.0 green:222.0/255.0 blue:52.0/255.0 alpha:1.0];
        cell.connectStatusLab.text = kJL_TXT("• 需要升级");
    }
    cell.connectStatusLab.layer.cornerRadius = 5;

    
    /*--- 查找设备 ---*/
    if (isDelete) {
        if (type == JLUuidTypeDisconnected) {
            cell.deleteBtn.hidden = NO;
            cell.connectStatusLab.hidden = YES;
        }else{
            cell.deleteBtn.hidden = YES;
            cell.connectStatusLab.hidden = NO;
        }
    }else{
        cell.deleteBtn.hidden = YES;
        cell.connectStatusLab.hidden = NO;
    }
    
    /*--- 查找设备 ---*/
    if ([model.findDevice isEqual:@"1"]) {
        cell.myLocationBtn.hidden = NO;
    }else{
        cell.myLocationBtn.hidden = YES;
    }
    
    cell.delegate = self;
    cell.index = (int)indexPath.row;
    return cell;
}

-(UIImage *)getProductImageUUID:(NSString*)uuid Type:(int)type{
    NSString *imageName = [NSString stringWithFormat:@"PRODUCT_LOGO_%@",uuid];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory
                             MiddlePath:@"" File:imageName];
    UIImage *image = nil;
    if (path) {
        NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
        image = [UIImage imageWithData:data];
    }else{
        image = [DeviceInfoTools getDevicesImageByType:type];
    }
    return image;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(_dataArray!=nil && _dataArray.count>indexPath.row){
        DeviceObjc *model = _dataArray[indexPath.row];
        if ([_delegate respondsToSelector:@selector(onDeviceListViewDidSelect:)] && isDelete == NO) {
            [self.delegate onDeviceListViewDidSelect:model];

        }
    }
}

-(void)setArrayData:(NSArray *)array{
    
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (DeviceObjc *objc in array) {
        JLUuidType type = [JL_RunSDK getStatusUUID:objc.uuid];
        
        if (type == JLUuidTypeInUse) {
            [newArray insertObject:objc atIndex:0];
        }
        if (type == JLUuidTypePreparing) {
            NSInteger index = 0;
            if (newArray.count >= 1) index = 1;
            [newArray insertObject:objc atIndex:index];
        }
    }
    NSInteger addIndex = newArray.count;
    for (DeviceObjc *objc in array) {
        JLUuidType type = [JL_RunSDK getStatusUUID:objc.uuid];
        if (type == JLUuidTypeConnected) {
            [newArray insertObject:objc atIndex:addIndex];
        }
        if (type == JLUuidTypeNeedOTA) {
            [newArray addObject:objc];
        }
    }
    for (DeviceObjc *objc in array) {
        JLUuidType type = [JL_RunSDK getStatusUUID:objc.uuid];
        if (type == JLUuidTypeDisconnected) {
            [newArray addObject:objc];
        }
    }
    
    if (newArray.count>0) {
        _noDeviceLab.hidden = YES;
        _centerImgv.hidden = YES;
    }else{
        _noDeviceLab.hidden = NO;
        _centerImgv.hidden = NO;
    }
    self.dataArray = newArray;

    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(0.0, 0.0)];
}

-(void)deviceBtnLocation:(int)indexPath{
    DeviceObjc *model = _dataArray[indexPath];
    if ([_delegate respondsToSelector:@selector(onDeviceMapLocationSelect:)] && isDelete == NO) {
        [self.delegate onDeviceMapLocationSelect:model];
    }
}


-(void)deviceCellDidSelectWith:(int)indexPath{
    NSLog(@"Delete indexPath:%d",indexPath);
    DeviceObjc *model = _dataArray[indexPath];
    [[SqliteManager sharedInstance] deleteItemByIdInt:model.idInt];
    [[SqliteManager sharedInstance] checkOutDevices:^(NSArray * _Nullable array) {
        if (array) {
            [self setArrayData:array];
        }
    }];
}


static BOOL isDelete = NO;
-(void)deviceCellDidDelete{
    if (isDelete) {
        isDelete = NO;
        [_collectionView removeGestureRecognizer:dismissTapAction];
    }else{
        isDelete = YES;
        [_collectionView addGestureRecognizer:dismissTapAction];
    }
    [_collectionView reloadData];
}



-(void)closeAllDeleteBtn{
    isDelete = NO;
    [_collectionView reloadData];
}

-(void)cancelDeleteAction{
    isDelete = NO;
    [_collectionView removeGestureRecognizer:dismissTapAction];
    [_collectionView reloadData];
}

@end
