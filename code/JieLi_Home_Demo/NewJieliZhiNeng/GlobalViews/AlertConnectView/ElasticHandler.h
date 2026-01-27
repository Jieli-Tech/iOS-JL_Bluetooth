//
//  ElasticHandler.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/5/27.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ElasticHandler : NSObject
@property (strong,nonatomic)JL_EntityM * __nullable nowEntity;
+(id)sharedInstance;
-(BOOL)isInBlackList:(JL_EntityM *)entity;
-(void)setToBlackList:(JL_EntityM *)entity;
-(void)addToBackList:(JL_EntityM *)entity;
-(void)removeToBlackList:(JL_EntityM *)entity;
@end

@interface BlackMgr : NSObject
@property(nonatomic,strong)NSString *uuid;
@property(nonatomic,assign)uint8_t seq;
@end

NS_ASSUME_NONNULL_END
