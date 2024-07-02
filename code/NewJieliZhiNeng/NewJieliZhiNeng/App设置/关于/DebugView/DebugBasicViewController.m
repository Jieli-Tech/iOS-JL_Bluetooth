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
    
    self.title = @"Debug";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if(@available(iOS 15.0, *)) {
        //设置导航颜色
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        //设置标题字体颜色
        [appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkTextColor], NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18]}];
        //去掉导航栏线条
        appearance.shadowColor= [UIColor clearColor];
    }
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Theme.bundle/icon_return.png"] style:UIBarButtonItemStyleDone target:self action:@selector(backBtnAction)];
    leftBtn.tintColor = [UIColor grayColor];
    [self.navigationItem setLeftBarButtonItem:leftBtn];
    
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
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
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
