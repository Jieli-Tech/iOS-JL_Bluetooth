//
//  JLAuracastMetaModel.h
//  JLAuracastKit
//
//  Created by EzioChan on 2024/8/27.
//  Copyright © 2024 Zhuhai Jieli Technology Co.，Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, JLMetaParentalRatingType) {
//    0x00: no rating Bits 0-3 Value representing the
//    parental rating.
//    0x01: recommended for
//    listeners of any age
//    Other values: recommended
//    for listeners of age Y years,
//    where Y = value + 3 years.
//    e.g., 0x05 = recommended
//    for listeners of 8 years or
//    older.
    /// 无评级
    JLMetaParentalRatingTypeNone = 0x00,
    /// 有评级
    JLMetaParentalRatingTypeRecommended = 0x01
};

/// 音频上下文
typedef NS_ENUM(NSUInteger, JLAuracastCodecContextType) {
    /// Prohibited
    /// 禁止使用
    JLAuracastCodecContextTypeProhibited = 0x0000,
    ///Identifies audio where the use case context does not match any other defined value, or where the context is unknown or cannot be determined.
    ///未定义
    JLAuracastCodecContextTypeUnspecified = 0x0001,
    ///Conversation between humans, for example, in telephony or video calls, including traditional cellular as well as VoIP and Push-to-Talk
    ///对话
    JLAuracastCodecContextTypeConversational = 0x0002,
    ///Media, for example, music playback, radio, podcast or movie soundtrack, or tv audio
    ///媒体
    JLAuracastCodecContextTypeMedia = 0x0004,
    ///Audio associated with video gaming, for example gaming media; gaming effects; music and in-game voice chat between participants; or a mix of all the above
    ///游戏
    JLAuracastCodecContextTypeGame = 0x0008,
    ///Instructional audio, for example, in navigation, announcements, or user guidance
    ///指令
    JLAuracastCodecContextTypeInstructional = 0x0010,
    ///Man-machine communication, for example, with voice recognition or virtual assistants
    ///人机交互
    JLAuracastCodecContextTypeVoiceAssistants = 0x0020,
    ///Live audio, for example, from a microphone where audio is perceived both through a direct acoustic path and through an LE Audio Stream
    ///直播
    JLAuracastCodecContextTypeLive = 0x0040,
    ///Sound effects including keyboard and touch feedback; menu and user interface sounds; and other system sound
    ///音效
    JLAuracastCodecContextTypeSoundEffects = 0x0080,
    ///Notification and reminder sounds; attention-seeking audio, for example, in beeps signaling the arrival of a message
    ///通知
    JLAuracastCodecContextTypeNotifications = 0x0100,
    ///Incoming call, for example, an incoming telephony or video call, including traditional cellular as well as VoIP and Push-to-Talk
    ///呼入
    JLAuracastCodecContextTypeRingtone = 0x0200,
    ///Alerts, for example, in a critical battery alarm, timer expiry or alarm clock, toaster, cooker, kettle, microwave, etc.
    ///警报
    JLAuracastCodecContextTypeAlerts = 0x0400,
    ///Emergency alarm, for example, fire alarms or other urgent alerts
    ///紧急
    JLAuracastCodecContextTypeEmergency = 0x0800
};


/// 节目元数据
@interface JLAuracastMetaModel : NSObject

/// 首选音频上下文
/// Preferred Audio Context
@property (nonatomic, assign) JLAuracastCodecContextType preferredAudioContexts;

/// 流式音频上下文
/// Streaming Audio Context
@property (nonatomic, assign) JLAuracastCodecContextType streamingAudioContexts;

/// 节目信息
/// Title and/or summary of Audio Stream
/// content: UTF-8 format
@property (nonatomic, strong) NSString *programInfo;

/// 语言
/// iSO-639-3 Language
@property (nonatomic, strong) NSString *language;


@property (nonatomic, strong) NSArray *ccids;

/// 家长指引，节目评级
/// Parental Rating
@property (nonatomic, assign)JLMetaParentalRatingType parentalRating;


/// Program Info URI
/// UTF-8格式的URL链接用于提供有关的更多节目信息
/// content: UTF-8 formatA UTF-8 formatted URL link used to
/// present more information about Program_Info
/// e.g.,
@property (nonatomic, strong)NSString *programInfoURI;


/// Audio Data Is Transmitted or not
/// 是否已在传输音频数据
@property (nonatomic, assign)BOOL audioDataIsTransmitted;

/// 广播音频即时渲染延迟
/// Broadcast_Audio_Immediate_Rendering_Flag
/// 0x00 – Zero length
@property (nonatomic, assign)uint8_t broadcastAudioImmediateRenderingFlag;

/// Assist Listen Stream
/// Listening Stream method
/// 0x00 – unspecified audio
/// 监听流方法
/// 0x00–未指定的音频
@property (nonatomic, assign)uint8_t assistListenStream;

/// 广播名称
/// Broadcast Name
@property (nonatomic, strong)NSString *broadcastName;

/// Extended_Metadata
/// 扩展的数据类型
/// TYPT: 0xFE
/// Octet 0–1: Extended Metadata Type
/// Octet 2–254: Extended Metadata
@property (nonatomic, strong) NSData *extendedData;


/// vendor id
/// 蓝牙的提供者公司 ID
@property (nonatomic, assign) uint16_t vendorID;

/// Vendor-Specific Metadata
/// Vendor-Specific Metadata
/// 扩展的 Vendeor 数据
@property (nonatomic, strong) NSData * vendorSpecificMetaData;

/// 基础数据
@property (nonatomic, strong)NSData *baseData;

- (instancetype)initWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
