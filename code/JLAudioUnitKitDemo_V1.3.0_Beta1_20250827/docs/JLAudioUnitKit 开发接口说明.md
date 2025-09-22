### JLAudioUnitKit 开发接口说明


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
##### **接口说明**  
```objective-c
// 初始化
- (instancetype)initDecoder:(JLOpusFormat *)format delegate:(id<JLOpusDecoderDelegate>)delegate;

// 输入 Opus 数据
- (void)opusDecoderInputData:(NSData *)data;

// 文件解码
- (void)opusDecodeFile:(NSString *)input outPut:(NSString *)outPut Resoult:(JLOpusDecoderConvertBlock)result;
```

##### **代理协议 `JLOpusDecoderDelegate`**  
```objective-c
- (void)opusDecoder:(JLOpusDecoder *)decoder Data:(NSData *)data error:(NSError *)error;
```

##### **示例**  
```objective-c
JLOpusFormat *format = [JLOpusFormat defaultFormats];
JLOpusDecoder *decoder = [[JLOpusDecoder alloc] initDecoder:format delegate:self];
[decoder opusDecoderInputData:opusData];

// 文件解码
[decoder opusDecodeFile:@"/path/to/input.opus" outPut:@"/path/to/output.pcm" Resoult:^(NSString *pcmPath, NSError *error) {
    if (!error) {
        NSLog(@"Opus 解码完成: %@", pcmPath);
    }
}];
```

##### **编码器 `JLOpusEncoder`**  
##### **接口说明**  
```objective-c
// 初始化
- (instancetype)initFormat:(JLOpusFormat *)format delegate:(id<JLOpusEncoderDelegate>)delegate;

// 输入 PCM 数据
- (void)opusEncodeData:(NSData *)data;

// 文件编码
- (void)opusEncodeFile:(NSString *)pcmPath outPut:(NSString *)outPut Resoult:(JLOpusEncoderConvertBlock)result;
```

##### **代理协议 `JLOpusEncoderDelegate`**  
```objective-c
- (void)opusEncoder:(JLOpusEncoder *)encoder Data:(NSData *)data error:(NSError *)error;
```

##### **示例**  
```objective-c
JLOpusFormat *format = [JLOpusFormat defaultFormats];
JLOpusEncoder *encoder = [[JLOpusEncoder alloc] initFormat:format delegate:self];
[encoder opusEncodeData:pcmData];

// 文件编码
[encoder opusEncodeFile:@"/path/to/input.pcm" outPut:@"/path/to/output.opus" Resoult:^(NSString *opusPath, NSError *error) {
    if (!error) {
        NSLog(@"Opus 编码完成: %@", opusPath);
    }
}];
```

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

### 6. Opus 转 OGG

`JLOpusToOgg.h` 是一个用于将 Opus 编码的音频数据转换为 Ogg 格式的类。它提供了两个主要方法：

1. **convertOpusDataToOgg:error:**
   - 将内存中的 Opus 数据（NSData）转换为 Ogg 格式的 NSData。
   - 支持的条件：帧长必须是 40ms，采样率为 16kHz，且必须是单声道。
2. **convertOpusFileToOgg:oggFilePath:**
   - 将存储在文件系统中的 Opus 文件转换为 Ogg 文件。
   - 同样需要满足帧长、采样率和声道的要求。

这两个方法都专门针对“杰理”的无头裸 Opus 数据/文件进行处理，这意味着输入的数据或文件没有包含标准 Opus 头信息。

### 使用示例说明

** 示例一：使用 `convertOpusDataToOgg:error:` 方法**

假设你有一段符合要求的 Opus 数据，并希望通过 `JLOpusToOgg` 类将其转换为 Ogg 数据。

```objective-c
// 假设 opusData 是你的 Opus 格式的 NSData
NSData *opusData = [self prepareOpusData]; // 这里你需要自己准备 Opus 数据

NSError *error;
NSData *oggData = [JLOpusToOgg convertOpusDataToOgg:opusData error:&error];

if (oggData) {
    NSLog(@"成功转换为 Ogg 数据");
} else {
    NSLog(@"转换失败，错误信息：%@", error.localizedDescription);
}
```

在这个例子中，我们首先准备了一段 Opus 数据（这一步需要根据实际情况实现），然后调用 `convertOpusDataToOgg:error:` 方法尝试将其转换为 Ogg 数据。如果转换成功，`oggData` 将包含转换后的 Ogg 数据；如果失败，则会返回一个 NSError 对象描述错误原因。

** 示例二：使用 `convertOpusFileToOgg:oggFilePath:` 方法**

如果你有一个 Opus 文件并希望将其转换为 Ogg 文件，可以使用如下代码：

```objective-c
NSString *opusFilePath = [[NSBundle mainBundle] pathForResource:@"example_opus" ofType:@"opus"]; // 替换为实际的 Opus 文件路径
NSString *oggFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"output.ogg"];

[JLOpusToOgg convertOpusFileToOgg:opusFilePath oggFilePath:oggFilePath];

NSLog(@"转换完成，Ogg 文件位于：%@", oggFilePath);

// 验证输出文件是否存在
if ([[NSFileManager defaultManager] fileExistsAtPath:oggFilePath]) {
    NSLog(@"Ogg 文件创建成功");
} else {
    NSLog(@"Ogg 文件创建失败");
}
```

这里，首先指定了 Opus 文件的路径和期望生成的 Ogg 文件路径，然后调用了 `convertOpusFileToOgg:oggFilePath:` 方法来执行转换。最后，通过检查 Ogg 文件是否存在来验证转换是否成功。

### **注意事项**  

1. **代理协议**：所有接口均需绑定对应的代理以接收事件或错误信息。  
2. **参数校验**：初始化时需确保参数（如采样率、文件路径）正确，避免运行时崩溃。  
3. **资源释放**：调用 `opusOnRelease` 或 `speexOnRelease` 释放编解码器资源。  
4. **线程安全**：涉及文件操作的方法（如 `convertPCMData:toWAVFile:`）需在主线程外执行以避免阻塞 UI。  
5. **格式兼容性**：WTG 转换要求输入 PCM 文件为 8kHz 16bit 小端格式。  


### **附录**  
#### **Opus 默认配置 `JLOpusFormat`**  

**常量配置**：
```
OPUS_JL_MAX_FRAME_SIZE：最大帧大小，单位是字节，等于 48000 * 2。
OPUS_JL_MAX_PACKET_SIZE：最大数据包大小，单位是字节，值为 1500。
```
主要属性说明：

- sampleRate：采样率，表示每秒采样次数（例如：16000Hz）。

- channels：声道数，1 为单声道，2 为双声道。

- frameDuration：每帧的时长（默认为 20 毫秒）。

- bitRate：比特率，影响音频质量和压缩率。

- frameSize：只读属性，计算得到的每帧大小。

- dataSize：每帧数据的大小。

- hasDataHeader：是否包含数据头部。

- usVoipSlik：是否启用 Slik 语音优化（主要针对 VoIP 语音优化）。

`+(JLOpusFormat*)defaultFormats：`类方法，返回一个默认配置的 JLOpusFormat 实例，包含了一些常见的默认值，如：采样率 16000，单声道，帧长度 20ms，比特率 16000 等。

```objective-c
JLOpusFormat *format = [JLOpusFormat defaultFormats];
// 若果需要设置自定义参数，可直接修改 format 的属性
format.sampleRate = 16000;
format.channels = 1;
format.frameDuration = 20;
format.bitRate = 16000;
format.hasDataHeader = YES;
format.usVoipSlik = YES;
NSLog(@"采样率: %d", format.sampleRate);     // 16000  
NSLog(@"帧长度: %dms", format.frameDuration); // 20ms  
NSLog(@"BitRate: %dkbps", format.bitRate);   // 自动计算  
```

#### **常见错误码**  
| 错误码 | 描述                   |
| ------ | ---------------------- |
| `-1`   | 文件路径无效或权限不足 |
| `-2`   | 音频格式不支持         |
| `-3`   | 内存分配失败           |

