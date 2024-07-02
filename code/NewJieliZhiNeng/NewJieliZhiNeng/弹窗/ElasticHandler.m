//
//  ElasticHandler.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/5/27.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "ElasticHandler.h"
#import "JL_RunSDK.h"
#import "JLUI_Cache.h"
#import "AppStatusManager.h"

@interface ElasticHandler(){
    //JL_BLEUsage     *JL_ug;
    NSMutableArray  *blackList;
}

@end

@implementation ElasticHandler

+(id)sharedInstance{
    static ElasticHandler *ME = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        ME = [[self alloc] init];
    });
    return ME;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        blackList = [NSMutableArray new];
    }
    return self;
}



-(void)setToBlackList:(JL_EntityM *)entity{
    //NSLog(@"--->Set Blacklist Name:%@ Seq:%d",entity.mItem,entity.mSeq);
    if (entity.mType == JL_DeviceTypeTWS && entity.mProtocolType == PTLVersion) {
        //挂脖耳机类型不加入黑名单
        return;
    }
    [self addToBackList:entity];
}

-(void)addToBackList:(JL_EntityM *)entity{
    BlackMgr *black;
    for (BlackMgr *item in blackList) {
        if ([item.uuid isEqualToString:entity.mPeripheral.identifier.UUIDString]) {
            black = item;
            break;
        }
    }
    if (black) {
        black.seq = entity.mSeq;
        
    }else{
        black = [BlackMgr new];
        black.seq = entity.mSeq;
        black.uuid = entity.mPeripheral.identifier.UUIDString;
        [blackList addObject:black];
    }
}

-(void)removeToBlackList:(JL_EntityM *)entity{
    for (BlackMgr *item in blackList) {
        if ([item.uuid isEqualToString:entity.mPeripheral.identifier.UUIDString]) {
            [blackList removeObject:item];
            break;
        }
    }
    //NSLog(@"----> Rest Black List count:%lu",(unsigned long)blackList.count);
}



/// 判断是不是在黑名单里面
/// @param entity entity
/// @return bool YES:在黑名单，NO：不在黑名单
-(BOOL)isInBlackList:(JL_EntityM *)entity{

    BOOL ret = NO;
    for (BlackMgr *item in blackList) {
        if ([item.uuid isEqualToString:entity.mPeripheral.identifier.UUIDString]) {
            //挂脖耳机特殊处理，不再次判断刷新seq值，只要存在就一直不回回连
            if (entity.mType == JL_DeviceTypeTWS && entity.mProtocolType == PTLVersion) {
                return YES;
            }
            //NSLog(@"------>Name:%@  SEQ:%d  Black:%d",entity.mItem,entity.mSeq,item.seq);
            if (entity.mSeq > item.seq) {
                if (entity.mSeq - item.seq >= 5) {
                    /*--- 同步SEQ ---*/
                    NSLog(@"【%@】--->0 同步SEQ：%d ",entity.mItem,entity.mSeq);
                    [self setToBlackList:entity];
                }
                ret = NO;//可以弹窗
            }else{
                if (entity.mSeq <= 5 && item.seq > 5) {
                    /*--- 同步SEQ ---*/
                    NSLog(@"【%@】--->1 同步SEQ：%d ",entity.mItem,entity.mSeq);
                    [self setToBlackList:entity];
                }
                ret = YES;
            }
            
            break;
        }
    }
    //NSLog(@"------>Name:%@  Bound:%d",entity.mItem,ret);
    return ret;
}

@end


@implementation BlackMgr

@end
