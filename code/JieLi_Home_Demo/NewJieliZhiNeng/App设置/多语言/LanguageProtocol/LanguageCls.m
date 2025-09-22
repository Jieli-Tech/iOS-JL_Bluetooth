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
    NSString *str = [DFUITools languageText:key Table:@"Localizable"];
    if (!str) {
        /*--- 检测当前语言 ---*/
        NSString *path;
        if ([kJL_GET hasPrefix:table]) {
            path = [[NSBundle mainBundle] pathForResource:table ofType:@"lproj"];
        }else{
            path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        }
        return [[NSBundle bundleWithPath:path] localizedStringForKey:key value:nil table:@"Localizable"];
    }
    return str;
}


@end
