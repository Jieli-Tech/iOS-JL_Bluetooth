//
//  DMusicHandler.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JL_RunSDK.h"

typedef enum : NSUInteger {
    DM_ERROR_Max_Fold,
    DM_ERROR_Unknown
} DM_ERROR;
NS_ASSUME_NONNULL_BEGIN
@protocol DMHandlerDelegate <NSObject>

-(void)dmHandleWithTabTitleArray:(NSArray<JLModel_File *> *)modelA;

-(void)dmHandleWithItemModelArray:(NSArray<JLModel_File *> *)modelB;

-(void)dmHandleWithPlayItemOK;

-(void)dmLoadFailed:(DM_ERROR)err;

-(void)dmCardMessageDismiss:(NSArray *)nowArray;

@end

@interface DMusicHandler : NSObject
@property(nonatomic,weak)id<DMHandlerDelegate> delegate;
@property(nonatomic,weak)JL_EntityM *nowEntity;
+(instancetype)sharedInstance;

-(void)loadModeData:(JL_CardType)type;
/// 点击对应的Title时更新目录
/// @param model fileModel
-(void)tabArraySelect:(JLModel_File *)model;

/// 请求目录列表或者点播该文件
/// @param model jlfilemodel
/// @param n 数目
-(void)requestWith:(JLModel_File *)model Number:(NSInteger)n;

/// 在同一个根目录下加载更多的数据
/// @param num 行数
-(void)requestModelBy:(NSInteger)num;


@end

NS_ASSUME_NONNULL_END
