//
//  ToolViewMusic.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
#import "JL_RunSDK.h"

NS_ASSUME_NONNULL_BEGIN



@protocol ToolViewMusicDelegate <NSObject>
-(void)enterList:(UIButton *)btn;
@end

@interface ToolViewMusic : UIView
@property (weak, nonatomic) IBOutlet UILabel *mTimeStart;
@property (weak, nonatomic) IBOutlet UILabel *mTimeEnd;
@property (weak, nonatomic) IBOutlet UILabel *mSonyName;
@property (strong, nonatomic) DFLabel *mSonyName_0;
@property (strong, nonatomic) DFLabel *mSonyName_1;
@property (strong, nonatomic) DFLabel *mSonyName_2;

@property (weak, nonatomic) IBOutlet UISlider *mProgressView;

@property (assign, nonatomic) id <ToolViewMusicDelegate> delegate;
-(void)chooseDiffMusic;
@end

NS_ASSUME_NONNULL_END
