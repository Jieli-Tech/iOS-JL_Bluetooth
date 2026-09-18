//
//  JLImagesToVideoGenerator.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/01/09.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 素材类型
 */
typedef NS_ENUM(NSUInteger, JLMediaType) {
    JLMediaTypeImage = 0,
    JLMediaTypeVideo
};

/**
 混合合成的素材项
 */
@interface JLMediaItem : NSObject

@property (nonatomic, assign, readonly) JLMediaType type;
@property (nonatomic, copy, readonly) NSString *path;

/// 显示时长（秒）。
/// - 图片：必须 > 0
/// - 视频：若 <= 0 则使用视频原始时长；若 > 0 则截取/循环/快进到该时长（当前实现为截取或播完停止）
@property (nonatomic, assign) NSTimeInterval duration;

+ (instancetype)itemWithImagePath:(NSString *)path duration:(NSTimeInterval)duration;
+ (instancetype)itemWithVideoPath:(NSString *)path; // 默认时长为0（表示完整播放）

@end

/**
 图片缩放模式
 */
typedef NS_ENUM(NSUInteger, JLImageScaleMode) {
    /// 拉伸填满 (可能变形) - 默认
    JLImageScaleModeScaleToFill = 0,
    /// 保持比例适应 (可能有留白/黑边)
    JLImageScaleModeAspectFit,
    /// 保持比例填充 (裁剪多余部分，居中)
    JLImageScaleModeAspectFill,
    /// 原始比例，从左上角对齐裁剪/留白
    JLImageScaleModeTopLeftCrop
};

/**
 时长适配策略（当素材总长 > 目标时长时）
 */
typedef NS_ENUM(NSUInteger, JLDurationAdaptationMode) {
    /// 抽帧加速 (默认)：保持内容完整，加速播放
    JLDurationAdaptationModeSpeedUp = 0,
    /// 尾部裁剪：保持原速，裁剪掉多余的尾部（优先裁剪视频）
    JLDurationAdaptationModeTrim
};

/**
 图片转视频配置选项
 */
@interface JLImageToVideoOptions : NSObject

/// 目标视频尺寸。若为 CGSizeZero，则使用第一张图片的尺寸。
@property (nonatomic, assign) CGSize targetSize;

/// 图片缩放模式，默认 JLImageScaleModeScaleToFill
@property (nonatomic, assign) JLImageScaleMode contentMode;

/// 留白时的背景色，默认黑色
@property (nonatomic, strong) UIColor *backgroundColor;

/// 编码质量（近似常量量化参数语义，数值越小质量越高）。默认 28。
@property (nonatomic, assign) NSInteger quality;

/// 时长适配策略（仅当指定了 duration 且素材过长时生效）。默认 SpeedUp。
@property (nonatomic, assign) JLDurationAdaptationMode adaptationMode;

+ (instancetype)defaultOptions;

@end

/**
 JLImagesToVideoGenerator
 将多张图片合并生成 MP4 视频
 
 功能特性：
 - 支持 jpg/png 等图片输入
 - 支持 视频 混排
 - 指定 fps 和总时长
 - 支持自定义分辨率和多种图片缩放模式
 */
@interface JLImagesToVideoGenerator : NSObject

/**
 将多张图片合并为视频
 
 @param imagePaths 图片文件的绝对路径数组 (有序)
 @param outputPath 视频输出路径 (以 .mp4 结尾)
 @param fps        帧率 (例如 30)
 @param duration   视频总时长 (秒)
 @param options    配置选项 (可选，传 nil 使用默认值)
 @param progress   进度回调 (0.0 - 1.0)
 @param completion 完成回调 (success, errorMsg)
 */
+ (void)generateVideoFromImages:(NSArray<NSString *> *)imagePaths
                     outputPath:(NSString *)outputPath
                            fps:(int)fps
                       duration:(NSTimeInterval)duration
                        options:(JLImageToVideoOptions * _Nullable)options
                       progress:(void(^ _Nullable)(float progress))progress
                     completion:(void(^ _Nullable)(BOOL success, NSString * _Nullable errorMsg))completion;

/**
 将混合素材（图片/视频）合并为视频
 
 @param items      素材列表 (JLMediaItem 数组，有序)
 @param outputPath 视频输出路径
 @param fps        目标帧率
 @param duration   目标总时长（<=0 表示不限制，由素材自动累加）。若指定时长与素材总长不符，将自动调整素材时长（视频抽帧/图片延长）。
 @param options    配置选项
 @param progress   进度回调
 @param completion 完成回调
 */
+ (void)generateVideoFromAssets:(NSArray<JLMediaItem *> *)items
                     outputPath:(NSString *)outputPath
                            fps:(int)fps
                       duration:(NSTimeInterval)duration
                        options:(JLImageToVideoOptions * _Nullable)options
                       progress:(void(^ _Nullable)(float progress))progress
                     completion:(void(^ _Nullable)(BOOL success, NSString * _Nullable errorMsg))completion;

/// 将多张图片合并为 GIF 动画
/// @param imagePaths 图片文件的绝对路径数组 (有序)
/// @param outputPath GIF 输出路径 (以 .gif 结尾)
/// @param duration   GIF 总时长 (秒)
/// @param completion 完成回调 (success, errorMsg)
+ (void)generateGifFromImages:(NSArray<NSString *> *)imagePaths
                   outputPath:(NSString *)outputPath
                     duration:(NSTimeInterval)duration
                   completion:(void(^ _Nullable)(BOOL success, NSString * _Nullable errorMsg))completion;

/// 将多张图片合并为 GIF 动画 (支持配置)
/// @param imagePaths 图片文件的绝对路径数组 (有序)
/// @param outputPath GIF 输出路径 (以 .gif 结尾)
/// @param duration   GIF 总时长 (秒)
/// @param options    配置选项 (可选，传 nil 使用默认值/原图尺寸)
/// @param completion 完成回调 (success, errorMsg)
+ (void)generateGifFromImages:(NSArray<NSString *> *)imagePaths
                   outputPath:(NSString *)outputPath
                     duration:(NSTimeInterval)duration
                      options:(JLImageToVideoOptions * _Nullable)options
                   completion:(void(^ _Nullable)(BOOL success, NSString * _Nullable errorMsg))completion;

/// 将 GIF 动画按目标总时长重定时后生成新的 GIF
/// @param inputPath  GIF 输入路径 (以 .gif 结尾)
/// @param outputPath GIF 输出路径 (以 .gif 结尾)
/// @param duration   目标总时长 (秒)
/// @param completion 完成回调 (success, errorMsg)
+ (void)generateGifFromGif:(NSString *)inputPath
                 outputPath:(NSString *)outputPath
                   duration:(NSTimeInterval)duration
                 completion:(void(^ _Nullable)(BOOL success, NSString * _Nullable errorMsg))completion;

@end

NS_ASSUME_NONNULL_END
