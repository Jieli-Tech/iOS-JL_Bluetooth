//
//  User_Http.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/6/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "User_Http.h"
#import "sys/utsname.h"
#import "JLUI_Cache.h"

@interface User_Http()<NSURLSessionDelegate>

@end

@implementation User_Http{
    NSString *mVer;
    NSString *mPid;
    NSString *mVid;
    NSString *mMac;
    NSString *accessToken; //访问令牌
    int requestTime; //设备日志请求时间
    NSTimer  *httpTimer;
    
    JL_RunSDK *bleSDK;
}

+(User_Http *)shareInstance{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        bleSDK = [JL_RunSDK sharedMe];
        [self addNote];
        [self requestFirstHttp];
    }
    return self;
}

-(void)requestFirstHttp{
    //App日志上报
    [JL_Tools subTask:^{
        [self requestUserLog:^(id  _Nonnull result, NSError * _Nonnull error) {
            self->requestTime = [result[@"data"][@"minute"] intValue];
            
            /*--- 用户认证登录 ---*/
            [self requestUserLogin:^(NSDictionary * _Nonnull info) {
                self->accessToken = info[@"data"][@"access_token"];
            }];
        }];
    }];
    
}

#pragma mark - 获取手机型号
- (NSString *)deviceVersion
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([platform isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([platform isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([platform isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([platform isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([platform isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([platform isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([platform isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([platform isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([platform isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
    if ([platform isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([platform isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([platform isEqualToString:@"iPhone13,3"])   return @"iPhone 12  Pro";
    if ([platform isEqualToString:@"iPhone13,4"])   return @"iPhone 12  Pro Max";
    if ([platform isEqualToString:@"iPhone14,4"])   return @"iPhone 13 mini";
    if ([platform isEqualToString:@"iPhone14,5"])   return @"iPhone 13";
    if ([platform isEqualToString:@"iPhone14,2"])   return @"iPhone 13  Pro";
    if ([platform isEqualToString:@"iPhone14,3"])   return @"iPhone 13  Pro Max";

    return platform;
}

/**
  App日志上报
*/
-(void)requestUserLog:(void(^)(id result,NSError *error)) block{
    NSDictionary *headers = @{ @"content-type": @"application/json",
                               @"cache-control": @"no-cache",
                               @"postman-token": @"61fd242d-48cc-a7df-e2d8-4e792c4a390f" };

    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSDictionary *infoDictionary=[[NSBundle mainBundle] infoDictionary];
    NSString *app_Version=[infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *userDic = @{ @"uuid": uuid,
                               @"platform": @"ios",
                               @"brand": @"iphone",
                               @"name": [self deviceVersion],
                               @"version": phoneVersion,
                               @"system": phoneVersion,
                               @"appname": @"杰理之家",
                               @"appversion": app_Version};
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:userDic options:0 error:nil];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://log.jieliapp.com/status/v1/log/user"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (block) {
                block(dict,error);
            }
        }
    }] resume];
}

/**
  固件日志上报
*/
-(void)requestDeviceLog:(NSString *)version withPid:(NSString *)pid
                    Vid:(NSString *)vid Mac:(NSString *)mac
                 Result:(void(^)(id result,NSError *error)) block{
    mVer = version;
    mPid = pid;
    mVid = vid;
    mMac = mac;
    
    NSDictionary *headers = @{ @"content-type": @"application/json",
                                  @"cache-control": @"no-cache",
                                  @"postman-token": @"61fd242d-48cc-a7df-e2d8-4e792c4a390f" };

    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *deviceDic = @{ @"vid": vid,
                                 @"pid": pid,
                                 @"uuid": uuid,
                                 @"type": @"bluetooth",
                                 @"series": @"ac697x",
                                 @"name": @"ac6971",
                                 @"mac": mac,
                                 @"version":version,
                                 @"tag": @""};
       NSData *postData = [NSJSONSerialization dataWithJSONObject:deviceDic options:0 error:nil];
       
       NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://log.jieliapp.com/status/v1/log/device"]
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:10.0];
       [request setHTTPMethod:@"POST"];
       [request setAllHTTPHeaderFields:headers];
       [request setHTTPBody:postData];
       
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
       [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
           if (!error) {
               NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
               if (block) {
                   block(dict,error);
               }
           }
       }] resume];
}

/**
  用户认证登录
*/
-(void)requestUserLogin:(void(^)(NSDictionary *info))result{
    NSDictionary *headers = @{ @"cache-control": @"no-cache",
                               @"postman-token": @"2605e415-6bcb-f699-e68c-57e5456fdca8" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://test01.jieliapp.com/auth/v1/service/login?username=13800000000&password=13800000000&type=mobile"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            if (result) result(dict);
        }
    }];
    [dataTask resume];
    
}

/**
  获取省市电台
*/
-(void)requestProvincialRadio:(void(^)(NSArray *info))result{
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache",
                              @"postman-token": @"3e8462ec-dbb4-8d49-e36f-c7256e68b69d" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://test01.jieliapp.com/res/v1/service/radio/place/list"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSArray *arr = dict[@"data"];
            NSMutableArray *myMutableArray = [arr mutableCopy];
            [myMutableArray removeObjectAtIndex:myMutableArray.count - 1];
            if (result) result([NSArray arrayWithArray:myMutableArray]);
        }
     }];
    [dataTask resume];
}

/**
  获取省市电台播放列表
*/
-(void)requestProvincialRadioList:(NSString *)areaId Result:(void(^)(NSArray *info))result{
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    
    NSDictionary *headers = @{@"jwt-token": accessToken?:@"",
                              @"cache-control": @"no-cache",
                              @"postman-token": @"f665110c-c746-769e-f2c6-fc53da2a1077" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://test01.jieliapp.com/res/v1/service/radio/meta/listbyplaceid?id=%@",areaId]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            if (result) result(nil);
        } else {
              NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
              NSArray *arr = dict[@"data"];
              if (result) result(arr);
        }
    }];
    [dataTask resume];
}

/**
  获取国家电台
*/
-(void)requestNationalRadio:(void(^)(NSArray *info))result{
    
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }

    
    NSDictionary *headers = @{@"jwt-token":accessToken?:@"",
                              @"cache-control": @"no-cache",
                              @"postman-token": @"3e8462ec-dbb4-8d49-e36f-c7256e68b69d" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://test01.jieliapp.com/res/v1/service/radio/place/list"]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSArray *arr = dict[@"data"];
            NSMutableArray *myMutableArray = [arr mutableCopy];
            [myMutableArray removeObjectsInRange:NSMakeRange(0, arr.count-1)];
            if (result) result([NSArray arrayWithArray:myMutableArray]);
        }
     }];
    [dataTask resume];
}

/**
  获取国家电台播放列表
*/
-(void)requestNationalRadioList:(void(^)(NSArray *info))result{
    if (accessToken.length == 0) {
        if (result) result(nil);
        return;
    }
    NSDictionary *headers = @{@"jwt-token": accessToken?:@"",
                              @"cache-control": @"no-cache",
                              @"postman-token": @"f665110c-c746-769e-f2c6-fc53da2a1077" };
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://test01.jieliapp.com/res/v1/service/radio/meta/listbyplaceid?id=%@",@"1278133982246658049"]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
            if (result) result(nil);
        } else {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSArray *arr = dict[@"data"];
            if (result) result(arr);
        }
    }];
    [dataTask resume];
}

-(void)startHttpTimer{
    int time = self->requestTime;
    if (time > 0) {
        if (httpTimer) {
            [JL_Tools timingContinue:httpTimer];
        }else{
            httpTimer = [JL_Tools timingStart:@selector(makeAction)
                                            target:self Time:time*60];
        }
    }
}

-(void)stopHttpTimer{
    [JL_Tools timingPause:httpTimer];
    httpTimer = nil;
}

-(void)makeAction{
    if(mVer.length>0&&mPid.length>0&&mVid.length>0&&mMac.length>0){
        [self requestDeviceLog:mVer withPid:mPid Vid:mVid Mac:mMac
                        Result:^(id  _Nonnull result, NSError * _Nonnull error) {
        }];
    }
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    
    if (type == JLDeviceChangeTypeSomethingConnected||
        type == JLDeviceChangeTypeManualChange) {
        [JL_Tools delay:4 Task:^{
            [self requestDeviceLog];
            [self startHttpTimer];
        }];
        return;
    }
    if (type == JLDeviceChangeTypeBleOFF) {
        [self stopHttpTimer];
    }
}

#pragma mark  固件日志上报
-(void)requestDeviceLog{
    [JL_Tools subTask:^{
        JLModel_Device *model = [self->bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        NSString *aVersion = model.versionFirmware;
        NSString *aVid = self->bleSDK.mBleEntityM.mVID;
        NSString *aPid = self->bleSDK.mBleEntityM.mPID;
        NSString *aEdr = self->bleSDK.mBleEntityM.mEdr;
        
        if (aVersion.length == 0 ||
            aVid.length     == 0 ||
            aPid.length     == 0 ||
            aEdr.length     == 0 ){
            return;}
        
        NSNumber *vidNumber = [NSNumber numberWithLong:strtoul(aVid.UTF8String, 0, 16)];
        NSString *vidStr = [vidNumber stringValue];
        
        NSNumber *pidNumber = [NSNumber numberWithLong:strtoul(aPid.UTF8String, 0, 16)];
        NSString *pidStr = [pidNumber stringValue];
        
        [self requestDeviceLog:aVersion withPid:pidStr Vid:vidStr Mac:aEdr
                        Result:^(id  _Nonnull result, NSError * _Nonnull error) {
        }];
    }];
}


-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)dealloc{
    [self stopHttpTimer];
    [JL_Tools remove:nil Own:self];
}


-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    
    NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,card);
}

@end
