//
//  NetworkPlayer.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/10.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DFUnits/DFUnits.h>
#import "CorePlayer.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *kNETWORK_PLAYER_STATUS;

@interface NetworkPlayer : NSObject
@property(nonatomic,strong) DFNetPlayer *mNetPlayer;
@property(nonatomic,strong) NSDictionary*mNowInfo;

@property(nonatomic,strong) NSString *province;
@property(nonatomic,strong) NSArray *provinceIDArray;
@property(nonatomic,strong) NSDictionary *provinceID;
@property(nonatomic,strong) NSArray         *localRadioArray;
@property(nonatomic,strong) NSArray         *nationRadioArray;
@property(nonatomic,strong) NSArray         *provinceRadioArray;
@property(nonatomic,strong) NSMutableArray  *collectionRadioArray;

+(id)sharedMe;
-(void)setPlayList:(NSArray*)list;
-(void)didPlay:(NSInteger)index;
-(void)didContinue;
-(void)didPause;
-(void)didNext;
-(void)didBefore;
-(void)didStop;
-(void)receiveRemoteEvent:(UIEvent*)event;
@end

NS_ASSUME_NONNULL_END
