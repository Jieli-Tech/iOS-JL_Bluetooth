//
//  KalaokView.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/11/18.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KalaokView : UIView

@property(nonatomic,strong) NSArray *qiFenArray;

-(void)setKMaxRowCount:(NSInteger) maxRowCount WithItemCountPerRow:(NSInteger) itemCountPerRow;

@end

NS_ASSUME_NONNULL_END
