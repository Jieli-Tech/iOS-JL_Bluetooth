|  开发前必读
===============================================



# 更新内容

1. 更新 Opus 库为标准库版本号为 V1.5.2，支持 slik 以及 celt 等标准库内容。
2. 更新编码传入参数为  JLOpusEncodeConfig 。
3. 更新文档说明流式接口用法和新增属性




## `JLOpusEncodeConfig` 使用说明
`JLOpusEncodeConfig` 是用于 Opus 音频编码器的配置类。它封装了 Opus 编码器的所有关键参数，可以用于初始化 `JLOpusEncoder` 或直接进行文件/数据编码。

### 属性说明

| 属性                    | 类型     | 默认值                              | 说明                                                         |
| --------------------- | ------ | -------------------------------- | ---------------------------------------------------------- |
| `sampleRate`          | `int`  | 16000                            | 音频采样率（Hz）。常用值：8000、16000、24000、48000。                      |
| `channels`            | `int`  | 1                                | 声道数：1=单声道，2=双声道。                                           |
| `frameDuration`       | `int`  | 20                               | 帧时长（ms）。Opus 默认 20ms，可选 2.5/5/10/20/40/60ms。               |
| `frameSize`           | `int`  | 采样率 \* frameDuration / 1000      | 每帧采样点数，由 `frameDuration` 和 `sampleRate` 计算得出。              |
| `bitRate`             | `int`  | 16000                            | 编码比特率（bps）。CBR 或 VBR 下都可设置。                                |
| `useVBR`              | `BOOL` | NO                               | 是否使用可变比特率（VBR）。NO 表示使用恒定比特率（CBR）。                          |
| `constrainedVBR`      | `BOOL` | NO                               | VBR 限制模式，启用后 VBR 不会超过设定比特率。                                |
| `complexity`          | `int`  | 5                                | 编码复杂度，0\~10。数值越高编码质量越好，但 CPU 消耗也越高。                        |
| `forceChannels`       | `int`  | -1                               | 强制输出声道数。-1=自适应，1=单声道，2=双声道。                                |
| `useDTX`              | `BOOL` | NO                               | 启用 DTX（静音段不发送数据）可降低带宽消耗。                                   |
| `packetLossPercent`   | `int`  | 0                                | 网络丢包率百分比，用于优化编码器抗丢包能力。                                     |
| `bandwidth`           | `int`  | `JLOpusEncoderBandwidthFullband` | 最大带宽限制，对应 Opus 的 `OPUS_BANDWIDTH_*`。                       |
| `lsbDepth`            | `int`  | 16                               | PCM 输入有效位深，通常 16bit。                                       |
| `expertFrameDuration` | `int`  | 与 `frameDuration` 一致             | 专家模式下帧时长（ms）。用于控制 Opus 内部帧长度。                              |
| `hasDataHeader`       | `BOOL` | YES                              | 是否在编码输出中写入数据头。<br>如果启用，编码器会写入每帧长度和偏移信息；<br>关闭则使用杰理自定义无头编码。 |


### 默认配置方法

#### 1. `defaultConfig`

```objc
JLOpusEncodeConfig *config = [JLOpusEncodeConfig defaultConfig];
```

* 适用于标准 Opus 编码场景。
* 默认参数示例：

```text
sampleRate: 16000 Hz
channels: 1
frameDuration: 20 ms
bitRate: 16000 bps
useVBR: NO
constrainedVBR: NO
complexity: 5
forceChannels: -1 (auto)
useDTX: NO
packetLossPercent: 0
bandwidth: Fullband
lsbDepth: 16
expertFrameDuration: 20 ms
hasDataHeader: YES
```

* 使用 `defaultConfig` 可以直接初始化编码器，保证兼容标准 Opus 数据格式。

#### 2. `defaultJL`

```objc
JLOpusEncodeConfig *jlConfig = [JLOpusEncodeConfig defaultJL];
```

* 杰理定制的“无头”配置。
* 适用于无需数据头、固定 16kHz、单声道、SILK 模式的场景。
* 默认参数示例：

```text
sampleRate: 16000 Hz
channels: 1
frameDuration: 20 ms
bitRate: 16000 bps
useVBR: NO
constrainedVBR: NO
complexity: 5
forceChannels: -1
useDTX: NO
packetLossPercent: 0
bandwidth: Wideband
lsbDepth: 16
expertFrameDuration: 20 ms
hasDataHeader: NO
```

* 初始化 `JLOpusEncoder` 时，会自动覆盖一些特殊参数：

  * `signal = OPUS_SIGNAL_VOICE`
  * `max_bandwidth = OPUS_BANDWIDTH_WIDEBAND`
  * 禁用 FEC 和 DTX

### 使用示例

#### 1. 使用标准配置编码 PCM 数据

```objc
JLOpusEncodeConfig *config = [JLOpusEncodeConfig defaultConfig];
JLOpusEncoder *encoder = [[JLOpusEncoder alloc] initFormat:config delegate:self];

NSData *pcmData = ...; // PCM 数据
[encoder opusEncodeData:pcmData];
```

#### 2. 使用杰理无头配置进行文件编码

```objc
JLOpusEncodeConfig *jlConfig = [JLOpusEncodeConfig defaultJL];
JLOpusEncoder *encoder = [[JLOpusEncoder alloc] initFormat:jlConfig delegate:self];

[encoder opusEncodeFile:@"input.pcm" outPut:@"output.opus" Resoult:^(NSString * _Nullable path, NSError * _Nullable error) {
    if (error) {
        NSLog(@"编码失败: %@", error);
    } else {
        NSLog(@"编码成功, 输出文件: %@", path);
    }
}];
```


### 注意事项

1. **frameDuration 和 frameSize 的关系**

   ```text
   frameSize = sampleRate * frameDuration / 1000
   ```

   推荐使用默认 20ms 帧长度，Opus 支持的帧长：2.5、5、10、20、40、60ms。

2. **VBR 与 CBR**

   * `useVBR = YES` 表示可变比特率，可在保证质量的同时动态调整码率。
   * `useVBR = NO` 表示恒定比特率（CBR），适合实时通信。

3. **hasDataHeader**

   * YES：生成标准 Opus 帧头，适合存储或网络传输。
   * NO：生成杰理自定义无头格式，适合嵌入式设备或自定义解析。

4. **bandwidth**

   * 不同场景选择不同带宽：

     * Narrowband: 4kHz
     * Mediumband: 6kHz
     * Wideband: 8kHz
     * Superwideband: 12kHz
     * Fullband: 20kHz


# 开发资料结构



📂 project-root
├── 📂 code       # 示例 demo
├── 📂 doc        # 开发资料结构
├── 📂 libs       # 核心库
└── 📄 readme.md  # 开发前必读



# 联系我们

1. 请联系资料获取人咨询
2. 发邮件给对应负责人的邮箱: 