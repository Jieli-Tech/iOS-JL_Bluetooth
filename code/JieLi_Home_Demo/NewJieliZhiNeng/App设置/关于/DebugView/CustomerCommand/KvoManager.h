//
//  KvoManager.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/1/6.
//  Copyright © 2023 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KvoManager : NSObject

+(instancetype)share;

-(void)startListen;
-(void)requestEq;

@end

NS_ASSUME_NONNULL_END
