//
//  DebugBasicViewController.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/10/9.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *localCellIdentify = @"localCellIdentify";

@interface DebugBasicViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSMutableArray *itemArray;
@property(nonatomic,strong)UITableView *subTable;

-(void)backBtnAction;
-(void)initData;
@end

NS_ASSUME_NONNULL_END
