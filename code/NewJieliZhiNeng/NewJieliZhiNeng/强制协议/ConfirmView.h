//
//  ConfirmView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/21.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ConfirmViewDelegate <NSObject>

-(void)confirmCancelBtnAction;
-(void)confirmDidSelect:(int)index;
-(void)confirmConfirmBtnAction;

@end
@interface ConfirmView : UIView
@property(nonatomic,weak)id<ConfirmViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
