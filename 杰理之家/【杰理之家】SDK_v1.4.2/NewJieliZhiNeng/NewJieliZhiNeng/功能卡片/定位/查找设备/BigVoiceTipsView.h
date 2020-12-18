//
//  BigVoiceTipsView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/23.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol VoiceTipsDelegate <NSObject>

-(void)voiceDidSelectWith:(NSInteger)index;

@end

@interface BigVoiceTipsView : UIView

@property(nonatomic,strong)NSString *title;
@property(nonatomic,strong)NSString *message;
@property(nonatomic,weak)id<VoiceTipsDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
