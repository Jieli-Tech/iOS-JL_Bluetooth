//
//  DebugBasicViewController.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/10/9.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "DebugBasicViewController.h"

@interface DebugBasicViewController ()



@end



@implementation DebugBasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _naviView = [[NavTopView alloc] init];
    _naviView.titleLab.text = @"Debug";
    [_naviView.existBtn addTarget:self action:@selector(backBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_naviView];
    
    [_naviView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@kJL_HeightNavBar);
    }];
    
    _itemArray = [NSMutableArray new];
    [self initData];
    [self initUI];
    
}

-(void)initData{
    
}



-(void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    _subTable = [UITableView new];
    _subTable.delegate = self;
    _subTable.dataSource = self;
    _subTable.rowHeight = 50;
    _subTable.tableFooterView = [UIView new];
    [_subTable registerClass:[UITableViewCell self] forCellReuseIdentifier:localCellIdentify];
    [self.view addSubview:_subTable];
    
    [_subTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.naviView.mas_bottom).offset(8);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
}



-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)setItemArray:(NSMutableArray *)itemArray{
    _itemArray = itemArray;
    [_subTable reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _itemArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:localCellIdentify forIndexPath:indexPath];
    cell.textLabel.text = self.itemArray[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}




@end
