[tag download]:https://github.com/Jieli-Tech/iOS-JL_Bluetooth/tags
[tag_badgen]:https://img.shields.io/github/v/tag/Jieli-Tech/iOS-JL_Bluetooth?style=plastic&logo=apple&labelColor=ffffff&color=informational&label=Tag&logoColor=blue

# iOS-JL_Bluetooth  [![tag][tag_badgen]][tag download]

<div align="center">

**杰理之家 SDK （iOS）-专为杰理音箱耳机类产品提供蓝牙控制开发平台**

![iOS](https://img.shields.io/badge/iOS-12.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-Latest-orange.svg)
[![zread](https://img.shields.io/badge/Ask_Zread-_.svg?style=flat&color=00b0aa&labelColor=000000&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQuOTYxNTYgMS42MDAxSDIuMjQxNTZDMS44ODgxIDEuNjAwMSAxLjYwMTU2IDEuODg2NjQgMS42MDE1NiAyLjI0MDFWNC45NjAxQzEuNjAxNTYgNS4zMTM1NiAxLjg4ODEgNS42MDAxIDIuMjQxNTYgNS42MDAxSDQuOTYxNTZDNS4zMTUwMiA1LjYwMDEgNS42MDE1NiA1LjMxMzU2IDUuNjAxNTYgNC45NjAxVjIuMjQwMUM1LjYwMTU2IDEuODg2NjQgNS4zMTUwMiAxLjYwMDEgNC45NjE1NiAxLjYwMDFaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00Ljk2MTU2IDEwLjM5OTlIMi4yNDE1NkMxLjg4ODEgMTAuMzk5OSAxLjYwMTU2IDEwLjY4NjQgMS42MDE1NiAxMS4wMzk5VjEzLjc1OTlDMS42MDE1NiAxNC4xMTM0IDEuODg4MSAxNC4zOTk5IDIuMjQxNTYgMTQuMzk5OUg0Ljk2MTU2QzUuMzE1MDIgMTQuMzk5OSA1LjYwMTU2IDE0LjExMzQgNS42MDE1NiAxMy43NTk5VjExLjAzOTlDNS42MDE1NiAxMC42ODY0IDUuMzE1MDIgMTAuMzk5OSA0Ljk2MTU2IDEwLjM5OTlaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik0xMy43NTg0IDEuNjAwMUgxMS4wMzg0QzEwLjY4NSAxLjYwMDEgMTAuMzk4NCAxLjg4NjY0IDEwLjM5ODQgMi4yNDAxVjQuOTYwMUMxMC4zOTg0IDUuMzEzNTYgMTAuNjg1IDUuNjAwMSAxMS4wMzg0IDUuNjAwMUgxMy43NTg0QzE0LjExMTkgNS42MDAxIDE0LjM5ODQgNS4zMTM1NiAxNC4zOTg0IDQuOTYwMVYyLjI0MDFDMTQuMzk4NCAxLjg4NjY0IDE0LjExMTkgMS42MDAxIDEzLjc1ODQgMS42MDAxWiIgZmlsbD0iI2ZmZiIvPgo8cGF0aCBkPSJNNCAxMkwxMiA0TDQgMTJaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00IDEyTDEyIDQiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIvPgo8L3N2Zz4K&logoColor=ffffff)](https://zread.ai/Jieli-Tech/iOS-JL_Bluetooth)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

[中文](./README.md)· [English](./README_EN.md) · [文档中心](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html) · [SDK 版本历史](#八版本历史) · [报告问题](https://github.com/Jieli-Tech/iOS-JL_Bluetooth/issues)

</div>

---

## 📋 目录

- [一、概述](#一概述)
- [二、运行环境](#二运行环境)
- [三、快速开始](#三快速开始)
- [四、工程结构](#四工程结构)
- [五、配置说明](#五配置说明)
- [六、调试技巧](#六调试技巧)
- [七、社区与支持](#七社区与支持)
- [八、版本历史](#八版本历史)
- [九、许可证](#九许可证)

---

## 一、概述

`iOS-JL_Bluetooth` 是**珠海市杰理科技股份有限公司**为杰理音箱耳机类产品提供的蓝牙控制开发平台。本 SDK 基于<strong style="color:red">RCSP协议(远程控制系统协议)</strong>，提供完整的蓝牙控制功能和丰富的应用示例，支持以下应用场景：

| 应用类型 | 典型产品 |
|---------|---------|
| **音箱类产品** | 智能音箱、蓝牙音箱、便携音箱、Auracast音箱 |
| **耳机类产品** | TWS耳机、头戴式耳机、挂脖耳机、彩屏仓、翻译耳机 |
| **音频设备** | 蓝牙音频接收器、音频解码器、声卡、录音笔 |

**杰理之家SDK**提供了丰富的功能接口：

| 功能           | 说明                                                     |
| -------------- | -------------------------------------------------------- |
| **音乐控制**   | 手机音乐播放控制、设备音乐播放控制、ID3音乐信息显示      |
| **设备设置**   | 音量设置、状态查询、重启设备等                           |
| **文件浏览**   | 查看SD卡、U盘等存储器的音乐文件列表                      |
| **闹钟管理**   | 闹钟的增删改查, 闹钟铃声设置                             |
| **FM控制**     | FM收音功能、FM发射功能                                   |
| **灯光控制**   | 灯光闪烁, 频率, 颜色(RGB), 模式等控制, 实现酷炫效果      |
| **音效调节**   | 均衡器音效调节, 轻易打造卓越音质、 混响、高低音设置      |
| **按键设置**   | 耳机按键功能设置, 丰富耳机功能                           |
| **查找设备**   | 查找设备或查找手机                                       |
| **ANC设置**    | 噪声处理模式设置, 支持正常模式、主动降噪模式、通透模式等 |
| **彩屏仓控制** | 亮度调节，壁纸更新，屏幕保护程序更新等                   |
| **AI翻译**     | 录音翻译，面对面翻译，音视频翻译，通话翻译等             |
| **自定义命令** | 支持客户拓展功能                                         |

本仓库包含完整的 SDK 框架库（XCFramework 格式）、iOS 示例工程源码及开发文档，帮助开发者快速集成杰理蓝牙控制能力到 iOS 应用中。

---

## 二、运行环境

| 类别 | 要求 | 说明 |
|------|------|------|
| **iOS 系统** | iOS 12.0+ | 支持 BLE 功能 |
| **硬件要求** | 支持 RCSP 协议的固件 | AC693X、AC697X、AC695X 等 SDK |
| **开发平台** | Xcode | 建议使用最新版本 |
| **语言支持** | Objective-C / Swift | 提供完整的 API 支持 |

---

## 三、快速开始

### 3.1 克隆仓库

```bash
git clone https://github.com/Jieli-Tech/iOS-JL_Bluetooth.git
cd iOS-JL_Bluetooth
```

### 3.2 集成 SDK

1. **导入框架**：将 `libs/` 目录下的 XCFramework 添加到项目中
2. **配置权限**：在 `Info.plist` 中添加蓝牙使用权限描述
3. **初始化 SDK**：参考示例工程的初始化代码进行集成
4. **开始开发**：使用 SDK 提供的 API 进行功能开发

### 3.3 SDK 测试助手

**SDKTestHelper** 是专为开发者提供的 Swift 测试工具，具备以下功能：

- **SDK 功能测试** — 完整的 SDK API 测试界面
- **设备连接调试** — 蓝牙设备扫描、连接、断开测试
- **音频功能验证** — 音频编解码、播放控制测试
- **Auracast 广播** — 音频广播功能测试和调试
- **开发辅助** — 日志查看、数据分析、问题诊断
- **性能监控** — 连接状态、音频质量实时监控

**使用方法：**

```bash
# 打开测试助手工程
open code/SDKTestHelper/SDKTestHelper.xcworkspace
```

运行项目到 iOS 设备即可使用各项测试功能验证 SDK 集成效果。

---

## 四、工程结构

```
iOS-JL_Bluetooth/
├── code/                           # 演示程序源码
│   ├── JLAudioUnitKitDemo/         #  音频编解码示例项目
│   │   ├── Code/JLAudioUnitKitDemo/
│   │   │   ├── JLAudioUnitKitDemo.xcworkspace
│   │   │   ├── JLAudioUnitKitDemo/      # Swift 示例应用
│   │   │   ├── JLAudioUnitKit.xcframework # 音频处理框架
│   │   │   ├── JLLogHelper.xcframework  # 日志辅助框架
│   │   │   └── Pods/                    # 依赖库
│   │   ├── Docs/                        # 开发文档
│   │   ├── Libs/                        # 框架库
│   │   └── readme.md                    # 项目说明
│   ├── JieLi_Home_Demo/             # 杰理之家主应用示例
│   │   ├── NewJieliZhiNeng.xcworkspace  # 主工作空间
│   │   ├── NewJieliZhiNeng/             # iOS 应用源码
│   │   │   ├── App设置/                 #   应用设置模块
│   │   │   ├── Http接口/               #   网络接口
│   │   │   ├── 多媒体/                  #   多媒体功能
│   │   │   ├── 卡拉OK/                  #   卡拉OK功能
│   │   │   ├── 设备/                    #   设备管理
│   │   │   └── 音效/                    #   音效处理
│   │   ├── Frameworks/                  # 内置框架库
│   │   ├── Sources/                     # 资源文件
│   │   ├── Languages/                   # 多语言支持
│   │   └── Pods/                        # CocoaPods 依赖
│   └── SDKTestHelper/               # SDK 测试助手工具
│       ├── SDKTestHelper.xcworkspace    # 测试工具工作空间
│       ├── SDKTestHelper/               # Swift 测试应用源码
│       │   ├── Controllers/             #   控制器模块
│       │   ├── Tools/                   #   工具类
│       │   ├── Models/                  #   数据模型
│       │   ├── Views/                   #   视图组件
│       │   ├── Bluetooth/               #   蓝牙连接模块
│       │   └── DataBase/                #   数据库管理
│       ├── JLAudioUnitKit.framework     # 音频编解码框架
│       ├── JLAV2Lib.framework           # AV2 音频编解码库
│       ├── JLAuracastKit.xcframework    # Auracast 广播框架
│       ├── SpeexKit.framework           # Speex 语音编解码
│       └── Pods/                        # 第三方依赖库
├── docs/                           # 文档资源
│   ├── html/                           # HTML 格式文档
│   │   ├── index.html                  #   文档首页
│   │   ├── Development/                #   开发指南
│   │   ├── Framework/                  #   框架说明
│   │   └── Other/                      #   其他文档
│   ├── 杰理之家SDK(iOS)发布记录.pdf
│   ├── 杰理开放平台接入说明文档_V1.0.3.pdf
│   └── 设备规范文档/                   # 设备使用规范
└── libs/                           # 核心 SDK 库 (XCFramework 格式)
    ├── JL_BLEKit.xcframework           # 蓝牙连接核心库
    ├── JL_OTALib.xcframework           # OTA 升级库
    ├── JLDialUnit.xcframework          # 表盘处理库
    ├── JLBmpConvertKit.xcframework     # 图像转换库
    ├── JLLogHelper.xcframework         # 日志辅助库
    ├── JLPackageResKit.xcframework     # 资源包处理库
    ├── JL_AdvParse.xcframework         # 广告解析库
    └── JL_HashPair.xcframework         # 哈希配对库
```

### 4.1 关键目录说明

| 目录 | 作用 |
|------|------|
| `code/` | **示例工程**：包含完整的 iOS 示例项目源码 |
| `code/*/Pods/` | **依赖管理**：CocoaPods 第三方依赖库 |
| `libs/` | **核心 SDK**：XCFramework 格式的蓝牙控制库 |
| `docs/` | **开发文档**：HTML 文档、PDF 说明、设备规范 |
| `docs/html/` | **API 文档**：在线可浏览的 HTML 格式文档 |

---

## 五、配置说明

### 5.1 杰理之家主应用 (`code/JieLi_Home_Demo/`)

| 项目 | 说明 |
|------|------|
| **适用场景** | 完整的音箱/耳机控制 App，支持多媒体、音效、设备管理 |
| **关键特性** | 卡拉 OK、音效调节、多语言、HTTP 接口、OTA 升级 |
| **参考文档** | [SDK 接入文档](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html) |

### 5.2 音频编解码示例 (`code/JLAudioUnitKitDemo/`)

| 项目 | 说明 |
|------|------|
| **适用场景** | 音频编解码功能的集成与调试 |
| **关键特性** | Opus/Speex 编解码、音频 Unit 处理、日志辅助 |
| **参考文档** | [项目内文档](./code/JLAudioUnitKitDemo/Docs/) |

### 5.3 SDK 测试助手 (`code/SDKTestHelper/`)

| 项目 | 说明 |
|------|------|
| **适用场景** | SDK 功能测试、设备调试、性能监控 |
| **关键特性** | 全 API 测试覆盖、Auracast 广播、蓝牙调试、性能监控 |
| **参考文档** | [项目内文档](./docs/html/index.html) |

---

## 六、调试技巧

- 日志输出：SDK提供详细的日志输出，可通过日志查看蓝牙连接状态和数据交互
- 设备调试：使用 xcode 的 Console 查看器查看实时日志
- 问题排查：
- SDK： 参考 [SDK调试说明](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/Other/debug.html)
- 杰理之家APP：参考[杰理之家导出打印日志说明](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/Other/debug.html#id3)


---

## 七、社区与支持

### 资源链接

| 资源 | 链接 |
|------|------|
| 📖 **在线文档中心** | [https://doc.zh-jieli.com/](https://doc.zh-jieli.com/) |
| 📄 **SDK 接入文档** | [https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html) |
| 🌐 **官方网站** | [https://www.zh-jieli.com/](https://www.zh-jieli.com/) |
| 📚 **SDK 发布记录** | [doc/杰理之家SDK(iOS)发布记录.pdf](./docs/杰理之家SDK(iOS)发布记录.pdf) |
| 🐛 **问题反馈** | [https://github.com/Jieli-Tech/iOS-JL_Bluetooth/issues](https://github.com/Jieli-Tech/iOS-JL_Bluetooth/issues) |

---

## 八、版本历史

| 版本 | 发布日期 |  主要更新 |
|------|----------|----------|
| **v1.14.0** | 2026/01/27 | 1. 新增功能<br/>（1）增加 LE Audio 与 RCSP 并存功能<br/>（2）增加 AI 翻译功能<br/>（3）增加 Auracast Broadcast 功能<br/>（4）增加 Gatt Over BR/EDR 连接方式的支持<br/>2. 修复功能<br/>（1）修改彩屏仓本地资源 |
| **v1.13.0** | 2025/07/18 | 新增功能<br/>（1）增加彩屏仓功能的支持<br/>（2）增加屏幕亮度控制<br/>（3）增加屏幕保护程序控制<br/>（4）增加同步天气信息 |
| **v1.12.0** | 2024/11/22 | 增加兼容 AC707N 的自定义表盘图像转换；分离图像转换工具作为独立模块库 |
| **v1.11.0** | 2024/03/15 | 新增表盘拓展参数和补充 AI 表盘流程；增加 4G 模块 OTA 功能；修复已知问题 |
| **v1.10.0** | 2023/11/23 | 新增 TWS 耳机一拖二功能和接口；支持芯片 JL701N v1.0.0_patch_06；修复已知问题 |
| **v1.6.4** | 2022/08/12 | 新增辅听耳机的验配功能 |
| **v1.6.3** | 2022/07/20 | 增加支持挂脖耳机 UI |
| **v1.5.0** | 2021/08/12 | 增加音箱 SDK 闹钟贪睡模式；支持响铃时长、再响间隔设置；增加耳机 SDK 的 ANC 主动降噪；支持降噪、通透模式切换 |


---

## 九、许可证

本项目采用 [Apache License 2.0](./LICENSE) 开源协议。

```
Copyright 2024 珠海市杰理科技股份有限公司

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

---

<div align="center">
  <sub>Copyright © 2024-2026 珠海市杰理科技股份有限公司. All rights reserved.</sub>
</div>
