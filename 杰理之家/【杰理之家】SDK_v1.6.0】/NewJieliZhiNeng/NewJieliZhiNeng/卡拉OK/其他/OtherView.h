//
//  OtherView.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/11/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^OtherViewBlock)(NSInteger tag);
@interface OtherView : UIView


@property(nonatomic,strong) NSArray *otherArray;

-(void)setKMaxRowCount:(NSInteger) maxRowCount WithItemCountPerRow:(NSInteger) itemCountPerRow;

-(void)onOtherViewBlock:(OtherViewBlock) block;

@end

NS_ASSUME_NONNULL_END
