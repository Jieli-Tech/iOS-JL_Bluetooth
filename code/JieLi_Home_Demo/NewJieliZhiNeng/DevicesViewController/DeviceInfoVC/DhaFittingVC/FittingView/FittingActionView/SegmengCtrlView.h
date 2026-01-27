//
//  SegmengCtrlView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/30.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SegmengCtrlViewDelegate <NSObject>

-(void)segmengDidTouchBtn:(int)index;

@end

@interface SegmengCtrlView : UIView

@property(nonatomic,weak)id<SegmengCtrlViewDelegate> delegate;

-(void)setBtnTo:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
