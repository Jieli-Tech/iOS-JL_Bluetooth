//
//  JLVideoTool.h
//  JLVideoTool
//
//  Created by EzioChan on 2025/8/20.
//

#import <Foundation/Foundation.h>

//! Project version number for JLVideoTool.
FOUNDATION_EXPORT double JLVideoToolVersionNumber;

//! Project version string for JLVideoTool.
FOUNDATION_EXPORT const unsigned char JLVideoToolVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JLVideoTool/PublicHeader.h>

// Version Info
#import <JLVideoTool/JLVersionInfo.h>

// Video Info
#import <JLVideoTool/JLVideoInfo.h>

// Converter
#import <JLVideoTool/JLAniConverter.h>
#import <JLVideoTool/JLVideoProcessingModels.h>
#import <JLVideoTool/JLVideoFilterProcessor.h>
#import <JLVideoTool/JLImagesToVideoGenerator.h>
#import <JLVideoTool/JLVideoThumbnailGenerator.h>

// Decoder
#import <JLVideoTool/JLDecoderOptions.h>
#import <JLVideoTool/JLVideoDecoderDelegate.h>
#import <JLVideoTool/JLVideoDecoder.h>
#import <JLVideoTool/JLH264Decoder.h>
#import <JLVideoTool/JLJPEGDecoder.h>

// JPEG Encoder
#import <JLVideoTool/JLJPEGEncoder.h>
#import <JLVideoTool/JLJPEGCompressor.h>
#import <JLVideoTool/JLJPEGImageProcessor.h>
#import <JLVideoTool/JLJPEGDataSeparator.h>
#import <JLVideoTool/JLJPEGPerformanceMonitor.h>

// JPEG to H264 Converter
#import <JLVideoTool/JLJpegToH264Options.h>
#import <JLVideoTool/JLJpegToH264Converter.h>
#import <JLVideoTool/JLConverterStatistics.h>

// Player
#import <JLVideoTool/JLPlayerTypes.h>
#import <JLVideoTool/JLPlayerOptions.h>
#import <JLVideoTool/JLPlayerDelegate.h>
#import <JLVideoTool/JLPlayerViewDelegate.h>
#import <JLVideoTool/JLPlayerCore.h>
#import <JLVideoTool/JLAudioRenderer.h>
#import <JLVideoTool/JLVideoRenderer.h>
#import <JLVideoTool/JLPlayerDebugger.h>
#import <JLVideoTool/JLPlayerView.h>
#import <JLVideoTool/JLPlayerDebugView.h>
#import <JLVideoTool/JLDataValidator.h>
#import <JLVideoTool/JLStreamRouter.h>

// Local File Player
#import <JLVideoTool/JLLocalFilePlayer.h>
#import <JLVideoTool/JLLocalFilePlayerView.h>
#import <JLVideoTool/JLLocalFilePlayerVM.h>
#import <JLVideoTool/JLLocalFileInfo.h>

// Utils
#import <JLVideoTool/JLVideoFrame.h>
#import <JLVideoTool/JLAudioFrame.h>
#import <JLVideoTool/JLTimeUtils.h>
