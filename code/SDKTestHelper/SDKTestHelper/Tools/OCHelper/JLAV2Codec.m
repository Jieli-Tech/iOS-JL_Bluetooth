//
//  JLAV2Codec.m
//  SDKTestHelper
//
//  Created by EzioChan on 2025/4/10.
//  Copyright © 2025 www.zh-jieli.com. All rights reserved.
//

#import <JLAV2Lib/JLAV2Lib.h>
#import <os/lock.h>
#import "JLAV2Codec.h"
#import "JLAV2CodeInfo.h"

#define BUFFER_SIZE 1024 * 1024
#define MIN_FRAME_SIZE 128

// 实现配置对象的拷贝
@implementation JLAV2CodecConfig

- (id)copyWithZone:(NSZone *)zone {
    JLAV2CodecConfig *copy = [[[self class] allocWithZone:zone] init];
    copy.fadeInDuration = self.fadeInDuration;
    copy.fadeOutDuration = self.fadeOutDuration;
    copy.channelMode = self.channelMode;
    copy.leftChannelCoefficient = self.leftChannelCoefficient;
    copy.rightChannelCoefficient = self.rightChannelCoefficient;
    copy.edFrameLength = self.edFrameLength;
    return copy;
}

@end


@interface JLAV2Codec () {
    // Encoder Resources
    void *_encWorkBuf;
    void *_encScratch;
    struct jla_v2_codec_ops *_encOps;
    JLAV2CodeInfo *_currentEncodeConfig;
    NSMutableData *_encInputBuffer;
    NSThread *_encodeThread;
    dispatch_semaphore_t _encodeSemaphore;
    
    // Decoder Resources
    void *_decWorkBuf;
    void *_decScratch;
    struct jla_v2_codec_ops *_decOps;
    NSMutableData *_decInputBuffer;
    JLAV2CodeInfo *_currentDecodeConfig;
    NSThread *_decodeThread;
    dispatch_semaphore_t _decodeSemaphore;
    
    // Locks
    os_unfair_lock _encodeLock;
    os_unfair_lock _decodeLock;
}

@property (nonatomic, strong) JLAV2CodecConfig *encoderConfig;
@property (nonatomic, strong) JLAV2CodecConfig *decoderConfig;
@property (nonatomic, weak) id<JLAV2CodecDelegate> delegate;


@property (nonatomic, strong) JLAV2CodecBlock encodeBlock;
@property (nonatomic, strong) JLAV2CodecBlock decodeBlock;
@property (nonatomic, strong) NSString *encodeFilePath;
@property (nonatomic, strong) NSString *decodeFilePath;
@property (nonatomic, strong) NSMutableData *encodeData;
@property (nonatomic, strong) NSMutableData *decodeData;

@end

@implementation JLAV2Codec

+ (instancetype)share {
    static JLAV2Codec *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JLAV2Codec alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _encodeLock = OS_UNFAIR_LOCK_INIT;
        _decodeLock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

+ (void)encodeFile:(NSString *)inFilePath outFilePath:(NSString *)outFilePath Option:(JLAV2CodeInfo *)option  Result:(JLAV2CodecBlock) result {
    if ([[self share] isEncoding]) {
        result(nil, outFilePath, [NSError errorWithDomain:@"Encoder is already running" code:0 userInfo:nil]);
        NSLog(@"Encoder is already running<<");
        return;
    }
    NSData *encodeData = [NSData dataWithContentsOfFile:inFilePath];
    if (encodeData.length == 0) {
        result(nil, outFilePath, [NSError errorWithDomain:@"Encode data is empty" code:0 userInfo:nil]);
        NSLog(@"Encode data is empty<<");
        return;
    }
    [self share].encodeData = [NSMutableData new];
    [self share].encodeBlock = result;
    [self share].encodeFilePath = outFilePath;
    [[self share] createEncode: option];
    [[self share] encodeData:encodeData];
    
}

+ (void)decodeFile:(NSString *)inFilePath outFilePath:(NSString *)outFilePath Option:(JLAV2CodeInfo *)option ApplyConfig:(JLAV2CodecConfig * _Nullable)config Result:(JLAV2CodecBlock) result {
    if ([[self share] isDecoding]) {
        result(nil, outFilePath, [NSError errorWithDomain:@"Decoder is already running" code:0 userInfo:nil]);
        NSLog(@"Decoder is already running<<");
        return;
    }
    NSData *decodeData = [NSData dataWithContentsOfFile:inFilePath];
    if (decodeData.length == 0) {
        result(nil, outFilePath, [NSError errorWithDomain:@"Decode data is empty" code:0 userInfo:nil]);
        NSLog(@"Decode data is empty<<");
        return;
    }
    [self share].decodeData = [NSMutableData new];
    [self share].decodeBlock = result;
    [self share].decodeFilePath = outFilePath;
    [[self share] createDecode: option];
    if (config) {
        [[self share] applyDecoderConfig:config];
    }
    [[self share] decodeData:decodeData];
    
}

- (instancetype)initWithDelegate:(id<JLAV2CodecDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _encodeLock = OS_UNFAIR_LOCK_INIT;
        _decodeLock = OS_UNFAIR_LOCK_INIT;
    }
    return self;
}

- (BOOL)isEncoding {
    return _encodeThread != nil;
}

- (BOOL)isDecoding {
    return _decodeThread != nil;
}

#pragma mark - Encoder
- (BOOL)createEncode:(JLAV2CodeInfo *)info{

    if (_encodeThread) {
        NSLog(@"%@, Encoder is already running", _encodeThread);
        return NO;
    }
    
    // Convert parameters
    struct jla_v2_codec_info c_info = [self convertToCodecInfo:info];
    // Get encoder ops
    _encOps = get_jla_v2_enc_ops();
    if (!_encOps) {
        NSLog(@"Failed to get encoder ops");
        return NO;
    }
    // Allocate memory
    size_t workSize = _encOps->need_dcbuf_size(&c_info);
    int respx = posix_memalign(&_encWorkBuf, 8, workSize);
    if (respx != 0) {
        NSLog(@"Failed to allocate encoder memory:%d", respx);
        return NO;
    }
    size_t scratchSize = _encOps->need_stbuf_size(&c_info);
    _encScratch = malloc(scratchSize);
    
    // Setup IO callbacks
    struct jla_v2_codec_io io = {
        .priv = (__bridge void *)self,
        .input_data = encoder_input_callback,
        .output_data = encoder_output_callback
    };
    
    uint32_t ret = _encOps->open(_encWorkBuf, &io, &c_info);
    if (ret != 0) {
        [self freeEncoderMemory];
        [self encodeData:nil error:[self errorWithCode:JLAV2CodecErrorInitializationFailed userInfo:@{@"errMsg": @"Encoder failed"}]];
        return NO;
    }
    _currentEncodeConfig = info;
    _encInputBuffer = [NSMutableData new];
    _encodeSemaphore = dispatch_semaphore_create(1);
    _encodeThread = [[NSThread alloc] initWithTarget:self selector:@selector(encodeThread) object:nil];
    [_encodeThread start];
    return YES;
}

- (void)encodeData:(NSData *)pcmData {
    if (!_encodeThread) {
        [self encodeData:nil error:[self errorWithCode:JLAV2CodecErrorInitializationFailed userInfo:@{@"errMsg": @"Encoder is not running"}]];
        return;
    }
    BOOL shouldRun = false;
    os_unfair_lock_lock(&_encodeLock);
    if (_encInputBuffer.length == 0) {
        shouldRun = true;
    }
    [_encInputBuffer appendData:pcmData];
    os_unfair_lock_unlock(&_encodeLock);
    if (shouldRun) {
        dispatch_semaphore_signal(_encodeSemaphore);
    }
}

#pragma mark - 编码器配置
- (BOOL)applyEncoderConfig:(JLAV2CodecConfig *)config  {
    __block BOOL success = YES;
    // ED帧长度配置
    if (config.edFrameLength > 0) {
        u32 edFrameLen = (u32)config.edFrameLength;
        uint32_t ret = _encOps->codec_config(_encWorkBuf, SET_EDFRAME_LEN, &edFrameLen);
        if (ret != 0) {
            [self encodeData:nil error:[self errorWithCode:JLAV2CodecErrorInvalidParameter userInfo:@{@"errMsg": @"Invalid ED frame length"}]];
            success = NO;
        }
    }
    // 保存配置
    _encoderConfig = [config copy];
    return success;
}


- (void)destoryEncode {
    os_unfair_lock_lock(&_encodeLock);
    _currentEncodeConfig = nil;
    [_encodeThread cancel];
    _encodeThread = nil;
    _encodeData = nil;
    _encodeBlock = nil;
    _encodeFilePath = nil;
    _encInputBuffer = [NSMutableData new];
    [self freeEncoderMemory];
    os_unfair_lock_unlock(&_encodeLock);
    _encodeSemaphore = nil;
}

-(void)encodeThread {
    while (1) {
        if (_encodeSemaphore == nil) break;
        dispatch_semaphore_wait(_encodeSemaphore, DISPATCH_TIME_FOREVER);
        static int Lcnt = 0;
        Lcnt++;
        if (Lcnt >= 577) {
            Lcnt = Lcnt;
        }
        if (_encWorkBuf && _encScratch) {
            int ret = _encOps->run(_encWorkBuf, _encScratch);
            if (ret != 0) {
                [self encodeData:nil error:[self errorWithCode:JLAV2CodecErrorProcessingFailed userInfo:@{@"errMsg": @"Encoder failed"}]];
                break;
            }
        }
    }
}


#pragma mark - Decoder
- (BOOL)createDecode:(JLAV2CodeInfo *)info {
    if (_decodeThread) {
        [self decodeData:nil error:[self errorWithCode:JLAV2CodecErrorInitializationFailed userInfo:@{@"errMsg": @"Decoder is already running"}]];
        return NO;
    }
    // Convert parameters
    struct jla_v2_codec_info c_info = [self convertToCodecInfo:info];
    // Get decoder ops
    _decOps = get_jla_v2_dec_ops();
    if (!_decOps) {
        [self decodeData:nil error:[self errorWithCode:JLAV2CodecErrorInitializationFailed userInfo:@{@"errMsg": @"Failed to get decoder ops"}]];
        return NO;
    }
    
    // Allocate memory
    size_t workSize = _decOps->need_dcbuf_size(&c_info);
    if (posix_memalign(&_decWorkBuf, 8, workSize) != 0) {
        [self decodeData:nil error:[self errorWithCode:JLAV2CodecErrorMemoryAllocation userInfo:@{@"errMsg": @"Failed to allocate decoder memory"}]];
        return NO;
    }
    size_t scratchSize = _decOps->need_stbuf_size(&c_info);
    _decScratch = malloc(scratchSize);
    // Setup IO callbacks
    struct jla_v2_codec_io io = {
        .priv = (__bridge void *)self,
        .input_data = decoder_input_callback,
        .output_data = decoder_output_callback
    };
    
    // Open decoder
    uint32_t ret = _decOps->open(_decWorkBuf, &io, &c_info);
    if (ret != 0) {
        [self decodeData:nil error:[self errorWithCode:JLAV2CodecErrorInitializationFailed userInfo:@{@"errMsg": @"Decoder failed"}]];
        [self freeDecoderMemory];
        return NO;
    }
    
    int frlen = _decOps->codec_config(_decWorkBuf, GET_EDFRAME_LEN, NULL);
    _decOps->codec_config(_decWorkBuf, SET_EDFRAME_LEN, &frlen);
    _decOps->codec_config(_decWorkBuf, SET_FADE_IN_OUT, &frlen);
    
    // Setup loop thread
    _currentDecodeConfig = info;
    _decodeSemaphore = dispatch_semaphore_create(1);
    _decInputBuffer = [NSMutableData new];
    _decodeThread = [[NSThread alloc] initWithTarget:self selector:@selector(decodeThread) object:nil];
    [_decodeThread start];
    
    return YES;
}

- (void)decodeData:(NSData *)encodeData {
    if (!_decodeThread) {
        [self decodeData:nil error:[self errorWithCode:JLAV2CodecErrorInitializationFailed userInfo:@{@"errMsg": @"Decoder is not running"}]];
        return;
    }
    BOOL shouldRun = false;
    os_unfair_lock_lock(&_decodeLock);
    if (_decInputBuffer.length == 0) {
        shouldRun = true;
    }
    [_decInputBuffer appendData:encodeData];
    os_unfair_lock_unlock(&_decodeLock);
    if (shouldRun) {
        dispatch_semaphore_signal(_decodeSemaphore);
    }
}


- (BOOL)applyDecoderConfig:(JLAV2CodecConfig *)config {
    if (_decodeThread) {
        [self decodeData:nil error:[self errorWithCode:JLAV2CodecErrorInitializationFailed userInfo:@{@"errMsg": @"Decoder is already running"}]];
        return NO;
    }
    // 淡入淡出配置
    if (config.fadeInDuration > 0 || config.fadeOutDuration > 0) {
        u32 fadeParams[2] = {
            (u32)config.fadeInDuration,
            (u32)config.fadeOutDuration
        };
        uint32_t ret = _decOps->codec_config(_decWorkBuf, SET_FADE_IN_OUT, fadeParams);
        if (ret != 0) {
            [self decodeData:nil error:[self errorWithCode:JLAV2CodecErrorInvalidParameter userInfo:@{@"errMsg": @"Invalid fade parameters"}]];
            return NO;
        }
    }
    
    // 声道输出模式
    struct jla_v2_dec_ch_oput_para chParam = {0};
    chParam.mode = (u32)config.channelMode;
    
    // 转换混合系数到Q13格式（0~8192对应0.0~1.0）
    chParam.pL = (short)(config.leftChannelCoefficient * 8192);
    chParam.pR = (short)(config.rightChannelCoefficient * 8192);
    
    uint32_t ret = _decOps->codec_config(_decWorkBuf, SET_DEC_CH_MODE, &chParam);
    if (ret != 0) {
        [self decodeData:nil error:[self errorWithCode:JLAV2CodecErrorInvalidParameter userInfo:@{@"errMsg": @"Invalid channel mix parameters"}]];
        return NO;
    }
    // 保存配置
    _decoderConfig = [config copy];
    return YES;
}

- (void)destoryDecode {
    os_unfair_lock_lock(&_decodeLock);
    _currentDecodeConfig = nil;
    [_decodeThread cancel];
    _decodeThread = nil;
    _decInputBuffer = nil;
    _decodeData = nil;
    _decodeBlock = nil;
    _decodeFilePath = nil;
    [self freeDecoderMemory];
    os_unfair_lock_unlock(&_decodeLock);
    _decodeSemaphore = nil;
}

- (void)decodeThread {
    while (1) {
        if (_decodeSemaphore == nil) break;
        dispatch_semaphore_wait(_decodeSemaphore, DISPATCH_TIME_FOREVER);
        if (_decWorkBuf && _decScratch) {
            uint32_t ret = _decOps->run(_decWorkBuf, _decScratch);
            if (ret != 0) {
                [self decodeData:nil error:[self errorWithCode:JLAV2CodecErrorProcessingFailed userInfo:@{@"errMsg": @"Decoder failed"}]];
            }
        }
    }
}

#pragma mark - Private Methods
- (struct jla_v2_codec_info)convertToCodecInfo:(JLAV2CodeInfo *)info {
    struct jla_v2_codec_info c_info;
    c_info.sr = info.sampleRate;
    c_info.br = info.bitRate;
    c_info.fr_idx = info.frameIdx;
    c_info.nch = info.channels;
    c_info.if_s24 = info.isSupportBit24 ? 1 : 0;
    return c_info;
}


- (void)freeEncoderMemory {
    if (_encWorkBuf) { free(_encWorkBuf); _encWorkBuf = NULL; }
    if (_encScratch) { free(_encScratch); _encScratch = NULL; }
    _encOps = NULL;
}

- (void)freeDecoderMemory {
    if (_decWorkBuf) { free(_decWorkBuf); _decWorkBuf = NULL; }
    if (_decScratch) { free(_decScratch); _decScratch = NULL; }
    _decOps = NULL;
}


- (NSError *)errorWithCode:(JLAV2CodecError)code userInfo:(NSDictionary *)info {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:info];
    userInfo[NSLocalizedDescriptionKey] = [self errorDescriptionForCode:code];
    return [NSError errorWithDomain:@"JLAV2Codec" code:code userInfo:userInfo];
}

- (NSString *)errorDescriptionForCode:(JLAV2CodecError)code {
    switch (code) {
        case JLAV2CodecErrorMemoryAllocation: return @"Memory allocation failed";
        case JLAV2CodecErrorInitializationFailed: return @"Codec initialization failed";
        case JLAV2CodecErrorInvalidParameter: return @"Invalid parameters";
        case JLAV2CodecErrorProcessingFailed: return @"Data processing failed";
        case JLAV2CodecErrorBufferFull: return @"Ring buffer full";
        default: return @"Unknown error";
    }
}

-(void)encodeData:(NSData * _Nullable)data error:(NSError * _Nullable)error {
    __weak typeof (JLAV2Codec *)weakSelf = self;
    if (_encodeBlock) {
        if (error) {
            _encodeBlock(_encodeData, _encodeFilePath, error);
            [self destoryEncode];
        }
        return;
    }
    if (![_delegate respondsToSelector:@selector(encodecData:error:)]) {
        NSLog(@"JLAV2Codec: encodecData:error: is not implemented");
        return;
    }
    if ([NSThread isMainThread]) {
        [_delegate encodecData:data error:error];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof (JLAV2Codec *)strongSelf = weakSelf;
            [strongSelf->_delegate encodecData:data error:error];
        });
    }
}

-(void)decodeData:(NSData * _Nullable)data error:(NSError * _Nullable)error {
    __weak typeof (JLAV2Codec *)weakSelf = self;
    if (_decodeBlock) {
        if (error) {
            _decodeBlock(_decodeData , _decodeFilePath, error);
            [self destoryDecode];
        }
        return;
    }
    if (![_delegate respondsToSelector:@selector(decodecData:error:)]) {
        NSLog(@"JLAV2Codec: decodecData:error: is not implemented");
    }
    if ([NSThread isMainThread]) {
        [_delegate decodecData:data error:error];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof (JLAV2Codec *)strongSelf = weakSelf;
            [strongSelf->_delegate decodecData:data error:error];
        });
    }
}

#pragma mark - C Callbacks
static u16 encoder_input_callback(void* priv, u8* buf, u16 len) {
    JLAV2Codec *self = (__bridge JLAV2Codec *)priv;
    os_unfair_lock_lock(&self->_encodeLock);
    if (self->_encInputBuffer.length < len) {
        os_unfair_lock_unlock(&self->_encodeLock);
        return 0;
    }
    NSData *data = [self->_encInputBuffer subdataWithRange:NSMakeRange(0, len)];
    [self->_encInputBuffer replaceBytesInRange:NSMakeRange(0, len) withBytes:NULL length:0];
    u16 copySize = (u16)data.length;
    memcpy(buf, data.bytes, copySize);
    //从S32文件中输入S24位宽数据处理.
    if (self->_currentEncodeConfig.isSupportBit24) {
        int i;
        int lenint = len / 4;
        int* ptrdata = (int*)buf;
        for (i = 0; i < lenint; i++)
        {
            ptrdata[i] = ptrdata[i] >> 8;
        }
    }
    os_unfair_lock_unlock(&self->_encodeLock);
    return (u16)copySize;
}

static u16 encoder_output_callback(void* priv, u8* buf, u16 len) {
    JLAV2Codec *self = (__bridge JLAV2Codec *)priv;
    NSData *data = [NSData dataWithBytes:buf length:len];
    [self encodeData:data error:nil];
    if (self->_encodeBlock && self->_encodeData) {
        os_unfair_lock_lock(&self->_encodeLock);
        [self->_encodeData appendData:data];
        os_unfair_lock_unlock(&self->_encodeLock);
    }
    if (self->_encInputBuffer.length > 0) {
        dispatch_semaphore_signal(self->_encodeSemaphore);
    } else {
        if (self->_encodeData.length > 0 && self->_encodeBlock) {
            [[NSFileManager defaultManager] removeItemAtPath:self->_encodeFilePath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:self->_encodeFilePath contents:self->_encodeData attributes:nil];
            self->_encodeBlock(self->_encodeData, self->_encodeFilePath,nil);
            NSLog(@"JLAV2Codec: encodeFile Finished, outFilePath:%@", self->_encodeFilePath);
            [self destoryEncode];
        }
    }
    return len;
}

static u16 decoder_input_callback(void* priv, u8* buf, u16 len) {
    JLAV2Codec *self = (__bridge JLAV2Codec *)priv;
    os_unfair_lock_lock(&self->_decodeLock);
    if (self->_decInputBuffer.length < len) {
        os_unfair_lock_unlock(&self->_decodeLock);
        return 0;
    }
    NSData *data = [self->_decInputBuffer subdataWithRange:NSMakeRange(0, len)];
    [self->_decInputBuffer replaceBytesInRange:NSMakeRange(0, len) withBytes:NULL length:0];
    u16 copySize = (u16)data.length;
    memcpy(buf, data.bytes, copySize);
    if (self->_currentDecodeConfig.isSupportBit24) {
        int i;
        int lenint = len / 4;
        int* ptrdata = (int*)buf;
        for (i = 0; i < lenint; i++)
        {
            ptrdata[i] = ptrdata[i] << 8;
        }
    }
    os_unfair_lock_unlock(&self->_decodeLock);
    return (u16)copySize;
}

static u16 decoder_output_callback(void* priv, u8* buf, u16 len) {
    JLAV2Codec *self = (__bridge JLAV2Codec *)priv;
    NSData *data = [NSData dataWithBytes:buf length:len];
    [self decodeData:data error:nil];
    if (self->_decodeBlock && self->_decodeData) {
        os_unfair_lock_lock(&self->_decodeLock);
        [self->_decodeData appendData:data];
        os_unfair_lock_unlock(&self->_decodeLock);
    }
    if (self->_decInputBuffer.length > 0) {
        dispatch_semaphore_signal(self->_decodeSemaphore);
    } else {
        if (self->_decodeData.length > 0 && self->_decodeBlock) {
            [[NSFileManager defaultManager] removeItemAtPath:self->_decodeFilePath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:self->_decodeFilePath contents:self->_decodeData attributes:nil];
            self->_decodeBlock(self->_decodeData, self->_decodeFilePath, nil);
            NSLog(@"JLAV2Codec: decodeFile Finished, outFilePath:%@", self->_decodeFilePath);
            [self destoryDecode];
        }
    }
    return len;
}

@end
