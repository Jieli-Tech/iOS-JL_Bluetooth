[toc]

# SDKTestHelper

当前 App 的编写是为了对 SDK 进行功能测试，验证 SDK 的流程以及相关接口，同时也有可能会提供给到客户，让客户更方便接入开发。

## 开发文档

**开发文档在[`./Docs/Documents/`](./Docs/Documents/index.html)目录下。**

## 更新日志

| 版本   | 日期  | 修改说明            |
| ------ | ----- | ------------------- |
| v1.4.0 | 2026/08/16 | [1. 完善通话翻译功能相关示例](###2026-08-16 (v1.4.0)) |
| v1.3.0 | 2026/07/20 | [1. 增加通话录音模式、翻译耳机关于面对面翻译(左耳+右耳)功能内容](###2026-07-20 (v1.3.0)) |
| v1.2.3 | 2026/07/16 | [1.新增广播报兼容处理](###2026-07-16 (v1.2.3)) |
| v1.2.2 | 2026/04/24 | 1. 增加流媒体传输功能示例代码 |
| v1.2.1 | 2026/03/18 | 1. 增加多图转换打包传输闭环业务流程 (ResPackageVC)<br>2. 修复主线程UI更新崩溃及优化列表选中高亮 |
| v1.2.0 | 2025/07/21 | 1. 增加翻译耳机模块内容 |
| v1.2.0 | 2025/03/07 | 1. 增加设备历史记录 |


### 2026-08-16 (v1.4.0)

- **完善通话翻译功能相关示例** — 新增通话翻译功能相关示例，包括通话录音模式、立体声翻译模式


### 2026-07-20 (v1.3.0)

#### 新增功能
- **通话录音模式（Beta）** — 新增通话过程双路录音功能，支持录制通话双方的语音用于后续转写、存档或分析
  - **核心机制**：通过 ESCO 音频通道分别采集上行（己方语音）和下行（对方语音），通过 `sourceType`（`JLTranslateAudioTypeESCOUp` / `ESCODown`）区分来源
  - **编码格式**：支持 OPUS 和 JLA_V2 两种编码格式，采样率 16kHz
  - **声道支持**：支持单声道/双声道录制（双声道时左声道=下行/对方，右声道=上行/己方）
  - **使用条件**：需在通话建立后才能启动，通话结束时自动退出
  - **测试集成**：`SDKTestHelper` 中已集成测试界面（Translate 页面 → 选择"通话录音模式"→ 设置模式启动）

- **面对面翻译（左耳+右耳）模式（Beta）** — 新增 TWS 主从分离面对面翻译功能，支持两人各佩戴一只耳机实时互译（如跨国会议、旅行对话）
  - **核心机制**：TWS 主从分离后独立录音，两路音频通过独立代理回调隔离处理 — 主机音频走 `JLTranslationManagerDelegate`，从机音频走 `JLTranslationManagerSimultaneousDelegate`
  - **音频处理流水线**：解码 → 保存 WAV → ASR（语音识别）→ 翻译 → TTS（语音合成）→ 编码 → 下发给对侧设备播放
  - **生命周期管理**：组件按需创建、退出即释放，不常驻内存；退出流程依赖设备 TWS 状态通知，等待设备自行恢复连接后再清理资源
  - **关键能力**：进入前可设置 `maxMtu` 分包大小、`simultaneousPairKey` 设备认证密钥；支持暂停/恢复（来电打断等场景）；从机 BLE 异常断开自动重连 1 次

### 2026-07-16 (v1.2.3)

#### 新增功能
- **广播包 Hash 适配开关** — 设置页面新增「广播报 Hash 适配」开关，对应 `JL_BLEMultiple.emableHash` 属性
- **新增广播报兼容处理** — 修复广播报对于无设备名称的隐藏设备进行可选择显示，对应 `JL_BLEMultiple.allowEmptyBleName` 属性
- **蓝牙搜索页广播信息展示** — 搜索设备列表改为自定义 Cell，显示设备名称、广播数据(hex)、RSSI、产品类型

> 当使用 SDK 内部蓝牙管理方式时，需要通过 `JL_BLEMultiple` 实例配置以下属性。

| 属性 | 类型 | 默认值 | 说明 |
|---|---|---|---|
| `BLE_FILTER_ENABLE` | BOOL | YES | 是否过滤非杰理设备 |
| `BLE_TIMEOUT` | int | 7 | 连接超时时间（秒） |
| `allowEmptyBleName` | BOOL | NO | 是否允许设备名为空时依然显示 |
| `emableHash` | BOOL | YES | 是否启用广播包 Hash 适配 |
| `authEnable` | BOOL | YES | 是否启用设备认证 |

**使用示例：**

```swift
let bleMultiple = JL_BLEMultiple()
bleMultiple.ble_FILTER_ENABLE = true
bleMultiple.ble_TIMEOUT = 7
bleMultiple.allowEmptyBleName = true   // 允许空设备名依然显示
bleMultiple.emableHash = false           // 指定关闭 Hash 适配
```
#### 修复优化
- **主页断开后 UI 恢复** — 修复设备断开连接后 MainViewController 卡片状态不更新的问题

#### 使用方法

**Hash 适配开关：** 设置 →「广播报 Hash 适配」Toggle → 控制 `JL_BLEMultiple.emableHash`
```
// 代码设置
bleMultiple.emableHash = YES;  // 默认启用
```

### 流媒体传输功能（Beta）
 - 新增流媒体传输功能示例代码

### 2025-07-21
- 支持录音模式下 A2DP 音频播放

### 翻译耳机相关

- 完善通话翻译流程与业务逻辑  
- 优化翻译内容传输与数据处理兼容性  
- 接入 JLAV2 / Opus 编解码流程  
- 增加大模型翻译接入能力  
- 丰富翻译 UI 示例与流程控制  

### 蓝牙与连接管理

- 修复 BLE 连接闪退问题  
- 改为使用外部蓝牙连接方式  
- 增加 TWS 耳机连接与交互示例  
- 添加通话状态监听与音量事件处理  

### 图像资源与文件处理

- 增加 GIF / BMP 打包与传输支持  
- 新增图像转换兼容处理逻辑  
- 优化文件浏览与分享界面  

### 音频模块改进

- 增加 AudioSession 设置与使用示例  
- 支持 PCM 播放与异常处理  
- 集成 Speex / Opus 解码器  

### OTA 与升级机制

- 接入 Auracast 协议功能与 UI 展示  
- 增强 OTA 升级资源管理与空间复用逻辑  
- 优化升级流程 UI 与示例功能  

## 使用指引

1. 将 `Libs` 目录下所有 `.xcframework` 添加到 Xcode 工程
2. `Code` 目录包含完整的示例实现供参考
3. 开发文档位于 `Docs/Documents/` 目录下，用浏览器打开 `index.html` 即可浏览

## 调试与日志

### 开启日志记录

```objc
// 开启 log 需要在 AppDelegate 中执行以下代码：
/*--- 记录 NSLOG ---*/
[JLLogManager setLog:true IsMore:false Level:JLLOG_DEBUG];
[JLLogManager clearLog]; // 执行这个会清理上一次的日志，如果想一直保留，此方法可注释
[JLLogManager logWithTimestamp:true];
[JLLogManager saveLogAsFile:true];
// 收集日志回调接口
[JLLogManager collectLog:^(NSString *log) {
    NSLog(@"收集到的日志: %@", log);
}];

// 重定向保存日志文件存放路径
[JLLogManager redirectLogPath:@"./Logs"];
```

### 日志文件位置

- 打印文件格式：`JL_LOG.txt`
  - debug 版本默认开启打印，开发者在发布时注意关闭打印，或者主动清理日志
- 文件存储路径：存储在 APP 的沙盒根目录 `Documents/` 下

### 异常处理步骤

1. 简单描述问题现象（必要）
2. 提供最接近时间戳的 log 文件（必要）
3. 提供现象的截图或者视频

## 注意事项

⚠️ 要求 Xcode 14.3+  
⚠️ 最低支持 iOS 13.0

## SDK 功能说明

当前包含了手表/耳机/音箱耳机的 SDK 汇总 Demo 示例。

### JL_AdvParse.xcframework

当前版本 V1.2.0 — BLE 广播包解析（所有 SDK 必选依赖）

### JL_HashPair.xcframework

当前版本 V1.0.3 — 设备配对认证（所有 SDK 必选依赖）

### JL_OTALib.xcframework

当前版本 V2.5.0_Beta_1_20251210 — 设备 OTA 升级（所有 SDK 必选依赖）

### JLLogHelper.xcframework

当前版本 V1.2 — 日志打印管理库（所有 SDK 必选依赖）

### JL_BLEKit.xcframework

当前版本 V1.15.0_Beta6_20260716 — 核心蓝牙通讯库
RCSP、设备音乐播放控制、查找设备、闹钟、大数据传输、大文件传输、小文件传输、EQ 设置、灯光控制、音量、TWS 设置、语音录制、声卡设置、FM 设置、手表设置、流媒体传输

### JLDialUnit.xcframework

当前版本 V1.1.1 — 表盘/屏幕操作管理（手表 SDK 必选）

### JLBmpConvertKit.xcframework

当前版本 V1.5.0 — 图片转换库（GIF/BMP/PNG 压缩与转换，用于彩屏设备）

### JLPackageResKit.xcframework

当前版本 V1.0 — 资源打包替换库（提示音打包）

### JLAudioUnitKit.xcframework

当前版本 V1.4.0 — OPUS/SPEEX 语音编解码

### JLAV2Lib.xcframework

当前版本 V1.0 — JLAv2 语音编解码

### JLVideoTool.xcframework

当前版本 V1.0 — 视频编解码工具


## 项目架构说明

当前示例 demo 基于 Swift + MVVM 架构，使用 CocoaPods 管理第三方依赖。

```
SDKTestHelper/
├── AppDelegate.swift             # 应用入口，@_exported import 全局依赖
├── MainTabBarViewController.swift # TabBar 主框架（SDK功能 + iNRF模拟）
├── Info.plist                    # 应用配置与权限声明
│
├── Basics/                       # 基础组件
│   ├── BaseViewController         # 所有 VC 父类（导航栏、DisposeBag、断开监听）
│   ├── BaseView                   # 所有 View 父类（initUI/initData 生命周期）
│   └── NavViewController          # 自定义导航控制器
│
├── JLSDKTest/                    # 核心业务代码
│   ├── Controllers/
│   │   ├── MainViewController           # 主页面（连接状态 + 功能入口）
│   │   ├── SearchBleViewControllers/    # 设备搜索与广播信息展示
│   │   ├── SettingViewControllers/      # 全局设置（日志、认证、Hash适配等）
│   │   ├── FileTransportViewControllers/ # 文件传输
│   │   │   ├── File/                    # 大文件传输/读回
│   │   │   ├── SmallFile/               # 小文件传输
│   │   │   ├── Image2Device/            # 图片→设备大数据传输
│   │   │   ├── Image2JLJpeg/            # 图片→JLJPEG 格式传输
│   │   │   ├── Gif2Device/              # GIF 发送到彩屏设备
│   │   │   ├── ResPackage/              # 资源包打包传输
│   │   │   ├── Contact/                 # 联系人同步
│   │   │   ├── WatchDial/               # 表盘传输
│   │   │   ├── FilesBrowse/             # 设备文件浏览
│   │   │   └── StreamViewController/    # 流媒体传输（推流/拉流）
│   │   ├── DefaultSetViewControllers/   # 设备基础功能
│   │   │   ├── TwsInfo/                 # TWS 信息与按键功能
│   │   │   ├── Translate/               # 翻译模式（通话翻译/面对面翻译(左耳+右耳)）
│   │   │   ├── EQ/                      # 均衡器设置
│   │   │   ├── Voice/                   # 语音录制与解码
│   │   │   ├── Alarm/                   # 闹钟管理
│   │   │   ├── Weather/                 # 天气设置
│   │   │   ├── VolumeSet/               # 音量控制
│   │   │   ├── FindDevices/             # 查找设备
│   │   │   ├── Auracast/                # Auracast 广播音频
│   │   │   ├── TwsHealth/               # 运动健康
│   │   │   ├── AIHelper/                # AI 助手
│   │   │   └── PromptTonePackage/       # 提示音打包替换
│   │   ├── UpdateViewControllers/       # 设备升级
│   │   │   ├── OTA/                     # 标准 OTA
│   │   │   ├── 4GOTA/                   # 4G OTA
│   │   │   ├── OtalibCustomCmd/         # OTA 自定义命令
│   │   │   └── UpdateSources/           # 升级源管理
│   │   ├── CustomDataViewControllers/   # 自定义命令调试
│   │   ├── HistoryViewController/       # 设备历史记录
│   │   ├── TestUnitViewController/      # 实验室（AudioSession 等）
│   │   ├── NormalViewController/        # 未连接状态下功能页
│   │   └── BroseViewController/         # 本地文件浏览
│   ├── ViewModel/                       # MVVM ViewModel 层
│   ├── Views/                           # 自定义视图组件
│   │   └── Translation/                 # 翻译相关视图
│   ├── Models/                          # 数据模型
│   ├── Adapters/                        # TableView/CollectionView 适配器
│   │   ├── FuncSelectCell               # 功能列表 Cell
│   │   ├── BleSearchCell                # 搜索设备 Cell（名称/广播/RSSI/类型）
│   │   └── ...
│   └── Bluetooth/                       # 蓝牙管理层
│       └── BleManager                   # 蓝牙中心管理器（搜索/连接/断开）
│
├── Tools/                               # 工具类
│   ├── SourceHelper                     # R.localStr 扩展、路径常量
│   ├── SettingInfo                      # UserDefaults 持久化配置
│   ├── JLAudioPlayer / JLAudioRecoder   # 音频播放/录制
│   ├── JLAudioSessionManager            # AudioSession 管理
│   ├── JLTaskPromise                    # 异步任务链
│   ├── Colors / EnumsHelper             # 颜色/枚举工具
│   ├── BluetoothDeviceParse             # 蓝牙设备图标解析
│   ├── TranslateTools                   # 翻译工具
│   └── ...
│
├── DataBase/                            # 本地数据库（FMDB）
├── ImitationNFR/                        # NFC 模拟功能
├── Sources/                             # 资源文件（音频/图片/CodeExample.plist）
│
├── JLAudioUnitKit.xcframework           # OPUS/SPEEX 解码
├── JLAV2Lib.xcframework                 # JLAv2 编解码
├── JLVideoTool.xcframework              # 视频工具
└── JPEGTurbo.xcframework                # JPEG 编解码
```

## 版权声明

© 2026 珠海市杰理科技股份有限公司 保留所有权利

[官网地址](https://www.zh-jieli.com)
