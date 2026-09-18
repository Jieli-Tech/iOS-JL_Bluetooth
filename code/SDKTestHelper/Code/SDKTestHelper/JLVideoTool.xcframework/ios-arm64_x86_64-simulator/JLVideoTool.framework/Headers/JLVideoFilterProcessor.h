//
//  JLVideoFilterProcessor.h
//  JLVideoTool
//
//  Created by EzioChan on 2024/01/08.
//

#import <Foundation/Foundation.h>
#import <JLVideoTool/JLVideoTool.h>

NS_ASSUME_NONNULL_BEGIN

/// 视频滤镜处理类
/// 提供视频裁剪、缩放、时长裁剪等滤镜处理功能
@interface JLVideoFilterProcessor : NSObject

/// 处理视频（裁剪、缩放、时长裁剪）
/// @param inputPath 输入路径
/// @param outputPath 输出路径
/// @param config 处理配置
/// @param progressCallback 进度回调 (0.0 - 1.0)
/// @param completion 完成回调 (YES/NO, errorMsg)
+ (void)processVideo:(NSString *)inputPath
              output:(NSString *)outputPath
              config:(JLVideoProcessingConfig *)config
            progress:(void(^_Nullable)(float progress))progressCallback
          completion:(void(^_Nullable)(BOOL success, NSString * _Nullable errorMsg))completion;

@end

NS_ASSUME_NONNULL_END
