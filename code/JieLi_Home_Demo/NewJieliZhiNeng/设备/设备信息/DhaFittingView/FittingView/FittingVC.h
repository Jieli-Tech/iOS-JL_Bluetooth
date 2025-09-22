//
//  FittingVC.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/30.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "FittingBasicVC.h"
#import "DhaSqlite.h"
#import "DhaFittingChartsView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FittingVC : FittingBasicVC

@property(nonatomic,strong)DhaFittingSql *dhaFitter;

@property(nonatomic,assign)DHAEarType type;

@property(nonatomic,assign)BOOL isCache;

@end

NS_ASSUME_NONNULL_END
