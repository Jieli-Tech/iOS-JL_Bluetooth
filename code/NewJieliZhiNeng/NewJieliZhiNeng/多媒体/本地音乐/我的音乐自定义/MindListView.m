//
//  MindListView.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "MindListView.h"
#import "JLUI_Cache.h"
#import "SongListCell.h"
#import "NetworkPlayer.h"

@interface MindListView()<UITableViewDelegate,UITableViewDataSource>{
    UIImageView *songListImv;
    UILabel *label_1; //全部歌曲
    UILabel *label_2; //共多少首
    UIImageView *imvNull; //暂无歌曲显示的图片
    UILabel *label_music_null; //暂无本地音乐的文字
    
    JL_RunSDK   *bleSDK;
    NSString    *bleUUID;
}

@end

@implementation MindListView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        bleSDK = [JL_RunSDK sharedMe];
        bleUUID= bleSDK.mBleUUID;
        
        [self addNote];
        [self initUI];
        [self setupUI];
        [self getMusicList];
    }
    return self;
}

-(void) initUI{
    songListImv = [[UIImageView alloc] init];
    songListImv.frame = CGRectMake(13.5, 13.0, 22, 22);
    [self addSubview:songListImv];
    songListImv.image = [UIImage imageNamed:@"Theme.bundle/icon_list"];
    
    //全部歌曲
    label_1 = [[UILabel alloc] init];
    label_1.frame = CGRectMake(42,15.0,80,22);
    label_1.numberOfLines = 0;
    [self addSubview:label_1];
    
    NSMutableAttributedString *label_1_Str = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("song_list_top_all_song") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    
    [label_1_Str addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18]} range:NSMakeRange(0, 4)];
    label_1.attributedText = label_1_Str;
    
    //共多少首
    label_2 = [[UILabel alloc] init];
    label_2.frame = CGRectMake(label_1.frame.origin.x+label_1.frame.size.width+2,16.5,100,17);
    label_2.numberOfLines = 0;
    [self addSubview:label_2];
    
    //暂无歌曲显示的图片
    imvNull = [[UIImageView alloc] initWithFrame:CGRectMake(songListImv.frame.origin.x+
                                                            songListImv.frame.size.width+36.5, label_1.frame.origin.y+label_1.frame.size.height+98, 250, 119.5)];
    imvNull.image = [UIImage imageNamed:@"Theme.bundle/local_img_empty"];
    imvNull.contentMode = UIViewContentModeCenter;
    [self addSubview:imvNull];
    imvNull.hidden = YES;

    
    //暂无本地音乐的文字
    label_music_null = [[UILabel alloc] init];
    label_music_null.frame = CGRectMake(imvNull.frame.origin.x+78,imvNull.frame.origin.y+imvNull.frame.size.height+12,120,15);
    label_music_null.numberOfLines = 0;
    [self addSubview:label_music_null];
    NSMutableAttributedString *label_music_null_str = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("local_music_none") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 16],NSForegroundColorAttributeName: [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1.0]}];
    label_music_null.attributedText = label_music_null_str;
    label_music_null.hidden = YES;
}

-(void)setupUI{
    if([UIScreen mainScreen].bounds.size.width == 320.0){
        _listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, label_1.frame.origin.y+label_1.frame.size.height+15, self.frame.size.width, self.frame.size.height-80)];
    }else{
        _listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, label_1.frame.origin.y+label_1.frame.size.height+15, self.frame.size.width, self.frame.size.height-30)];
    }
    _listTable.tableFooterView = [UIView new];
    _listTable.rowHeight = 60;
    _listTable.backgroundColor = [UIColor clearColor];
    _listTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    _listTable.dataSource = self;
    _listTable.delegate = self;
    [_listTable setSeparatorInset:(UIEdgeInsetsMake(0, 0, 0, 0))];
    [self addSubview:_listTable];
}

//获取本地音乐列表
-(void)getMusicList{
        [DFAction mainTask:^{
                self->_mAudioPlayer = [DFAudioPlayer sharedMe];
                self->_mItemArray   = self->_mAudioPlayer.mList;
                //[[JLUI_Cache sharedInstance] setPhoneArray:self->_mItemArray];
                
                if (self->_mItemArray > 0) {
                    [self->_listTable reloadData];
                    NSMutableAttributedString *label_2_Str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:kJL_TXT("all_song_number"),(unsigned long)self->_mItemArray.count] attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13],NSForegroundColorAttributeName:  [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1.0]}];
                    
                    [label_2_Str addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 13]} range:NSMakeRange(0, 4)];
                    
                    self->label_2.attributedText = label_2_Str;
                }
                
                if (self->_mItemArray == 0) {
                    self->imvNull.hidden = NO;
                    self->label_music_null.hidden = NO;
                }else{
                    self->imvNull.hidden = YES;
                    self->label_music_null.hidden = YES;
                }
        }];
}

#pragma mark <- tableview delegate ->
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _mItemArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SongListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SongListCell"];
    if (cell == nil) {
        cell = [[SongListCell alloc] init];
    }

    [cell.contentView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
    
    MusicOfPhoneMode *model = _mItemArray[indexPath.row];
    MusicOfPhoneMode *nowModel = [DFAudioPlayer currentPlayer].mNowItem;
    
    DFAudioPlayer_TYPE type = [DFAudioPlayer currentType];
    

    BOOL isTF = [[JLCacheBox cacheUuid:bleUUID] isTFType];
    if (nowModel.mIndex == model.mIndex && !isTF && type == DFAudioPlayer_TYPE_IPOD) {
        if ([[DFAudioPlayer sharedMe] mState] == DFAudioPlayer_PLAYING ||
            [[DFAudioPlayer sharedMe] mState] == DFAudioPlayer_PAUSE) {
            cell.songName.textColor = kColor_0000;//[UIColor colorWithRed:85/255.0 green:56/255.0 blue:227/255.0 alpha:1.0];
        }
        cell.animateImgv.hidden = NO;
        cell.animateImgv.animationImages = @[[UIImage imageNamed:@"Theme.bundle/list_play_01"],
                                             [UIImage imageNamed:@"Theme.bundle/list_play_02"],
                                             [UIImage imageNamed:@"Theme.bundle/list_play_03"],
                                             [UIImage imageNamed:@"Theme.bundle/list_play_04"]];
        cell.animateImgv.animationDuration = 0.7;
        cell.animateImgv.animationRepeatCount = 0;
        if ([[DFAudioPlayer sharedMe] mState] == DFAudioPlayer_PLAYING) {
            [cell.animateImgv startAnimating];
            cell.numberLab.hidden = YES;
        }else{
            [cell.animateImgv stopAnimating];
            [cell.animateImgv setImage:[UIImage imageNamed:@"Theme.bundle/list_play_01"]];
            cell.numberLab.hidden = YES;
        }
        
    }else{
        cell.songName.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
        cell.numberLab.textColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1.0];
        cell.animateImgv.hidden = YES;
        cell.numberLab.hidden = NO;
    }
    
    cell.numberLab.font = [UIFont systemFontOfSize:16];
    cell.numberLab.text = [NSString stringWithFormat:@"%ld",(long)(indexPath.row+1)];
    cell.songName.text = model.mTitle;
    cell.artistLab.text = model.mArtist;
    return cell;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*--- 关闭网络电台 ---*/
    [[NetworkPlayer sharedMe] didStop];
    
    /*--- 判断有无连经典蓝牙 ---*/
    NSDictionary *info = [JL_BLEMultiple outputEdrInfo];
    NSString *addr = info[@"ADDRESS"];
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    if ([addr isEqualToString:entity.mEdr]) {
        [self playMusic:indexPath];
        [JL_Tools post:@"kUI_FUNCTION_ACTION" Object:@(0)];
        [[JLCacheBox cacheUuid:bleUUID] setIsTFType:NO];
    }else{
        [DFUITools showText:kJL_TXT("connect_match_edr") onView:self delay:1.0];
    }
    
}


-(void)playMusic:(NSIndexPath *)indexPath{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    
    NSUInteger maxVol = model.maxVol;
    if (maxVol == 0) maxVol = 25;
    float val = (((float)model.currentVol)/((float)maxVol));
    
     
    NSLog(@"UI关闭ID3信息。33");
    [[JLCacheBox cacheUuid:bleUUID] setIsID3_PUSH:NO];
    [[JLCacheBox cacheUuid:bleUUID] setIsID3_PLAY:NO];
    [[JLCacheBox cacheUuid:bleUUID] setIsID3_ST:NO];
    [bleSDK.mBleEntityM.mCmdManager.mChargingBinManager cmdID3_PushEnable:NO];

    [DFAction delay:0.15 Task:^{
        DFAudioPlayer *player = [DFAudioPlayer sharedMe];
        [player didPause];
        [player didPlay:indexPath.row];
        
        /*--- 耳机用系统音量 ---*/
        if (entity.mType != JL_DeviceTypeTWS ) {
            NSLog(@"--->设备音量：%.1f",val);
            player.mPlayer.volume = val;
        }else{
            [DFAudioPlayer getPhoneVolume];
            NSLog(@"--->手机音量：%.1f",val);
            player.mPlayer.volume = [DFAudioPlayer getPhoneVolume];
        }
    }];

    [JL_Tools delay:0.2 Task:^{
        [self->_listTable reloadData];
    }];
}

-(void)scrollToNowMusic{
    if (_mItemArray.count == 0) return;
    
    DFAudioPlayer *player = [DFAudioPlayer sharedMe];
    NSInteger playIndex = player.play_index;
    NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:playIndex inSection:0];
    [_listTable scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];//cell滚动到选中指定cell位置
}

#pragma mark 媒体音乐播放状态
-(void)notePlayerState:(NSNotification *)note{
    [self->_listTable reloadData];
}

-(void)addNote{
    [JL_Tools add:kDFAudioPlayer_NOTE Action:@selector(notePlayerState:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

@end
