//
//  JLVideoProcessingModels.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/01/08.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Models

/**
 裁剪范围模型
 - 用途：用于 crop 滤镜（crop=w:h:x:y）的参数描述
 - 坐标系：以输入视频帧的像素坐标系为准；原点位于左上角，x 向右增大，y 向下增大
 - 边界与约束：建议 width/height 使用偶数以适配多数编码器,越界参数将导致报错或被自动裁剪
 */
@interface JLCropRegion : NSObject
/// 裁剪矩形左上角的 X 坐标（像素，>=0，建议满足 0 <= x <= 原始宽度 - width）
@property (nonatomic, assign) NSInteger x;
/// 裁剪矩形左上角的 Y 坐标（像素，>=0，建议满足 0 <= y <= 原始高度 - height）
@property (nonatomic, assign) NSInteger y;
/// 裁剪矩形的宽度（像素，>0，建议为偶数以便编码器对齐）
@property (nonatomic, assign) NSInteger width;
/// 裁剪矩形的高度（像素，>0，建议为偶数以便编码器对齐）
@property (nonatomic, assign) NSInteger height;

/// 创建一个新的裁剪范围实例
/// @param x 裁剪矩形左上角的 X 坐标（像素，>=0，建议满足 0 <= x <= 原始宽度 - width）
/// @param y 裁剪矩形左上角的 Y 坐标（像素，>=0，建议满足 0 <= y <= 原始高度 - height）
/// @param width 裁剪矩形的宽度（像素，>0，建议为偶数以便编码器对齐）
/// @param height 裁剪矩形的高度（像素，>0，建议为偶数以便编码器对齐）
+ (instancetype)regionWithX:(NSInteger)x y:(NSInteger)y width:(NSInteger)width height:(NSInteger)height;
@end

/**
 缩放模式枚举
 - keepAspect：按比例对原始尺寸等比缩放（基于 ratio）
 - fixedResolution：缩放到明确指定的分辨率（targetSize）
 - percentage：按百分比缩放到原始尺寸的百分比（percentage）
 */
typedef NS_ENUM(NSUInteger, JLScaleMode) {
    JLScaleModeKeepAspect,      // 等比缩放 (使用 ratio 或 目标边长)
    JLScaleModeFixedResolution, // 指定分辨率
    JLScaleModePercentage       // 百分比缩放
};

/**
 缩放规则模型
 - 用途：用于 FFmpeg scale 滤镜（scale=out_w:out_h[:flags]）的参数描述
 - 仅在对应模式下读取有效属性：
   - KeepAspect 使用 ratio（>0）
   - FixedResolution 使用 targetSize（width/height >0）
   - Percentage 使用 percentage（>0，例如 0.75 表示缩到 75%）
 - 算法选择：实现层默认使用 bicubic 或 lanczos，可根据质量与性能需求动态调整
 */
@interface JLScaleRule : NSObject
/// 缩放模式（决定使用 ratio/targetSize/percentage 的哪一种参数）
@property (nonatomic, assign) JLScaleMode mode;
/// 等比缩放比例（>0，例如 0.5 表示缩小到一半；仅在 KeepAspect 模式下生效）
@property (nonatomic, assign) double ratio;
/// 指定分辨率的目标尺寸（width/height >0；仅在 FixedResolution 模式下生效）
@property (nonatomic, assign) CGSize targetSize;
/// 百分比缩放（>0，例如 0.75 表示缩放到 75% 原始尺寸；仅在 Percentage 模式下生效）
@property (nonatomic, assign) CGFloat percentage;

/// 创建一个新的缩放规则实例（等比缩放）
/// @param ratio 等比缩放比例（>0，例如 0.5 表示缩小到一半）
+ (instancetype)ruleWithRatio:(double)ratio;
/// 创建一个新的缩放规则实例（指定分辨率）
/// @param size 指定分辨率的目标尺寸（width/height >0）
+ (instancetype)ruleWithResolution:(CGSize)size;
/// 创建一个新的缩放规则实例（百分比缩放）
/// @param percentage 百分比缩放（>0，例如 0.75 表示缩放到 75% 原始尺寸）
+ (instancetype)ruleWithPercentage:(CGFloat)percentage;
@end

/**
 时长控制模型
 - 用途：用于 FFmpeg trim 滤镜（视频 trim 与音频 atrim）
 - 取值规则：优先使用 startTime/endTime；若 endTime <= startTime 且提供了 duration，则采用 startTime + duration 作为结束时间
 - 时间单位：秒；实现层会转换为 FFmpeg 所需的参数，并通过 setpts/asetpts 保证时间戳连续
 */
@interface JLDurationControl : NSObject
/// 开始时间（秒，>=0），用于裁剪起点；未设置时默认从 0 开始
@property (nonatomic, assign) double startTime;
/// 结束时间（秒，>startTime），用于裁剪终点；未设置但提供了 duration 时由 startTime + duration 推导
@property (nonatomic, assign) double endTime;
/// 持续时长（秒，>0），与 startTime 组合使用以推导 endTime；二选一场景可仅设置 startTime 与 duration
@property (nonatomic, assign) double duration;

/// 创建一个新的时长控制实例（指定开始时间与结束时间）
/// @param start 开始时间（秒，>=0）
/// @param end 结束时间（秒，>start）
+ (instancetype)controlWithStart:(double)start end:(double)end;
/// 创建一个新的时长控制实例（指定开始时间与持续时长）
/// @param start 开始时间（秒，>=0）
/// @param duration 持续时长（秒，>0）
+ (instancetype)controlWithStart:(double)start duration:(double)duration;

@end

/**
 视频处理配置模型（聚合）
 - 用途：统一描述一次处理的所有滤镜参数（裁剪、缩放、时长）与帧率重置
 - 为空策略：
   - crop 为空：不进行画面裁剪
   - scale 为空：保持原始分辨率
   - duration 为空：处理整段视频（不做时长裁剪）
   - outputFPS <= 0：沿用输入帧率或由滤镜/编码器自动推导
 */
@interface JLVideoProcessingConfig : NSObject
/// 裁剪范围配置；为空表示不裁剪
@property (nonatomic, strong, nullable) JLCropRegion *crop;
/// 缩放规则配置；为空表示保持原始分辨率
@property (nonatomic, strong, nullable) JLScaleRule *scale;
/// 时长控制配置；为空表示全时长处理
@property (nonatomic, strong, nullable) JLDurationControl *duration;
/// 输出帧率（>0 时应用 fps 滤镜重置帧率；<=0 表示沿用输入或由编码器推导）
@property (nonatomic, assign) NSInteger outputFPS;

+ (instancetype)config;
@end

NS_ASSUME_NONNULL_END
