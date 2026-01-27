//
//  FittingResultVC.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/2.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "FittingBasicVC.h"


NS_ASSUME_NONNULL_BEGIN

@interface FittingResultVC : FittingBasicVC

@property(nonatomic,strong)NSArray<FittingMgr *> *results;

@property(nonatomic,strong)DhaFittingSql *fitResultSql;

@property(nonatomic,strong)NSString *titleString;

@property(nonatomic,assign)NSInteger exitNumber;

@property(nonatomic,assign)BOOL isCache;

@end

NS_ASSUME_NONNULL_END
