# iOS-JL_Bluetooth

<div align="center">

![iOS](https://img.shields.io/badge/iOS-12.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-Latest-orange.svg)
[![zread](https://img.shields.io/badge/Ask_Zread-_.svg?style=flat&color=00b0aa&labelColor=000000&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQuOTYxNTYgMS42MDAxSDIuMjQxNTZDMS44ODgxIDEuNjAwMSAxLjYwMTU2IDEuODg2NjQgMS42MDE1NiAyLjI0MDFWNC45NjAxQzEuNjAxNTYgNS4zMTM1NiAxLjg4ODEgNS42MDAxIDIuMjQxNTYgNS42MDAxSDQuOTYxNTZDNS4zMTUwMiA1LjYwMDEgNS42MDE1NiA1LjMxMzU2IDUuNjAxNTYgNC45NjAxVjIuMjQwMUM1LjYwMTU2IDEuODg2NjQgNS4zMTUwMiAxLjYwMDEgNC45NjE1NiAxLjYwMDFaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00Ljk2MTU2IDEwLjM5OTlIMi4yNDE1NkMxLjg4ODEgMTAuMzk5OSAxLjYwMTU2IDEwLjY4NjQgMS42MDE1NiAxMS4wMzk5VjEzLjc1OTlDMS42MDE1NiAxNC4xMTM0IDEuODg4MSAxNC4zOTk5IDIuMjQxNTYgMTQuMzk5OUg0Ljk2MTU2QzUuMzE1MDIgMTQuMzk5OSA1LjYwMTU2IDE0LjExMzQgNS42MDE1NiAxMy43NTk5VjExLjAzOTlDNS42MDE1NiAxMC42ODY0IDUuMzE1MDIgMTAuMzk5OSA0Ljk2MTU2IDEwLjM5OTlaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik0xMy43NTg0IDEuNjAwMUgxMS4wMzg0QzEwLjY4NSAxLjYwMDEgMTAuMzk4NCAxLjg4NjY0IDEwLjM5ODQgMi4yNDAxVjQuOTYwMUMxMC4zOTg0IDUuMzEzNTYgMTAuNjg1IDUuNjAwMSAxMS4wMzg0IDUuNjAwMUgxMy43NTg0QzE0LjExMTkgNS42MDAxIDE0LjM5ODQgNS4zMTM1NiAxNC4zOTg0IDQuOTYwMVYyLjI0MDFDMTQuMzk4NCAxLjg4NjY0IDE0LjExMTkgMS42MDAxIDEzLjc1ODQgMS42MDAxWiIgZmlsbD0iI2ZmZiIvPgo8cGF0aCBkPSJNNCAxMkwxMiA0TDQgMTJaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00IDEyTDEyIDQiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIvPgo8L3N2Zz4K&logoColor=ffffff)](https://zread.ai/Jieli-Tech/iOS-JL_Bluetooth)
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
- 🧪 Provides SDK test helper tool for development and debugging
- 📡 Support for Auracast audio broadcasting functionality

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

### 🧪 SDK Test Helper Tool

**SDKTestHelper** is a Swift testing tool specifically designed for developers with the following features:

- 🔍 **SDK Function Testing** - Complete SDK API testing interface
- 📱 **Device Connection Debugging** - Bluetooth device scanning, connection, and disconnection testing
- 🎵 **Audio Function Verification** - Audio codec and playback control testing
- 📡 **Auracast Broadcasting** - Audio broadcast function testing and debugging
- 🔧 **Development Assistance** - Log viewing, data analysis, and issue diagnosis
- 📊 **Performance Monitoring** - Real-time monitoring of connection status and audio quality

**Usage Instructions:**
1. Open `code/SDKTestHelper/SDKTestHelper.xcworkspace`
2. Run the project on an iOS device
3. Use various testing features to verify SDK integration effectiveness

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
│   └── 📂 SDKTestHelper/             # SDK Test Helper Tool (Swift Project)
│       ├── 🏗️ SDKTestHelper.xcworkspace # Test tool workspace
│       ├── 📱 SDKTestHelper/         # Swift test application source code
│       │   ├── 🎯 Controllers/       # Controller modules
│       │   ├── 🔧 Tools/             # Utility classes
│       │   ├── 📊 Models/            # Data models
│       │   ├── 🎨 Views/             # View components
│       │   ├── 🔗 Bluetooth/         # Bluetooth connection module
│       │   └── 💾 DataBase/          # Database management
│       ├── 🎵 JLAudioUnitKit.framework # Audio codec framework
│       ├── 🎬 JLAV2Lib.framework    # AV2 audio codec library
│       ├── 📡 JLAuracastKit.xcframework # Auracast broadcast framework
│       ├── 🔧 SpeexKit.framework    # Speex voice codec
│       └── 🔧 Pods/                  # Third-party dependencies
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
| **v1.14.0** | 2026/01/27 | EzioChan | 1. New Features<br/>(1) Added coexistence of LE Audio and RCSP<br/>(2) Added AI translation feature<br/>(3) Added Auracast Broadcast feature<br/>(4) Added support for the GATT over BR/EDR connection method<br/>2. Fixes<br/>(1) Modified local resources of the color-screen repository |
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

