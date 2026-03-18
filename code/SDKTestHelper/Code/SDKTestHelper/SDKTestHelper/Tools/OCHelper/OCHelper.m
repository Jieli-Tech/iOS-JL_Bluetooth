//
//  OCHelper.m
//  SDKTestHelper
//
//  Created by EzioChan on 2024/2/18.
//  Copyright © 2024 www.zh-jieli.com. All rights reserved.
//

#import "OCHelper.h"
#import <JL_BLEKit/JL_BLEKit.h>
#import <JLBmpConvertKit/JLBmpConvertKit.h>

@implementation OCHelper

+(void)handleBr28Bmp:(NSString *)path size:(CGSize) size binPath:(NSString *)binPath{
    //    br28_btm_to_res_path_with_alpha((char*)[path UTF8String], size.width, size.height, (char*)[binPath UTF8String]);
}

+(void)handleBr23mp:(NSString *)bmpPath size:(CGSize) size binPath:(NSString *)binPath{
    //    br23_btm_to_res_path((char*)[bmpPath UTF8String], size.width, size.height, (char*)[binPath UTF8String]);
}

+(void)testApi:(JL_ManagerM *)manager {
    
}

// 将 32 位整数从小端字节序转换为大端字节序
uint32_t convertToBigEndian(uint32_t littleEndianValue) {
    uint32_t result = 0;
    
    result |= ((littleEndianValue & 0xFF000000) >> 24);
    result |= ((littleEndianValue & 0x00FF0000) >> 8);
    result |= ((littleEndianValue & 0x0000FF00) << 8);
    result |= ((littleEndianValue & 0x000000FF) << 24);
    
    return result;
}



@end
