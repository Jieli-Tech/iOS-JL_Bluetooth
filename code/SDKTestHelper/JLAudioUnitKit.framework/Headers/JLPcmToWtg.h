//
//  JLPcmToWtg.h
//  JLAudioUnitKit
//
//  Created by EzioChan on 2025/1/21.
//  Copyright © 2025 ZhuHai JieLi Technology Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JLPcm2WtgModel : NSObject <NSCopying>

/// 音频文件
@property (nonatomic, copy) NSString *pcmPath;

/// 输出文件
@property (nonatomic, copy) NSString *wtgPath;

@end


/// JLPcmToWtgProtocol
@protocol JLPcmToWtgDelegate <NSObject>

/// 音频转码完成
/// - Parameter model: 音频转码模型
- (void)convertPcmToWtgDone:(JLPcm2WtgModel *)model;

@end

/// 音频转码
/// PCM 转 WTG
@interface JLPcmToWtg : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// 音频转码初始化
/// - Parameter delegate: 音频转码代理
- (instancetype)initWithDelegate:(id<JLPcmToWtgDelegate>)delegate;

/// 音频转码
/// 当前接口模型只限制 PCM 文件格式为：8k 16bit
/// 输入的pcm文件（16bit,小端，8k采样率），wtg_filename：输出的wtg文件
/// - Parameter model: 音频转码模型
-(void)convertPcmToWtg:(JLPcm2WtgModel *)model;

@end

NS_ASSUME_NONNULL_END
