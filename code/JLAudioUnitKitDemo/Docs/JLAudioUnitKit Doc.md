## JLAudioUnitKit 开发接口说明

[toc]

#### **概述**  

JLAudioUnitKit 是一个专注于音频处理的工具库，提供音频播放、编解码及格式转换功能。支持格式包括 MP3/WAV/AAC/PCM/Opus/Speex 等，适用于 iOS/macOS 平台的 Objective-C 项目。本接口文档涵盖主要功能模块的使用方法及代码示例。


### **核心组件与接口**

#### **1. 音频播放器 `JLAudioUnitPlayer`**

##### **功能**  

- 支持 **MP3/WAV/AAC 文件播放**（基于 AVAudioPlayer）  
- 支持 **PCM 流式播放**（基于 Audio Queue）  

##### **接口说明**  

```objective-c
// 初始化（文件播放）
- (instancetype)initWithAudioFile:(NSString *)filePath;

// 初始化（PCM 流播放）
- (instancetype)initWithPCMFormat:(AudioStreamBasicDescription)format;

// 播放控制
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)time; // 仅文件模式有效

// PCM 数据追加（仅 PCM 模式有效）
- (void)appendPCMData:(NSData *)pcmData;
- (void)endPCMStream;
```

##### **代理协议 `JLAudioPlayerDelegate`**  

```objective-c
@optional
- (void)audioPlayer:(JLAudioUnitPlayer *)player didUpdateProgress:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;
- (void)audioPlayerDidFinishPlaying:(JLAudioUnitPlayer *)player;
- (void)audioPlayer:(JLAudioUnitPlayer *)player didFailWithError:(NSError *)error;
```

##### **示例**  

```objective-c
// 文件播放
JLAudioUnitPlayer *filePlayer = [[JLAudioUnitPlayer alloc] initWithAudioFile:@"/path/to/audio.mp3"];
filePlayer.delegate = self;
[filePlayer play];

// PCM 流播放
AudioStreamBasicDescription pcmFormat = {0};
pcmFormat.mSampleRate = 16000;
pcmFormat.mFormatID = kAudioFormatLinearPCM;
pcmFormat.mChannelsPerFrame = 1;
JLAudioUnitPlayer *pcmPlayer = [[JLAudioUnitPlayer alloc] initWithPCMFormat:pcmFormat];
[pcmPlayer appendPCMData:pcmData];
[pcmPlayer play];
```

---

#### **2. Opus 编解码器**

##### **解码器 `JLOpusDecoder`**  
###### 用法速览
- 流式解码：逐段输入，代理回传 PCM。
- 文件解码：输入 Opus，输出 PCM 文件。
- 大文件解码（Ex）：双缓冲 IO+聚合写，适合超大文件。
- 动态切换：运行时更新采样率/声道/帧长。
- 配置灵活：支持自定义回调队列（`callBackQueue`）。

##### **解码配置 `JLOpusFormat`**

##### **接口说明**

```objective-c
// 初始化（默认：16kHz, 1ch, 20ms）
- (instancetype)init;

// 回调队列（默认为主队列，Strong 引用）
@property (nonatomic, strong) dispatch_queue_t callBackQueue;
```

##### **接口说明**  

```objective-c
// 初始化
- (instancetype)initDecoder:(JLOpusFormat *)format delegate:(id<JLOpusDecoderDelegate>)delegate;

// 重置解码格式（运行时切换采样率/声道/帧长等）
- (void)resetOpusFramet:(JLOpusFormat *)format;

// 输入 Opus 数据（流式）
- (void)opusDecoderInputData:(NSData *)data;

// 文件解码（回调返回 PCM 文件路径或错误）
- (void)opusDecodeFile:(NSString *)input outPut:(NSString *_Nullable)outPut Resoult:(JLOpusDecoderConvertBlock _Nullable)result;

// 面向大型 Opus 文件的双缓冲重叠 IO/解码接口（可调聚合阈值；仅最终回调，不逐帧回调）
- (void)opusDecodeLargeFileEx:(NSString *)input
                        output:(NSString *_Nullable)output
                     chunkBytes:(NSUInteger)chunkBytes
             aggregateThreshold:(NSUInteger)aggregateThreshold
                         result:(JLOpusDecoderConvertBlock _Nullable)result;

// 释放资源
- (void)opusOnRelease;
```

##### **代理协议 `JLOpusDecoderDelegate`**  

```objective-c
// 基本回调（PCM 交错数据：L,R,L,R,...）
-(void)opusDecoder:(JLOpusDecoder *)decoder Data:(NSData* _Nullable)data error:(NSError* _Nullable)error;

@optional
// 立体声可选回调（仅在 channels==2 时触发，分别返回左/右声道的单声道 PCM）
-(void)opusDecoderStereo:(JLOpusDecoder *)decoder Left:(NSData* _Nullable)left Right:(NSData* _Nullable)right error:(NSError* _Nullable)error;
```

##### **示例（流式 / 文件 / 动态切换）**  

###### 流式解码：逐段输入 Opus 数据，PCM 数据通过代理返回
- 前置条件：
- - format.sampleRate 与源一致；channels 与源一致。
- - 有头源建议 hasDataHeader=true；无头源需确保 dataSize 正确（固定帧）。

```objective-c

JLOpusFormat *streamFmt = [JLOpusFormat defaultFormats];
JLOpusDecoder *streamDecoder = [[JLOpusDecoder alloc] initDecoder:streamFmt delegate:self];
[streamDecoder opusDecoderInputData:opusChunk1];
[streamDecoder opusDecoderInputData:opusChunk2];
// ... 更多数据块
[streamDecoder opusOnRelease];

// 代理接收 PCM 数据
- (void)opusDecoder:(JLOpusDecoder *)decoder Data:(NSData * _Nullable)data error:(NSError * _Nullable)error {
    if (data) {
        // 处理 PCM 数据块（写入文件 / 播放 / 可视化）
    } else if (error) {
        NSLog(@"解码错误: %@", error.localizedDescription);
    }
}

```

###### 立体声可选回调：仅在 channels==2 时触发，分别返回左/右声道单声道 PCM 数据
```objective-c
- (void)opusDecoderStereo:(JLOpusDecoder *)decoder Left:(NSData * _Nullable)left Right:(NSData * _Nullable)right error:(NSError * _Nullable)error {
    if (left) {
        // 处理左声道，例如写入 <源名>_L.pcm
    }
    if (right) {
        // 处理右声道，例如写入 <源名>_R.pcm
    }
}
```
###### 文件解码：输入 Opus 文件，输出 PCM 文件
- 前置条件：
- - 目标输出路径可为空（默认写入 ~/Documents/opusToPcm.pcm 或文档示例路径）。
- - 若源为杰理无头裸帧，请确保 JLOpusFormat.dataSize 与实际帧长一致。

```objective-c  
JLOpusFormat *fileFmt = [JLOpusFormat defaultFormats];
JLOpusDecoder *fileDecoder = [[JLOpusDecoder alloc] initDecoder:fileFmt delegate:self];
[fileDecoder opusDecodeFile:@"/path/to/input.opus" outPut:@"/path/to/output.pcm" Resoult:^(NSString * _Nullable pcmPath, NSError * _Nullable error) {
    if (!error && pcmPath) {
        NSLog(@"Opus 文件解码完成: %@", pcmPath);
    } else if (error) {
        NSLog(@"解码错误: %@", error.localizedDescription);
    }
}];

###### 动态切换格式：运行中重置参数（如采样率/声道/帧长）
```objective-c  
JLOpusFormat *newFmt = [JLOpusFormat defaultFormats];
newFmt.sampleRate = 16000;
newFmt.channels = 1;
[streamDecoder resetOpusFramet:newFmt];
[streamDecoder opusDecoderInputData:opusChunk3];
```

###### 大文件解码（Ex：带聚合阈值，最终一次性回调；不逐帧触发代理）

```objective-c  
JLOpusFormat *largeFmt = [JLOpusFormat defaultFormats];
JLOpusDecoder *largeDecoder = [[JLOpusDecoder alloc] initDecoder:largeFmt delegate:nil];
[largeDecoder opusDecodeLargeFileEx:@"/path/to/input.opus"
                             output:@"/path/to/output.pcm"
                          chunkBytes:(1024*1024) // 1MB
                  aggregateThreshold:(256*1024) // 256KB
                               result:^(NSString * _Nullable pcmPath, NSError * _Nullable error) {
    if (!error && pcmPath) {
        NSLog(@"Opus 大文件解码完成: %@", pcmPath);
    } else {
        NSLog(@"解码错误: %@", error.localizedDescription);
    }
}];
```

##### **示例（Swift - 立体声回调与本地保存）**

```swift
// 在 OpusDecodeVC 中实现可选回调
func opusDecoderStereo(_ decoder: JLOpusDecoder, left: Data?, right: Data?, error: Error?) {
    if let l = left { pcmRecorderLeft?.append(l) }
    if let r = right { pcmRecorderRight?.append(r) }
}
```

- 参数建议：
- - chunkBytes：按设备内存选择（低内存 512KB/中等 1MB/较高 2MB/高内存 4MB）。
- - aggregateThreshold：建议 128–512KB，提升吞吐同时控制缓冲占用。
- - EOF 边界处理：尾部不足帧会自动补零至帧长后解码；有头模式需至少保留完整 8 字节头以解析 frameSize。

##### **Demo 更新要点：OpusDecodeVC 本地分包读取与保存**

- 本地分包：在有头模式（hasDataHeader=true）按“帧头+负载”对齐读取，避免随机分包破坏帧边界导致 -4。
- 帧聚合：每批聚合 1–6 个完整帧后一次性喂入解码器，提升稳定性与吞吐；批大小上限 128KB。
- 保存路径：所有 `.pcm` 与 `*.pcm.meta.json` 输出到与输入 `.opus` 相同目录。
- 兼容性：文件写入针对 iOS 13.4 以下使用 `seekToEndOfFile`/`write(_:)`；13.4 以上使用 `seekToEnd()`/`write(contentsOf:)`。

```swift
// 头对齐本地分包读取（示意）
while !eof && simulationRunning {
    let groupCount = Int.random(in: 1...6)
    var batch = Data()
    for _ in 0..<groupCount {
        let lenData = fh.readData(ofLength: 4)
        if lenData.count < 4 { eof = true; break }
        let rawLen = lenData.withUnsafeBytes { $0.load(as: UInt32.self) }
        let frameSize = Int(UInt32(littleEndian: rawLen))
        let extra = fh.readData(ofLength: 4)
        if extra.count < 4 { eof = true; break }
        let payload = fh.readData(ofLength: frameSize)
        if payload.count < frameSize { eof = true; break }
        batch.append(lenData)
        batch.append(extra)
        batch.append(payload)
        if batch.count > 128 * 1024 { break }
    }
    guard !batch.isEmpty else { continue }
    DispatchQueue.main.async { self.opusDecoder.opusDecoderInputData(batch) }
}
```

##### **示例（Swift - 无头模式本地分包读取）**

- 无头模式（hasDataHeader=false）默认采用固定帧长度分割，长度取 `format.dataSize`；双声道通常为单声道的两倍（例如 40→80）。
- 仅适用于固定长度帧；若源为 VBR 或帧长与 `dataSize` 不一致，可能出现 `-4` 或杂音。

```swift
// 无头模式：按固定帧长度分割并投递解码器
guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return }
var len = 0
let fixed = max(Int(format.dataSize), 1)
while len + fixed <= data.count {
    let packet = data.subdata(in: len ..< len + fixed)
    opusDecoder.opusDecoderInputData(packet)
    len += fixed
    usleep(200) // 可选：节流，模拟流式
}
// 若有末尾不足 fixed 的残留，可选择丢弃或缓冲等待下一段
```

###### 注意
- 无头模式更依赖正确的 `dataSize` 配置；Demo 中 `Channels` 开关会同步设置 `dataSize`（单声道 40、双声道 80）。
- 为提高鲁棒性，建议优先使用有头模式（hasDataHeader=true），或在投递前对包做合法性校验（例如基于 TOC 使用 `opus_packet_get_nb_frames` 验证）。

##### **辅助工具：Opus Inspector 完整性检测**
- 用途：快速判断包是否完整、统计不完整/未知包数量，定位尾帧截断与容器损坏。
- 使用：

```bash
python3 tools/opus_inspector.py /path/to/file.opus --json
```

- 关键字段：
- - frames_complete：整体是否完整（或未知）。
- - checked_packets / incomplete_packets / unknown_packets：完整性统计。
- - last_packet_complete：最后一个音频包是否完整（或未知）。


##### **编码配置 `JLOpusEncodeConfig`**

##### **接口说明**

```objective-c
// 创建默认配置（标准 Opus，带头信息）
+ (instancetype)defaultConfig;

// 创建杰理默认配置（无头模式，16kHz, 1ch, 20ms，适用于杰理芯片方案）
+ (instancetype)defaultJL;

// 回调队列（默认为主队列，Strong 引用）
@property (nonatomic, strong) dispatch_queue_t callBackQueue;
```

##### **编码器 `JLOpusEncoder`**  

##### **接口说明**  

```objective-c
// 初始化
- (instancetype)initFormat:(JLOpusEncodeConfig *)format delegate:(id<JLOpusEncoderDelegate>)delegate;

// 流式编码（输入 PCM 数据块）
- (void)opusEncodeData:(NSData *)data;

// 文件编码（新：流式读取，避免一次性加载内存）
- (void)opusEncodeFile:(NSString *)pcmPath output:(NSString *_Nullable)output result:(JLOpusEncoderConvertBlock _Nullable)result;

// 面向大型 PCM 的流式编码接口（带聚合阈值；文件模式不逐帧触发代理，仅最终回调）
- (void)opusEncodeFileEx:(NSString *)pcmPath
                   output:(NSString *_Nullable)output
                chunkBytes:(NSUInteger)chunkBytes
        aggregateThreshold:(NSUInteger)aggregateThreshold
                    result:(JLOpusEncoderConvertBlock _Nullable)result;

// 释放资源
- (void)opusOnRelease;

// 兼容旧接口（已废弃）
- (void)opusEncodeFile:(NSString *)pcmPath outPut:(NSString *_Nullable)outPut Resoult:(JLOpusEncoderConvertBlock _Nullable)result;
```

##### **代理协议 `JLOpusEncoderDelegate`**  

```objective-c
-(void)opusEncoder:(JLOpusEncoder *)encoder Data:(NSData* _Nullable)data error:(NSError* _Nullable)error;
```

说明：
- 流式编码（`opusEncodeData:`）逐帧触发代理回调，便于实时观察或传输。
- 文件编码（`opusEncodeFile:`、`opusEncodeFileEx:`）在文件模式下不逐帧触发代理；仅在编码完成后通过 `result` 回调返回输出路径或错误。
- 若启用 `hasDataHeader=YES`，文件输出为每帧写入 8 字节索引信息（长度 + final_range），便于解析与随机访问。

##### **示例（流式与文件编码）**  

```objective-c
// 流式编码示例：逐段传入 PCM 数据
JLOpusEncodeConfig *streamCfg = [JLOpusEncodeConfig defaultJL];
JLOpusEncoder *streamEncoder = [[JLOpusEncoder alloc] initFormat:streamCfg delegate:self];
[streamEncoder opusEncodeData:pcmChunk1];
[streamEncoder opusEncodeData:pcmChunk2];
// ... 更多数据块
[streamEncoder opusOnRelease];

// 文件编码示例（新接口）：output 为空时使用默认路径 ~/Documents/pcmToOpus.opus
JLOpusEncodeConfig *fileCfg = [JLOpusEncodeConfig defaultJL];
JLOpusEncoder *fileEncoder = [[JLOpusEncoder alloc] initFormat:fileCfg delegate:self];
[fileEncoder opusEncodeFile:@"/path/to/input.pcm" output:nil result:^(NSString * _Nullable path, NSError * _Nullable error) {
    if (!error && path) {
        NSLog(@"Opus 编码完成: %@", path);
    }
}];

// 旧接口（不推荐，仅兼容迁移）
[fileEncoder opusEncodeFile:@"/path/to/input.pcm" outPut:@"/path/to/output.opus" Resoult:^(NSString * _Nullable path, NSError * _Nullable error) {
    if (!error && path) {
        NSLog(@"Opus 编码完成(旧接口): %@", path);
    }
}];
```

```objective-c
// 大文件编码示例（Ex：带聚合阈值；不逐帧回调，仅最终回调）
JLOpusEncodeConfig *largeCfg = [JLOpusEncodeConfig defaultJL];
largeCfg.hasDataHeader = YES; // 可选：为每帧输出头信息
JLOpusEncoder *largeEncoder = [[JLOpusEncoder alloc] initFormat:largeCfg delegate:nil];
[largeEncoder opusEncodeFileEx:@"/path/to/input.pcm"
                       output:@"/path/to/output.opus"
                    chunkBytes:(1024*1024) // 1MB
            aggregateThreshold:(256*1024)  // 256KB
                        result:^(NSString * _Nullable path, NSError * _Nullable error) {
    if (!error && path) {
        NSLog(@"Opus 大文件编码完成: %@", path);
    } else {
        NSLog(@"编码错误: %@", error.localizedDescription);
    }
}];
```

##### 输出格式与容器说明

- 若在配置中启用了 `hasDataHeader = YES`，编码器会在输出中写入每帧的长度等索引信息（便于解析与随机访问）；关闭该选项则输出“无头”裸帧，适用于杰理定制场景。

##### 性能与监控

- 解码 Ex 日志
  - `Large decode(ex) begin: chunkBytes=<B>, agg=<B>, header=<0/1>, dataSize=<bytes>`
  - `Large decode(ex) done: opus=<bytes>, pcm=<bytes>, time=<sec>, throughput=<MB/s>`
  - `Large decode(ex) breakdown: read=<sec>, decode=<sec>, write=<sec>, chunks=<count>, frames=<count>, aggFlush=<count>`
- 编码 Ex 日志
  - `Large encode begin: chunkBytes=<B>, agg=<B>, frameBytes=<bytes>`
  - `Large encode done: pcm=<bytes>, time=<sec>, throughput=<MB/s>`
  - `Large encode breakdown: read=<sec>, encode=<sec>, write=<sec>, chunks=<count>, aggFlush=<count>`
- 指标说明
  - `read`：分块读取累计耗时；`decode/encode`：逐帧解码/编码累计耗时；`write`：写盘累计耗时
  - `throughput`：输出字节 / 秒（MB/s）；`chunks`：读取块次数；`frames`：成功解码帧数；`aggFlush`：达到聚合阈值的批量写次数
- 调优建议
  - 增大 `chunkBytes` 可减少 IO 频度，但可能增加峰值内存；减小 `chunkBytes` 可提升调度灵活性
  - 增大 `aggregateThreshold` 可减少写盘次数但增大缓冲；减小则更实时但写盘更频繁
  - 通过“breakdown”日志观察瓶颈位于读、编解码或写盘环节，结合设备存储与 CPU 特性调整参数

---

#### **3. PCM 转 WAV `JLPcmToWav`**

##### **接口说明**  

```objective-c
// 流式编码初始化
- (instancetype)initWithOutputPath:(NSString *)outputPath
                       sampleRate:(uint32_t)sampleRate
                     numChannels:(uint16_t)numChannels
                  bitsPerSample:(uint16_t)bitsPerSample;

// 追加 PCM 数据
- (BOOL)appendPCMData:(NSData *)pcmData error:(NSError **)error;

// 完成编码
- (BOOL)finishWithError:(NSError **)error;

// 一次性转换
+ (BOOL)convertPCMData:(NSData *)pcmData
            toWAVFile:(NSString *)outputPath
           sampleRate:(uint32_t)sampleRate
         numChannels:(uint16_t)numChannels
      bitsPerSample:(uint16_t)bitsPerSample
              error:(NSError **)error;
```

##### **示例**  

```objective-c
// 流式转换
JLPcmToWav *pcmToWav = [[JLPcmToWav alloc] initWithOutputPath:@"/path/to/output.wav"
                                                  sampleRate:16000
                                                numChannels:1
                                             bitsPerSample:16];
[pcmToWav appendPCMData:pcmData error:nil];
[pcmToWav finishWithError:nil];

// 一次性转换
[JLPcmToWav convertPCMData:pcmData
               toWAVFile:@"/path/to/output.wav"
              sampleRate:16000
            numChannels:1
         bitsPerSample:16
                 error:nil];
```

#### **4. PCM 转 WTG `JLPcmToWtg`**

##### **接口说明**  

```objective-c
// 初始化
- (instancetype)initWithDelegate:(id<JLPcmToWtgDelegate>)delegate;

// 转换
- (void)convertPcmToWtg:(JLPcm2WtgModel *)model;
```

##### **代理协议 `JLPcmToWtgDelegate`**  

```objective-c
- (void)convertPcmToWtgDone:(JLPcm2WtgModel *)model;
```

##### **示例**  

```objective-c
JLPcm2WtgModel *model = [[JLPcm2WtgModel alloc] init];
model.pcmPath = @"/path/to/input.pcm";
model.wtgPath = @"/path/to/output.wtg";

JLPcmToWtg *converter = [[JLPcmToWtg alloc] initWithDelegate:self];
[converter convertPcmToWtg:model];
```

#### **5. Speex 解码器 `JLSpeexDecoder`**

##### **接口说明**  

```objective-c
// 初始化
- (instancetype)initWithDelegate:(id<JLSpeexDelegate>)delegate;

// 输入 Speex 数据
- (void)speexInputData:(NSData *)data;

// 文件解码
- (void)speexConvertToPcm:(NSString *)filePath outPutFilePath:(NSString *)opPath Result:(JLSpeexConvertBlock)result;
```

##### **代理协议 `JLSpeexDelegate`**  

```objective-c
- (void)speexDecoder:(JLSpeexDecoder *)decoder Data:(NSData *)data error:(NSError *)error;
```

##### **示例**  

```objective-c
JLSpeexDecoder *decoder = [[JLSpeexDecoder alloc] initWithDelegate:self];
[decoder speexInputData:speexData];

// 文件解码
[decoder speexConvertToPcm:@"/path/to/input.spx" outPutFilePath:@"/path/to/output.pcm" Result:^(NSString *pcmPath, NSError *error) {
    if (!error) {
        NSLog(@"Speex 解码完成: %@", pcmPath);
    }
}];
```

---

#### **6. Opus 转 OGG `JLOpusToOgg`**  

##### **功能概述**

`JLOpusToOgg` 是一个用于将杰理无头裸 Opus 数据转换为标准 Ogg 格式的类。支持一次性转换和流式转换两种模式，并提供灵活的配置选项和多线程处理能力。

##### **配置类 `JLOpusToOggConfig`**

用于配置转换参数，支持多种预设配置和自定义配置。

###### **属性说明**

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `sampleRate` | `uint32_t` | 16000 | 采样率，支持：8000, 12000, 16000, 24000, 48000 |
| `channelCount` | `uint8_t` | 1 | 声道数，支持：1（单声道）, 2（立体声） |
| `frameDurationMs` | `uint8_t` | 20 | 帧时长（ms），支持：2.5, 5, 10, 20, 40, 60 |
| `frameLength` | `uint32_t` | 40 | 每帧字节数（压缩后的 Opus 帧大小） |
| `preSkip` | `uint16_t` | 自动计算 | 预跳过样本数（用于解码器同步） |

###### **计算属性**

```objective-c
// 每帧采样数（根据采样率和帧时长自动计算）
- (uint32_t)samplesPerFrame;

// 输出采样率（Opus 内部使用 48kHz）
- (uint32_t)outputSampleRate;
```

###### **验证方法**

```objective-c
// 验证配置是否有效
- (BOOL)validateWithError:(NSError **)error;

// 检查配置是否与标准值有显著差异，返回警告信息数组
- (NSArray<NSString *> *)configurationWarnings;
```

###### **预设配置工厂方法**

```objective-c
// 标准配置（20ms, 40bytes）- 公版默认，最常用
+ (instancetype)standardConfiguration;

// 短帧配置（10ms, 20bytes）- 低延迟场景
+ (instancetype)shortFrameConfiguration;

// 长帧配置（40ms, 80bytes）- 高压缩率场景
+ (instancetype)longFrameConfiguration;

// 超长帧配置（60ms, 120bytes）- 极致压缩场景
+ (instancetype)extraLongFrameConfiguration;

// 超短帧配置（5ms, 10bytes）- 极低延迟场景
+ (instancetype)ultraShortFrameConfiguration;

// 根据帧时长创建配置
+ (nullable instancetype)configurationWithFrameDurationMs:(uint8_t)frameDurationMs;

// 完整自定义配置
+ (instancetype)configurationWithSampleRate:(uint32_t)sampleRate
                               channelCount:(uint8_t)channelCount
                            frameDurationMs:(uint8_t)frameDurationMs
                                frameLength:(uint32_t)frameLength;
```

##### **转换器类 `JLOpusToOgg`**

###### **属性说明**

```objective-c
// 转码内容的回调
@property(nonatomic,strong) JLOpusToOggConvertBlock _Nullable convertBlock;

// 当前配置（只读）
@property(nonatomic, strong, readonly) JLOpusToOggConfig *configuration;

// 数据处理队列（可选）
// 默认使用主队列，建议在高频数据传输场景下设置为串行队列
@property (nonatomic, strong, nullable) dispatch_queue_t processingQueue;
```

###### **初始化方法**

```objective-c
// 使用配置初始化（推荐）
- (instancetype)initWithConfiguration:(JLOpusToOggConfig *)configuration;

// 初始化帧长（旧接口，已废弃）
- (instancetype)initWithFrameLength:(uint32_t)frameLen __attribute__((deprecated("Use -initWithConfiguration: instead.")));
```

###### **流式转换方法**

```objective-c
// 开始流
- (void)startStream;

// 添加 Opus 数据（符合杰理的无头裸 opus 数据）
- (void)appendOpusData:(NSData *)opusData;

// 关闭流
- (void)closeStream;
```

###### **类方法（一次性转换）**

```objective-c
// 将 Opus 数据转换为 Ogg 数据（使用配置）
+ (NSData *_Nullable)convertOpusDataToOgg:(NSData *)opusData
                            configuration:(JLOpusToOggConfig *)configuration
                                 duration:(double *_Nullable)duration
                                    error:(NSError *__autoreleasing _Nullable *)error;

// 将 Opus 文件转换为 Ogg 文件（使用配置）
+ (void)convertOpusFileToOgg:(NSString *)opusFilePath
                 oggFilePath:(NSString *)oggFilePath
               configuration:(JLOpusToOggConfig *)configuration
                    duration:(double *_Nullable)duration;

// 旧接口（已废弃）
+ (NSData *_Nullable)convertOpusDataToOgg:(NSData *)opusData
                                 frameLen:(uint32_t)frameLen
                                 duration:(double *)duration
                                    error:(NSError *__autoreleasing _Nullable *)error __attribute__((deprecated("Use -convertOpusDataToOgg:configuration:duration:error: instead.")));

+ (void)convertOpusFileToOgg:(NSString *)opusFilePath
                 oggFilePath:(NSString *)oggFilePath
                    frameLen:(uint32_t)frameLen
                    duration:(double *)duration __attribute__((deprecated("Use -convertOpusFileToOgg:oggFilePath:configuration:duration: instead.")));
```

##### **示例代码**

###### **示例一：使用预设配置进行一次性转换**

```objective-c
// 使用标准配置（20ms, 40bytes）
JLOpusToOggConfig *config = [JLOpusToOggConfig standardConfiguration];

NSData *opusData = [self prepareOpusData]; // 准备无头裸 Opus 数据
NSError *error;
double duration;

NSData *oggData = [JLOpusToOgg convertOpusDataToOgg:opusData
                                        configuration:config
                                             duration:&duration
                                                error:&error];

if (oggData) {
    NSLog(@"转换成功，时长：%.2fs", duration);
} else {
    NSLog(@"转换失败：%@", error.localizedDescription);
}
```

###### **示例二：使用长帧配置进行文件转换**

```objective-c
// 使用长帧配置（40ms, 80bytes）- 高压缩率场景
JLOpusToOggConfig *config = [JLOpusToOggConfig longFrameConfiguration];

NSString *opusFilePath = [[NSBundle mainBundle] pathForResource:@"input" ofType:@"opus"];
NSString *oggFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.ogg"];

[JLOpusToOgg convertOpusFileToOgg:opusFilePath
                       oggFilePath:oggFilePath
                     configuration:config
                          duration:nil];

if ([[NSFileManager defaultManager] fileExistsAtPath:oggFilePath]) {
    NSLog(@"Ogg 文件创建成功：%@", oggFilePath);
}
```

###### **示例三：流式转换（带后台队列处理）**

```objective-c
// 创建配置
JLOpusToOggConfig *config = [JLOpusToOggConfig standardConfiguration];

// 初始化转换器
JLOpusToOgg *converter = [[JLOpusToOgg alloc] initWithConfiguration:config];

// 设置后台处理队列，解决高频数据传输导致的主线程卡顿问题
dispatch_queue_t queue = dispatch_queue_create("com.jl.opustogg", DISPATCH_QUEUE_SERIAL);
converter.processingQueue = queue;

// 设置回调
converter.convertBlock = ^(NSData * _Nullable oggData, BOOL isLast, NSError * _Nullable error) {
    if (oggData) {
        NSLog(@"收到 Ogg 数据块，大小：%lu", (unsigned long)oggData.length);
        // 写入文件或传输
    } else if (error) {
        NSLog(@"转换错误：%@", error.localizedDescription);
    }
    
    if (isLast) {
        NSLog(@"流式转换结束");
    }
};

// 开始流式转换
[converter startStream];

// 逐段添加 Opus 数据
[converter appendOpusData:opusChunk1];
[converter appendOpusData:opusChunk2];
// ...

// 完成转换
[converter closeStream];
```

###### **示例四：自定义配置与验证**

```objective-c
// 创建自定义配置
JLOpusToOggConfig *config = [JLOpusToOggConfig configurationWithSampleRate:16000
                                                              channelCount:1
                                                           frameDurationMs:20
                                                               frameLength:40];

// 验证配置
NSError *error;
if (![config validateWithError:&error]) {
    NSLog(@"配置无效：%@", error.localizedDescription);
    return;
}

// 检查警告
NSArray *warnings = [config configurationWarnings];
if (warnings.count > 0) {
    NSLog(@"配置警告：%@", warnings);
}

// 使用配置进行转换
NSData *oggData = [JLOpusToOgg convertOpusDataToOgg:opusData
                                        configuration:config
                                             duration:nil
                                                error:&error];
```

##### **注意事项**

1. **输入数据要求**：输入必须为符合杰理的无头裸 Opus 数据，不包含标准 Opus 头信息。

2. **处理队列**：在高频数据传输场景下，建议设置 `processingQueue` 为后台串行队列，避免主线程阻塞或数据丢失。

3. **配置验证**：使用自定义配置时，建议先调用 `validateWithError:` 验证配置有效性。

4. **流式转换流程**：必须按顺序调用 `startStream` → `appendOpusData:`（多次）→ `closeStream`。

5. **向后兼容性**：旧接口 `initWithFrameLength:` 和 `convertOpusDataToOgg:frameLen:duration:error:` 已标记为废弃，但仍可正常使用，内部会自动使用默认配置。

---

#### **7. MP3 转 UMP3 `JLAudioConverter`**

##### **接口说明**

`JLAudioConverter` 提供将单声道 MP3 文件转换为 UMP3 的能力。

```objective-c
// 单声道 MP3 → UMP3
+ (void)convertMP3ToUmp3:(NSString *)mp3Path
                ump3Path:(NSString *)ump3Path
                  Result:(void (^)(BOOL success))result;

// 同步转换（阻塞当前线程，不建议在主线程调用）
+ (void)convertMP3ToUmp3Sync:(NSString *)mp3Path
                    ump3Path:(NSString *)ump3Path;
```

支持的采样率/码率对应关系（sr→br）：

- sr=8k/12k：br=8k,16k,24k,32k,40k,48k,56k,64k
- sr=16k/24k：br=8k,16k,24k,32k,40k,48k,56k,64k,80k,96k,112k,128k,144k,160k
- sr=32k：br=32k,40k,48k,56k,64k,80k,96k,112k,128k,160k,192k,224k,256k,320k

> 注意：输入必须为单声道 MP3，采样率与码率需要符合上述支持表。

##### **示例（Objective-C）**

```objective-c
NSString *mp3Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"input.mp3"]; // 替换为实际路径
NSString *ump3Path = [[mp3Path stringByDeletingPathExtension] stringByAppendingPathExtension:@"ump3"]; 

[JLAudioConverter convertMP3ToUmp3:mp3Path ump3Path:ump3Path Result:^(BOOL success) {
    if (success) {
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:ump3Path error:nil];
        NSNumber *size = attrs[NSFileSize];
        if (size != nil && size.intValue > 0) {
            NSLog(@"UMP3 转换成功，输出: %@ (大小: %d)", ump3Path, size.intValue);
        } else {
            NSLog(@"转换成功但输出文件校验失败（大小为 0）");
        }
    } else {
        NSLog(@"UMP3 转换失败");
    }
}];
```

###### 同步转换示例（Objective-C）

```objective-c
NSString *mp3Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"input.mp3"]; // 替换为实际路径
NSString *ump3Path = [[mp3Path stringByDeletingPathExtension] stringByAppendingPathExtension:@"ump3"]; 

dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
    [JLAudioConverter convertMP3ToUmp3Sync:mp3Path ump3Path:ump3Path];
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:ump3Path error:nil];
    NSNumber *size = attrs[NSFileSize];
    BOOL ok = (size != nil && size.intValue > 0);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(ok ? @"UMP3 同步转换成功: %@" : @"UMP3 同步转换失败", ump3Path);
    });
});
```

##### **示例（Swift）**

```swift
let mp3Path = Tools.mp3Path + "/example.mp3" // 替换为实际文件
let outPath: String
if mp3Path.hasSuffix(".mp3") {
    outPath = (mp3Path as NSString).deletingPathExtension + ".ump3"
} else {
    outPath = mp3Path + ".ump3"
}

JLAudioConverter.convertMP3ToUmp3(mp3Path, ump3Path: outPath) { success in
    DispatchQueue.main.async {
        let fm = FileManager.default
        var ok = false
        if fm.fileExists(atPath: outPath),
           let attrs = try? fm.attributesOfItem(atPath: outPath),
           let size = attrs[.size] as? NSNumber,
           size.intValue > 0 {
            ok = true
        }
        print(success && ok ? "UMP3 转换成功: \(outPath)" : "UMP3 转换失败")
    }
}
```

###### 同步转换示例（Swift）

```swift
let mp3Path = Tools.mp3Path + "/example.mp3" // 替换为实际文件
let outPath: String = (mp3Path as NSString).deletingPathExtension + ".ump3"

DispatchQueue.global(qos: .default).async {
    JLAudioConverter.convertMP3ToUmp3Sync(mp3Path, ump3Path: outPath)
    var ok = false
    let fm = FileManager.default
    if fm.fileExists(atPath: outPath),
       let attrs = try? fm.attributesOfItem(atPath: outPath),
       let size = attrs[.size] as? NSNumber,
       size.intValue > 0 {
        ok = true
    }
    DispatchQueue.main.async {
        print(ok ? "UMP3 同步转换成功: \(outPath)" : "UMP3 同步转换失败")
    }
}
```

> 参考 Demo 页面：`JLAudioUnitKitDemo/ViewControllers/Mp3ToUmp3VC.swift`，该页面提供选择文件、执行转换、结果校验与提示的完整示例。

##### **注意事项**

- 仅支持单声道 MP3 输入；双声道文件需先做声道下混。
- 转换过程涉及文件 I/O，建议在后台线程执行，回调中再切回主线程更新 UI。
- 为保证正确性，建议在回调后执行输出文件存在与大小校验（>0）。
- 建议将待处理文件置于 `Documents/mp3Convert` 目录，便于 Demo 与工具类统一管理。
- 同步接口会阻塞调用线程，不建议在主线程调用；请使用 GCD/后台队列执行并在主线程回调 UI。

### **附录**  

#### **Opus 默认编码配置 `JLOpusFormat`**  

##### 常量

* `OPUS_JL_MAX_FRAME_SIZE`：最大帧大小，单位是字节，等于 48000 * 2。
* `OPUS_JL_MAX_PACKET_SIZE`：最大数据包大小，单位是字节，值为 1500。

##### 属性

* `sampleRate`：采样率，表示每秒采样次数（例如：16000Hz）。
* `channels`：声道数，1 为单声道，2 为双声道。
* `frameDuration`：每帧的时长（默认为 20 毫秒）。
* `bitRate`：比特率，影响音频质量和压缩率。
* `frameSize`：只读属性，计算得到的每帧大小。
* `dataSize`：每帧数据的大小。
* `hasDataHeader`：是否包含数据头部。
* `usVoipSlik`：是否启用 Slik 语音优化（主要针对 VoIP 语音优化）。

##### 方法

* `+(JLOpusFormat*)defaultFormats`：类方法，返回一个默认配置的 `JLOpusFormat` 实例，包含了一些常见的默认值，如：采样率 16000，单声道，帧长度 20ms，比特率 16000 等。

```objective-c
JLOpusFormat *format = [JLOpusFormat defaultFormats];
NSLog(@"采样率: %d", format.sampleRate);     // 16000  
NSLog(@"帧长度: %dms", format.frameDuration); // 20ms  
NSLog(@"BitRate: %dkbps", format.bitRate);   // 自动计算  
```
#### **Opus 编码配置 `JLOpusEncodeConfig` 使用说明**

`JLOpusEncodeConfig` 是用于 Opus 音频编码器的配置类。它封装了 Opus 编码器的所有关键参数，可以用于初始化 `JLOpusEncoder` 或直接进行文件/数据编码。

##### 属性说明

| 属性                    | 类型     | 默认值                              | 说明                                                         |
| --------------------- | ------ | -------------------------------- | ---------------------------------------------------------- |
| `sampleRate`          | `int`  | 16000                            | 音频采样率（Hz）。常用值：8000、16000、24000、48000。                      |
| `channels`            | `int`  | 1                                | 声道数：1=单声道，2=双声道。                                           |
| `frameDuration`       | `int`  | 20                               | 帧时长（ms）。Opus 默认 20ms，可选 2.5/5/10/20/40/60ms。               |
| `frameSize`           | `int`  | 采样率 * frameDuration / 1000      | 每帧采样点数，由 `frameDuration` 和 `sampleRate` 计算得出。              |
| `bitRate`             | `int`  | 16000                            | 编码比特率（bps）。CBR 或 VBR 下都可设置。                                |
| `useVBR`              | `BOOL` | NO                               | 是否使用可变比特率（VBR）。NO 表示使用恒定比特率（CBR）。                          |
| `constrainedVBR`      | `BOOL` | NO                               | VBR 限制模式，启用后 VBR 不会超过设定比特率。                                |
| `complexity`          | `int`  | 5                                | 编码复杂度，0~10。数值越高编码质量越好，但 CPU 消耗也越高。                        |
| `forceChannels`       | `int`  | -1                               | 强制输出声道数。-1=自适应，1=单声道，2=双声道。                                |
| `useDTX`              | `BOOL` | NO                               | 启用 DTX（静音段不发送数据）可降低带宽消耗。                                   |
| `packetLossPercent`   | `int`  | 0                                | 网络丢包率百分比，用于优化编码器抗丢包能力。                                     |
| `bandwidth`           | `int`  | `JLOpusEncoderBandwidthFullband` | 最大带宽限制，对应 Opus 的 `OPUS_BANDWIDTH_*`。                       |
| `lsbDepth`            | `int`  | 16                               | PCM 输入有效位深，通常 16bit。                                       |
| `expertFrameDuration` | `int`  | 与 `frameDuration` 一致             | 专家模式下帧时长（ms）。用于控制 Opus 内部帧长度。                              |
| `hasDataHeader`       | `BOOL` | YES                              | 是否在编码输出中写入数据头。<br>如果启用，编码器会写入每帧长度和偏移信息；<br>关闭则使用杰理自定义无头编码。 |


#### 默认配置方法

##### 1. `defaultConfig`

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

##### 2. `defaultJL`

```objc
JLOpusEncodeConfig *jlConfig = [JLOpusEncodeConfig defaultJL];
```

* 杰理定制的"无头"配置。
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


#### 使用示例

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
#### 注意事项

1. **frameDuration 和 frameSize 的关系**

   ```text
   frameSize = sampleRate * frameDuration / 1000
   ```

   推荐使用默认 20ms 帧长度，Opus 支持的帧长：2.5、5、10、20、40、60ms。

2. **VBR 与 CBR**

   * `useVBR = YES` 表示可变比特率，可在保证质量的同时动态调整码率。
   * `useVBR = NO` 表示恒定码率（CBR），码率稳定，便于带宽规划。

3. **输出容器与兼容性**

   * `JLOpusEncoder` 输出为裸 Opus 帧，不包含 Ogg 容器。部分通用播放器可能无法直接播放该输出文件。

4. **hasDataHeader 的影响**

   * 若 `hasDataHeader = YES`，编码器会在输出中写入每帧的长度/偏移等头部索引信息，便于解析与随机访问；
   * 若 `hasDataHeader = NO`，输出为"无头"裸帧，更轻量，但上层读取时需按配置的 `frameDuration`、`sampleRate` 等参数进行解析与拼帧。
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


#### **常见错误码**  

| 错误码 | 描述                   |
| ------ | ---------------------- |
| `-1`   | 文件路径无效或权限不足 |
| `-2`   | 音频格式不支持         |
| `-3`   | 内存分配失败           |