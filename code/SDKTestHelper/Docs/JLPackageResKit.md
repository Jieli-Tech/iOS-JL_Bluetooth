# ``JLPackageResKit``


## 概述

JLPackageResKit 是一个用于语音资源处理与管理的工具库，支持将多个语音文件打包为配置数据，提供提示音替换、PCM 转换、资源打包等功能。

- JLPackageResKit.h：主入口头文件，导入其他模块。

- JLPackageSourceMgr.h：资源打包管理器。

- JLPcmToWts.h：PCM 转换为 WTS。

- JLToneCfgModel.h：提示音配置模型。

- JLVoicePackageManager.h：提示音打包与替换管理器。

## SDK 导入

### 环境要求

- iOS 11.0+
- Xcode 12.0+

### 安装方式

1. 将 `JLPackageResKit.framework` 添加到项目中
2. 在 Target → General → Frameworks, Libraries, and Embedded Content 中添加框架
3. 设置为 "Embed & Sign"

## 模块说明

- JLPackageResKit.h

该头文件作为框架统一导入点，暴露了以下组件接口：
```objc
#import <JLPackageResKit/JLVoicePackageManager.h>
#import <JLPackageResKit/JLPcmToWts.h>
#import <JLPackageResKit/JLToneCfgModel.h>
#import <JLPackageResKit/JLVoiceReplaceInfo.h>
#import <JLPackageResKit/JLPackageSourceMgr.h>
```
### 资源打包模块接口说明

资源打包模块，用于将多个 .bin 文件合并为一个资源包。

类：JLPackageBaseInfo 
contentData：文件数据

fileName：文件名

类：JLPackageSourceMgr
+ (NSData *)makePks:(NSArray<JLPackageBaseInfo *>*)infos;
将多个 JLPackageBaseInfo 打包成 .res 数据。

#### JLPackageBaseInfo 类

**功能**：用于描述单个文件资源的基本信息

##### 属性

- `contentData` (NSData *)
  文件内容的二进制数据表示
- `fileName` (NSString *)
  原始文件名（包含扩展名）

#### JLPackageSourceMgr 类

**功能**：提供资源打包功能，将多个二进制文件合并为单个资源包

- 核心方法说明

`+(NSData *)makePks:(NSArray<JLPackageBaseInfo *> *)infos`

- 功能

将多个二进制文件打包成单个 `package` 格式的资源文件

- 参数

| 参数名 | 类型                           | 说明                                                         |
| :----- | :----------------------------- | :----------------------------------------------------------- |
| infos  | NSArray<JLPackageBaseInfo *> * | 包含多个JLPackageBaseInfo对象的数组，每个对象代表一个要打包的文件 |

- 返回值

| 类型     | 说明                                     |
| :------- | :--------------------------------------- |
| NSData * | 打包后的资源数据，可直接写入.xxx文件 |

#### 使用示例

```
// 准备要打包的文件
JLPackageBaseInfo *file1 = [JLPackageBaseInfo new];
file1.fileName = @"texture.res";
file1.contentData = [NSData dataWithContentsOfFile:path1];

JLPackageBaseInfo *file2 = [JLPackageBaseInfo new];
file2.fileName = @"config.res";
file2.contentData = [NSData dataWithContentsOfFile:path2];

// 执行打包
NSData *packageData = [JLPackageSourceMgr makePks:@[file1, file2]];

// 写入文件
[packageData writeToFile:@"/path/to/package" atomically:YES];
```

### PCM 转换模块

提供 PCM 转换为 WTS 文件功能。

类：`JLPcmToWts.h`
+ (instancetype)share;
获取单例对象。

- (void)pcmToWts:...
将 PCM 文件编码为 WTS 文件。支持配置码率、采样率、VAD 阈值、编码策略（位流优先或质量优先）等。

- 参数说明：

speechInFileName：输入 PCM 路径

bitOutFileName：输出 WTS 路径

targetRate：目标码率

sr_in：采样率

vadthr：VAD 阈值

usesavemodef：0=位流优先，1=质量优先

### 提示音数据打包、解析说明

提示音数据打包、解析与下发设备的核心内容，主要包括以下的类

- JLToneCfgModel.h

用于描述单个提示音配置项。
类：JLToneCfgModel
- fileName：提示音文件名
- data：文件数据

- **JLVoiceReplaceInfo.h**

定义提示音替换相关的数据结构。

类：JLTipsVoiceInfo

参数如下：

- index：语音索引

- offset：偏移地址

- length：文件长度

- fileName：原始文件名

- nickName：昵称

类：JLVoiceReplaceInfo

- version：结构版本

- blockSize：保留字段

- maxNum：最大语音数量

- fileName：配置文件名

- infoArray：提示音详细列表

类：JLVoicePackageManager

+ (NSData *)makePks:...
将多个 .wts 文件打包成 tone.cfg

+ (NSArray<JLToneCfgModel *> *)parsePks:(NSData *)data;
解包 tone.cfg 获取语音列表

#### 使用示例

```objc
//1. 打包多个 .wts 文件为 tone.cfg
NSArray *paths = @[
    @"/Users/xxx/voice1.wts",
    @"/Users/xxx/voice2.wts"
];
NSArray *names = @[
    @"boot.wts",
    @"connect.wts"
];

JLVoiceReplaceInfo *info = [[JLVoiceReplaceInfo alloc] init];
info.version = 1;
info.fileName = @"tone.cfg";
info.maxNum = 2;
info.blockSize = 0;

NSData *cfgData = [JLVoicePackageManager makePks:paths FileNames:names Info:info];

// 将生成的 tone.cfg 写入本地
[cfgData writeToFile:@"/Users/xxx/tone.cfg" atomically:YES];

//2. 解析 tone.cfg 文件

NSData *data = [NSData dataWithContentsOfFile:@"/Users/xxx/tone.cfg"];
NSArray<JLToneCfgModel *> *tones = [JLVoicePackageManager parsePks:data];

for (JLToneCfgModel *model in tones) {
    NSLog(@"Tone File: %@, Data Length: %lu", model.fileName, (unsigned long)model.data.length);
}

//3. 查询设备是否支持提示音替换
//这里假设是通过某个初始化的类获取到了 manager 类，具体实现方式需要用户根据实际调整
JL_ManagerM *manager = [[JL_BLEMultiple share] getCurrentManager];

[[JLTipsSoundReplaceMgr share] isSupportTipsVoiceReplace:manager result:^(BOOL support) {
    if (support) {
        NSLog(@"支持提示音替换");
    } else {
        NSLog(@"不支持提示音替换");
    }
}];

//4. 获取设备中已有的提示音信息
[[JLTipsSoundReplaceMgr share] voicesReplaceGetVoiceInfo:manager Result:^(JL_CMDStatus status, NSData * _Nullable data) {
    if (status == JL_CMDStatusSuccess && data) {
        JLVoiceReplaceInfo *info = [JLVoiceReplaceInfo parsePks:data];
        for (JLTipsVoiceInfo *item in info.infoArray) {
            NSLog(@"Index: %d, Name: %@ (%@)", item.index, item.fileName, item.nickName);
        }
    } else {
        NSLog(@"获取失败");
    }
}];

///5. 推送提示音到设备
NSString *tonePath = @"/Users/xxx/tone.cfg";
//具体句柄需要从设备端通讯获取到
NSData *devHandle = [NSData dataWithBytes:"\xff\xff\xff\xff" length:4]; // 默认句柄

[[JLTipsSoundReplaceMgr share] voicesReplacePushDataRequest:manager
                                                  DevHandle:devHandle
                                                   TonePath:tonePath
                                                  IsReborn:YES
                                                    Result:^(JL_CMDStatus status, uint8_t pre, uint8_t finish) {
    if (status == JL_CMDStatusSuccess && finish == 100) {
        NSLog(@"推送成功");
    } else {
        NSLog(@"状态: %d，进度: %d%%", status, finish);
    }
}];

```
