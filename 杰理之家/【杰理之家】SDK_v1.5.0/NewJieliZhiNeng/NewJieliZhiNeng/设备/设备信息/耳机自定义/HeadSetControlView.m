//
//  HeadSetControlView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "HeadSetControlView.h"
#import "DeviceInfoTVCell.h"
#import "JL_RunSDK.h"
#import "DeviceInfoTools.h"

@interface HeadSetControlView()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *tableView;
    NSArray *sortArray;
    NSArray *doubleArray;
    NSArray *itemArray;
}

@end

@implementation HeadSetControlView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        tableView.rowHeight = 55.0;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [tableView registerNib:[UINib nibWithNibName:@"DeviceInfoTVCell" bundle:nil] forCellReuseIdentifier:@"DeviceInfoTVCell"];
        [self addSubview:tableView];
        tableView.scrollEnabled = NO;
    }
    return self;
}

-(void)initWithDataWithSort:(NSArray<DeviceInfoUsage *>*)sort withDouble:(NSArray<DeviceInfoUsage *> *)doubleA{
    sortArray = sort;
    doubleArray = doubleA;
    [tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
          case 0:
              return sortArray.count;
              break;
          case 1:{
              return doubleArray.count;
          }break;
          default:
              return 0;
              break;
      }
      return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45.0)];
    newView.backgroundColor = [UIColor clearColor];
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, self.frame.size.width, 45)];
    lab.font = [UIFont boldSystemFontOfSize:15];
    lab.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
    lab.text = @"";
    if (section == 0) {
        lab.text = kJL_TXT("短按耳机");
    }else{
        lab.text = kJL_TXT("轻点两下耳机");
    }
    [newView addSubview:lab];
    return newView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceInfoTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceInfoTVCell" forIndexPath:indexPath];
    DeviceInfoUsage *usage;
    if (indexPath.section == 0) {
        usage = sortArray[indexPath.row];
    }else{
        usage = doubleArray[indexPath.row];
    }
    if (usage.directionType == 0) {
        cell.imgv.image = [UIImage imageNamed:@"Theme.bundle/mes_icon_left"];
    }else{
        cell.imgv.image = [UIImage imageNamed:@"Theme.bundle/mes_icon_right"];
    }
    
    cell.funcTitle.text = usage.title;
    cell.detailTitle.text = usage.type;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.backgroundColor = [UIColor whiteColor];
    return cell;
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DeviceInfoUsage *usage;
    if (indexPath.section == 0) {
        usage = sortArray[indexPath.row];
    }else{
        usage = doubleArray[indexPath.row];
    }
    
    if ([_delegate respondsToSelector:@selector(headSetControlDidTouch:)]) {
        [_delegate headSetControlDidTouch:usage];
    }
    
}




@end
