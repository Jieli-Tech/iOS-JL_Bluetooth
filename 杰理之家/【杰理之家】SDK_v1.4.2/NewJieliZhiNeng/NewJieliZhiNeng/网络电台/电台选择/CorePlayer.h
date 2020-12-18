//
//  CorePlayer.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/28.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IJKMediaFrameworkWithSSL/IJKMediaFrameworkWithSSL.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CorePlayerDelegate <NSObject>

-(void)didChangeStatus:(DFNetPlayer_STATUS)status;

@end

@interface CorePlayer : NSObject
@property(nonatomic,strong)IJKFFMoviePlayerController * __nullable player;
@property(nonatomic,assign)DFNetPlayer_STATUS status;
@property(nonatomic,weak)id <CorePlayerDelegate> delegate;

+(instancetype)shareInstanced;
-(void)playWithUrl:(NSString *)url;
-(void)didPause;
-(void)didContinue;
-(void)didStop;
-(BOOL)wetherPlay;

@end

NS_ASSUME_NONNULL_END
