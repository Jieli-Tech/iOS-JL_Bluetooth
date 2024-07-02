//
//  JLShareLogViewController.m
//  JL_OTA
//
//  Created by EzioChan on 2022/10/17.
//  Copyright © 2022 Zhuhia Jieli Technology. All rights reserved.
//

#import "JLShareLogViewController.h"
#import "TipsDeleteView.h"
#import "JLShareDetailViewController.h"

@interface JLShareLogViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)TipsDeleteView *deleteView;


@end


@implementation JLShareLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUIOverWrite];
    
}

-(void)initData{
    self.itemArray = [NSMutableArray new];
    NSString *basicPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true) lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:basicPath error:nil];
    for (NSString *path in files) {
        if([path hasSuffix:@".txt"]){
            NSString *newPath = [NSString stringWithFormat:@"%@/%@",basicPath,path];
            [self.itemArray addObject:newPath];
        }
    }
    [self.subTable reloadData];
}

-(void)initUIOverWrite{
    self.title = @"log file";
    UIImage *img = [[UIImage imageNamed:@"Theme.bundle/icon_return.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStyleDone target:self action:@selector(backBtnAction)];
    leftBtn.tintColor = [UIColor grayColor];
    [self.navigationItem setLeftBarButtonItem:leftBtn];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"clean log" style:UIBarButtonItemStyleDone target:self action:@selector(removeAllLog)];
    [rightBtn setTintColor:[UIColor blueColor]];
    [self.navigationItem setRightBarButtonItem:rightBtn];
    self.subTable.hidden = NO;
    
    
    UIWindow *windows = [[UIApplication sharedApplication] keyWindow];
    _deleteView = [TipsDeleteView new];
    [windows addSubview:_deleteView];
    [_deleteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(windows.mas_top).offset(0);
        make.bottom.equalTo(windows.mas_bottom).offset(0);
        make.left.equalTo(windows.mas_left).offset(0);
        make.right.equalTo(windows.mas_right).offset(0);
    }];
    _deleteView.hidden = YES;
    [self.deleteView addObserver:self forKeyPath:@"hidenStatus" options:NSKeyValueObservingOptionNew context:nil];
    
}


-(void)backBtnAction{
    [self.navigationController popViewControllerAnimated:true];
}

-(void)removeAllLog{
    _deleteView.hidden = NO;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"hidenStatus"]){
        [self initData];
        [self.subTable reloadData];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:localCellIdentify forIndexPath:indexPath];
    cell.textLabel.text = [self.itemArray[indexPath.row] lastPathComponent];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    JLShareDetailViewController *vc = [[JLShareDetailViewController alloc] init];
    vc.path = self.itemArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
