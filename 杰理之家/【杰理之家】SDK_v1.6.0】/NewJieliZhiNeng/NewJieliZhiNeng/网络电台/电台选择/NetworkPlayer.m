//
//  NetworkPlayer.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/10.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "NetworkPlayer.h"
#import "JLUI_Cache.h"


NSString *kNETWORK_PLAYER_STATUS = @"NETWORK_PLAYER_STATUS";

@interface NetworkPlayer ()<DFNetPlayerDelegate,CorePlayerDelegate>{
    NSArray     *playList;
    NSInteger   playIndex;
    float       volume;
    BOOL        isID3_NO;
}

@end

@implementation NetworkPlayer

static NetworkPlayer *ME = nil;
+(id)sharedMe{
    if (ME == nil) {
        ME = [[self alloc] init];
        
    }
    return ME;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        isID3_NO = YES;
        playIndex = 0;
        volume = [DFAudioPlayer getPhoneVolume];
        self.mNetPlayer = [[DFNetPlayer alloc] init];
        self.mNetPlayer.delegate = self;
        [[CorePlayer shareInstanced] setDelegate:self];
        [JL_Tools add:AVAudioSessionInterruptionNotification Action:@selector(noteInterruption:) Own:self];
        [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    }
    return self;
}

-(void)setPlayList:(NSArray*)list{
    //playIndex= 0;
    playList = list;
    
    if (list.count > 0 && self.mNowInfo==nil) self.mNowInfo = list[0];
}

-(void)didNext{
    if (playList.count == 0) return;
    
    playIndex++;
    if (playIndex >= playList.count) playIndex = 0;
    [self didPlay:playIndex];
}

-(void)didBefore{
    if (playList.count == 0) return;

    playIndex--;
    if (playIndex < 0) playIndex = playList.count-1;
    [self didPlay:playIndex];

}

-(void)didPlay:(NSInteger)index{
    if (playList.count == 0) return;
    [[DFAudioPlayer sharedMe] didPause];
        
    NSLog(@"UI关闭ID3信息。44");
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    [bleSDK.mBleEntityM.mCmdManager.mChargingBinManager cmdID3_PushEnable:NO];
    [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PUSH:NO];
    [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PLAY:NO];
    [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_ST:NO];
    
    self->playIndex = index;
    self.mNowInfo = self->playList[index];
    [self setLockScreenNowPlayingInfo];
    [[CorePlayer shareInstanced] playWithUrl:self.mNowInfo[@"stream"]];
    [self.mNetPlayer setVolume:self->volume];
}

-(void)didPause{
    [[CorePlayer shareInstanced] didPause];
    [JL_Tools post:@"kUI_NETPLAYER_PAUSE" Object:nil];
}

-(void)didContinue{
    [[DFAudioPlayer sharedMe] didPause];
    
    if ([CorePlayer shareInstanced].status == DFNetPlayer_STATUS_STOP) {
        [self didPlay:playIndex];
    }else{
        [[CorePlayer shareInstanced] didContinue];
        if (isID3_NO == YES) {
            JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];

            [[JLCacheBox cacheUuid:bleSDK.mBleUUID] setIsID3_PUSH:NO];
            [bleSDK.mBleEntityM.mCmdManager.mChargingBinManager cmdID3_PushEnable:NO];
            NSLog(@"UI关闭ID3信息。55");
            isID3_NO = NO;
        }

    }
}

-(void)didStop{
    [[CorePlayer shareInstanced] didStop];
}

-(void)noteInterruption:(NSNotification*)note{
    if ([[CorePlayer shareInstanced] status] == DFNetPlayer_STATUS_PLAY) {
        [[CorePlayer shareInstanced] didPause];
        NSLog(@"NetWorkPlayer ----> 中断");
        [JL_Tools post:@"kUI_NETPLAYER_PAUSE" Object:nil];
    }else{
        [[CorePlayer shareInstanced] didContinue];
    }

}


-(void)receiveRemoteEvent:(UIEvent*)event{
    if (event.type == UIEventTypeRemoteControl){
        UIEventSubtype subType = event.subtype;
        switch (subType) {
            case UIEventSubtypeRemoteControlPause:{
                [self didPause];
            }break;
            case UIEventSubtypeRemoteControlPlay:{
                [self didContinue];
            }break;
            case UIEventSubtypeRemoteControlPreviousTrack:{
                [self didBefore];
            }break;
            case UIEventSubtypeRemoteControlNextTrack:{
                [self didNext];
            }break;
            default:
                break;
        }
    }
}


-(void)onDFNetPlayer:(DFNetPlayer*)player ChangeStatus:(DFNetPlayer_STATUS)status{
    [DFNotice post:kNETWORK_PLAYER_STATUS Object:@(status)];
//    NSLog(@"ChangeStatus --->%lu",(unsigned long)status);
}
-(void)onDFNetPlayer:(DFNetPlayer*)player CachedProgress:(float)progress{
    
}
-(void)onDFNetPlayer:(DFNetPlayer*)player Speed:(float)speed TimeGap:(NSTimeInterval)timeGap{
    
}
-(void)onDFNetPlayer:(DFNetPlayer*)player PlayTime:(float)time{
    
}
-(void)onDFNetPlayer:(DFNetPlayer*)player PlayFinished:(float)ret{
    
}

#pragma mark ///CorePlayerDelegate
-(void)didChangeStatus:(DFNetPlayer_STATUS)status{

    [DFNotice post:kNETWORK_PLAYER_STATUS Object:@(status)];
    NSLog(@"ChangeStatus --->%lu",(unsigned long)status);
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeSomethingConnected ||
        type == JLDeviceChangeTypeBleOFF) {
        [[CorePlayer shareInstanced] didStop];
        //[JL_Tools post:@"kUI_NETPLAYER_PAUSE" Object:nil];
    }
}

#pragma mark 更新锁屏时的歌曲信息
-(void)setLockScreenNowPlayingInfo
{
    if(NSClassFromString(@"MPNowPlayingInfoCenter")){
        
        NSMutableDictionary*dict=[NSMutableDictionary new];
        [dict setObject:self.mNowInfo[@"name"]?:@"Unknow Music" forKey:MPMediaItemPropertyTitle];

        [dict setObject:@"Unknow Artist" forKey:MPMediaItemPropertyArtist];

        [dict setObject:self.mNowInfo[@"name"]?:@"Unknow Album" forKey:MPMediaItemPropertyAlbumTitle];
        //进度光标的速度 （这个随 自己的播放速率调整，我默认是原速播放）
        [dict setObject:@(1.0) forKey:MPNowPlayingInfoPropertyPlaybackRate];
        
        //音乐当前已经播放时间
        [dict setObject:@(0) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        
        //歌曲总时间设置
        [dict setObject:@(0) forKey:MPMediaItemPropertyPlaybackDuration];
        
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}

@end
