//
//  JLUI_Cache.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "JLUI_Cache.h"
#import "JLCacheBox.h"

#define kJL_EQ_CACHE_ARRAY     @"JL_EQ_CACHE_ARRAY"

@implementation JLUI_Cache

+(instancetype)sharedInstance{
    static JLUI_Cache *ME = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        ME = [[self alloc] init];
    });
    return ME;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        NSArray *cacheArr = [self getToDataWithName:kJL_EQ_CACHE_ARRAY];
        if (cacheArr.count == 0) {
            NSArray *arr = @[@[@(0 ),@(0),@(0),@(0 ),@(0 ),@(0 ),@(0 ),@(0),@(0),@(0)],
                           @[@(-2),@(0),@(2),@(4 ),@(-2),@(-2),@(0 ),@(0),@(4),@(4)],
                           @[@(3 ),@(1),@(0),@(-2),@(-4),@(-4),@(-2),@(0),@(1),@(2)],
                           @[@(0 ),@(8),@(8),@(4 ),@(0 ),@(0 ),@(0 ),@(0),@(2),@(2)],
                           @[@(0 ),@(0),@(0),@(4 ),@(4 ),@(4 ),@(0 ),@(2),@(3),@(4)],
                           @[@(-2),@(0),@(0),@(2 ),@(2 ),@(0 ),@(0 ),@(0),@(4),@(4)],
                           @[@(0 ),@(0),@(0),@(0 ),@(0 ),@(0 ),@(0 ),@(0),@(0),@(0)]];
            [self saveToData:arr WithName:kJL_EQ_CACHE_ARRAY];
        }
        self.eqCacheArray = [NSMutableArray arrayWithArray:cacheArr];
        
        NSArray *arr_1 = @[@[@(0 ),@(0),@(0),@(0 ),@(0 ),@(0 ),@(0 ),@(0),@(0),@(0)],
                       @[@(-2),@(0),@(2),@(4 ),@(-2),@(-2),@(0 ),@(0),@(4),@(4)],
                       @[@(3 ),@(1),@(0),@(-2),@(-4),@(-4),@(-2),@(0),@(1),@(2)],
                       @[@(0 ),@(8),@(8),@(4 ),@(0 ),@(0 ),@(0 ),@(0),@(2),@(2)],
                       @[@(0 ),@(0),@(0),@(4 ),@(4 ),@(4 ),@(0 ),@(2),@(3),@(4)],
                       @[@(-2),@(0),@(0),@(2 ),@(2 ),@(0 ),@(0 ),@(0),@(4),@(4)],
                       @[@(0 ),@(0),@(0),@(0 ),@(0 ),@(0 ),@(0 ),@(0),@(0),@(0)]];
        self.eqCacheArray_1 = [NSMutableArray arrayWithArray:arr_1];
    }
    return self;
}

- (instancetype)initWithUuid:(NSString*)uuid
{
    self = [super init];
    if (self) {
        
        NSArray *cacheArr = [self getToDataWithName:uuid];
        if (cacheArr.count == 0) {
            NSArray *arr = @[@[@(0 ),@(0),@(0),@(0 ),@(0 ),@(0 ),@(0 ),@(0),@(0),@(0)],
                           @[@(-2),@(0),@(2),@(4 ),@(-2),@(-2),@(0 ),@(0),@(4),@(4)],
                           @[@(3 ),@(1),@(0),@(-2),@(-4),@(-4),@(-2),@(0),@(1),@(2)],
                           @[@(0 ),@(8),@(8),@(4 ),@(0 ),@(0 ),@(0 ),@(0),@(2),@(2)],
                           @[@(0 ),@(0),@(0),@(4 ),@(4 ),@(4 ),@(0 ),@(2),@(3),@(4)],
                           @[@(-2),@(0),@(0),@(2 ),@(2 ),@(0 ),@(0 ),@(0),@(4),@(4)],
                           @[@(0 ),@(0),@(0),@(0 ),@(0 ),@(0 ),@(0 ),@(0),@(0),@(0)]];
            [self saveToData:arr WithName:uuid];
        }
        self.eqCacheArray = [NSMutableArray arrayWithArray:cacheArr];
        
        NSArray *arr_1 = @[@[@(0 ),@(0),@(0),@(0 ),@(0 ),@(0 ),@(0 ),@(0),@(0),@(0)],
                       @[@(-2),@(0),@(2),@(4 ),@(-2),@(-2),@(0 ),@(0),@(4),@(4)],
                       @[@(3 ),@(1),@(0),@(-2),@(-4),@(-4),@(-2),@(0),@(1),@(2)],
                       @[@(0 ),@(8),@(8),@(4 ),@(0 ),@(0 ),@(0 ),@(0),@(2),@(2)],
                       @[@(0 ),@(0),@(0),@(4 ),@(4 ),@(4 ),@(0 ),@(2),@(3),@(4)],
                       @[@(-2),@(0),@(0),@(2 ),@(2 ),@(0 ),@(0 ),@(0),@(4),@(4)],
                       @[@(0 ),@(0),@(0),@(0 ),@(0 ),@(0 ),@(0 ),@(0),@(0),@(0)]];
        self.eqCacheArray_1 = [NSMutableArray arrayWithArray:arr_1];
        self.mUuid = uuid;
    }
    return self;
}


-(void)saveToData:(NSArray *)points WithName:(NSString *)name{
    NSData * wData = [NSKeyedArchiver archivedDataWithRootObject:points];
    [JL_Tools setUser:wData forKey:name];
}

-(NSArray*)getToDataWithName:(NSString*)name{
    NSData *data = [JL_Tools getUserByKey:name];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return array;
}

-(void)setEqCustomArray:(NSArray*)array{
    [self.eqCacheArray removeLastObject];
    [self.eqCacheArray addObject:array];
    [self saveToData:self.eqCacheArray WithName:self.mUuid];
}

-(void)setEqCustomArray_1:(NSArray*)array{
    [self.eqCacheArray_1 removeLastObject];
    [self.eqCacheArray_1 addObject:array];
}

-(void)setAllImage:(NSDictionary *)dict WithUuid:(NSString*)uuid{
    NSDictionary *proDict = dict[@"PRODUCT_LOGO"];
    if (proDict) {
        [self setProductData:proDict[@"IMG"]];
        [self saveProductImage:proDict[@"IMG"] UUID:uuid Name:@"PRODUCT_LOGO"];
    }
    NSDictionary *doubleDict = dict[@"DOUBLE_HEADSET"];
    if (doubleDict) {
        [self setLeftData:doubleDict[@"IMG"]];
        [self saveProductImage:doubleDict[@"IMG"] UUID:uuid Name:@"DOUBLE_HEADSET"];
    }
    NSDictionary *leftDict = dict[@"LEFT_DEVICE_CONNECTED"];
    if (leftDict) {
        [self setLeftData:leftDict[@"IMG"]];
        [self saveProductImage:leftDict[@"IMG"] UUID:uuid Name:@"LEFT_DEVICE_CONNECTED"];
    }
    NSDictionary *rightDict = dict[@"RIGHT_DEVICE_CONNECTED"];
    if (rightDict) {
        [self setRightData:rightDict[@"IMG"]];
        [self saveProductImage:rightDict[@"IMG"] UUID:uuid Name:@"RIGHT_DEVICE_CONNECTED"];
    }
    NSDictionary *cabinDict = dict[@"CHARGING_BIN_IDLE"];
    if (cabinDict) {
        [self setChargingBinData:cabinDict[@"IMG"]];
        [self saveProductImage:cabinDict[@"IMG"] UUID:uuid Name:@"CHARGING_BIN_IDLE"];
    }
    
    NSDictionary *doubleHeadsetLocationDict = dict[@"DOUBLE_HEADSET_LOCATION"];
    if (doubleHeadsetLocationDict) {
        [self saveProductImage:doubleHeadsetLocationDict[@"IMG"] UUID:uuid Name:@"DOUBLE_HEADSET_LOCATION"];
    }
    
    NSDictionary *leftDeviceLocationLocationDict = dict[@"LEFT_DEVICE_LOCATION"];
    if (leftDeviceLocationLocationDict) {
        [self saveProductImage:leftDeviceLocationLocationDict[@"IMG"] UUID:uuid Name:@"LEFT_DEVICE_LOCATION"];
    }
    
    NSDictionary *rightDeviceLocationDict = dict[@"RIGHT_DEVICE_LOCATION"];
    if (rightDeviceLocationDict) {
        [self saveProductImage:rightDeviceLocationDict[@"IMG"] UUID:uuid Name:@"RIGHT_DEVICE_LOCATION"];
    }
}

-(void)saveProductImage:(NSData*)data UUID:(NSString*)uuid Name:(NSString*)name{
    if (data.length == 0) return;

    NSString *imageName = [NSString stringWithFormat:@"%@_%@",name,uuid];
    NSString *path = [JL_Tools findPath:NSLibraryDirectory
                             MiddlePath:@"" File:imageName];
    if (path) {
        [JL_Tools writeData:data fillFile:path];
    }else{
        NSString *newPath = [JL_Tools createOn:NSLibraryDirectory MiddlePath:@"" File:imageName];
        [JL_Tools writeData:data fillFile:newPath];
    }
}



@end
