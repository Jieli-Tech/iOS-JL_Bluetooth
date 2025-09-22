//
//  FunctionsView.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FunctionsViewBlock)(NSInteger index);


@interface FunctionsView : UIView

@property(nonatomic,strong)NSArray *dataArray;
@property(nonatomic,assign)NSInteger selectIndex;

-(void)setFunctionsViewDataArray:(NSArray*)array;
-(void)setFunctionsViewSelectIndex:(NSInteger)index;
-(void)setFunctionsViewSelectName:(NSString *)name;
-(void)onFunctionViewSelectIndex:(FunctionsViewBlock)block;
@end

NS_ASSUME_NONNULL_END
