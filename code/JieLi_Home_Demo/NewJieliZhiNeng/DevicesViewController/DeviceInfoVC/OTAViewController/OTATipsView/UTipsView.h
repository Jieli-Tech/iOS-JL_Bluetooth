//
//  UTipsView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/25.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UTipViewDelegate <NSObject>

-(void)UtipsOkWithIndex:(NSInteger) index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface UTipsView : UIView
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;
@property (weak, nonatomic) IBOutlet UIImageView *tipsIcon;
@property (weak, nonatomic) id<UTipViewDelegate> delegate;
@property (assign, nonatomic)NSInteger index;

@end

NS_ASSUME_NONNULL_END
