# JL_SDK 发布包说明

## 项目概述
本发布包包含深圳杰理科技蓝牙SDK的核心组件及开发文档，适用于iOS平台开发。

## 目录结构

Release/
├── Code/             # 核心代码
│   └── SDKTestHelper  # 示例工程
├── Libs/             # 预编译框架
│   ├── JL_AdvParse.xcframework
│   ├── JL_BLEKit.xcframework
│   ├── JL_OTALib.xcframework
│   └── ...其他框架
└── Docs/             # 开发文档
    ├── APP说明书.md
    └── 翻译传输功能说明.md

## 使用指引
1. 将Libs目录下所有.xcframework添加到Xcode工程
2. Code目录包含完整的示例实现供参考
3. 开发前请仔细阅读Docs目录下的技术文档

## 注意事项
⚠️ 要求Xcode 14.3+ 
⚠️ 最低支持iOS 10.0

## 版权声明
© 2026 珠海市杰理科技股份有限公司 保留所有权利
[官网地址](https://www.zh-jieli.com)
 20260318
