//
//  BianShenView.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/11/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^BianShenViewBlock)(NSInteger tag);
typedef void(^BianShenViewGroupBlock)(BOOL group);

@interface BianShenView : UIView

@property(nonatomic,strong) NSArray *bianShenArray;
@property(nonatomic,strong) NSArray *dianYinArray;

-(void)setKMaxRowCount:(NSInteger) maxRowCount WithItemCountPerRow:(NSInteger) itemCountPerRow;

-(void)onBianShenViewBlock:(BianShenViewBlock) block;
-(void)onBianShenViewGroupBlock:(BianShenViewGroupBlock) block;
@end

NS_ASSUME_NONNULL_END
