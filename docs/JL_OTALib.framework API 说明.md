# JL_OTALib.framework API 说明

## 1. 概述

 当前文档是关于 **JL_OTALib.framework** 的API文档，包含了OTA升级的所有API，用于实现OTA升级的过程，包括BLE设备握手连接，获取设备信息，OTA升级能实现等。

 ## 2. API列表

| 名称          | 功能描述                                                  | 备注 |
| ------------- | --------------------------------------------------------- | ---- |
| JL_OTAManager | OTA升级管理对象类，用于管理升级过程                       |      |
| JLOTAFile     | 文件下载，根据授权的 key 和 code 从杰理服务器下载升级文件 |      |

## 3. JL_OTAManager

OTA 升级管理对象，用于管理设备的升级过程。**JL_OTAManager** 是杰理科技开发的一款专业 OTA 升级管理工具类，为开发者提供高效、安全的设备固件升级支持。通过丰富的功能接口和灵活的回调机制，帮助开发者轻松实现设备升级管理。

### 3.1 初始化

1. **+ (JL_OTAManager *)getOTAManager**  
   获取 OTA 升级管理对象。

2. **- (instancetype)init**  
   初始化方法，但已被标记为弃用，请使用 **getOTAManager** 方法获取实例。

### 3.2 类型定义

#### 3.2.1 枚举类型

1. **JL_OTAResult**  
   表示 OTA 升级过程的结果状态。

| 值                                   | 描述                                     |
| ------------------------------------ | ---------------------------------------- |
| **JL_OTAResultSuccess**              | OTA 升级成功                             |
| **JL_OTAResultFail**                 | OTA 升级失败                             |
| **JL_OTAResultDataIsNull**           | OTA 升级数据为空                         |
| **JL_OTAResultCommandFail**          | OTA 指令失败                             |
| **JL_OTAResultSeekFail**             | OTA 标示偏移查找失败                     |
| **JL_OTAResultInfoFail**             | OTA 升级固件信息错误                     |
| **JL_OTAResultLowPower**             | OTA 升级设备电压低                       |
| **JL_OTAResultEnterFail**            | 未能进入 OTA 升级模式                    |
| **JL_OTAResultUpgrading**            | OTA 升级中                               |
| **JL_OTAResultReconnect**            | OTA 需重连设备（UUID 方式）              |
| **JL_OTAResultReboot**               | OTA 需设备重启                           |
| **JL_OTAResultPreparing**            | OTA 准备中                               |
| **JL_OTAResultPrepared**             | OTA 准备完成                             |
| **JL_OTAResultStatusIsUpdating**     | 设备已在升级中                           |
| **JL_OTAResultFailedConnectMore**    | 当前固件多台设备连接，请手动断开其他设备 |
| **JL_OTAResultFailSameSN**           | 升级数据校验失败，SN 多次重复            |
| **JL_OTAResultCancel**               | 升级取消                                 |
| **JL_OTAResultFailVerification**     | 升级数据校验失败                         |
| **JL_OTAResultFailCompletely**       | 升级失败                                 |
| **JL_OTAResultFailKey**              | 升级数据校验失败，加密 Key 不对          |
| **JL_OTAResultFailErrorFile**        | 升级文件出错                             |
| **JL_OTAResultFailUboot**            | Uboot 不匹配                             |
| **JL_OTAResultFailLenght**           | 升级过程长度出错                         |
| **JL_OTAResultFailFlash**            | 升级过程 Flash 读写失败                  |
| **JL_OTAResultFailCmdTimeout**       | 升级过程指令超时                         |
| **JL_OTAResultFailSameVersion**      | 相同版本                                 |
| **JL_OTAResultFailTWSDisconnect**    | TWS 耳机未连接                           |
| **JL_OTAResultFailNotInBin**         | 耳机未在充电仓                           |
| **JL_OTAResultReconnectWithMacAddr** | OTA 需重连设备（MAC 方式）               |
| **JL_OTAResultDisconnect**           | OTA 设备断开                             |
| **JL_OTAResultUnknown**              | OTA 未知错误                             |

2. **JL_OTAReconnectType**  
   表示 OTA 升级回连方式。

| 值                             | 描述                      |
| ------------------------------ | ------------------------- |
| **JL_OTAReconnectTypeUUID**    | 使用 UUID 方式回连设备    |
| **JL_OTAReconnectTypeMACAddr** | 使用 MAC 地址方式回连设备 |

3. **JL_OtaStatus**  
   表示设备 OTA 状态。

| 值                     | 描述     |
| ---------------------- | -------- |
| **JL_OtaStatusNormal** | 正常升级 |
| **JL_OtaStatusForce**  | 强制升级 |

4. **JL_OtaHeadset**  
   表示耳机单备份是否需要强制升级。

| 值                   | 描述               |
| -------------------- | ------------------ |
| **JL_OtaHeadsetNO**  | 耳机单备份正常升级 |
| **JL_OtaHeadsetYES** | 耳机单备份强制升级 |

5. **JL_OtaWatch**  
   表示手表资源是否需要强制升级。

| 值                 | 描述             |
| ------------------ | ---------------- |
| **JL_OtaWatchNO**  | 手表资源正常升级 |
| **JL_OtaWatchYES** | 手表资源强制升级 |

6. **JL_BootLoader**  
   表示是否需要下载 BootLoader。

| 值                   | 描述                  |
| -------------------- | --------------------- |
| **JL_BootLoaderNO**  | 不需要下载 BootLoader |
| **JL_BootLoaderYES** | 需要下载 BootLoader   |

7. **JL_Partition**  
   表示设备 OTA 时支持的固件备份类型。

| 值                     | 描述       |
| ---------------------- | ---------- |
| **JL_PartitionSingle** | 固件单备份 |
| **JL_PartitionDouble** | 固件双备份 |

### 3.3 属性

| 属性名               | 类型              | 描述                           |
| -------------------- | ----------------- | ------------------------------ |
| **mBLE_UUID**        | **NSString**      | 设备 UUID，需要开发者填入      |
| **mBLE_NAME**        | **NSString**      | 设备名称，需要开发者填入       |
| **bleOnly**          | **BOOL**          | 是否仅支持 BLE                 |
| **bleAddr**          | **NSString**      | 蓝牙地址                       |
| **mCmdSN**           | **uint8_t**       | SN 值                          |
| **version**          | **uint16_t**      | 设备版本号                     |
| **versionFirmware**  | **NSString**      | 设备版本信息                   |
| **otaStatus**        | **JL_OtaStatus**  | OTA 状态                       |
| **otaHeadset**       | **JL_OtaHeadset** | 耳机升级模式                   |
| **otaPartition**     | **JL_Partition**  | 固件单/双备份支持              |
| **otaLength** (只读) | **int64_t**       | OTA 升级内容大小（设备通知的） |
| **otaSent** (只读)   | **uint32_t**      | 已传输的数据大小               |

### 3.4 方法

#### 3.4.1 设备操作

1. **- (void)noteEntityConnected**  
   通知 SDK 当前设备 BLE 已连接。

2. **- (void)noteEntityDisconnected**  
   通知 SDK 当前设备 BLE 已断开。

3. **- (void)cmdRebootDevice**  
   请求设备重启。

4. **- (void)cmdRebootForceDevice**  
   强制请求设备重启。

#### 3.4.2 OTA 操作

1. **- (void)cmdOTAData:(NSData *)data Result:(JL_OTA_RT __nullable)result**  
   发起 OTA 升级请求。

   **参数**:

   - **data**: 升级文件数据。
   - **result**: 升级结果回调。

2. **- (void)cmdOTACancelResult:(JL_OTA_RESULT __nullable)result**  
   取消当前 OTA 升级流程。

3. **-(void)cmdUpgrade:(NSData *)data Option:(JLOtaReConnectOption *_Nullable)option Result:(JL_OTA_RT _Nonnull)result**

    此接口免去了公版 OTA 的外边回连策略，内部实现回连

    ⚠️使用此方法时不可使用 delegate 的回调信息，要使用 Result 的回调信息

4. **- (BOOL)cmdOtaIsRelinking**  
   检查当前 OTA 单备份是否正在回连。

#### 3.3.3 状态查询

1. **- (void)cmdTargetFeature**  
   查询设备支持的 OTA 特性，建议连接设备后第一时间调用。

2. **- (void)cmdSystemFunction**  
   查询设备系统状态，主要用于外置 Flash 场景。

### 3.5 回调协议

**JL_OTAManagerDelegate**

| 方法                                                         | 描述               |
| ------------------------------------------------------------ | ------------------ |
| **- (void)otaDataSend:(NSData *)data**                       | 数据发送回调       |
| **- (void)otaFeatureResult:(JL_OTAManager *)manager**        | 设备状态信息回调   |
| **- (void)otaUpgradeResult:(JL_OTAResult)result Progress:(float)progress** | 升级状态与进度回调 |
| **- (void)otaCancel**                                        | OTA 升级取消回调   |

## 4. JLOTAFile

**JLOTAFile** 是杰理科技提供的 OTA 文件管理类，主要用于支持 OTA 升级文件的下载和管理功能。通过简单的接口调用，开发者可以轻松获取固件文件并实现相关业务逻辑。

### 4.1 类型定义

#### 4.1.1 枚举类型

1. **JL_OTAUrlResult**  
   表示 OTA 文件获取的结果状态。

| 值                              | 描述             |
| ------------------------------- | ---------------- |
| **JL_OTAUrlResultSuccess**      | OTA 文件获取成功 |
| **JL_OTAUrlResultFail**         | OTA 文件获取失败 |
| **JL_OTAUrlResultDownloadFail** | OTA 文件下载失败 |

#### 4.1.2 回调类型

1. **JL_OTA_URL**  
   文件下载结果的回调类型。

**参数说明**：

- **result**：结果状态，对应 **JL_OTAUrlResult** 枚举值。
- **version**：文件版本信息，可能为空。
- **url**：下载链接地址，可能为空。
- **explain**：文件说明信息，可能为空。

``` objective-c
typedef void(^JL_OTA_URL)(JL_OTAUrlResult result,
                          NSString* __nullable version,
                          NSString* __nullable url,
                          NSString* __nullable explain);
```


### 4.2 方法

#### 4.2.1 文件下载

1. **-(void)cmdGetOtaFileKey:(NSString*)key Code:(NSString*)code Result:(JL_OTA_URL __nullable)result**

**描述**：
根据授权 **key** 和 **code**，下载指定的 OTA 升级文件。

**参数**：

- **key**：授权的密钥。
- **code**：授权码。
- **result**：下载结果回调，返回文件信息和状态。

**使用示例**：

``` objective-c
JLOTAFile *otaFile = [[JLOTAFile alloc] init];
[otaFile cmdGetOtaFileKey:@"yourKey"
                     Code:@"yourCode"
                   Result:^(JL_OTAUrlResult result, NSString * _Nullable version, NSString * _Nullable url, NSString * _Nullable explain) {
    if (result == JL_OTAUrlResultSuccess) {
        NSLog(@"文件下载成功，版本：%@，链接：%@，说明：%@", version, url, explain);
    } else {
        NSLog(@"文件下载失败，状态：%d", result);
    }
}];
```

2. **-(void)cmdGetOtaFileKey:(NSString*)key Code:(NSString*)code hash:(NSString*)hash Result:(JL_OTA_URL __nullable)result**

**描述**：
根据授权 **key**、**code** 和文件 **MD5** 值，下载指定的 OTA 升级文件。

**参数**：

- **key**：授权的密钥。
- **code**：授权码。
- **hash**：文件的 MD5 值，用于校验文件完整性。
- **result**：下载结果回调，返回文件信息和状态。

**使用示例**：

``` objective-c
[otaFile cmdGetOtaFileKey:@"yourKey"
                     Code:@"yourCode"
                     hash:@"yourFileMD5"
                   Result:^(JL_OTAUrlResult result, NSString * _Nullable version, NSString * _Nullable url, NSString * _Nullable explain) {
    if (result == JL_OTAUrlResultSuccess) {
        NSLog(@"文件下载成功，版本：%@，链接：%@，说明：%@", version, url, explain);
    } else {
        NSLog(@"文件下载失败，状态：%d", result);
    }
}];
```

---

### 4.3 注意事项

1. 确保 **key** 和 **code** 的有效性，避免因授权失败导致文件无法下载。
2. 如果使用 MD5 校验，请正确传入文件的 **hash** 值，以确保文件完整性。
3. 回调参数 **version**、**url** 和 **explain** 可能为空，请在使用前进行有效性检查。
4. 为了提高下载的稳定性，建议在失败时添加重试机制。