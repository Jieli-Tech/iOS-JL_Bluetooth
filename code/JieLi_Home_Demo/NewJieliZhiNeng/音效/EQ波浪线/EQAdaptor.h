//
//  EQAdaptor.h
//  newAPP
//
//  Created by EzioChan on 2020/6/5.
//  Copyright © 2020 Ezio. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef void(^RESULT)(NSArray *pointArray);

@interface EQAdaptor : NSObject//{

@property(nonatomic,strong)NSArray *cfArray;

/// 设置宽高
/// @param w 宽
/// @param h 高
-(void)setSize:(int)w hight:(int)h;

/// 初始化计算数组
/// @param eq EQ数组
/// @param h 高度
/// @param w 宽度
- (void)initWithArray:(NSArray *)eq withHight:(int)h width:(int)w;

/// 计算单个eq值变化
/// @param num 增益
/// @param index 对应数组中的序号
/// @param result 新的CGPoint数组用来绘图
-(void)calculaterForOne:(int)num withIndex:(int)index result:(RESULT)result;


/// 计算单个或多个eq的值
/// @param num eq值
/// @param index 序号
/// @param eq EQ数组
/// @param result  新的CGPoint数组用来绘图
-(void)calculaterForOne:(int)num withIndex:(int)index eqArray:(NSArray *)eq result:(RESULT)result;

/// 全部的eq的值
/// @param num eq值
/// @param index 序号
/// @param eq EQ数组
/// @param result  新的CGPoint数组用来绘图
-(void)calculaterForAll:(int)num withIndex:(int)index eqArray:(NSArray *)eq result:(RESULT)result;


/// 查询所有的中心频率
-(NSArray *)getCenterFrequencys;

@end

NS_ASSUME_NONNULL_END
