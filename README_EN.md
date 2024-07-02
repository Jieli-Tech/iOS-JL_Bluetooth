# iOS-JL_Bluetooth
The bluetooth SDK for iOS
## 1.  summary
Jieli Bluetooth Speaker SDK is developed by Zhuhai Jieli Technology Co., Ltd. (hereinafter referred to as "the Company"), specifically providing a Bluetooth control development platform for our company's speaker and headphone products.
### 1.1 Environment

| Category                                                     | Compatibility Range                  | Remarks                                                     |
| ------------------------------------------------------------ | ------------------------------------ | ----------------------------------------------------------- |
| IOS system                                                   | iOS 12.0+                            | supports BLE function                                       |
| Hardware requirements                                        | Firmware that supports RCSP protocol | SDKs such as AC693X, AC697X, AC695X, etc                    |
| Development Platform                                         | xcode                                | It is recommended to use the latest version for development |

### 1.2 Access

To help developers quickly access the Jerry's Home SDK, please read the [SDK Access Document carefully before development](https://doc.zh-jieli.com/Apps/iOS/jielihome/zh-cn/master/index.html)

## 2.  Directory structure

```
|-Code - Demonstration program source code
|- JieLiHome
|- NewJieliZhiNeng
|- docs
|- ReleseRecord.pdf
|-Libs - Core Library
```
## 3.  Edition

| SDK version | date       | editing       | modified content                                             |
| ----------- | ---------- | ------------- | ------------------------------------------------------------ |
| v1.10.0     | 2023/11/23 | EzioChen      | 1. Newly added TWS earphone one to two function and interface (corresponding to chip JL701N v1.0.0_patch.06)<br/>2 Fix some issues |
| V1.6.4      | 2022/08/12 | EzioChen      | Added verification function for auxiliary listening headphones |
| V1.6.3      | 2022/07/20 | EzioChen      | Added UI support for neck mounted headphones                 |
| V1.5.0      | 2021/08/12 | Feng Hongpeng | 1 Adding the alarm clock snooze mode of the speaker SDK allows for setting the duration and interval of the ringing<br/>2 Adding ANC (active noise reduction) to the headphone SDK allows for switching between different headphone modes through noise reduction and transparency modes |

