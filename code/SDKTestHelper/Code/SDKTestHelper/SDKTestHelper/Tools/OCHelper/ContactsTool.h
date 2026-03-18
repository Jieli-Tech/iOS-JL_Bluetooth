//
//  ContactsTool.h
//  JieliJianKang
//
//  Created by kaka on 2021/3/23.
//

#import <Foundation/Foundation.h>
#import "PersonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactsTool : NSObject

+ (NSData *)setContactsToData:(NSArray *)array;

@end

NS_ASSUME_NONNULL_END
