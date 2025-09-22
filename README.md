# iOS-JL_Bluetooth

<div align="center">

![iOS](https://img.shields.io/badge/iOS-12.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-Latest-orange.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

**杰理蓝牙音箱 iOS SDK**

*专业的蓝牙音箱耳机控制开发平台*

</div>

---

## 📖 概述

杰理蓝牙音箱SDK是由**珠海市杰理科技股份有限公司**开发的专业蓝牙控制开发平台，专门为杰理音箱耳机类产品提供完整的iOS端控制解决方案。

### ✨ 主要特性

- 🎵 支持音箱、耳机等多种设备类型
- 🔊 完整的音频控制功能
- 🎤 专业的音频编解码库（Opus、Speex）
- 🖼️ 图像转换和表盘处理功能
- 📱 原生iOS开发体验
- 🔗 基于RCSP协议的稳定连接
- 🎧 支持TWS耳机一拖二功能
- 🔇 支持ANC主动降噪功能
- 🧪 提供SDK测试助手工具，便于开发调试
- 📡 支持Auracast音频广播功能

---

## 🛠 运行环境

| 类别 | 要求 | 说明 |
|------|------|------|
| **iOS系统** | iOS 12.0+ | 支持BLE功能 |
| **硬件要求** | 支持RCSP协议的固件 | AC693X、AC697X、AC695X等SDK |
| **开发平台** | Xcode | 建议使用最新版本 |
| **语言支持** | Objective-C / Swift | 完整API支持 |

---

## 🚀 快速开始

### 📚 文档资源

为了帮助开发者快速接入杰理之家SDK，请在开发前详细阅读：

- 📖 [SDK接入文档](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html)
- 📄 [开发说明文档](./docs/)
- 🔧 [API参考手册](./docs/JieLiBluetoothControlSDKDevelopmentInstructions(iOS)/)

### 💻 集成步骤

1. **下载SDK** - 从本仓库获取最新版本
2. **导入框架** - 将libs目录下的framework添加到项目
3. **配置权限** - 添加蓝牙相关权限
4. **初始化SDK** - 参考示例代码进行初始化
5. **开始开发** - 使用API进行功能开发

### 🧪 SDK测试助手工具

**SDKTestHelper** 是专为开发者提供的Swift测试工具，具备以下功能：

- 🔍 **SDK功能测试** - 完整的SDK API测试界面
- 📱 **设备连接调试** - 蓝牙设备扫描、连接、断开测试
- 🎵 **音频功能验证** - 音频编解码、播放控制测试
- 📡 **Auracast广播** - 音频广播功能测试和调试
- 🔧 **开发辅助** - 日志查看、数据分析、问题诊断
- 📊 **性能监控** - 连接状态、音频质量实时监控

**使用方法：**
1. 打开 `code/SDKTestHelper/SDKTestHelper.xcworkspace`
2. 运行项目到iOS设备
3. 使用各项测试功能验证SDK集成效果

---

## 📁 项目结构

```
iOS-JL_Bluetooth/
├── 📂 code/                          # 演示程序源码
│   ├── 📦 Example of audio encoding and decoding V1.1.0.zip
│   ├── 📂 JLAudioUnitKitDemo_V1.3.0_Beta1_20250827/ # 音频编解码示例项目 (最新版本)
│   │   ├── 📂 code/JLAudioUnitKitDemo/
│   │   │   ├── 🏗️ JLAudioUnitKitDemo.xcworkspace
│   │   │   ├── 📱 JLAudioUnitKitDemo/    # Swift示例应用
│   │   │   ├── 🎵 JLAudioUnitKit.xcframework # 音频处理框架
│   │   │   ├── 📝 JLLogHelper.xcframework # 日志辅助框架
│   │   │   └── 🔧 Pods/                  # 依赖库
│   │   ├── 📂 docs/                      # 开发文档
│   │   ├── 📂 libs/                      # 框架库
│   │   └── 📄 readme.md                  # 项目说明
│   └── 📂 JieLi_Home_Demo/           # 杰理之家主应用示例
│       ├── 🏗️ NewJieliZhiNeng.xcworkspace # 主工作空间
│       ├── 📱 NewJieliZhiNeng/       # iOS应用源码
│       │   ├── 🎯 App设置/            # 应用设置模块
│       │   ├── 🌐 Http接口/          # 网络接口
│       │   ├── 🎵 多媒体/            # 多媒体功能
│       │   ├── 🎤 卡拉OK/            # 卡拉OK功能
│       │   ├── 📱 设备/              # 设备管理
│       │   └── 🎛️ 音效/              # 音效处理
│       ├── 🔧 Frameworks/            # 内置框架库
│       ├── 📚 Sources/               # 资源文件
│       ├── 🌍 Languages/             # 多语言支持
│       └── 🔧 Pods/                  # CocoaPods依赖
│   └── 📂 SDKTestHelper/             # SDK测试助手工具 (Swift项目)
│       ├── 🏗️ SDKTestHelper.xcworkspace # 测试工具工作空间
│       ├── 📱 SDKTestHelper/         # Swift测试应用源码
│       │   ├── 🎯 Controllers/       # 控制器模块
│       │   ├── 🔧 Tools/             # 工具类
│       │   ├── 📊 Models/            # 数据模型
│       │   ├── 🎨 Views/             # 视图组件
│       │   ├── 🔗 Bluetooth/         # 蓝牙连接模块
│       │   └── 💾 DataBase/          # 数据库管理
│       ├── 🎵 JLAudioUnitKit.framework # 音频编解码框架
│       ├── 🎬 JLAV2Lib.framework    # AV2音频编解码库
│       ├── 📡 JLAuracastKit.xcframework # Auracast广播框架
│       ├── 🔧 SpeexKit.framework    # Speex语音编解码
│       └── 🔧 Pods/                  # 第三方依赖库
├── 📂 docs/                          # 文档资源
│   ├── 📖 JL_OTALib.framework API 说明.md
│   ├── 📄 html/                      # HTML格式文档
│   │   ├── 🏠 index.html             # 文档首页
│   │   ├── 📁 Development/           # 开发指南
│   │   ├── 📁 Framework/             # 框架说明
│   │   └── 📁 Other/                 # 其他文档
│   ├── 📋 杰理之家SDK(iOS)发布记录.pdf
│   ├── 📄 杰理开放平台接入说明文档_V1.0.3.pdf
│   └── 📦 设备规范文档/              # 设备使用规范
└── 📂 libs/                          # 核心SDK库 (XCFramework格式)
    ├── 🔗 JL_BLEKit.xcframework      # 蓝牙连接核心库
    ├── 🔧 JL_OTALib.xcframework      # OTA升级库
    ├── 🎵 JLDialUnit.xcframework     # 表盘处理库
    ├── 🖼️ JLBmpConvertKit.xcframework # 图像转换库
    ├── 📝 JLLogHelper.xcframework    # 日志辅助库
    ├── 📦 JLPackageResKit.xcframework # 资源包处理库
    ├── 🔍 JL_AdvParse.xcframework    # 广告解析库
    └── 🔐 JL_HashPair.xcframework    # 哈希配对库
```

---

## 📋 版本历史

| 版本 | 发布日期 | 编辑者 | 主要更新 |
|------|----------|--------|----------|
|**v1.13.0** | 2025/07/18 | EzioChen | • 新增功能<br/>（1）增加彩屏仓功能的支持<br/>（2）增加屏幕亮度控制<br/>（3）增加屏幕保护程序控制<br/>（4）增加同步天气信息 |
| **v1.12.0** | 2024/11/22 | EzioChen | • 增加兼容 AC707N 的自定义表盘图像转换<br/>• 分离图像转换工具作为独立模块库 |
| **v1.11.0** | 2024/03/15 | EzioChen | • 新增表盘拓展参数和补充 AI 表盘流程；<br/>• 增加 4G 模块 OTA 功能<br/>• 修复已知问题 |
| **v1.10.0** | 2023/11/23 | EzioChen | • 新增TWS耳机一拖二功能和接口<br/>• 支持芯片JL701N v1.0.0_patch_06<br/>• 修复已知问题 |
| **v1.6.4** | 2022/08/12 | EzioChen | • 新增辅听耳机的验配功能 |
| **v1.6.3** | 2022/07/20 | EzioChen | • 增加支持挂脖耳机UI |
| **v1.5.0** | 2021/08/12 | 冯洪鹏 | • 增加音箱SDK闹钟贪睡模式<br/>• 支持响铃时长、再响间隔设置<br/>• 增加耳机SDK的ANC主动降噪<br/>• 支持降噪、通透模式切换 |

---

## 📞 技术支持

- 🌐 **官方网站**: [杰理科技](https://www.zh-jieli.com/)
- 📧 **技术支持**: 请通过官方渠道联系
- 📖 **在线文档**: [SDK开发文档](https://doc.zh-jieli.com/)
- 🔗 **自定义接入**: [蓝牙接入方式](./docs/自定义蓝牙接入方式.url)

---

## 📄 许可证

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

**© 2024 珠海市杰理科技股份有限公司 | Licensed under Apache License 2.0**

</div>
