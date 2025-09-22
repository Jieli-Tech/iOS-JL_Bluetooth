//
//  KalaokModel.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/11/20.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "KalaokModel.h"

@implementation KalaokModel

- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    [coder encodeBool:self.hasEq forKey:@"hasEq"];
    [coder encodeBool:self.paging forKey:@"paging"];
    [coder encodeBool:self.group forKey:@"group"];
    
    [coder encodeObject:self.mList forKey:@"mList"];
   
    [coder encodeInteger:self.mId forKey:@"mId"];
    [coder encodeInteger:self.column forKey:@"column"];
    [coder encodeInteger:self.row forKey:@"row"];
    
    [coder encodeObject:self.type forKey:@"type"];
    [coder encodeObject:self.icon_url forKey:@"icon_url"];
    [coder encodeObject:self.zh_name forKey:@"zh_name"];
    [coder encodeObject:self.en_name forKey:@"en_name"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
        self.hasEq = [coder decodeBoolForKey:@"hasEq"];
        self.paging = [coder decodeBoolForKey:@"paging"];
        self.group = [coder decodeBoolForKey:@"group"];
        
        self.mList = [coder decodeObjectForKey:@"mList"];
        
        self.mId  = [coder decodeIntegerForKey:@"mId"];
        self.column  = [coder decodeIntegerForKey:@"column"];
        self.row  = [coder decodeIntegerForKey:@"row"];
        
        self.type = [coder decodeObjectForKey:@"type"];
        self.icon_url = [coder decodeObjectForKey:@"icon_url"];
        self.zh_name = [coder decodeObjectForKey:@"zh_name"];
        self.en_name = [coder decodeObjectForKey:@"en_name"];
    }
    return self;
}
@end
