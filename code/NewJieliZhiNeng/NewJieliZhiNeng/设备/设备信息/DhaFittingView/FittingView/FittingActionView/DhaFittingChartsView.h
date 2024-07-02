//
//  DhaFittingChartsView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/1.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DhaSqlite.h"

typedef NS_ENUM(NSUInteger, DHAEarType) {
    DHAEarTypeBoth,
    DHAEarTypeLeft,
    DHAEarTypeRight,
};

NS_ASSUME_NONNULL_BEGIN

@protocol DhaFittingFinishPtl <NSObject>

-(void)dhaFittingFinish:(NSArray <FittingMgr *> *)results;

@end

@interface DhaFittingChartsView : UIView

@property(nonatomic,weak)id<DhaFittingFinishPtl> delegate;

@property(nonatomic,strong)DhaFittingSql *dhaSqlFitter;

@property(nonatomic,assign)BOOL isFitting;

@property(nonatomic,assign)DHAEarType dhaType;

-(void)beginFitting;

-(void)saveToSql;

@end

NS_ASSUME_NONNULL_END
