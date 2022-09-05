//
//  MindListView.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JL_BLEKit/JL_BLEKit.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface MindListView : UIView

@property(nonatomic,weak)DFAudioPlayer *mAudioPlayer;
@property(nonatomic,weak)NSMutableArray *mItemArray;
@property(nonatomic,strong)UITableView *listTable;

-(void)getMusicList; //获取本地音乐列表
-(void)scrollToNowMusic;

@end

NS_ASSUME_NONNULL_END
