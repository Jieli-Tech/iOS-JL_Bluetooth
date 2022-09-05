//
//  JLCacheBox.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/9/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "JLCacheBox.h"


@interface JLCacheBox(){
    NSMutableDictionary *cacheDict;
}

@end

@implementation JLCacheBox

static JLCacheBox *oneBox = nil;
+(id)Box{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        oneBox = [[self alloc] init];
    });
    return oneBox;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        cacheDict = [NSMutableDictionary new];
    }
    return self;
}

+(JLUI_Cache*)cacheUuid:(NSString*)uuid{
    [JLCacheBox Box];
    NSString *keyUUID = @"xxxx-xxxx-xxxx";
    if (uuid.length > 0) keyUUID = uuid;
    
    if (!oneBox->cacheDict[keyUUID]) {
        JLUI_Cache *cache = [[JLUI_Cache alloc] initWithUuid:keyUUID];
        [oneBox->cacheDict setObject:cache forKey:keyUUID];
    }
    JLUI_Cache *cache = oneBox->cacheDict[keyUUID];
    
    return cache;
}




@end
