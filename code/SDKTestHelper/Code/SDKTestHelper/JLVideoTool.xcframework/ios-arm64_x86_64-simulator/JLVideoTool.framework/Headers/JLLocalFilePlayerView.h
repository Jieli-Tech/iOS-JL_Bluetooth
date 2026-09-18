//
//  JLLocalFilePlayerView.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/5/22.
//  Copyright © 2026 www.zh-jieli.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JLLocalFilePlayerDelegate;

NS_ASSUME_NONNULL_BEGIN

typedef void (^JLLocalFilePlayerViewTimeCallback)(NSTimeInterval currentTime, NSTimeInterval duration);

@interface JLLocalFilePlayerView : UIView

- (void)loadFile:(NSString *)filePath;
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)time;
- (void)updateRenderViewFrame:(CGRect)frame;

@property (nonatomic, weak, nullable) id<JLLocalFilePlayerDelegate> playerDelegate;
@property (nonatomic, copy, nullable) JLLocalFilePlayerViewTimeCallback timeUpdateCallback;
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, assign) BOOL showControls;
@property (nonatomic, assign) float volume;

@end

NS_ASSUME_NONNULL_END
