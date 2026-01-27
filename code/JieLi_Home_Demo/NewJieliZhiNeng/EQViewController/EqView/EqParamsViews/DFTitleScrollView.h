//
//  DFTitleScrollView.h
//  TestUIDemo
//
//  Created by 杰理科技 on 2020/5/27.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DFTitleScrollViewBlock)(NSInteger index);


@interface DFTitleScrollView : UIView
-(void)reloadDataArray:(NSArray*)array;
-(void)setTitleScrollViewSelectIndex:(DFTitleScrollViewBlock)block;
-(void)setSubIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
