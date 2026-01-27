//
//  LanguageCls.m
//  JieliJianKang
//
//  Created by EzioChan on 2021/12/24.
//

#import "LanguageCls.h"

#define LocalLanguage  @"LocalLanguage"

@interface LanguageCls()

@property(nonatomic,strong)NSHashTable         *delegates;
@property(nonatomic,strong)NSLock              *delegateLock;

+ (NSBundle *)bundleForLanguageCode:(NSString *)languageCode;

@end

@implementation LanguageCls


+(instancetype)share{
    static LanguageCls *me;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        me = [[LanguageCls alloc] init];
    });
    return me;
}

-(NSLock *)delegateLock{
    if (_delegateLock == nil) {
        _delegateLock = [NSLock new];
    }
    return _delegateLock;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}

-(void)add:(id<LanguagePtl>)objc{
    [self.delegateLock lock];
    if (![self.delegates containsObject:objc]) {
        [self.delegates addObject:objc];
    }
    [self.delegateLock unlock];
}

-(void)remove:(id<LanguagePtl>)objc{
    [self.delegateLock lock];
    if ([self.delegates containsObject:objc]) {
        [self.delegates removeObject:objc];
    }
    [self.delegateLock unlock];
}

-(void)setLanguage:(NSString *)lgg{
    for (NSObject<LanguagePtl> *objc in self.delegates) {
        if ([objc respondsToSelector:@selector(languageChange)]) {
            [objc languageChange];
        }
    }
}

+(NSString *)checkLanguage {
    NSString *objc = [[NSUserDefaults standardUserDefaults] valueForKey:LocalLanguage];
    if (objc && ![objc isEqualToString:@""]) {
        return objc;
    }else{
        return [DFUITools systemLanguage];
    }
}

+(NSString *)currentLocalization{
    NSString *language = [self checkLanguage];
    if ([language isEqual:@""]) {
        return @"en_US_POSIX";
    }else if ([language hasPrefix:@"zh"]) {
        return @"zh_CN";
    }else if ([language hasPrefix:@"ja"]) {
        return @"ja_JP";
    }else{
        return @"en_US_POSIX";
    }
}

+(NSString *)currentLanguage{
    NSString *code = [LanguageCls checkLanguage];
    NSString *lower = [code lowercaseString];
    NSString *resource = nil;
    if ([lower hasPrefix:@"zh"]) {
        if ([lower containsString:@"hant"] || [lower containsString:@"tw"]) {
            resource = @"zh-Hant"; // 优先尝试繁体
        } else {
            resource = @"zh-Hans"; // 默认简体
        }
    } else if ([lower hasPrefix:@"ja"]) {
        resource = @"ja";
    } else {
        resource = @"en";
    }
    return resource;
}

+(void)setLangague:(NSString *)lan{
    [[NSUserDefaults standardUserDefaults] setValue:lan forKey:LocalLanguage];
    if ([lan isEqual:@""]) {
        [DFUITools languageSet:[DFUITools systemLanguage]];
        NSString *str = [DFUITools systemLanguage];
        [[self share] setLanguage:str];
    }else{
        [DFUITools languageSet:lan];
        [[self share] setLanguage:lan];
    }
    
}

+(NSString *)localizableTxt:(NSString *)key{
    NSString *str = [DFUITools languageText:key Table:@"Localizable"];
    if (!str) {
        /*--- 检测当前语言 ---*/
        NSString *path;
        if ([kJL_GET hasPrefix:@"en"]) {
            path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        }else if([kJL_GET hasPrefix:@"ja"]){
            path = [[NSBundle mainBundle] pathForResource:@"ja" ofType:@"lproj"];
        }else if ([kJL_GET hasPrefix:@"zh-Hans"]){
            path = [[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
        }else{
            path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        }
        return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:nil table:@"Localizable"];
    }
    return str;
}




+(NSString *)localizableTxt:(NSString *)key table:(NSString *)table {
    BOOL isLanguageCode = (table.length > 0) && ({
        NSString *lower = table.lowercaseString;
        [lower hasPrefix:@"en"] || [lower hasPrefix:@"ja"] || [lower hasPrefix:@"zh"];
    });
    NSBundle *bundle = isLanguageCode ? [LanguageCls bundleForLanguageCode:table] : [LanguageCls bundleForLanguageCode:nil];
    NSString *tb = isLanguageCode ? @"Localizable" : (table ?: @"Localizable");

    NSString *value = [bundle localizedStringForKey:key value:nil table:tb];

    // 回退到当前语言的 Localizable
    if (!value || [value isEqualToString:key]) {
        value = [bundle localizedStringForKey:key value:nil table:@"Localizable"];
    }

    // 最后回退到英语的 Localizable
    if (!value || [value isEqualToString:key]) {
        NSBundle *enBundle = [LanguageCls bundleForLanguageCode:@"en"];
        value = [enBundle localizedStringForKey:key value:nil table:@"Localizable"];
    }
    return value;
}

+ (NSBundle *)bundleForLanguageCode:(NSString *)languageCode {
    // languageCode 为空时，使用当前设置语言
    NSString *code = languageCode;
    if (code == nil || [code isEqualToString:@""]) {
        code = [LanguageCls checkLanguage];
    }
    NSString *lower = [code lowercaseString];
    NSString *resource = nil;
    if ([lower hasPrefix:@"zh"]) {
        if ([lower containsString:@"hant"] || [lower containsString:@"tw"]) {
            resource = @"zh-Hant"; // 优先尝试繁体
        } else {
            resource = @"zh-Hans"; // 默认简体
        }
    } else if ([lower hasPrefix:@"ja"]) {
        resource = @"ja";
    } else {
        resource = @"en";
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:resource ofType:@"lproj"];
    if (!path && [resource isEqualToString:@"zh-Hant"]) {
        // 若繁体资源不存在，回退到简体
        path = [[NSBundle mainBundle] pathForResource:@"zh-Hans" ofType:@"lproj"];
    }
    if (path) {
        return [NSBundle bundleWithPath:path];
    }
    return [NSBundle mainBundle];
}

+ (NSString *)localizableTxt:(NSString *)key language:(NSString *)languageCode {
    return [LanguageCls localizableTxt:key table:@"Localizable" language:languageCode];
}

+ (NSString *)localizableTxt:(NSString *)key table:(NSString *)table language:(NSString *)languageCode {
    NSBundle *bundle = [LanguageCls bundleForLanguageCode:languageCode];
    NSString *tb = table ?: @"Localizable";
    NSString *value = [bundle localizedStringForKey:key value:nil table:tb];
    if (!value || [value isEqualToString:key]) {
        // 回退到当前指定语言的 Localizable
        value = [bundle localizedStringForKey:key value:nil table:@"Localizable"];
    }
    if (!value || [value isEqualToString:key]) {
        // 最后回退到英语的 Localizable
        NSBundle *enBundle = [LanguageCls bundleForLanguageCode:@"en"];
        value = [enBundle localizedStringForKey:key value:nil table:@"Localizable"];
    }
    return value;
}

@end
