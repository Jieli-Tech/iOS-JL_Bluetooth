//
//  DMusicHandler.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DMusicHandler.h"

#define USB_Card   @"usb"
#define SD_0_Card  @"SD0"
#define SD_1_Card  @"SD1"
#define FLASH_Card @"Flash"
#define Linein_Card @"LineIn"

#define MaxFoldNum 9

@interface DMusicHandler(){
    /**
     层级结构
        {
          "uuid0": {//设备uuid
            "card": [
              "fm model0",
              "fm model1",
              "fm model2"
            ]
          },
          "uuid1": {
            "card1": "value",
            "usb": [
              "fm model0",
              "fm model1",
              "fm model2"
            ]
          },
          "uuid2": {
            "card1": [
              "fm model0",
              "fm model1",
              "fm model2"
            ],
            "usb": "usbq"
          }
        }
     */
    NSMutableDictionary *saveDict;
    NSString *bleUuid;
    JL_CardType nowType;
    NSInteger reqNum;
    JLModel_File *reqModel;
    BOOL    playItem;
}
@end

@implementation DMusicHandler

static dispatch_once_t onceToken;
static DMusicHandler *_dmh;

+(instancetype)sharedInstance{
    dispatch_once(&onceToken, ^{
        _dmh = [[DMusicHandler alloc] init];
    });
    return _dmh;
}

+(void)deallocDMusic{
    onceToken = 0;
    _dmh = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        saveDict = [NSMutableDictionary new];
        [self handleFileMonitor];
        [self addNote];
        playItem = NO;
    }
    return self;
}

-(void)setDelegate:(id<DMHandlerDelegate>)delegate{
    _delegate = delegate;
    [self handleFileMonitor];
    NSLogEx(@"%@",delegate);
}

-(void)setNowEntity:(JL_EntityM *)nowEntity{
//    _nowEntity = nowEntity;
    bleUuid = [nowEntity.mPeripheral.identifier UUIDString];
    if (!saveDict[bleUuid]) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [saveDict setValue:dict forKey:bleUuid];
    }
}

-(void)addNote{
    [JL_Tools add:kJL_BLE_M_ENTITY_DISCONNECTED Action:@selector(bleDisconnectAction:) Own:self];
    [JLModel_Device observeModelProperty:@"currentClus" Action:@selector(noteCurrentClus:) Own:self];
    [JLModel_Device observeModelProperty:@"cardArray" Action:@selector(noteCardArray:) Own:self];
}

-(void)bleDisconnectAction:(NSNotification *)note{
    CBPeripheral *pl = [note object];
    NSMutableDictionary *dict = saveDict[pl.identifier.UUIDString];
    [dict removeAllObjects];
}

-(void)noteCardArray:(NSNotification *)note{
    
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO)return;
    
    NSDictionary *tmpDict = [note object];
    NSString *uuid = tmpDict[kJL_MANAGER_KEY_UUID];
    if (![uuid isEqualToString:[[JL_RunSDK sharedMe] mBleUUID]]) {
        return;
    }
    NSArray *array = tmpDict[kJL_MANAGER_KEY_OBJECT];
    NSArray *tmpA = @[@(JL_CardTypeUSB),@(JL_CardTypeSD_0),@(JL_CardTypeSD_1),@(JL_CardTypeFLASH),@(JL_CardTypeLineIn)];
    for (int i  = 0;i<tmpA.count;i++) {
        if (![array containsObject:tmpA[i]]) {
            JL_CardType type = [tmpA[i] integerValue];
            NSMutableDictionary *dict = saveDict[uuid];
            [dict removeObjectForKey:[self keyByType:type]];
        }
    }
    if ([_delegate respondsToSelector:@selector(dmCardMessageDismiss:)]) {
        [_delegate dmCardMessageDismiss:array];
    }
}

-(void)noteCurrentClus:(NSNotification *)note{
    BOOL isOk = [JL_RunSDK isCurrentDeviceCmd:note];
    if (isOk == NO)return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updatePlay];
    });
}


/// 检查是否已经存在缓存
/// @param type 类型
-(BOOL)checkCaChe:(JL_CardType)type{
    NSMutableDictionary *sDict = saveDict[bleUuid];
    NSString *key = [self keyByType:type];
    if (sDict[key]) {
        return YES;
    }else{
        return NO;
    }
}
-(NSString *)keyByType:(JL_CardType)type{
    NSString *key = USB_Card;
       switch (type) {
           case JL_CardTypeUSB:{
               key = USB_Card;
           }break;
           case JL_CardTypeSD_0:{
               key = SD_0_Card;
           }break;
           case JL_CardTypeSD_1:{
               key = SD_1_Card;
           }break;
           case JL_CardTypeFLASH:{
               key = FLASH_Card;
           }break;
           case JL_CardTypeLineIn:{
               key = Linein_Card;
           }break;
           default:
               break;
       }
    return key;
}

-(NSMutableArray *)checkoutArray:(JL_CardType)type{
    NSString *key = [self keyByType:type];
    NSMutableDictionary *dict = saveDict[bleUuid];
    return dict[key];
}

-(void)addTabArray:(JLModel_File *)model{
    NSMutableArray *array = [self checkoutArray:nowType];
    if (array.count==10) {
        [self updateTitleData:array];
        if ([_delegate respondsToSelector:@selector(dmLoadFailed:)]) {
            [_delegate dmLoadFailed:DM_ERROR_Max_Fold];
        }
        return;
    }
    if (!model.pathData) {
        [self updateTitleData:array];
        return;
    }
    //这里的操作是自拟一个叠加完之后的pathData，作为本地存储
    JLModel_File *newModel = [JLModel_File new];
    newModel.fileHandle = model.fileHandle;
    newModel.fileType = model.fileType;
    newModel.cardType = model.cardType;
    newModel.folderName = model.fileName;
    newModel.fileName = model.fileName;
    newModel.fileIndex = model.fileIndex;
    newModel.fileClus = model.fileClus;
    NSMutableData *newData = [NSMutableData new];
    [newData appendData:model.pathData];
    NSData *usData = [JL_Tools uInt32_data:model.fileClus Endian:YES];
    [newData appendData:usData];
    newModel.pathData = newData;
    for (JLModel_File *item in array) {
        if ([item.pathData isEqualToData:newModel.pathData]) {
            [self updateTitleData:array];
            return;
        }
    }
    [array addObject:newModel];
    [self updateTitleData:array];
}

/// 点击对应的Title时更新目录
/// @param model fileModel
-(void)tabArraySelect:(JLModel_File *)model{
    if (reqNum>0) {
        NSLogEx(@"取消请求%@",model.fileName);
        return;
    }
    if (playItem == YES) {
        NSLogEx(@"需要等待播放成功之后才可以继续操控");
        return;
    }
    NSMutableArray *array = [self checkoutArray:nowType];
    NSMutableArray *newArray = [NSMutableArray new];
    for (int i = 0; i<array.count; i++) {
        JLModel_File *fm = array[i];
        [newArray addObject:array[i]];
        if ([fm.pathData isEqualToData:model.pathData]) {
            break;
        }
        if (model.pathData == nil) {
            break;
        }
    }
    NSMutableDictionary *dict = saveDict[bleUuid];
    NSString *key = [self keyByType:nowType];
    [dict setValue:newArray forKey:key];
    if ([_delegate respondsToSelector:@selector(dmHandleWithTabTitleArray:)]) {
        [_delegate dmHandleWithTabTitleArray:newArray];
    }
    JLModel_File *backModel = [self lastPathRequest];
    reqNum = -1;
    [self requestWith:backModel Number:20];
}

-(BOOL)shouldBeUpdate:(JLModel_File *)model{
    NSMutableArray *arr = [self checkoutArray:nowType];
    JLModel_File *item = [arr lastObject];
    if (item.pathData == nil) {
        return YES;
    }
    if ([item.pathData isEqualToData:model.pathData]) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark ///请求上下层文件
-(JLModel_File *)lastPathRequest{
    NSMutableArray *arr = [self checkoutArray:nowType];
    if (arr.count<2) {
        return arr[0];
    }
    //这里的操作其实是倒回去获取上一层的pathData，然后交给库重新叠加一个
    JLModel_File *model = [arr lastObject];
    JLModel_File *model1 = arr[arr.count-2];
    JLModel_File *newModel = [JLModel_File new];
    newModel.fileHandle = model.fileHandle;
    newModel.fileType = model.fileType;
    newModel.cardType = model.cardType;
    newModel.folderName = model.fileName;
    newModel.fileName = model.fileName;
    newModel.fileIndex = model.fileIndex;
    newModel.fileClus = model.fileClus;
    if (model1.pathData == nil) {
        uint8_t firstData[4] = {0x00,0x00,0x00,0x00};
        newModel.pathData = [NSData dataWithBytes:firstData length:4];
    }else{
        newModel.pathData = model1.pathData;
    }
    return newModel;
}

#pragma mark ///请求数据

-(void)loadModeData:(JL_CardType)type{
    nowType = type;
    BOOL result = [self checkCaChe:type];
    if (!result) {
        [self firstLoadData];
    }else{
        NSMutableArray *arr = [self checkoutArray:type];
        if ([_delegate respondsToSelector:@selector(dmHandleWithTabTitleArray:)]) {
            [_delegate dmHandleWithTabTitleArray:arr];
        }
        JLModel_File *model = [self lastPathRequest];
        [self request:model];
    }
}
-(void)firstLoadData{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    JLModel_File *fileModel = [JLModel_File new];
    fileModel.fileType   = JL_BrowseTypeFolder;
    NSMutableArray *mutbA = [NSMutableArray new];
    NSMutableDictionary *sDict = saveDict[bleUuid];
    switch (nowType) {
        case JL_CardTypeUSB:{
            fileModel.cardType   = JL_CardTypeUSB;
            fileModel.fileName   = @"USB";
            fileModel.folderName = @"USB";
            fileModel.fileHandle = model.handleUSB;
            fileModel.fileClus   = 0;
            [mutbA addObject:fileModel];
            [sDict setValue:mutbA forKey:USB_Card];
        }break;
        case JL_CardTypeSD_0:{
            fileModel.cardType   = JL_CardTypeSD_0;
            fileModel.fileName   = @"SD Card";
            fileModel.folderName = @"SD Card";
            fileModel.fileHandle = model.handleSD_0;
            fileModel.fileClus   = 0;
            [mutbA addObject:fileModel];
            [sDict setValue:mutbA forKey:SD_0_Card];
        }break;
        case JL_CardTypeSD_1:{
            fileModel.cardType   = JL_CardTypeSD_1;
            fileModel.fileName   = @"SD Card 2";
            fileModel.folderName = @"SD Card 2";
            fileModel.fileHandle = model.handleSD_1;
            fileModel.fileClus   = 0;
            [mutbA addObject:fileModel];
            [sDict setValue:mutbA forKey:SD_1_Card];
        }break;
        case JL_CardTypeFLASH:{
            fileModel.cardType   = JL_CardTypeFLASH;
            fileModel.fileName   = @"FLASH";
            fileModel.folderName = @"FLASH";
            fileModel.fileHandle = model.handleFlash;
            fileModel.fileClus   = 0;
            [mutbA addObject:fileModel];
            [sDict setValue:mutbA forKey:FLASH_Card];
        }break;
        default:
            break;
    }
    [self requestWith:fileModel Number:20];
}


-(void)requestWith:(JLModel_File *)model Number:(NSInteger)n{
    reqModel = model;
    if (model.fileType == JL_BrowseTypeFile) {
        if (playItem == YES) {
            return;
        }
        playItem = YES;
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        [entity.mCmdManager.mFileManager cmdBrowseModel:model Number:1 Result:nil];
    }else{
        if (reqNum>0) {
            NSLogEx(@"取消请求%@",model.fileName);
            return;
        }
        reqNum = n;
        [self addTabArray:model];
        [self request:model];
        NSLogEx(@"%@",model.fileName);
    }
}

-(void)request:(JLModel_File *)model{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager.mFileManager cmdBrowseModel:model Number:10 Result:nil];
}

-(void)requestModelBy:(NSInteger)num{
    JLModel_File *fm = [self lastPathRequest];
    [self requestWith:fm Number:num];
}

#pragma mark ///处理返回数组
-(void)handleFileMonitor{
    __weak typeof(self) wself = self;
    [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager.mFileManager cmdBrowseMonitorResult:^(NSArray * _Nullable array, JL_BrowseReason reason) {
        switch (reason) {
            case JL_BrowseReasonReading:{
                [wself updateData:array];
               
                NSLogEx(@"正在读取:%lu",(unsigned long)array.count);
            }break;
            case JL_BrowseReasonCommandEnd:{
                [wself updateData:array];
                unsigned long shouldDown = self->reqNum - array.count;
                if (shouldDown>0) {
                    [wself request:self->reqModel];
                }else{
                    self->reqNum = -1;
                }
                NSLogEx(@"读取命令结束:%lu delegate:%@",(unsigned long)array.count,self->_delegate);
            }break;
            case JL_BrowseReasonFolderEnd:{
                [wself updateData:array];
                if (array.count == 0 && self->reqNum != -1) {
                    if ([self->_delegate respondsToSelector:@selector(dmHandleWithItemModelArray:)]) {
                        [self->_delegate dmHandleWithItemModelArray:array];
                    }
                }
                self->reqNum = -1;
                NSLogEx(@"目录读取结束:%lu delegate:%@",(unsigned long)array.count,self->_delegate);
            }break;
            case JL_BrowseReasonBusy:{
                NSLogEx(@"设备在忙");
            }break;
            case JL_BrowseReasonDataFail:{
                NSLogEx(@"数据读取失败");
            }break;
            case JL_BrowseReasonPlaySuccess:{
                [wself updatePlay];
                self->playItem = NO;
                NSLogEx(@"播放成功");
            }break;
            case JL_BrowseReasonUnknown:{
                NSLogEx(@"未知错误");
                self->reqNum = -1;
                self->playItem = NO;
                [self requestWith:self->reqModel Number:10];
            }
            default:
                break;
        }
    }];
}

#pragma mark ///更新数据
-(void)updateData:(NSArray *)array{
    JLModel_File *model = [array firstObject];
    if (![self shouldBeUpdate:model]) {
        return;
    }
    if ([_delegate respondsToSelector:@selector(dmHandleWithItemModelArray:)]) {
        [_delegate dmHandleWithItemModelArray:array];
    }
}
-(void)updateTitleData:(NSArray *)array{
    if ([_delegate respondsToSelector:@selector(dmHandleWithTabTitleArray:)]) {
          [_delegate dmHandleWithTabTitleArray:array];
    }
}

-(void)updatePlay{
    if ([_delegate respondsToSelector:@selector(dmHandleWithPlayItemOK)]) {
        [_delegate dmHandleWithPlayItemOK];
    }
}


@end
