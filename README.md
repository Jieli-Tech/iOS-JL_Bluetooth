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

---

## 📁 项目结构

```
iOS-JL_Bluetooth/
├── 📂 code/                          # 演示程序源码
│   ├── 📦 Example of audio encoding and decoding V1.1.0.zip
│   ├── 📂 JLAudioUnitKitDemo/        # 音频编解码示例项目
│   │   ├── 🏗️ JLAudioUnitKitDemo.xcworkspace
│   │   ├── 📱 JLAudioUnitKitDemo/    # Swift示例应用
│   │   ├── 🎵 JLAudioUnitKit.framework # 音频处理框架
│   │   ├── 🔧 Tools/                 # 音频工具类
│   │   ├── 📺 ViewControllers/       # 视图控制器
│   │   └── 🎛️ Views/                 # 自定义视图组件
│   └── 📂 NewJieliZhiNeng/           # 主要示例项目
│       ├── 🏗️ NewJieliZhiNeng.xcworkspace
│       ├── 📱 NewJieliZhiNeng/       # iOS应用源码
│       ├── 📚 Sources/               # 源代码文件
│       └── 🔧 Pods/                  # 依赖库
├── 📂 docs/                          # 文档资源
│   ├── 📖 JieLiBluetoothControlSDKDevelopmentInstructions(iOS)/
│   ├── 📄 More/                      # 更多文档
│   └── 📋 杰理之家SDK(iOS)发布记录.pdf
└── 📂 libs/                          # 核心SDK库
    ├── 🔗 JL_BLEKit.framework        # 蓝牙连接核心库
    ├── 🔧 JL_OTALib.framework        # OTA升级库
    ├── 🎵 JLDialUnit.framework       # 表盘处理库
    ├── 🎵 JLAudioUnitKit.framework   # 音频编解码库
    ├── 🖼️ JLBmpConvertKit.framework   # 图像转换库
    ├── 🔐 JL_HashPair.framework      # 配对加密库
    ├── 📡 JL_AdvParse.framework      # 广播解析库
    ├── 📝 JLLogHelper.framework      # 日志辅助库
    ├── 🎤 SpeexKit.framework         # 语音编解码库
    └── 📦 third_party/               # 第三方依赖
```

---

## 📋 版本历史

| 版本 | 发布日期 | 编辑者 | 主要更新 |
|------|----------|--------|----------|
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
