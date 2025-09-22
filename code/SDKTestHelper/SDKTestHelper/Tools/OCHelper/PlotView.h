//
//  PlotView.h
//  Opus
//
//  Created by Jonor on 2018/9/13.
//  Copyright © 2018年 Jonor. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface DFAudioFormat : NSObject
@property(nonatomic,assign)Float64 mSampleRate;
@property(nonatomic,assign)UInt32  mBitsPerChannel;
@property(nonatomic,assign)UInt32  mChannelsPerFrame;
@property(nonatomic,assign)AudioFormatID mFormatID;

@end

@interface PlotView : UIView

@property (nonatomic, strong) NSData *points;
@property (nonatomic, strong) DFAudioFormat *fm;

@end
