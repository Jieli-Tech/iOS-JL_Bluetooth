//
//  NormalSettingView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "NormalSettingView.h"
#import "DeviceInfoTools.h"
#import "DeviceInfoTVCell.h"

@interface NormalSettingView()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *normalArray;
    UITableView *normalTable;
}
@end

@implementation NormalSettingView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        normalTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        normalTable.rowHeight = 55.0;
        normalTable.delegate = self;
        normalTable.dataSource =self;
        normalTable.scrollEnabled = NO;
        normalTable.backgroundColor = [UIColor clearColor];
        normalTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        [normalTable registerNib:[UINib nibWithNibName:@"DeviceInfoTVCell" bundle:nil] forCellReuseIdentifier:@"normalTableCell"];
        [self addSubview:normalTable];
    }
    return self;
}

-(void)config:(NSArray<NormalSettingObject *>*)array{
    normalArray = array;
    [normalTable reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return normalArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceInfoTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"normalTableCell" forIndexPath:indexPath];
    NormalSettingObject *item = normalArray[indexPath.row];
    cell.imgv.image = item.img;
    cell.funcTitle.text = item.funcStr;
    cell.detailTitle.text = item.detailStr;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_delegate respondsToSelector:@selector(noremalSetting:Selected:)]) {
        [_delegate noremalSetting:self Selected:normalArray[indexPath.row]];
    }
}





@end

@implementation NormalSettingObject



@end
