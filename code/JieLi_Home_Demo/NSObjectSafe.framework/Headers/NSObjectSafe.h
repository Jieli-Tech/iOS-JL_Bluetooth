//
//  NSObjectSafe.h
//  NSObjectSafe
//
//  Created by jasenhuang on 15/12/29.
//  Copyright © 2015年 tencent. All rights reserved.
//


/**
 * Warn: NSObjectSafe must used in MRC, otherwise it will cause 
 * strange release error: [UIKeyboardLayoutStar release]: message sent to deallocated instance
 */

#import "TargetConditionals.h"
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Appkit/Appkit.h>
#endif

//! Project version number for NSObjectSafe.
FOUNDATION_EXPORT double NSObjectSafeVersionNumber;

//! Project version string for NSObjectSafe.
FOUNDATION_EXPORT const unsigned char NSObjectSafeVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <NSObjectSafe/PublicHeader.h>

FOUNDATION_EXPORT NSString *const NSSafeNotification;

@interface NSObject(Swizzle)
+ (void)swizzleClassMethod:(SEL)origSelector withMethod:(SEL)newSelector;
- (void)swizzleInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector;
@end

