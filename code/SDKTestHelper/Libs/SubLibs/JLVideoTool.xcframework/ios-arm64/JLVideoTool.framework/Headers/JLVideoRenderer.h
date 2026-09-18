//
//  JLVideoRenderer.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 视频帧渲染器，基于 AVSampleBufferDisplayLayer 将 CVPixelBuffer 渲染到 UIView
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@class JLVideoFrame;

/**
 视频帧渲染器

 @discussion
 基于 AVSampleBufferDisplayLayer 实现高效的视频帧渲染:
 - 内部维护一个 AVSampleBufferDisplayLayer 作为渲染层
 - 将 CVPixelBufferRef 包装为 CMSampleBuffer 后入队渲染
 - 渲染失败时自动 flush 并恢复
 - 支持暂停/恢复控制

 渲染层自动添加到 bindRenderView 的 layer 上，使用 AspectFit 模式。
 目标帧率影响 CMSampleBuffer 的 duration 计算，用于控制显示节奏。
 */
@interface JLVideoRenderer : NSObject

/// 绑定的渲染视图（弱引用）
@property (nonatomic, weak, readonly) UIView *renderView;

/// 目标帧率（fps），影响 CMSampleBuffer 的 duration，默认 30
@property (nonatomic, assign) int32_t targetFrameRate;

/// 是否正在渲染
@property (nonatomic, assign, readonly) BOOL isRendering;

/**
 绑定渲染视图并初始化

 @param view 用于显示视频的 UIView
 @return 渲染器实例
 @discussion 不会自动 start:，需手动调用
 */
- (instancetype)initWithRenderView:(UIView *)view;

/**
 启动渲染

 @param error 启动失败时返回错误信息
 @return YES 成功，NO 失败
 @discussion 创建 AVSampleBufferDisplayLayer 并添加到 renderView.layer 上
 */
- (BOOL)start:(NSError **)error;

/// 停止渲染，移除并释放 displayLayer
- (void)stop;

/**
 渲染一帧视频

 @param frame 视频帧对象（内部提取 pixelBuffer）
 */
- (void)renderFrame:(JLVideoFrame *)frame;

/**
 直接渲染像素缓冲

 @param pixelBuffer 像素缓冲（不会被 retain，调用方持有）
 @discussion 将 pixelBuffer 包装为 CMSampleBuffer 后入队到 AVSampleBufferDisplayLayer
 */
- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer;

/// 暂停渲染（flush displayLayer）
- (void)pause;

/// 恢复渲染
- (void)resume;

/// 更新渲染层 frame（在 renderView layoutSubviews 时调用）
- (void)layoutSubviews;

@end

NS_ASSUME_NONNULL_END
