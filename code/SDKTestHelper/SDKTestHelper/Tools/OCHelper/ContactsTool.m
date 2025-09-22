//
//  ContactsTool.m
//  JieliJianKang
//
//  Created by kaka on 2021/3/23.
//

#import "ContactsTool.h"
#import <JL_BLEKit/JL_BLEKit.h>

@implementation ContactsTool

#pragma mark 设置联系人列表为Data
+ (NSData *)setContactsToData:(NSArray *)array {
    
    NSMutableData *data = [NSMutableData new];
    for (PersonModel *model in array) {
        NSString *name;
        NSArray *titleTextLengthArray = [self unicodeLengthOfString:model.fullName];
        if ([[titleTextLengthArray firstObject] integerValue] > 7) {
            NSInteger maxMumLength = [[titleTextLengthArray lastObject] integerValue];
            model.fullName = [model.fullName stringByReplacingCharactersInRange:NSMakeRange(maxMumLength, model.fullName.length-maxMumLength) withString:@""];
        }
        if (model.fullName.length < 20) {
            name = [self CharacterStringMainString:model.fullName addDigit:20 addString:@"\0"];
        } else {
            name = model.fullName;
        }
        name = [name stringByReplacingOccurrencesOfString:@"<0>"withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@"<0" withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@"0>" withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@"<" withString:@""];
        name = [name stringByReplacingOccurrencesOfString:@">" withString:@""];
//        NSString *name = [self removeMoreString:model.fullName];
        NSData *nameData = [name dataUsingEncoding:NSUTF8StringEncoding];
        NSData *changeNameData = [JL_Tools data:nameData R:0 L:20];
        [data appendData:changeNameData];
        
        NSString *phoneNum;
        if (model.phoneNum.length < 20) {
            phoneNum = [self CharacterStringMainString:model.phoneNum addDigit:20 addString:@"\0"];
        } else {
            phoneNum = model.phoneNum;
        }
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"<0>"withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"<0" withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@"<"withString:@""];
        phoneNum = [phoneNum stringByReplacingOccurrencesOfString:@">"withString:@""];
//        NSString *phoneNum = [self removeMoreString:model.phoneNum];
        NSData *phoneNumData = [phoneNum dataUsingEncoding:NSUTF8StringEncoding];
        NSData *changePhoneNumData = [JL_Tools data:phoneNumData R:0 L:20];
        [data appendData:changePhoneNumData];
    }
    return data;
}

+ (NSString *)removeMoreString:(NSString *)text {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    while (data.length > 19) {
        text = [text substringWithRange:NSMakeRange(0, text.length - 1)];
        data = [text dataUsingEncoding:NSUTF8StringEncoding];
    }
    return text;
}

#pragma mark字符串自动补充方法

+ (NSString*)CharacterStringMainString:(NSString*)MainString addDigit:(int)AddDigit addString:(NSString*)AddString {
    NSString *ret = [[NSString alloc]init];
    ret = MainString;
    for (int y = 0; y < (AddDigit - MainString.length); y++) {
        ret = [NSString stringWithFormat:@"%@%@%@%@", ret, @"<", AddString, @">"];
    }
    return ret;
}

+ (NSMutableArray *)unicodeLengthOfString:(NSString *)text {
    NSMutableArray *array = [NSMutableArray array];
    float asciiLength = 0;
    NSInteger maxmumShowIndex  = 0;
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        if (isalnum(uc)) {
            asciiLength += 1.1;
        } else {
            asciiLength += isascii(uc) ? 1 : 2;
        }
        //计算可以显示的最大字数的Index位置
        if (asciiLength / 2 < 8) {
            maxmumShowIndex =i;
        }
    }
    //所有的字数
    NSUInteger unicodeLength = asciiLength / 2;
    
    if((NSInteger)asciiLength % 2) {
        unicodeLength++;
    }
    
    [array addObject:[NSNumber numberWithInteger:unicodeLength]];
    [array addObject:[NSNumber numberWithInteger:maxmumShowIndex]];
    return array;
}
@end
