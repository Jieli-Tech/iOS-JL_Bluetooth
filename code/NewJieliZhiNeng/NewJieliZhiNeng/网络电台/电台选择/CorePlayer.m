//
//  CorePlayer.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/28.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "CorePlayer.h"
#import <UIKit/UIKit.h>

@interface CorePlayer(){
    
    UIView *centerView;
}



@end

@implementation CorePlayer

+(instancetype)shareInstanced{
    static CorePlayer *me;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        me = [[CorePlayer alloc] init];
    });
    return me;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
#ifdef DEBUG
        [IJKFFMoviePlayerController setLogReport:NO];
        [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_ERROR];
#endif
        centerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _status = DFNetPlayer_STATUS_STOP;
    }
    return self;
}

-(void)playWithUrl:(NSString *)url{
    
    if (self.player) {
        [self.player shutdown];
        [self.player.view removeFromSuperview];
        self.player = nil;
        [self removeMovieNotificationObservers];
    }
    NSLog(@"---> Net Play:%@",url);
    
    [self installMovieNotificationObservers];
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [self ijkOptionSet:options];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:url withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = centerView.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    [centerView addSubview:self.player.view];
    [self.player prepareToPlay];
//    _status = DFNetPlayer_STATUS_PLAY;
}

-(void)didPause{
    if (self.status == DFNetPlayer_STATUS_PLAY) {
        [self.player pause];
    }
//    _status = DFNetPlayer_STATUS_PAUSE;
}

-(void)didContinue{
    if (self.status == DFNetPlayer_STATUS_PAUSE) {
        [self.player play];
    }
}

-(void)didStop{
    if (self.player) {
        [self.player shutdown];
        [self.player.view removeFromSuperview];
        [self removeMovieNotificationObservers];
        if ([_delegate respondsToSelector:@selector(didChangeStatus:)]) {
            _status = DFNetPlayer_STATUS_STOP;
            [_delegate didChangeStatus:DFNetPlayer_STATUS_STOP];
        }
        self.player = nil;
    }
    
}
//-(DFNetPlayer_STATUS)status{
//    if (self.player.playbackState == IJKMPMoviePlaybackStatePlaying) {
//        return DFNetPlayer_STATUS_PLAY;
//    }else{
//        return DFNetPlayer_STATUS_PAUSE;
//    }
//}
-(BOOL)wetherPlay{
    if (self.player) {
        return YES;
    }else{
        return NO;
    }
}




-(void)ijkOptionSet:(IJKFFOptions *)options{
    
    //开启硬件解码
    [options setCodecOptionIntValue:600 forKey:@"min-frames"];
    [options setPlayerOptionIntValue:0 forKey:@"videotoolbox"]; //0是软解，1是硬解
    //连接超时
    // 会引起音视频不同步，也可以通过设置它来跳帧达到倍速播放
    [options setPlayerOptionIntValue:5 forKey:@"framedrop"];
    [options setPlayerOptionIntValue:IJK_AVDISCARD_NONKEY forKey:@"skip_frame"];
    [options setPlayerOptionIntValue:IJK_AVDISCARD_NONREF forKey:@"skip_loop_filter"];
    //设置缓冲大小
    [options setFormatOptionIntValue:1000 forKey:@"analyzeduration"];
    [options setFormatOptionValue:@"nobuffer" forKey:@"fflags"];
    [options setFormatOptionIntValue:4096 forKey:@"probesize"];
    [options setPlayerOptionIntValue:0 forKey:@"packet-buffering"];
    //    [options setPlayerOptionIntValue:1 forKey:@"flush_packets"];
    //设置最大队列帧数
    [options setPlayerOptionIntValue:3 forKey:@"video-pictq-size"];
    //设置自动准备播放
    [options setPlayerOptionIntValue:1 forKey:@"start-on-prepared"];
    //视频渲染方式
    [options setPlayerOptionValue:@"fcc-i420" forKey:@"overlay-format"];
    
}

-(void)showErrorUI{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *windows = [UIApplication sharedApplication].keyWindow;
        [DFUITools showText_1:kJL_TXT("radio_cannot_play") onView:windows delay:2];
    });
}

#pragma mark <- 接收IJK的通知 ->
/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:self.player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:self.player];
    
}
#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:self.player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:self.player];
    
}

#pragma mark <- 通知信息处理 ->
- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    IJKMPMovieLoadState loadState = self.player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

//播放完成之后的状态返回通知
- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            self.status = DFNetPlayer_STATUS_STOP;
            [self showErrorUI];
            [JL_Tools post:@"kUI_NETPLAY_ERR" Object:self];
            break;
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

//准备播放
- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
    
}
- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (self.player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)self.player.playbackState);
            _status = DFNetPlayer_STATUS_STOP;
            if ([_delegate respondsToSelector:@selector(didChangeStatus:)]) {

                [_delegate didChangeStatus:DFNetPlayer_STATUS_STOP];
            }
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)self.player.playbackState);
            _status = DFNetPlayer_STATUS_PLAY;
            if ([_delegate respondsToSelector:@selector(didChangeStatus:)]) {
                
                [_delegate didChangeStatus:DFNetPlayer_STATUS_PLAY];
            }
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)self.player.playbackState);
            _status = DFNetPlayer_STATUS_PAUSE;
            if ([_delegate respondsToSelector:@selector(didChangeStatus:)]) {
                [_delegate didChangeStatus:DFNetPlayer_STATUS_PAUSE];
            }
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)self.player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)self.player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)self.player.playbackState);
            break;
        }
    }
}



@end

