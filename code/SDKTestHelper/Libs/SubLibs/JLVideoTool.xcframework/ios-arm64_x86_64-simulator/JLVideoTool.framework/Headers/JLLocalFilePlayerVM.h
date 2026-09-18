//
//  JLLocalFilePlayerVM.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/22.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JLLocalFileInfo;
@protocol JLLocalFilePlayerDelegate;

typedef NS_ENUM(NSInteger, JLLocalFilePlayerState) {
    JLLocalFilePlayerStateIdle,
    JLLocalFilePlayerStateLoading,
    JLLocalFilePlayerStateReady,
    JLLocalFilePlayerStatePlaying,
    JLLocalFilePlayerStatePaused,
    JLLocalFilePlayerStateStopped,
    JLLocalFilePlayerStateError,
};

NS_ASSUME_NONNULL_BEGIN

@protocol JLLocalFilePlayerDelegate <NSObject>
@optional
- (void)playerDidChangeState:(JLLocalFilePlayerState)state;
- (void)playerDidUpdateTime:(NSTimeInterval)currentTime duration:(NSTimeInterval)duration;
- (void)playerDidUpdateBufferProgress:(float)progress;
- (void)playerDidFailWithError:(NSError *)error;
- (void)playerDidFinishPlayback;
@end

typedef void (^JLLocalFilePlayerTimeCallback)(NSTimeInterval currentTime, NSTimeInterval duration);

@interface JLLocalFilePlayerVM : NSObject

@property (nonatomic, weak, nullable) id<JLLocalFilePlayerDelegate> delegate;
@property (nonatomic, copy, nullable) JLLocalFilePlayerTimeCallback timeUpdateCallback;
@property (nonatomic, assign, readonly) JLLocalFilePlayerState state;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, strong, readonly) JLLocalFileInfo * _Nullable fileInfo;
@property (nonatomic, assign, readonly) float bufferProgress;
@property (nonatomic, assign) float volume;

- (void)openFile:(NSString *)filePath;
- (void)bindRenderView:(UIView *)view;
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)time;
- (void)updateRenderViewFrame;

@end

NS_ASSUME_NONNULL_END
