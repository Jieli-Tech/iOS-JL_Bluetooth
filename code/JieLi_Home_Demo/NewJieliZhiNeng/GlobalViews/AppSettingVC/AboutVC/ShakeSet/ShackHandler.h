//
//  ShackHandler.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2021/1/27.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShackHandler : NSObject

+(instancetype)sharedInstance;

@property(nonatomic,assign) NSInteger index;

-(void)shackerHandle;

@end

NS_ASSUME_NONNULL_END
