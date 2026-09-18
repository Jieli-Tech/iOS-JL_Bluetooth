//
//  JLLocalFilePlayer.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/22.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^JLLocalFilePlayerTimeCallback)(NSTimeInterval currentTime, NSTimeInterval duration);

@interface JLLocalFilePlayer : NSObject

- (instancetype)initWithRenderView:(UIView *)view;
- (void)loadFile:(NSString *)filePath;
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)seekTo:(NSTimeInterval)time;

@property (nonatomic, copy, nullable) JLLocalFilePlayerTimeCallback timeUpdateCallback;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) BOOL isPlaying;

@end

NS_ASSUME_NONNULL_END
