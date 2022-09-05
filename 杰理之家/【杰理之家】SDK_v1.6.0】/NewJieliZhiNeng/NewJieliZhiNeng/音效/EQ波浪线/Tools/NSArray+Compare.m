//
//  NSArray+Compare.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2021/4/23.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "NSArray+Compare.h"

@implementation NSArray (Compare)

-(BOOL)isSame:(NSArray *)array{
    if (array.count == self.count) {
        BOOL rec = NO;
        for (int k = 0; k<self.count; k++) {
            if ([array[k] intValue] == [self[k] intValue]) {
                rec = YES;
                continue;
            }else{
                NSLog(@"not match:%d , %d",[array[k] intValue],[self[k] intValue]);
                rec = NO;
                break;
            }
        }
        return rec;
    }else{
        return NO;
    }
}

@end
