//
//  LanguageCls.h
//  JieliJianKang
//
//  Created by EzioChan on 2021/12/24.
//

#import <Foundation/Foundation.h>
#import "LanguagePtl.h"

NS_ASSUME_NONNULL_BEGIN

@interface LanguageCls : NSObject

+(instancetype)share;

+(NSString *)checkLanguage;

+(NSString *)localizableTxt:(NSString *)key;

+(void)setLangague:(NSString *)lan;

-(void)add:(id<LanguagePtl>)objc;

-(void)remove:(id<LanguagePtl>)objc;

-(void)setLanguage:(NSString *)lgg;

@end

NS_ASSUME_NONNULL_END
