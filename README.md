# iOS杰理之家SDK接入

[toc]



# iOS杰理之家SDK接入

- APP开发环境：iOS平台，iOS 10.0以上，Xcode 13.0以上
- 对应的芯片类型：AC692x，AC693x，AC695x，BD29
- 杰理之家对外开发文档：https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html

## 声明

1. 本项⽬所参考、使⽤技术必须全部来源于公知技术信息，或⾃主创新设计。 

2. 本项⽬不得使⽤任何未经授权的第三⽅知识产权的技术信息。 

3. 如个⼈使⽤未经授权的第三⽅知识产权的技术信息，造成的经济损失和法律后果由个⼈承担。 

## 版本

| 版本 | 日期           | 编辑    | 修改内容                                                     |
| ---- | -------------- | ------- | ------------------------------------------------------------ |
| v1.4 | 2020年12月17日 | 冯 洪鹏 | 1、手表表盘操作(表盘OTA)； |
| v1.3 | 2020年12月11日 | 冯 洪鹏 | 1、重新整理代码框架；<br />2、增加多设备管理； |
| v1.2 | 2020年12月09日 | 冯 洪鹏 | 更新文档 |
| v1.1 | 2020年04月20日 | 冯 洪鹏 | 增加升级的错误回调                             |
| v1.0 | 2019年09月09日 | 冯 洪鹏 | OTA升级功能                                    |


## 概述

本文档是为了后续开发者更加便捷移植杰理蓝牙控制功能而创建。

## 1、导入JL_BLEKit.framework

1、将「 **JL_BLEKit.framework** 」导入Xcode工程，添加两个权限:

- *Privacy - Bluetooth Peripheral Usage Description*
- *Privacy - Bluetooth Always Usage Description*

2、SDK具体使用的两种方式：

​        第一种，使用自定义的蓝牙连接API进行OTA：所有BLE的操作都自行实现，SDK只负责对OTA数据包解析

从而实现OTA功能。

​        第二种，使用SDK内的蓝牙连接API进行OTA：完全使用SDK。
​        
​ 3、针对【杰理之家APP】的开发文档，请看《杰理蓝牙控制库_IOS_SDK开发说明》描述杰理之家内部所有功
​ 
​ 能的实现。
​ 

4、本工程可Build出的ipa需要iPhone手机系统版本在iOS10.0以上。

## 2、使用自定义的蓝牙API接入SDK

**参考Demo**：「**OTA_Update_M(外部BLE)** 」

**1、支持的功能**：

- BLE设备握手连接；
- 获取设备信息；
- OTA升级能实现；
- 注意：所有BLE扫描、连接、断开、重连等操作都需自行实现。

**2、接触到的类**：

- **JL_BLEAction**：实现BLE设备握手连接；(可选，需设备支持)
- **JL_Handle**：RCSP数据格式分包器；(必须)
- **JL_ManagerM**：命令处理中心，所有的命令操作都集中于此；(必须)
- **JLModel_Device**：设备信息存储的数据模型；(必须)

**3、BLE参数**：
- **【服务号】**：AE00
- **【写】特征值**：AE01
- **【读 】特征值**：AE02


### 2.1、初始化SDK 
```objective-c
//主要是3个类，分别是配对器、数据分包器、命令中心类
/*--- 配对器 ---*/
bleAction = [[JL_BLEAction alloc] init];
bleAction.delegate = self;
        
/*--- 数据结构分包 ---*/
bleHandle = [[JL_Handle alloc] init];
bleHandle.delegate = self;
        
/*--- 命令处理中心 ---*/
self.mCmdManager = [[JL_ManagerM alloc] init];
self.mCmdManager.delegate = self;
```
### 2.2、BLE握手连接(可选)

```objective-c
/**
 蓝牙设备配对
 @param pKey 配对码（默认传nil）
 @param bk   配对回调YES：成功 NO：失败
 */
-(void)bluetoothPairingKey:(NSData*)pKey Result:(ATC_Block)bk
  
//外部蓝牙更新通知特征的状态的回调处实现，以下：
#pragma mark - 更新通知特征的状态
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(nonnull CBCharacteristic *)characteristic
             error:(nullable NSError *)error
{
    if (error) { NSLog(@"Err: Update NotificationState For Characteristic fail."); return; }
    if (characteristic.isNotifying) {
        if ([characteristic.UUID.UUIDString containsString:@"AE02"])
        {
            QCY_BLE_LEN_45 = [peripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse];
            NSLog(@"BLE ---> MTU:%lu",(unsigned long)QCY_BLE_LEN_45);
                    
            NSData *pairKey = nil;//使用内置默认
            [bleAction bluetoothPairingKey:pairKey Result:^(BOOL ret) {
                if (ret) {
                    self.mBlePeripheral = peripheral;
                    self.lastUUID = peripheral.identifier.UUIDString;
                    self.mBleName = peripheral.name;
                    
                    [JL_Tools setUser:self.lastUUID forKey:kUUID_BLE_LAST];
                    
                    /*--- 存储名字和UUID ---*/
                    [self.mCmdManager setBleUuid:self.lastUUID];
                    [self.mCmdManager setBleName:self.mBleName];
                    
                    /*--- 告之SDK，设备连接成功 ---*/
                    [JL_Tools post:kJL_BLE_M_ENTITY_CONNECTED Object:peripheral];
                    
                }else{
                    NSLog(@"Err: bluetooth pairing fail.");
                    [self->bleManager cancelPeripheralConnection:peripheral];
                }
            }];
            
            /*            //不需要握手可以这样处理。
                    self.lastUUID = peripheral.identifier.UUIDString;
                    self.mBleName = peripheral.name;
                    
                    [JL_Tools setUser:self.lastUUID forKey:kUUID_BLE_LAST];
                    
                    //存储名字和UUID
                    [self.mCmdManager setBleUuid:self.lastUUID];
                    [self.mCmdManager setBleName:self.mBleName];
                    
                    //告之SDK，设备连接成功
                    [JL_Tools post:kJL_BLE_M_ENTITY_CONNECTED Object:peripheral];
            */
        }
    }
}
```


### 2.3、BLE设备返回的数据传入SDK
```objective-c
//外部蓝牙数据接收处，实现以下：
#pragma mark - 设备返回的数据 GET
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    if (error) { NSLog(@"Err: receive data fail."); return; }
    
    NSData *data = characteristic.value;
    if (data.length <= 0) { return; }
    
    /*--- 【命令】通道返回的数据 ---*/
    if ([characteristic.UUID.UUIDString containsString:QCY_BLE_RCSP_R])
    {
        /*--- 配对输入 ---*/
        [bleAction inputPairData:data];
        
        /*--- RCSP数据结构分包 ---*/
        [bleHandle inputHandleData:data];
    }
}
```

### 2.4、实现SDK的Delete方法
```objective-c
#pragma mark -【JL_BLEActionDelegate】配对数据输出
-(void)onPairOutputData:(NSData *)data{
    [self writeRcspData:data];//使用外部蓝牙发数API
}

#pragma mark -【JL_HandleDelegate】RCSP数据包
-(void)onHandleOutputPKG:(JL_PKG *)pkg{
    [self.mCmdManager inputPKG:pkg];
}

#pragma mark -【JL_ManagerMDelegate】RCSP数据包
-(void)onManagerSendPackage:(JL_PKG *)pkg{
    NSData *data = [bleHandle sendPackage:pkg WithName:self.mBleName];
    [self writeRcspData:data];//使用外部蓝牙发数API
}
```
### 2.5、设备断开的处理
```objective-c
//外部蓝牙设备断开连接处，实现以下：
#pragma mark - 设备断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(nullable NSError *)error
{
    NSLog(@"BLE Disconnect ---> Device %@ error:%d",peripheral.name,(int)error.code);
    
    /*--- 表盘清除回调 ---*/
    [self.mCmdManager cmdFlashActionDisconnect];
    
    /*--- 告之SDK，设备已断开 ---*/
    [JL_Tools post:kJL_BLE_M_ENTITY_DISCONNECTED Object:peripheral];
}
```
### 2.6、手机蓝牙状态传入SDK
```objective-c
//外部蓝牙，手机蓝牙状态回调处，实现以下：
#pragma mark - 蓝牙初始化 Callback
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSInteger st = central.state;
    if (st != CBManagerStatePoweredOn) {
        /*--- 表盘清除回调 ---*/
        [self.mCmdManager cmdFlashActionDisconnect];
        
        /*--- 告之SDK，手机已关闭蓝牙 ---*/
        [JL_Tools post:kJL_BLE_M_OFF Object:@(0)];
    }
}
```
### 2.7、功能实现
#### 2.7.1、获取设备信息 
```objective-c
    [bt_ble.mCmdManager cmdTargetFeatureResult:^(NSArray * _Nullable array) {
        JL_CMDStatus st = [array[0] intValue];
        if (st == JL_CMDStatusSuccess) {
            JLModel_Device *model = [self->bt_ble.mCmdManager outputDeviceModel];
            JL_OtaStatus upSt = model.otaStatus;
            if (upSt == JL_OtaStatusForce) {
                NSLog(@"---> 进入强制升级.");
                [self noteOtaUpdate:nil];
                return;
            }else{
                if (model.otaHeadset == JL_OtaHeadsetYES) {
                    NSLog(@"---> 进入强制升级: OTA另一只耳机.");
                    [self noteOtaUpdate:nil];
                    return;
                }
            }
            NSLog(@"---> 设备正常使用...");
        }else{
            NSLog(@"---> ERROR：设备信息获取错误!");
        }
    }];
```
#### 2.7.2、固件OTA升级
```objective-c
   //升级流程：连接设备-->获取设备信息-->是否强制升级-->(是)则必须调用该API去OTA升级;
     //                                                                        |_______>(否)则可以正常使用APP;
                                                                            
        NSData *otaData = [[NSData alloc] initWithContentsOfFile:@"OTA升级文件路径"];
    [bt_ble.mCmdManager cmdOTAData:otaData Result:^(JL_OTAResult result, float progress) {
        if (result == JL_OTAResultSuccess) {
            NSLog(@"--->升级成功.");
        }
        if (result == JL_OTAResultFail) {
            NSLog(@"--->OTA升级失败");
        }
        if (result == JL_OTAResultDataIsNull) {
            NSLog(@"--->OTA升级数据为空!");
        }
        if (result == JL_OTAResultCommandFail) {
            NSLog(@"--->OTA指令失败!");
        }
        if (result == JL_OTAResultSeekFail) {
            NSLog(@"--->OTA标示偏移查找失败!");
        }
        if (result == JL_OTAResultInfoFail) {
            NSLog(@"--->OTA升级固件信息错误!");
        }
        if (result == JL_OTAResultLowPower) {
            NSLog(@"--->OTA升级设备电压低!");
        }
        if (result == JL_OTAResultEnterFail) {
            NSLog(@"--->未能进入OTA升级模式!");
        }
        if (result == JL_OTAResultUnknown) {
            NSLog(@"--->OTA未知错误!");
        }
        if (result == JL_OTAResultFailSameVersion) {
            NSLog(@"--->相同版本！");
        }
        if (result == JL_OTAResultFailTWSDisconnect) {
            NSLog(@"--->TWS耳机未连接");
        }
        if (result == JL_OTAResultFailNotInBin) {
            NSLog(@"--->耳机未在充电仓");
        }
        
        if (result == JL_OTAResultPreparing ||
            result == JL_OTAResultUpgrading)
        {
            if (result == JL_OTAResultUpgrading) NSLog(@"---> 正在升级：%.1f",progress*100.0f);
            if (result == JL_OTAResultPreparing) NSLog(@"---> 检验文件：%.1f",progress*100.0f);
        }
        
        if (result == JL_OTAResultPrepared) {
            NSLog(@"---> 检验文件【完成】");
        }
        if (result == JL_OTAResultReconnect) {
            NSLog(@"---> OTA正在回连设备... %@",self->bt_ble.mBleName);
            [self->bt_ble connectPeripheralWithUUID:self->bt_ble.lastUUID];//自行实现回连
        }
    }];
```

#### 2.7.3、⼿表切换表盘(OTA功能)
- 详情看【FAT_Demo】
- 导⼊【FATApi】【FATTool】⽂件内代码;

##### STEP.1、设置命令中⼼类
```objective-c
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        bt_ble = bleSDK.bt_ble;
        
        /*--- 设置命令处理中心 ---*/
        [FatsObject makeCmdManager:bt_ble.mCmdManager];
```

##### STEP.2、获取外挂Flash的信息
```objective-c
//调⽤该API需要⽤异步，[JL_Tools subTask:^{}]为异步代码块
 [JL_Tools subTask:^{
        JL_ManagerM *mCmdManager = self->bleSDK.mBleEntityM.mCmdManager;
         [mCmdManager cmdGetFlashInfoResult:^(JLModel_Flash * _Nullable model) {
                 [JL_Tools mainTask:^{
                        //mFlashSize;     //flash大小
                        //mFatfsSize;     //FAT系统大小
                        //mFlashType;     //系统类型 0:FAT
                        //mFlashStatus;   //系统当前状态,0x00正常，0x01异常
                        //mFlashVersion;  //Flash版本
                        //mFlashMtu;      //发包窗口大小
                        //mFlashCluster;  //扇区大小
                         [DFUITools showText:@"FATFS信息已更新" onView:self delay:1.0];
                 }];
         }];
 }];
```
##### STEP.3、初始化本地FATFS系统
```objective-c
//调⽤该API需要⽤异步
 [JL_Tools subTask:^{
        JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        uint32_t flashSize = model.flashInfo.mFlashSize;//外挂Flash剩余空间
        uint32_t fatsSize = model.flashInfo.mFatfsSize; //统⼤⼩
        BOOL isOk = [FatsObject makeFlashSize:flashSize FatsSize:fatsSize];
         [JL_Tools mainTask:^{
                NSString *txt = @"FATFS Mount OK ！";
                if (isOk == NO) txt = @"FATFS Mount Fail~";
                 [DFUITools showText:txt onView:self delay:1.0];
         }];
 }];
```
##### 读取表盘(⽂件)名字
```objective-c
//调⽤该API需要⽤异步
 [JL_Tools subTask:^{
            self->dataArray = [FatsObject makeListPath:@"/"];
            NSLog(@"Fats List ---> %@",self->dataArray);
             [JL_Tools mainTask:^{
                     [self->subTableView reloadData];
             }];
 }];

```
##### 新增表盘(⽂件)
```objective-c
    NSString *pathMatch = [DFFile find:@"watch6.zip"];
    NSData *data = [NSData dataWithContentsOfFile:pathMatch];
    NSLog(@"-->创建的文件大小:%lld",(long long)data.length);
    
    NSString *path = @"/watch6";
    
    [JL_Tools subTask:^{
#if IS_FROM_BLE
        /*--- 开始写文件 ---*/
        __block uint8_t mFlag_0 = 0;
        NSLog(@"--->Fats Insert stat.");
        [mCmdManager cmdInsertFlashPath:path Size:(uint32_t)data.length
                                   Flag:0x01 Result:^(uint8_t flag) {
            mFlag_0 = flag;
        }];
        if (mFlag_0 != 0) {
            NSLog(@"--->Fats Insert Fail.");
            [JL_Tools mainTask:^{
                [self setLoadingText:@"创建文件失败！" Delay:0.5];
            }];
            return;
        }
#endif
        
        BOOL isOk = [FatsObject makeCreateFile:path Content:data Result:^(float progress) {
            [JL_Tools mainTask:^{
                //NSLog(@"---> Progress: %.1f",progress*100.0f);
                NSString *txt = [NSString stringWithFormat:@"正在升级:%.1f%%",progress*100.0f];
                self->progressLabel.text = txt;
                self->progressView.progress = progress;
            }];
        }];
        NSLog(@"Fats Add ---> %d",isOk);
        
        [JL_Tools mainTask:^{
            if (isOk) {
                [self setLoadingText:@"创建文件成功！" Delay:0.5];
#if IS_FROM_BLE
                [JL_Tools subTask:^{
                    /*--- 结束写文件 ---*/
                    NSLog(@"--->Fats Insert end.");
                    [mCmdManager cmdInsertFlashPath:nil Size:0 Flag:0x00 Result:nil];
                }];
#endif
                [JL_Tools delay:1.0 Task:^{
                    self->progressView.hidden = YES;
                    self->progressLabel.hidden = YES;
                    self->progressView.progress = 0.0f;
                    /*--- 读取列表 ---*/
                    [wSelf btn_List:nil];
                }];
            }else{
                [self setLoadingText:@"创建文件失败！" Delay:0.5];
            }
        }];
    }];

```
##### 删除表盘(⽂件)
```objective-c
    [self startLoadingView:@"删除文件..." Delay:20.0];
    NSString *path = [NSString stringWithFormat:@"/%@",selectText];
    JL_ManagerM *mCmdManager = bt_ble.mCmdManager;
    
    [JL_Tools subTask:^{
#if IS_FROM_BLE
        /*--- 开始删除文件 ---*/
        __block uint8_t m_flag = 0;
        NSLog(@"--->Fats Delete stat.");
        [mCmdManager cmdDeleteFlashPath:path Flag:0x01 Result:^(uint8_t flag) {
            m_flag = flag;
        }];
        if (m_flag != 0) {
            NSLog(@"--->Fats Delete Fail.");
            [JL_Tools mainTask:^{
                [self setLoadingText:@"删除文件失败！" Delay:0.5];
            }];
            return;
        }
#endif
        
        BOOL isOk = [FatsObject makeRemoveFile:path];
        NSLog(@"Fats Remove ---> %d",isOk);
        
        [JL_Tools mainTask:^{
            if (isOk) {
                [self setLoadingText:@"删除文件成功！" Delay:0.5];
#if IS_FROM_BLE
                [JL_Tools subTask:^{
                    /*--- 结束删除文件 ---*/
                    NSLog(@"--->Fats Delete end.");
                    [mCmdManager cmdDeleteFlashPath:nil Flag:0x00 Result:nil];
                }];
#endif
                /*--- 读取列表 ---*/
                [wSelf btn_List:nil];
            }else{
                [self setLoadingText:@"删除文件失败！" Delay:0.5];
            }

        }];
    }];
```
##### ⽤户设置当前表盘
```objective-c
    NSString *path = [NSString stringWithFormat:@"/%@",selectText];
    
    JL_ManagerM *mCmdManager = bt_ble.mCmdManager;
    [mCmdManager cmdWatchFlashPath:path Flag:0x01
                            Result:^(uint8_t flag, uint32_t size,
                                     NSString * _Nullable path,
                                     NSString * _Nullable describe) {
        [JL_Tools mainTask:^{
            NSString *txt = @"设置表盘成功!";
            if (flag != 0) txt = @"设置表盘失败~";
            [DFUITools showText:txt onView:self delay:1.0];
        }];
    }];
```
##### 设备主动切换的表盘
```objective-c
        //监听通知
        [JL_Tools add:kJL_MANAGER_WATCH_FACE Action:@selector(noteWatchFace:) Own:self];

    JL_ManagerM *mCmdManager = bt_ble.mCmdManager;
    [mCmdManager cmdWatchFlashPath:nil Flag:0x00
                            Result:^(uint8_t flag, uint32_t size,
                                     NSString * _Nullable path,
                                     NSString * _Nullable describe) {
        [JL_Tools mainTask:^{
            NSString *txt = @"获取表盘成功!";
            if (flag != 0) txt = @"获取表盘失败~";
            [DFUITools showText:txt onView:self delay:1.0];
            
            self->deviceText = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
            [self->subTableView reloadData];
        }];
    }];
```
##### 获取FAT系统剩余空间
```objective-c
//调⽤该API需要⽤异步
        [JL_Tools subTask:^{
        JLModel_Device *model = [self->bt_ble.mCmdManager outputDeviceModel];
        uint32_t flashSize = model.flashInfo.mFlashSize;
        uint32_t fatsSize = model.flashInfo.mFatfsSize;
        
        uint32_t fatsFree = [FatsObject makeGetFree];
        NSLog(@"--->FatsFree ==> %u",fatsFree);

        self->realFreeSize = flashSize - (fatsSize - (fatsFree * 4096));
        NSLog(@"--->剩余空间 ==> %u",self->realFreeSize);
    }];
```




## 3、使用内部的蓝牙API接入SDK

**参考Demo**：「**OTA_Update_M(内部BLE)** 」

**1、支持的功能**：

- BLE设备的扫描、连接、断开、收发数据；
- BLE设备过滤；

- BLE设备握手连接；

- BLE连接服务号和特征值设置；
- 获取设备信息；
- OTA升级能实现；

**2、接触到的类**：

- **JL_BLEMultiple**：

  1、BLE设备过滤，可选关闭；(可选)

  2、BLE配对码设置，可选关闭；(可选，需固件支持功能)

  3、连接超时设置；

  4、BLE连接服务号和特征值设置；

  5、缓存已连接和发现的BLE设备；

- **JL_EntityM**：BLE设备的模型类；(必须)

- **JL_ManagerM**：命令处理中心，所有的命令操作都集中于此；(必须)

- **JLModel_Device**：设备信息存储的数据模型；(必须)

**3、BLE参数**：

- **【服务号】**：AE00
- **【写】特征值**：AE01
- **【读 】特征值**：AE02

### 3.1、初始化SDK 
```objective-c
//1、外部的引用
@property(strong,nonatomic) JL_BLEMultiple  *mBleMultiple;
@property(weak  ,nonatomic) JL_EntityM      *mBleEntityM;    //需要Weak引用，断开设备重新搜索，SDK需释放。(作为当前正在操作的设备使用)
@property(strong,nonatomic) NSString        *mBleUUID;
@property(weak  ,nonatomic) NSArray         *mFoundArray; //需要Weak引用，扫描到的设备。
@property(weak  ,nonatomic) NSArray         *mConnectedArray;//需要Weak引用，已连接的设备。

//2、实例化SDK
self.mBleMultiple = [[JL_BLEMultiple alloc] init];
self.mBleMultiple.BLE_FILTER_ENABLE = YES;
self.mBleMultiple.BLE_PAIR_ENABLE = YES;
self.mBleMultiple.BLE_TIMEOUT = 7;

//1、SDK搜索到的设备，点击连接后，会加入bleConnectedArr数组中。
//2、调用[self.mBleMultiple scanStart]会释放掉blePeripheralArr的JL_EntityM。
self.mFoundArray = self.mBleMultiple.blePeripheralArr;
    
//SDk已连接上的设备，断开连接后，会加入blePeripheralArr数组中。
self.mConnectedArray = self.mBleMultiple.bleConnectedArr;

//后续会用mBleEntityM内的【JL_ManagerM】发命令。
```

### 3.2、监听发现、连接、断开、蓝牙状态等通知回调
```objective-c
extern NSString *kJL_BLE_M_FOUND;               //发现设备
extern NSString *kJL_BLE_M_FOUND_SINGLE;        //发现单个设备
extern NSString *kJL_BLE_M_ENTITY_CONNECTED;    //连接有更新
extern NSString *kJL_BLE_M_ENTITY_DISCONNECTED; //断开连接
extern NSString *kJL_BLE_M_ON;                  //BLE开启
extern NSString *kJL_BLE_M_OFF;                 //BLE关闭
extern NSString *kJL_BLE_M_EDR_CHANGE;          //经典蓝牙输出通道变化
```

### 3.3、连接设备
```objective-c
//从已发现的设备列表里连接一个。
JL_EntityM *entity = self.mFoundArray[indexPath.row];

[self.mBleMultiple connectEntity:entity
                          Result:^(JL_EntityM_Status status) {
    [JL_Tools mainTask:^{
        /*【status】错误码与错误原因
    JL_EntityM_StatusBleOFF         = 0,    //BLE蓝牙未开启
    JL_EntityM_StatusConnectFail    = 1,    //BLE连接失败
    JL_EntityM_StatusConnecting     = 2,    //BLE正在连接
    JL_EntityM_StatusConnectRepeat  = 3,    //BLE重复连接
    JL_EntityM_StatusConnectTimeout = 4,    //BLE连接超时
    JL_EntityM_StatusConnectRefuse  = 5,    //BLE被拒绝
    JL_EntityM_StatusPairFail       = 6,    //配对失败
    JL_EntityM_StatusPairTimeout    = 7,    //配对超时
    JL_EntityM_StatusPaired         = 8,    //已配对
    JL_EntityM_StatusMasterChanging = 9,    //正在主从切换
    JL_EntityM_StatusDisconnectOk   = 10,   //已断开成功
    JL_EntityM_StatusNull           = 11,   //Entity为空 */
    
        if (status == JL_EntityM_StatusPaired) {
        NSString *txt = [NSString stringWithFormat:@"连接成功:%@",deviceName];
        [DFUITools showText:txt onView:wSelf.view delay:1.0];
    }else{
        NSString *txt = [NSString stringWithFormat:@"连接失败:%@",deviceName];
      [DFUITools showText:txt onView:wSelf.view delay:1.0];
    }
    }];
}];
```

### 3.4、断开设备
```objective-c
[self.mBleMultiple disconnectEntity:entity Result:^(JL_EntityM_Status status) {
        [JL_Tools mainTask:^{
        if (status == JL_EntityM_StatusDisconnectOk) {
          NSString *txt = [NSString stringWithFormat:@"已断开:%@",deviceName];
          [DFUITools showText:txt onView:wSelf.view delay:1.0];
        }
        }];
}];

```
### 3.5、功能实现
#### 3.5.1、获取设备信息
```objective-c
[self.mBleEntityM.mCmdManager cmdTargetFeatureResult:^(NSArray * _Nullable array) {
    JL_CMDStatus st = [array[0] intValue];
        if (st == JL_CMDStatusSuccess) {
            JLModel_Device *model = [self.mBleEntityM.mCmdManager outputDeviceModel];
            JL_OtaStatus upSt = model.otaStatus;
            if (upSt == JL_OtaStatusForce) {
                NSLog(@"---> 进入强制升级.");
                [self noteOtaUpdate:nil];
                return;
            }else{
                if (model.otaHeadset == JL_OtaHeadsetYES) {
                    NSLog(@"---> 进入强制升级: OTA另一只耳机.");
                    [self noteOtaUpdate:nil];
                    return;
                }
            }
            NSLog(@"---> 设备正常使用...");
        }else{
        NSLog(@"---> ERROR：设备信息获取错误!");
    }
}];
```
#### 3.5.2、OTA升级
```objective-c
   //升级流程：连接设备-->获取设备信息-->是否强制升级-->(是)则必须调用该API去OTA升级;
     //                                                                        |_______>(否)则可以正常使用APP;

        NSString *filePath = [[NSBundle mainBundle]pathForResource:@"update_watch" ofType:@"ufw"];
    NSData *otaData = [[NSData alloc] initWithContentsOfFile:filePath];
    
    [self.mBleEntityM.mCmdManager cmdOTAData:otaData Result:^(JL_OTAResult result, float progress) {
        if (result == JL_OTAResultSuccess) {
            NSLog(@"--->升级成功.");
        }
        if (result == JL_OTAResultFail) {
            NSLog(@"--->OTA升级失败");
        }
        if (result == JL_OTAResultDataIsNull) {
            NSLog(@"--->OTA升级数据为空!");
        }
        if (result == JL_OTAResultCommandFail) {
            NSLog(@"--->OTA指令失败!");
        }
        if (result == JL_OTAResultSeekFail) {
            NSLog(@"--->OTA标示偏移查找失败!");
        }
        if (result == JL_OTAResultInfoFail) {
            NSLog(@"--->OTA升级固件信息错误!");
        }
        if (result == JL_OTAResultLowPower) {
            NSLog(@"--->OTA升级设备电压低!");
        }
        if (result == JL_OTAResultEnterFail) {
            NSLog(@"--->未能进入OTA升级模式!");
        }
        if (result == JL_OTAResultUnknown) {
            NSLog(@"--->OTA未知错误!");
        }
        if (result == JL_OTAResultFailSameVersion) {
            NSLog(@"--->相同版本！");
        }
        if (result == JL_OTAResultFailTWSDisconnect) {
            NSLog(@"--->TWS耳机未连接");
        }
        if (result == JL_OTAResultFailNotInBin) {
            NSLog(@"--->耳机未在充电仓");
        }
        
        if (result == JL_OTAResultPreparing ||
            result == JL_OTAResultUpgrading)
        {
            if (result == JL_OTAResultUpgrading) NSLog(@"---> 正在升级：%.1f",progress*100.0f);
            if (result == JL_OTAResultPreparing) NSLog(@"---> 检验文件：%.1f",progress*100.0f);
        }
        
        if (result == JL_OTAResultPrepared) {
            NSLog(@"---> 检验文件【完成】");
        }
        if (result == JL_OTAResultReconnect) {
            NSLog(@"---> OTA正在回连设备... %@",self.mBleEntityM.mItem);
            [self.mBleMultiple connectEntity:self.mBleEntityM Result:^(JL_EntityM_Status status) {
                if (status != JL_EntityM_StatusPaired) {
                    NSLog(@"---> Error:OTA回连设备失败！");
                }
            }];
        }
    }];
```


## 4、其他功能实现，请看《杰理蓝牙控制库_IOS_SDK开发说明》

```objective-c
        //全都用JL_ManagerM内的方法，详情看头文件JL_ManagerM.h
        //
```
