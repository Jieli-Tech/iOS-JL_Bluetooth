//
//  AlarmObject.h
//  CMD_APP
//
//  Created by Ezio on 2018/2/28.
//  Copyright © 2018年 DFung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmObject : NSObject

@property(nonatomic,assign)uint8_t  index;
@property(nonatomic,assign)uint8_t  hour;
@property(nonatomic,assign)uint8_t  min;
@property(nonatomic,assign)uint8_t  state;
@property(nonatomic,assign)uint8_t  mode;
@property(nonatomic,strong)NSArray  *repeatMode;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSData *reserved;

/**
根据Data内容转换成对象

 @param baseData 基本内容
 @return 闹钟信息对象
 */
+(AlarmObject *)alarmClockDataToObject:(NSData *)baseData;

+(NSString*)stringMode:(uint8_t)mode;

+(NSArray*)stringsMode:(uint8_t)mode;
@end
