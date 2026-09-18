//
//  JLPlayerDebugView.h
//  JLVideoTool
//
//  Created by EzioChan on 2026/4/30.
//  Copyright © 2026 EzioChan. All rights reserved.
//
//  功能描述: 播放器调试视图，提供调试信息的可视化展示，
//           包括实时统计标签、日志输出面板和控制按钮
//

#import <UIKit/UIKit.h>
#import <JLVideoTool/JLPlayerTypes.h>

@class JLPlayerView;

NS_ASSUME_NONNULL_BEGIN

/**
 播放器调试视图

 @discussion
 提供调试信息的可视化展示，包括:
 - 统计信息面板: 视频/音频/系统实时统计数据
 - 日志输出面板: 带颜色标识的日志列表
 - 控制按钮区: 清空日志、导出报告等操作

 支持三种显示样式:
 - Minimal: 仅显示关键指标（帧率、缓存、同步偏移）
 - Detailed: 显示完整统计信息
 - Graph: 显示性能曲线（当前版本预留）

 通过 addLogMessage:level:category: 添加日志条目，
 通过 updateStatistics: 更新统计数据显示。
 */
@interface JLPlayerDebugView : UIView

/**
 初始化调试视图

 @param frame 视图帧
 @param playerView 关联的播放器视图
 @return 调试视图实例
 */
- (instancetype)initWithFrame:(CGRect)frame playerView:(JLPlayerView *)playerView;

/// 调试浮层样式，默认 JLDebugOverlayStyleMinimal
@property (nonatomic, assign) JLDebugOverlayStyle style;

/// 是否自动滚动日志，默认 YES
@property (nonatomic, assign) BOOL autoScrollLog;

/// 最大显示日志条数，默认 100
@property (nonatomic, assign) NSInteger maxLogEntries;

/**
 添加日志条目

 @param message 日志内容
 @param level 日志级别
 @param category 日志类别（如 "Video", "Audio", "Sync"）
 */
- (void)addLogMessage:(NSString *)message
                level:(JLLogLevel)level
             category:(NSString *)category;

/**
 更新统计数据显示

 @param statistics 统计字典，key 为统计项名称，value 为数值
 */
- (void)updateStatistics:(NSDictionary<NSString *, id> *)statistics;

/**
 设置日志显示过滤器

 @param level 最低显示级别（低于此级别的日志不显示）
 @param categories 类别筛选数组，nil 或空数组表示不过滤
 */
- (void)setLogFilterLevel:(JLLogLevel)level categories:(nullable NSArray<NSString *> *)categories;

/// 清空日志显示
- (void)clearLogs;

/// 导出当前日志（返回格式化后的文本）
- (NSString *)exportLogs;

@end

NS_ASSUME_NONNULL_END
