//
//  JLAniConverter.h
//  ConvertCase
//
//  Created by EzioChan on 2025/8/19.
//
#import <Foundation/Foundation.h>
#import <JLBmpConvertKit/JLBmpConvertKit.h>

NS_ASSUME_NONNULL_BEGIN

#define JL_VIDEO_TOOL_VERSION   @"1.0.0_Beta1_20251015"

/// 转换配置选项
@interface JLAniConvertOptions : NSObject

/// 输出视频宽度 (像素)，<=0 则可能沿用原始宽度或默认值
@property (nonatomic, assign) int width;

/// 输出视频高度 (像素)，<=0 则可能沿用原始高度或默认值
@property (nonatomic, assign) int height;

/// 输出视频帧率 (fps)，建议 10-30
@property (nonatomic, assign) int fps;

/// 视频质量 (范围 2–31；数值越小质量越高、体积越大)
/// 对于 convertGifToGif，此参数映射到 palettegen 的 stats_mode (full/diff) 的某种内部逻辑
@property (nonatomic, assign) int quality;

// MARK: - GIF Optimization Specific (仅用于 convertGifToGif)

/// 目标颜色数量 (2-256)，推荐 2 的幂 (16, 32, 64, 128, 256)
@property (nonatomic, assign) int colors;

/// 抖动模式: "none", "bayer"
@property (nonatomic, copy) NSString *ditherMode;

/// Bayer 抖动强度 (0-5)，默认 3
@property (nonatomic, assign) int bayerScale;

/// 创建默认配置
+ (instancetype)defaultOptions;

@end

/// 转换工具
@interface JLAniConverter : NSObject

/// MP4 转换 ani 
/// @param inputPath 输入视频路径(限制 mp4）
/// @param outputPath 输出视频路径
/// @param options 配置选项
/// @param progressBlock 进度回调
/// @param completion 完成回调（0 成功，其他失败）
+ (void)convertMp4ToAni:(NSString *)inputPath
             outputPath:(NSString *)outputPath
                options:(JLAniConvertOptions *)options
               progress:(void(^ _Nullable)(float))progressBlock
             completion:(void(^)(int result))completion;

/// MP4 转换 ani
/// @param inputPath 输入视频路径(限制 mp4）
/// @param outputPath 输出视频路径
/// @param width 输出视频宽度
/// @param height 输出视频高度
/// @param fps 输出视频帧率
/// @param progressBlock 进度回调
/// @param completion 完成回调（0 成功，其他失败）
+ (void)convertMp4ToAni:(NSString *)inputPath
          outputPath:(NSString *)outputPath
               width:(int)width
              height:(int)height
                 fps:(int)fps
            progress:(void(^ _Nullable)(float))progressBlock
          completion:(void(^)(int result))completion;



/// mp4 转换 AVI
/// @param inputPath 输入视频路径(限制 mp4）
/// @param outputPath 输出视频路径
/// @param options 配置选项
/// @param progressBlock 进度回调
/// @param completion 完成回调（0 成功，其他失败）
+ (void)convertMp4ToAVI:(NSString *)inputPath
             outputPath:(NSString *)outputPath
                options:(JLAniConvertOptions *)options
               progress:(void(^ _Nullable)(float))progressBlock
             completion:(void(^)(int result))completion;

/// mp4 转换 AVI
/// @param inputPath 输入视频路径(限制 mp4）
/// @param outputPath 输出视频路径
/// @param width 宽
/// @param height 高
/// @param fps fps
/// @param quality MJPEG 视频质量（范围 2–31；数值越小质量越高、体积越大）
/// @param progressBlock 进度回调
/// @param completion 完成回调（0 成功，其他失败）
+ (void)convertMp4ToAVI:(NSString *)inputPath
          outputPath:(NSString *)outputPath
               width:(int)width
              height:(int)height
                 fps:(int)fps
             quality:(int)quality
            progress:(void(^ _Nullable)(float))progressBlock
          completion:(void(^)(int result))completion;


/// GIF转换成 AVI 
/// @param inputPath 输入GIF路径
/// @param outputPath 输出AVI路径
/// @param options 配置选项
/// @param completion 完成回调（0 成功，其他失败）
+ (void)convertGifToAVI:(NSString *)inputPath
        outputPath:(NSString *)outputPath
             options:(JLAniConvertOptions *)options
        completion:(void(^)(int result))completion;

/// GIF转换成 AVI
/// @param inputPath 输入GIF路径
/// @param outputPath 输出AVI路径
/// @param width 输出视频宽度
/// @param height 输出视频高度
/// @param fps 输出视频帧率
/// @param quality MJPEG 视频质量（范围 2–31；数值越小质量越高、体积越大）
/// @param completion 完成回调（0 成功，其他失败）
+ (void)convertGifToAVI:(NSString *)inputPath
        outputPath:(NSString *)outputPath
             width:(int)width
            height:(int)height
               fps:(int)fps
           quality:(int)quality
        completion:(void(^)(int result))completion;


/// 转换GIF到ANI (带 Options)
/// @param inputPath 输入GIF路径
/// @param outputPath 输出ANI路径
/// @param options 配置选项
/// @param progressBlock 进度回调
/// @param completion 完成回调（0 成功，其他失败）
+ (void)convertGifToAni:(NSString *)inputPath
             outputPath:(NSString *)outputPath
                  options:(JLAniConvertOptions *)options
               progress:(void(^ _Nullable)(float progress))progressBlock
             completion:(void(^)(int result))completion;

/// 转换GIF到ANI（可调视频质量）
/// @param inputPath 输入GIF路径
/// @param outputPath 输出ANI路径
/// @param width 输出视频宽度
/// @param height 输出视频高度
/// @param fps 输出视频帧率
/// @param quality 视频质量（以量化参数近似，范围 2–31；数值越小质量越高、体积越大）
/// @param progressBlock 进度回调
/// @param completion 完成回调（0 成功，其他失败）
+ (void)convertGifToAni:(NSString *)inputPath
             outputPath:(NSString *)outputPath
                  width:(int)width
                 height:(int)height
                    fps:(int)fps
                 quality:(int)quality
               progress:(void(^ _Nullable)(float progress))progressBlock
             completion:(void(^)(int result))completion;


/// 转换GIF To Res
/// @param data Gif 的数据
/// @param level 等级
///          1: 低码率
///          2: 中码率 (仅 JLGIFBinChipJL_701N 支持）
///          3: 高码率 (仅 JLGIFBinChipJL_701N 支持）
/// @param chip 芯片类型
/// @param packageType 打包类型
///          1: JLUI 杰理 UI 格式
///          0: 无 不打包
/// @param block 回调内容
+(void)convertGifToRes:(NSData *)data
                 Level:(int)level
              ChipType:(JLGIFBinChipType)chip
           PackageType:(JLGIFBinPackageType)packageType
                Result:(JLGif2BinBlock)block;

/// 严格颜色数量控制的 GIF 优化 
/// 支持抖动参数与质量控制，确保输出精确达到目标 colors 数量并优化体积。
/// @param inputPath GIF 输入路径
/// @param outputPath GIF 输出路径（结果仍为 GIF）
/// @param options 配置选项 (width, height, fps, colors, ditherMode, bayerScale, quality)
/// @param completion 完成回调（0 成功，其他失败）
+ (void)convertGifToGif:(NSString *)inputPath
            outputPath:(NSString *)outputPath
                 options:(JLAniConvertOptions *)options
            completion:(void(^)(int result))completion;

/// 严格颜色数量控制的 GIF 优化
/// 支持抖动参数与质量控制，确保输出精确达到目标 colors 数量并优化体积。
/// @param inputPath GIF 输入路径
/// @param outputPath GIF 输出路径（结果仍为 GIF）
/// @param width 输出宽度（像素），<=0 则沿用原始宽度
/// @param height 输出高度（像素），<=0 则沿用原始高度
/// @param fps 目标帧率（建议 10–30，范围将被钳制到 1–60）
/// @param colors 目标颜色数量（严格控制，范围 2–256）
/// - 定义输出 GIF 的调色板大小（颜色总数）
/// - 数值越小，文件体积通常越小，但会增加颜色量化导致的“断层”（颜色过渡不平滑,锯齿）；数值越大，画面更接近原图但文件可能更大。
/// - 推荐值按内容选择：像素风格/图标建议 16/32；一般动画建议 64/128；复杂或色彩丰富的画面可选 256。
/// - 常用是 2 的幂（16、32、64、128、256），有利于量化质量和兼容性。
/// @param ditherMode 抖动模式：可选 "none"、"bayer"；默认 "bayer"
/// - 定义在应用调色板时是否使用抖动来缓解量化带来的色带与断层问题。
/// - "none" 表示不使用抖动，可能导致颜色过渡不连续（“断层”）。
/// - "bayer" 表示使用 Bayer 抖动，能有效减少“断层”但可能引入颜色平滑度问题（“色带”）。
/// @param bayerScale bayer 抖动强度（0–5，默认 3），仅当 ditherMode 为 "bayer" 时有效
/// - 定义 Bayer 抖动的强度，数值越大抖动越明显（可能导致“色带”），建议范围 2–4。
/// - 推荐值按内容选择：简单动画/图标建议 3；复杂动画/色彩丰富画面建议 4。
/// @param quality 质量参数（2–31，数值越小质量越高），映射到 palettegen 的 stats_mode（full/diff）
/// - 定义生成调色板时的统计模式，影响颜色选择和量化效果。
/// - "full" 表示全局统计，考虑所有像素，可能导致全局颜色量化。
/// - "diff" 表示差异统计，仅考虑变化区域，可能导致局部颜色量化。
/// - 推荐值按内容选择：简单动画/图标建议 "full"；复杂动画/色彩丰富画面建议 "diff"。
/// @param completion 完成回调（0 成功，其他失败）
+ (void)convertGifToGif:(NSString *)inputPath
            outputPath:(NSString *)outputPath
                 width:(int)width
                height:(int)height
                   fps:(int)fps
                colors:(int)colors
            ditherMode:(NSString *)ditherMode
            bayerScale:(int)bayerScale
               quality:(int)quality
            completion:(void(^)(int result))completion;

@end

NS_ASSUME_NONNULL_END


