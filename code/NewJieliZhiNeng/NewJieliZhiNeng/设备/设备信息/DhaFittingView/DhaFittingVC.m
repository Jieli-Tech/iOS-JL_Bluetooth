//
//  DhaFittingVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/6/30.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DhaFittingVC.h"
#import "DhaFitHeadView.h"
#import "JLUI_Effect.h"
#import "RecordTableCell.h"
#import "FitStepOneVC.h"
#import "DhaSqlite.h"
#import "FittingResultVC.h"


@interface DhaFittingVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    DhaFitHeadView *headCell;
    UILabel *recordLab;
    UITableView *recordView;
    NSMutableArray *recordList;
    BOOL canbeEdit;
   
}


@end

@implementation DhaFittingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    recordList = [NSMutableArray new];
    [self steptUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stepData) name:@"DHA_SQL_UPDATE" object:nil];
    canbeEdit = true;
    [self stepData];
  
}




-(void)stepData{
    [recordList removeAllObjects];
#if (DHAUITest == 0)
    JLModel_Device *md = [[[JL_RunSDK sharedMe] mBleEntityM].mCmdManager outputDeviceModel];
    int number = md.dhaFitInfo.ch_num;
#elif (DHAUITest == 1)
    int number = 6;
#endif
//    number = 6;
    [[DhaSqlite share] checkListBy:[[JL_RunSDK sharedMe] mBleEntityM].mUUID Number:number Result:^(NSArray<DhaFittingSql *> * _Nonnull list) {
        [self->recordList setArray:list];
        [self->recordView reloadData];
    }];
    
}

-(void)steptUI{
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Theme.bundle/icon_return.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backBtnAction)];
    leftBtn.tintColor = [UIColor grayColor];
    [self.navigationItem setLeftBarButtonItem:leftBtn];
    self.title = kJL_TXT("hearing_aid_fitting");
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F8FAFC"];
    
    headCell = [[DhaFitHeadView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:headCell];
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectGesAction)];
    [headCell addGestureRecognizer:ges];
    
    recordLab = [[UILabel alloc] init];
    recordLab.textColor = [UIColor colorFromHexString:@"#242424"];
    recordLab.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    recordLab.text = kJL_TXT("fitting_records");
    [self.view addSubview:recordLab];
    
    recordView = [[UITableView alloc] init];
    recordView.delegate = self;
    recordView.dataSource = self;
    recordView.rowHeight = 70;
    recordView.tableFooterView = [UIView new];
    recordView.separatorColor = [UIColor clearColor];
    recordView.showsVerticalScrollIndicator = NO;
    recordView.backgroundColor = [UIColor clearColor];
    [recordView registerClass:[RecordTableCell class] forCellReuseIdentifier:@"dhaRecord"];
    [self.view addSubview:recordView];
    
    [self makeLayout];
    
    
}

-(void)makeLayout{
    [headCell mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(kJL_HeightNavBar+16);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.right.equalTo(self.view.mas_right).offset(-15);
        make.height.offset(121);
    }];
    [JLUI_Effect addShadowOnView:headCell];
    headCell.layer.masksToBounds = YES;
    
    [recordLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->headCell.mas_bottom).offset(16);
        make.left.equalTo(self.view.mas_left).offset(24);
        make.right.equalTo(self.view.mas_right).offset(-24);
        make.height.offset(48);
    }];
    
    [recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->recordLab.mas_bottom).offset(0);
        make.left.equalTo(self.view.mas_left).offset(8);
        make.right.equalTo(self.view.mas_right).offset(-8);
        make.bottom.equalTo(self.view.mas_bottom).offset(-kJL_HeightStatusBar);
    }];
    
}





-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:true];
}



-(void)goBackToRoot{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)selectGesAction{
    FitStepOneVC *vc = [[FitStepOneVC alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return recordList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RecordTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dhaRecord" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[RecordTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dhaRecord"];
    }
    DhaFittingSql *item = recordList[indexPath.row];
    
    if ([item.type isEqualToString: DoubleFitter]) {
        cell.typeLab.text = kJL_TXT("dha_Both");
        cell.typeLab.textColor = [UIColor colorFromHexString:@"#805BEB"];
        cell.typeLab.font = [UIFont systemFontOfSize:12];
        cell.typeLab.backgroundColor = [UIColor colorFromHexString:@"#F2F1F8"];
        cell.typeLab.layer.borderColor = [UIColor colorFromHexString:@"#C5B2FD"].CGColor;
        cell.typeLab.layer.borderWidth = 1.0;
    }
    if ([item.type isEqualToString:LeftFitter]) {
        cell.typeLab.text = kJL_TXT("dha_Left");
        cell.typeLab.textColor = [UIColor colorFromHexString:@"#1677FF"];
        cell.typeLab.font = [UIFont systemFontOfSize:12];
        cell.typeLab.backgroundColor = [UIColor colorFromHexString:@"#EDF5FF"];
        cell.typeLab.layer.borderColor = [UIColor colorFromHexString:@"#97C3FF"].CGColor;
        cell.typeLab.layer.borderWidth = 1.0;
    }
    
    if ([item.type isEqualToString:RightFitter]) {
        cell.typeLab.text = kJL_TXT("dha_Right");
        cell.typeLab.textColor = [UIColor colorFromHexString:@"#FF9E39"];
        cell.typeLab.font = [UIFont systemFontOfSize:12];
        cell.typeLab.backgroundColor = [UIColor colorFromHexString:@"#FFF1EB"];
        cell.typeLab.layer.borderColor = [UIColor colorFromHexString:@"#FFB999"].CGColor;
        cell.typeLab.layer.borderWidth = 1.0;
    }
    
    cell.recordLab.text = item.recordName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    DhaFittingSql *item = self->recordList[indexPath.row];
    if (item.isFinish){
        FittingResultVC *vc = [[FittingResultVC alloc] init];
        vc.results = [item beFitterMgr];
        vc.exitNumber = 1;
        vc.fitResultSql = item;
        [self.navigationController pushViewController:vc animated:true];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cell-->%s:%d",__func__,canbeEdit);
    return canbeEdit;
}




-(void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath{

    canbeEdit = false;
    [self setupSlideBtnWithEditingIndexPath:indexPath];
    NSLog(@"cell-->%s:%d",__func__,canbeEdit);

}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cell-->%s:%d",__func__,canbeEdit);
    canbeEdit = true;
}



- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cell-->%s:%d",__func__,canbeEdit);
    return UITableViewCellEditingStyleDelete;
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cell-->%s:%d",__func__,canbeEdit);
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:kJL_TXT("delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        // 删除点击后的操作
        [tableView setEditing:NO animated:YES];
        DhaFittingSql *item = self->recordList[indexPath.row];
        [[DhaSqlite share] remove:item];
        [self->recordList removeObjectAtIndex:indexPath.row];
        [self stepData];
    }];
    action.backgroundColor = [UIColor clearColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self->canbeEdit == false) {
            [self setupSlideBtnWithEditingIndexPath:indexPath];
        }
    });
    return @[action];
}

//- (void)tableView:(UITableView *)tableView
//  willDisplayCell:(UITableViewCell *)cell
//forRowAtIndexPath:(NSIndexPath *)indexPath{
//    [self setupSlideBtnWithEditingIndexPath:indexPath];
//    
//}

//MARK: - 设置左滑按钮的样式
- (void)setupSlideBtnWithEditingIndexPath:(NSIndexPath *)editingIndexPath {
    if (@available(iOS 13.0, *)) {
        for (UIView *subView in recordView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"_UITableViewCellSwipeContainerView")] && [subView.subviews count] >= 1) {
                // 修改图片
                UIView *remarkContentView = subView.subviews.firstObject;
                [self setupRowActionView:remarkContentView];
            }
        }
        return;
    }

    // 判断系统是否是 iOS11 及以上版本
    if (@available(iOS 11.0, *)) {
        for (UIView *subView in recordView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UISwipeActionPullView")] && [subView.subviews count] >= 1) {
                // 修改图片
                UIView *remarkContentView = subView;
                [self setupRowActionView:remarkContentView];
            }
        }
        return;
    }

    // iOS11 以下的版本
    RecordTableCell *cell = [recordView cellForRowAtIndexPath:editingIndexPath];
    for (UIView *subView in cell.subviews) {
        if ([subView isKindOfClass:NSClassFromString(@"UITableViewCellDeleteConfirmationView")] && [subView.subviews count] >= 1) {
            // 修改图片
            UIView *remarkContentView = subView;
            [self setupRowActionView:remarkContentView];
        }
    }
}

- (void)setupRowActionView:(UIView *)rowActionView {
    // 切割圆角
    rowActionView.layer.cornerRadius = 10;
    rowActionView.layer.masksToBounds = true;
    // 改变父 View 的frame，这句话是因为我在 contentView 里加了另一个 View，为了使划出的按钮能与其达到同一高度
    CGRect frame = rowActionView.frame;
    NSLog(@"frame\n x:%f,y:%f,w:%f,h:%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    if (frame.size.width>0) {
        frame.origin.y += 7;
        frame.size.height -= 13;
    }
    rowActionView.frame = frame;
    // 拿到按钮,设置图片
    UIButton *button = rowActionView.subviews.firstObject;
    [button setTitle:kJL_TXT("delete") forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor redColor]];
}





@end
