# JLAudioUnitKit

一个面向 iOS 的音频编解码与转换示例工程，包含 `JLAudioUnitKit` 框架与演示 App。工程提供 Opus/Speex 编解码、PCM 录制、流式转换（Opus→Ogg）、MP3→UMP3 转换、PCM→WAV/WTG 等常用能力，并在 Demo 中展示本地分包读取、立体声分离回调与同目录 PCM 保存的完整流程。

## 版本历史（摘要）
| 版本 | 日期 | 类型 | 主要变更 |
| --- | --- | --- | --- |
|1.5.1_Beta2 | 2026-02-03 | release | 增加 opus 编解码时，可选指定队列回调|
| 1.5.1_Beta1 | 2026-01-06 | release | 实现动态内存预算与文件流处理优化, 增加解码时对不足一帧数据的处理 |
| 1.5.0_Beta1 | 2025-12-26 | release | 增加 opus 的大文件编解码接口，支持大文件编解码以增加速率 |
| 1.4.0_Beta2 | 2025-12-04 | release | 添加立体声（双声道 opus）分离回调支持并更新Demo |
| 1.3.1_Beta1 | 2025-11-27 | release | 升级发布流程与架构：移除 i386/armv7，新增 arm64 模拟器；集成发布脚本与 Demo 配置；文档与忽略规则优化 |
| — | 2025-12-03 | feat | 音频播放器线程安全改进；添加解码后 PCM 记录；Demo 增加本地分包读取与顺序重组示例；新增 `opus_inspector.py` |
| 1.3.0_Beta1 | 2025-08-27 | release | 新增 `JLOpusEncodeConfig` 重构编码配置；增加带宽枚举与默认配置 |
| 1.2.0_Beta1 | 2025-08-21 | release | 重构 Opus 库结构至 `libJLOpus`；升级 SDK；优化发布脚本与文档 |
| 1.1.0_Beta4 | 2025-08-21 | feat | 新增流式 `JLOpusToOgg` 转换接口；增加 Slik 语音优化属性 |
| — | 2025-11-28 | feat | 新增 MP3→UMP3 转换能力与 Demo 页面；完善转换参数与示例 |
| — | 2025-11-03 | fix | 修复文件编码内存问题；改为流式读取；增加一致性检查日志与兼容转调 |
| — | 2025-05 ~ 2024-11 | docs/feat | 逐步补充 Opus 解码示例、PCM 播放/录制、UI 功能；完善版本信息与文档 |


## 功能概览
- Opus 解码/编码，支持有头/无头模式与动态格式重置
- 立体声分离回调：仅双声道触发，提供左右声道 PCM 回调
- 本地分包读取：按 `dataSize` 或 `8字节头 + 负载` 顺序送入解码器
- PCM 录制与元数据生成：线程安全、iOS 13.4 以下 API 兼容
- 流式转换：Opus 按帧转 Ogg，支持时长统计
- MP3 → UMP3 转换：支持多采样率/码率组合
- PCM → WAV/WTG 转换与播放器示例

## 快速接入
- 获取 SDK
  - 使用发布包中的 `Release/Libs/JLAudioUnitKit.xcframework`，或 Demo 内 `JLAudioUnitKit/XCFrameworks/JLAudioUnitKit.xcframework`
  - 使用发布包中的 `Release/Libs/JLLogHelper.xcframework`，或 Demo 内 `JLAudioUnitKit/XCFrameworks/JLLogHelper.xcframework`
- 集成步骤
  - 将 `JLAudioUnitKit.xcframework`, `JLLogHelper.xcframework` 添加到工程
  - 在 Target → Build Phases → Embed Frameworks 设置为 Embed & Sign（必须）
  - Swift：`import JLAudioUnitKit`；Objective‑C：`#import <JLAudioUnitKit/JLAudioUnitKit.h>`
- 能力总览（JLAudioUnitKit.framework）
  - 编解码：`JLOpusDecoder`、`JLOpusEncoder`、`JLSpeexDecoder`
  - 配置：`JLOpusFormat`、`JLOpusEncodeConfig`
  - 转换：`JLOpusToOgg`、`JLPcmToWav`、`JLPcmToWtg`、`JLAudioConverter`（MP3→UMP3）
  - 播放：`JLAudioUnitPlayer`
  - Demo 能力：本地分包读取、立体声分离回调、PCM 录制与元数据
- 工程初始化（JLAudioUnitKitDemo）
  - 工程使用了 Cocoapod 依赖：`pod 'RxSwift' `, `pod 'RxCocoa'`, `pod 'SnapKit'`, `pod 'R.swift'`, `pod 'Toast-Swift'`，需要先安装 Cocoapod 并执行 `pod install`。
- 开发文档
  - 参见 `Docs/JLAudioUnitKit Doc.md`（接口说明、分包策略、回调示例）
- 示例参考
  - 解码演示：`JLAudioUnitKitDemo/JLAudioUnitKitDemo/ViewControllers/OpusDecodeVC.swift`
  - 转 Ogg：`JLAudioUnitKitDemo/JLAudioUnitKitDemo/ViewControllers/OpusToOggVC.swift`
  - 入口：`JLAudioUnitKitDemo/JLAudioUnitKitDemo/ViewControllers/MainVC.swift`

## 本地分包与有头/无头
- 无头模式：每包固定 `dataSize` 字节，直接顺序送入解码器。
- 有头模式：每包 `8字节头 + 负载`，头含长度与保留字段；需按头对齐切分后喂入。
- 可根据采样率/声道动态调整 `dataSize`，并通过 `resetOpusFramet` 重置解码格式（`JLOpusDecoder.h:55-58`）。

## 立体声分离回调
- 委托方法 `opusDecoderStereo(_:left:right:error:)` 仅在 `channels == 2` 时触发；
- 可分别写入 `L/R` 两个 PCM 文件，配合主 PCM 进行比对与分析；
- 在无立体声或单声道时，该回调不触发，使用主回调处理。

## 其他能力与示例
- Opus 编码：`JLOpusEncoder` 支持文件/流式编码，提供 `defaultJL` 快速创建杰理无头配置（`JLAudioUnitKit/JLAudioUnitKit/Opus/JLOpusEncoder.m:69-100,206-275`）。
- 流式 Opus→Ogg：`JLOpusToOgg` 支持逐帧转换与时长统计（Demo 参见 `JLAudioUnitKitDemo/.../OpusToOggVC.swift`）。
- MP3→UMP3 转换：提供 `JLAudioConverter` 与底层 UMP3 能力（接口头见 `JLAudioUnitKit/JLAudioUnitKit/JLAudioUnitKit.h:1-27`）。
- PCM→WAV/WTG 转换：`JLPcmToWav`、`JLPcmToWtg`。
- 播放器：示例工程内含 `JLAudioPlayer` 播放 PCM 的实现与波形展示。

## 常见问题与建议
- 采样率与帧时长：常见帧时长为 2.5/5/10/20/40/60ms；帧大小需与采样率、声道保持一致。编码侧已有一致性日志提示。
- 分包顺序：请保持包顺序送入，避免破坏帧边界；有头模式必须按头对齐。
- 输出位置：PCM 与元数据默认保存在源 Opus 同目录，便于资产管理与比对。


## 兼容性
- iOS：支持 iOS 13.0+；部分文件写入逻辑对 13.4 做了 API 兼容处理
- 架构：arm64（设备）、arm64 模拟器；旧 i386/armv7 已移除
- 开发环境：Xcode 15+，Swift 5.9+/Objective-C

## 免责声明
本工程用于演示与集成参考，涉及的编解码实现与参数选择请结合具体业务场景评估与测试。对于第三方库或工具的许可证与使用条款，请遵循相应开源协议。
