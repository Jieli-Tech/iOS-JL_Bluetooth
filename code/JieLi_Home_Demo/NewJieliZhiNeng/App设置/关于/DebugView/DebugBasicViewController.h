//
//  DebugBasicViewController.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/10/9.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavTopView.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *localCellIdentify = @"localCellIdentify";

@interface DebugBasicViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSMutableArray *itemArray;
@property(nonatomic,strong)UITableView *subTable;
@property(nonatomic, strong)  NavTopView*naviView;

-(void)backBtnAction;
-(void)initData;
-(void)initUI;
@end

NS_ASSUME_NONNULL_END
