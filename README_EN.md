[tag download]:https://github.com/Jieli-Tech/iOS-JL_Bluetooth/tags
[tag_badgen]:https://img.shields.io/github/v/tag/Jieli-Tech/iOS-JL_Bluetooth?style=plastic&logo=apple&labelColor=ffffff&color=informational&label=Tag&logoColor=blue

# iOS-JL_Bluetooth  [![tag][tag_badgen]][tag download]

<div align="center">

**JieLi Home SDK (iOS) - Bluetooth Control Development Platform for JieLi Speaker & Headphone Products**

![iOS](https://img.shields.io/badge/iOS-12.0+-blue.svg)
![Xcode](https://img.shields.io/badge/Xcode-Latest-orange.svg)
[![zread](https://img.shields.io/badge/Ask_Zread-_.svg?style=flat&color=00b0aa&labelColor=000000&logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB3aWR0aD0iMTYiIGhlaWdodD0iMTYiIHZpZXdCb3g9IjAgMCAxNiAxNiIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTQuOTYxNTYgMS42MDAxSDIuMjQxNTZDMS44ODgxIDEuNjAwMSAxLjYwMTU2IDEuODg2NjQgMS42MDE1NiAyLjI0MDFWNC45NjAxQzEuNjAxNTYgNS4zMTM1NiAxLjg4ODEgNS42MDAxIDIuMjQxNTYgNS42MDAxSDQuOTYxNTZDNS4zMTUwMiA1LjYwMDEgNS42MDE1NiA1LjMxMzU2IDUuNjAxNTYgNC45NjAxVjIuMjQwMUM1LjYwMTU2IDEuODg2NjQgNS4zMTUwMiAxLjYwMDEgNC45NjE1NiAxLjYwMDFaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00Ljk2MTU2IDEwLjM5OTlIMi4yNDE1NkMxLjg4ODEgMTAuMzk5OSAxLjYwMTU2IDEwLjY4NjQgMS42MDE1NiAxMS4wMzk5VjEzLjc1OTlDMS42MDE1NiAxNC4xMTM0IDEuODg4MSAxNC4zOTk5IDIuMjQxNTYgMTQuMzk5OUg0Ljk2MTU2QzUuMzE1MDIgMTQuMzk5OSA1LjYwMTU2IDE0LjExMzQgNS42MDE1NiAxMy43NTk5VjExLjAzOTlDNS42MDE1NiAxMC42ODY0IDUuMzE1MDIgMTAuMzk5OSA0Ljk2MTU2IDEwLjM5OTlaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik0xMy43NTg0IDEuNjAwMUgxMS4wMzg0QzEwLjY4NSAxLjYwMDEgMTAuMzk4NCAxLjg4NjY0IDEwLjM5ODQgMi4yNDAxVjQuOTYwMUMxMC4zOTg4NSA1LjMxMzU2IDEwLjY4NSA1LjYwMDEgMTEuMDM4NCA1LjYwMDFIMTMuNzU4NEMxNC4xMTE5IDUuNjAwMSAxNC4zOTg0IDUuMzEzNTYgMTQuMzk4NCA0Ljk2MDFWMi4yNDAxQzE0LjM5ODQgMS44ODY2NCAxNC4xMTE5IDEuNjAwMSAxMy43NTg0IDEuNjAwMVoiIGZpbGw9IiNmZmYiLz4KPHBhdGggZD0iTTQgMTJMMTIgNCE0IDEJaIiBmaWxsPSIjZmZmIi8%2BCjxwYXRoIGQ9Ik00IDEyTDEyIDQiIHN0cm9rZT0iI2ZmZiIgc3Ryb2tlLXdpZHRoPSIxLjUiIHN0cm9rZS1saW5lY2FwPSJyb3VuZCIvPgo8L3N2Zz4K&logoColor=ffffff)](https://zread.ai/Jieli-Tech/iOS-JL_Bluetooth)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

[中文](./README.md) · [English](./README_EN.md) · [Documentation](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html) · [SDK Version History](#8-version-history) · [Report Issues](https://github.com/Jieli-Tech/iOS-JL_Bluetooth/issues)

</div>

---

## 📋 Table of Contents

- [1. Overview](#1-overview)
- [2. System Requirements](#2-system-requirements)
- [3. Quick Start](#3-quick-start)
- [4. Project Structure](#4-project-structure)
- [5. Configuration Guide](#5-configuration-guide)
- [6. Debugging Tips](#6-debugging-tips)
- [7. Community & Support](#7-community--support)
- [8. Version History](#8-version-history)
- [9. License](#9-license)

---

## 1. Overview

`iOS-JL_Bluetooth` is a Bluetooth control development platform provided by **Zhuhai JieLi Technology Co., Ltd.** for JieLi speaker and headphone products. This SDK is based on **RCSP Protocol (Remote Control System Protocol)**, providing complete Bluetooth control functionality and rich application examples, supporting the following application scenarios:

| Application Type | Typical Products |
|-----------------|-----------------|
| **Speaker Products** | Smart speakers, Bluetooth speakers, portable speakers, Auracast speakers. |
| **Headphone Products** | TWS earbuds, over-ear headphones, neckband headphones, color screen cases, translation headphones |
| **Audio Devices** | Bluetooth audio receivers, audio decoders, sound cards, voice recorders |

**JieLi Home SDK** provides rich functional interfaces:

| Function | Description |
| -------- | ------------------------------------------------------------ |
| **Music Control** | Phone music playback control, device music playback control, ID3 music info display |
| **Device Settings** | Volume settings, status query, device restart, etc. |
| **File Browser** | View music file lists on SD card, USB drive and other storage devices |
| **Alarm Management** | Add, delete, modify, query alarms, alarm ringtone settings |
| **FM Control** | FM radio function, FM transmitter function |
| **Light Control** | Light flash, frequency, color (RGB), mode control, create cool effects |
| **Sound Effects** | Equalizer sound effect adjustment, easily create excellent sound quality, reverb, high/low tone settings |
| **Button Settings** | Headphone button function settings, enrich headphone features |
| **Find Device** | Find device or find phone |
| **ANC Settings** | Noise processing mode settings, supports normal mode, active noise cancellation mode, transparency mode, etc. |
| **Color Screen Case Control** | Brightness adjustment, wallpaper update, screensaver update, etc. |
| **AI Translation** | Recording translation, face-to-face translation, audio/video translation, call translation, etc. |
| **Custom Commands** | Support customer extended functionality |

This repository includes complete SDK framework libraries (XCFramework format), iOS demo project source code, and development documentation to help developers quickly integrate JieLi Bluetooth control capabilities into iOS applications.

---

## 2. System Requirements

| Category | Requirements | Description |
|----------|--------------|-------------|
| **iOS System** | iOS 12.0+ | Supports BLE functionality |
| **Hardware Requirements** | Firmware supporting RCSP protocol | SDKs such as AC693X, AC697X, AC695X, etc. |
| **Development Platform** | Xcode | Latest version recommended |
| **Language Support** | Objective-C / Swift | Full API support |

---

## 3. Quick Start

### 3.1 Clone the Repository

```bash
git clone https://github.com/Jieli-Tech/iOS-JL_Bluetooth.git
cd iOS-JL_Bluetooth
```

### 3.2 Integrate the SDK

1. **Import Frameworks** — Add XCFrameworks from the `libs/` directory to your project
2. **Configure Permissions** — Add Bluetooth usage description in `Info.plist`
3. **Initialize SDK** — Follow the demo project's initialization code
4. **Start Development** — Use the SDK APIs for feature development

### 3.3 SDK Test Helper

**SDKTestHelper** is a Swift testing tool designed specifically for developers, featuring:

- **SDK Function Testing** — Complete SDK API testing interface
- **Device Connection Debugging** — Bluetooth scanning, connection, and disconnection testing
- **Audio Function Verification** — Audio codec and playback control testing
- **Auracast Broadcasting** — Audio broadcast function testing and debugging
- **Development Assistance** — Log viewing, data analysis, issue diagnosis
- **Performance Monitoring** — Real-time connection status and audio quality monitoring

**Usage:**

```bash
# Open the test helper project
open code/SDKTestHelper/SDKTestHelper.xcworkspace
```

Run the project on an iOS device and use the testing features to verify SDK integration.

---

## 4. Project Structure

```
iOS-JL_Bluetooth/
├── code/                           # Demo source code
│   ├── JLAudioUnitKitDemo/         #  Audio codec demo project
│   │   ├── Code/JLAudioUnitKitDemo/
│   │   │   ├── JLAudioUnitKitDemo.xcworkspace
│   │   │   ├── JLAudioUnitKitDemo/      # Swift demo application
│   │   │   ├── JLAudioUnitKit.xcframework # Audio processing framework
│   │   │   ├── JLLogHelper.xcframework  # Log helper framework
│   │   │   └── Pods/                    # Dependencies
│   │   ├── Docs/                        # Development documentation
│   │   ├── Libs/                        # Framework libraries
│   │   └── readme.md                    # Project description
│   ├── JieLi_Home_Demo/             # JieLi Home main application demo
│   │   ├── NewJieliZhiNeng.xcworkspace  # Main workspace
│   │   ├── NewJieliZhiNeng/             # iOS application source code
│   │   │   ├── App Settings/            #   App settings module
│   │   │   ├── Http Interfaces/         #   Network interfaces
│   │   │   ├── Multimedia/              #   Multimedia features
│   │   │   ├── Karaoke/                 #   Karaoke features
│   │   │   ├── Device/                  #   Device management
│   │   │   └── Audio Effects/           #   Audio effects
│   │   ├── Frameworks/                  # Built-in framework libraries
│   │   ├── Sources/                     # Resource files
│   │   ├── Languages/                   # Multi-language support
│   │   └── Pods/                        # CocoaPods dependencies
│   └── SDKTestHelper/               # SDK Test Helper Tool
│       ├── SDKTestHelper.xcworkspace    # Test tool workspace
│       ├── SDKTestHelper/               # Swift test application source code
│       │   ├── Controllers/             #   Controller modules
│       │   ├── Tools/                   #   Utility classes
│       │   ├── Models/                  #   Data models
│       │   ├── Views/                   #   View components
│       │   ├── Bluetooth/               #   Bluetooth connection module
│       │   └── DataBase/                #   Database management
│       ├── JLAudioUnitKit.framework     # Audio codec framework
│       ├── JLAV2Lib.framework           # AV2 audio codec library
│       ├── JLAuracastKit.xcframework    # Auracast broadcast framework
│       ├── SpeexKit.framework           # Speex voice codec
│       └── Pods/                        # Third-party dependencies
├── docs/                           # Documentation resources
│   ├── html/                           # HTML format documentation
│   │   ├── index.html                  #   Documentation homepage
│   │   ├── Development/                #   Development guide
│   │   ├── Framework/                  #   Framework documentation
│   │   └── Other/                      #   Other documentation
│   ├── JieLi Home SDK(iOS) Release Record.pdf
│   ├── JieLi Open Platform Integration Guide_V1.0.3.pdf
│   └── Device Specification Documents/ # Device usage specifications
└── libs/                           # Core SDK libraries (XCFramework format)
    ├── JL_BLEKit.xcframework           # Bluetooth connection core library
    ├── JL_OTALib.xcframework           # OTA upgrade library
    ├── JLDialUnit.xcframework          # Watch face processing library
    ├── JLBmpConvertKit.xcframework     # Image conversion library
    ├── JLLogHelper.xcframework         # Log helper library
    ├── JLPackageResKit.xcframework     # Resource package processing library
    ├── JL_AdvParse.xcframework         # Advertisement parsing library
    └── JL_HashPair.xcframework         # Hash pairing library
```

### 4.1 Key Directory Descriptions

| Directory | Purpose |
|-----------|---------|
| `code/` | **Demo projects**: Complete iOS demo application source code |
| `code/*/Pods/` | **Dependency management**: CocoaPods third-party libraries |
| `libs/` | **Core SDK**: XCFramework format Bluetooth control libraries |
| `docs/` | **Documentation**: HTML docs, PDF guides, device specifications |
| `docs/html/` | **API docs**: Browseable HTML documentation |

---

## 5. Configuration Guide

### 5.1 JieLi Home Main App (`code/JieLi_Home_Demo/`)

| Item | Description |
|------|-------------|
| **Use Case** | Full-featured speaker/headphone control App with multimedia, effects, and device management |
| **Key Features** | Karaoke, audio effects, multi-language, HTTP API, OTA upgrades |
| **Reference Docs** | [SDK Integration Guide](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html) |

### 5.2 Audio Codec Demo (`code/JLAudioUnitKitDemo/`)

| Item | Description |
|------|-------------|
| **Use Case** | Audio codec integration and debugging |
| **Key Features** | Opus/Speex codec, Audio Unit processing, log assistance |
| **Reference Docs** | [Project Documentation](./code/JLAudioUnitKitDemo/Docs/) |

### 5.3 SDK Test Helper (`code/SDKTestHelper/`)

| Item | Description |
|------|-------------|
| **Use Case** | SDK function testing, device debugging, performance monitoring |
| **Key Features** | Full API test coverage, Auracast broadcasting, Bluetooth debugging, performance monitoring |
| **Reference Docs** | [Project Documentation](./docs/html/index.html) |

---

## 6. Debugging Tips

- **Log Output**: SDK provides detailed log output, you can view Bluetooth connection status and data interaction through logs
- **Device Debugging**: Use Xcode's Console viewer to view real-time logs
- **Troubleshooting**:
  - **SDK**: Refer to [SDK Debugging Guide](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/Other/debug.html)
  - **JieLi Home App**: Refer to [JieLi Home Export Log Instructions](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/Other/debug.html#id3)

---

## 7. Community & Support

### Resource Links

| Resource | Link |
|----------|------|
| 📖 **Online Documentation Center** | [https://doc.zh-jieli.com/](https://doc.zh-jieli.com/) |
| 📄 **SDK Integration Guide** | [https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html) |
| 🌐 **Official Website** | [https://www.zh-jieli.com/](https://www.zh-jieli.com/) |
| 📚 **SDK Release Record** | [docs/JieLi Home SDK(iOS) Release Record.pdf](./docs/杰理之家SDK(iOS)发布记录.pdf) |
| 🐛 **Issue Reporting** | [https://github.com/Jieli-Tech/iOS-JL_Bluetooth/issues](https://github.com/Jieli-Tech/iOS-JL_Bluetooth/issues) |

---

## 8. Version History

| Version | Release Date | Major Updates |
|---------|--------------|---------------|
| **v1.14.0** | 2026/01/27 | 1. New Features<br/>(1) Added coexistence of LE Audio and RCSP<br/>(2) Added AI translation feature<br/>(3) Added Auracast Broadcast feature<br/>(4) Added support for GATT over BR/EDR connection method<br/>2. Fixes<br/>(1) Modified local resources of the color-screen repository |
| **v1.13.0** | 2025/07/18 | New Features<br/>(1) Added color screen case feature support<br/>(2) Added screen brightness control<br/>(3) Added screen saver program control<br/>(4) Added weather information synchronization |
| **v1.12.0** | 2024/11/22 | Added AC707N compatible custom watch face image conversion; separated image conversion tool as independent module library |
| **v1.11.0** | 2024/03/15 | Added watch face extension parameters and supplemented AI watch face process; added 4G module OTA functionality; fixed known issues |
| **v1.10.0** | 2023/11/23 | Added TWS earphone one-to-two functionality and interface; support for chip JL701N v1.0.0_patch_06; fixed known issues |
| **v1.6.4** | 2022/08/12 | Added fitting function for hearing aid earphones |
| **v1.6.3** | 2022/07/20 | Added support for neck-mounted earphone UI |
| **v1.5.0** | 2021/08/12 | Added speaker SDK alarm clock snooze mode; support for ring duration and re-ring interval settings; added ANC active noise cancellation for earphone SDK; support for noise reduction and transparency mode switching |

---

## 9. License

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
  <sub>Copyright © 2024-2026 Zhuhai JieLi Technology Co., Ltd. All rights reserved.</sub>
</div>