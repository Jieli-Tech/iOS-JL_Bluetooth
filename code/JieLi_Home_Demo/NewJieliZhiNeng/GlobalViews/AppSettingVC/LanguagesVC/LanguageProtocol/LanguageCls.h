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

+(NSString *)currentLocalization;

+(NSString *)currentLanguage;

+(NSString *)localizableTxt:(NSString *)key;

+(NSString *)localizableTxt:(NSString *)key table:(NSString *)table;
// 支持显式指定语言（不依赖系统或APP当前语言设置）
+(NSString *)localizableTxt:(NSString *)key language:(NSString *)languageCode;
+(NSString *)localizableTxt:(NSString *)key table:(NSString *)table language:(NSString *)languageCode;

+(void)setLangague:(NSString *)lan;

-(void)add:(id<LanguagePtl>)objc;

-(void)remove:(id<LanguagePtl>)objc;

-(void)setLanguage:(NSString *)lgg;

@end

NS_ASSUME_NONNULL_END
