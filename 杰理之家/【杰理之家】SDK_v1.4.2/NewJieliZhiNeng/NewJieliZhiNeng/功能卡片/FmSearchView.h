//
//  FmSearchView.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FmSearchViewtBlock)(NSInteger index);

@interface FmSearchView : UIView
+(void)showMeWithBlock:(FmSearchViewtBlock)blk;
+(void)showMeCollectedView:(BOOL)type;
@end

NS_ASSUME_NONNULL_END
