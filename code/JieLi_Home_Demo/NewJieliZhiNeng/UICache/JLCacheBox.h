//
//  JLCacheBox.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/9/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JLUI_Cache.h"

NS_ASSUME_NONNULL_BEGIN
@class JLUI_Cache;
@interface JLCacheBox : NSObject
+(JLUI_Cache*)cacheUuid:(NSString*)uuid;
@end

NS_ASSUME_NONNULL_END
