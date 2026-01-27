//
//  JLAudioFormatModel.m
//  JLAuracastKit
//
//  Created by EzioChan on 2024/10/10.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import "JLAudioFormatModel.h"

@implementation JLAudioFormatModel

- (instancetype)initWithAudioFormat:(JLBroadcastSetAudioFormat)audioFormat
{
    self = [super init];
    if (self) {
        _audioFormat = audioFormat;
        [self initData];
    }
    return self;
}

- (void)initData {
    switch (self.audioFormat) {
        case JLBroadcastSetAudioFormat8_1:{
            _name = @"8_1_1";
            _sampleRate = 8000;
            _SDUInterval = 7500;
            _RTN = 2;
            _presentaionDelay = 40000;
            _maxTransportLatency = 8;
            _maxSDUOctets = 26;
            _maxSDUOctetsStr = @"26(27.734kbps)";
        }break;
        case JLBroadcastSetAudioFormat8_2:
            _name = @"8_2_1";
            _sampleRate = 8000;
            _SDUInterval = 10000;
            _RTN = 2;
            _presentaionDelay = 40000;
            _maxTransportLatency = 10;
            _maxSDUOctets = 30;
            _maxSDUOctetsStr = @"30(24kbps)";
            break;
        case JLBroadcastSetAudioFormat16_1_1:
            _name = @"16_1_1";
            _sampleRate = 16000;
            _SDUInterval = 7500;
            _maxSDUOctets = 30;
            _maxSDUOctetsStr = @"30(32kbps)";
            _RTN = 2;
            _maxTransportLatency = 8;
            _presentaionDelay = 40000;
            break;
        case JLBroadcastSetAudioFormat16_2_1:
            _name = @"16_2_1";
            _sampleRate = 16000;
            _SDUInterval = 10000;
            _maxSDUOctets = 40;
            _maxSDUOctetsStr = @"40(32kbps)";
            _RTN = 2;
            _maxTransportLatency = 10;
            _presentaionDelay = 40000;
            break;
        case JLBroadcastSetAudioFormat24_1_1:
            _name = @"24_1_1";
            _sampleRate = 24000;
            _SDUInterval = 7500;
            _maxSDUOctets = 45;
            _maxSDUOctetsStr = @"45(48kbps)";
            _RTN = 2;
            _maxTransportLatency = 8;
            _presentaionDelay = 40000;
            break;
        case JLBroadcastSetAudioFormat24_2_1:
            _name = @"24_2_1";
            _sampleRate = 24000;
            _SDUInterval = 10000;
            _maxSDUOctets = 60;
            _maxSDUOctetsStr = @"60(48kbps)";
            _RTN = 2;
            _maxTransportLatency = 10;
            _presentaionDelay = 40000;
            break;
        case JLBroadcastSetAudioFormat32_1_1:
            _name = @"32_1_1";
            _sampleRate = 32000;
            _SDUInterval = 7500;
            _maxSDUOctets = 60;
            _maxSDUOctetsStr = @"60(64kbps)";
            _RTN = 2;
            _maxTransportLatency = 8;
            _presentaionDelay = 40000;
            break;
        case JLBroadcastSetAudioFormat32_2_1:
            _name = @"32_2_1";
            _sampleRate = 32000;
            _SDUInterval = 10000;
            _maxSDUOctets = 80;
            _maxSDUOctetsStr = @"80(64kbps)";
            _RTN = 2;
            _maxTransportLatency = 10;
            _presentaionDelay = 40000;
            break;
        case JLBroadcastSetAudioFormat441_1_1:
            _name = @"441_1_1";
            _sampleRate = 44100;
            _SDUInterval = 8163;
            _maxSDUOctets = 97;
            _maxSDUOctetsStr = @"97(95.06kbps)";
            _RTN = 4;
            _maxTransportLatency = 24;
            _presentaionDelay = 40000;
            break;
        case JLBroadcastSetAudioFormat441_2_1:
            _name = @"441_2_1";
            _sampleRate = 44100;
            _SDUInterval = 10884;
            _maxSDUOctets = 130;
            _maxSDUOctetsStr = @"130(95.55kbps)";
            _RTN = 4;
            _maxTransportLatency = 31;
            _presentaionDelay = 40000;
            break;
        case JLBroadcastSetAudioFormat48_1:
            _name = @"48_1_1";
            _sampleRate = 48000;
            _SDUInterval = 7500;
            _maxSDUOctets = 75;
            _maxSDUOctetsStr = @"75(80kbps)";
            _RTN = 4;
            _maxTransportLatency = 15;
            _presentaionDelay = 40000;
            break;
        case JLBroadcastSetAudioFormat48_2:
            _name = @"48_2_1";
            _sampleRate = 48000;
            _SDUInterval = 10000;
            _maxSDUOctets = 100;
            _maxSDUOctetsStr = @"100(80kbps)";
            _RTN = 4;
            _maxTransportLatency = 20;
            _presentaionDelay = 40000;
            break;
    }
}


@end
