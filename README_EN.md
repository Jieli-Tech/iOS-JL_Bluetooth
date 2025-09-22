# iOS-JL_Bluetooth

<div align="center">

![iOS](https://img.shields.io/badge/iOS-12.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-Latest-orange.svg)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

**JieLi Bluetooth Speaker iOS SDK**

*Professional Bluetooth Speaker and Headphone Control Development Platform*

</div>

---

## 📖 Overview

JieLi Bluetooth Speaker SDK is a professional Bluetooth control development platform developed by **Zhuhai JieLi Technology Co., Ltd.**, specifically providing complete iOS-side control solutions for JieLi speaker and headphone products.

### ✨ Key Features

- 🎵 Support for multiple device types including speakers and headphones
- 🔊 Complete audio control functionality
- 🎤 Professional audio codec libraries (Opus, Speex)
- 🖼️ Image conversion and watch face processing capabilities
- 📱 Native iOS development experience
- 🔗 Stable connection based on RCSP protocol
- 🎧 Support for TWS earphone one-to-two functionality
- 🔇 Support for ANC active noise cancellation

---

## 🛠 System Requirements

| Category | Requirements | Description |
|----------|--------------|-------------|
| **iOS System** | iOS 12.0+ | Supports BLE functionality |
| **Hardware Requirements** | Firmware supporting RCSP protocol | SDKs such as AC693X, AC697X, AC695X, etc. |
| **Development Platform** | Xcode | Latest version recommended |
| **Language Support** | Objective-C / Swift | Full API support |

---

## 🚀 Quick Start

### 📚 Documentation Resources

To help developers quickly integrate the JieLi Home SDK, please read carefully before development:

- 📖 [SDK Integration Documentation](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html)
- 📄 [Development Documentation](./docs/)
- 🔧 [API Reference Manual](./docs/JieLiBluetoothControlSDKDevelopmentInstructions(iOS)/)

### 💻 Integration Steps

1. **Download SDK** - Get the latest version from this repository
2. **Import Frameworks** - Add frameworks from the libs directory to your project
3. **Configure Permissions** - Add Bluetooth-related permissions
4. **Initialize SDK** - Refer to example code for initialization
5. **Start Development** - Use APIs for feature development

---

## 📁 Project Structure

```
iOS-JL_Bluetooth/
├── 📂 code/                          # Demo program source code
│   ├── 📦 Example of audio encoding and decoding V1.1.0.zip
│   ├── 📂 JLAudioUnitKitDemo_V1.3.0_Beta1_20250827/ # Audio codec demo project (Latest Version)
│   │   ├── 📂 code/JLAudioUnitKitDemo/
│   │   │   ├── 🏗️ JLAudioUnitKitDemo.xcworkspace
│   │   │   ├── 📱 JLAudioUnitKitDemo/    # Swift demo application
│   │   │   ├── 🎵 JLAudioUnitKit.xcframework # Audio processing framework
│   │   │   ├── 📝 JLLogHelper.xcframework # Log helper framework
│   │   │   └── 🔧 Pods/                  # Dependencies
│   │   ├── 📂 docs/                      # Development documentation
│   │   ├── 📂 libs/                      # Framework libraries
│   │   └── 📄 readme.md                  # Project description
│   └── 📂 JieLi_Home_Demo/           # JieLi Home main application demo
│       ├── 🏗️ NewJieliZhiNeng.xcworkspace # Main workspace
│       ├── 📱 NewJieliZhiNeng/       # iOS application source code
│       │   ├── 🎯 App Settings/       # App settings module
│       │   ├── 🌐 Http Interfaces/   # Network interfaces
│       │   ├── 🎵 Multimedia/        # Multimedia features
│       │   ├── 🎤 Karaoke/           # Karaoke features
│       │   ├── 📱 Device/            # Device management
│       │   └── 🎛️ Audio Effects/     # Audio effects
│       ├── 🔧 Frameworks/            # Built-in framework libraries
│       ├── 📚 Sources/               # Resource files
│       ├── 🌍 Languages/             # Multi-language support
│       └── 🔧 Pods/                  # CocoaPods dependencies
├── 📂 docs/                          # Documentation resources
│   ├── 📖 JL_OTALib.framework API Documentation.md
│   ├── 📄 html/                      # HTML format documentation
│   │   ├── 🏠 index.html             # Documentation homepage
│   │   ├── 📁 Development/           # Development guide
│   │   ├── 📁 Framework/             # Framework documentation
│   │   └── 📁 Other/                 # Other documentation
│   ├── 📋 JieLi Home SDK(iOS) Release Record.pdf
│   ├── 📄 JieLi Open Platform Integration Guide_V1.0.3.pdf
│   └── 📦 Device Specification Documents/ # Device usage specifications
└── 📂 libs/                          # Core SDK libraries (XCFramework format)
    ├── 🔗 JL_BLEKit.xcframework      # Bluetooth connection core library
    ├── 🔧 JL_OTALib.xcframework      # OTA upgrade library
    ├── 🎵 JLDialUnit.xcframework     # Watch face processing library
    ├── 🖼️ JLBmpConvertKit.xcframework # Image conversion library
    ├── 📝 JLLogHelper.xcframework    # Log helper library
    ├── 📦 JLPackageResKit.xcframework # Resource package processing library
    ├── 🔍 JL_AdvParse.xcframework    # Advertisement parsing library
    └── 🔐 JL_HashPair.xcframework    # Hash pairing library
```

---

## 📋 Version History

| Version | Release Date | Editor | Major Updates |
|---------|--------------|--------|---------------|
| **v1.13.0** | 2025/07/18 | EzioChen | • Added color screen case feature support<br/>• Added screen brightness control<br/>• Added screen saver program control<br/>• Added weather information synchronization |
| **v1.12.0** | 2024/11/22 | EzioChen | • Added AC707N compatible custom watch face image conversion<br/>• Separated image conversion tool as independent module library |
| **v1.11.0** | 2024/03/15 | EzioChen | • Added watch face extension parameters and supplemented AI watch face process<br/>• Added 4G module OTA functionality<br/>• Fixed known issues |
| **v1.10.0** | 2023/11/23 | EzioChen | • Added TWS earphone one-to-two functionality and interface<br/>• Support for chip JL701N v1.0.0_patch_06<br/>• Fixed known issues |
| **v1.6.4** | 2022/08/12 | EzioChen | • Added fitting function for hearing aid earphones |
| **v1.6.3** | 2022/07/20 | EzioChen | • Added support for neck-mounted earphone UI |
| **v1.5.0** | 2021/08/12 | Feng Hongpeng | • Added speaker SDK alarm clock snooze mode<br/>• Support for ring duration and re-ring interval settings<br/>• Added ANC active noise cancellation for earphone SDK<br/>• Support for noise reduction and transparency mode switching |

---

## 📞 Technical Support

- 🌐 **Official Website**: [JieLi Technology](https://www.zh-jieli.com/)
- 📧 **Technical Support**: Please contact through official channels
- 📖 **Online Documentation**: [SDK Development Documentation](https://doc.zh-jieli.com/)
- 🔗 **Custom Integration**: [Bluetooth Integration Methods](./docs/自定义蓝牙接入方式.url)

---

## 📄 License

This project is licensed under the [Apache License 2.0](./LICENSE).

```
Copyright 2024 Zhuhai JieLi Technology Co., Ltd.

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

**© 2024 Zhuhai JieLi Technology Co., Ltd. | Licensed under Apache License 2.0**

</div>

