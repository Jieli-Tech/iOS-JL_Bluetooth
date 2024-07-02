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
    NSArray *sortArray;
    NSArray *doubleArray;
    NSArray *titleArray;
}

@end

@implementation HeadSetControlView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.tableView.rowHeight = 55.0;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerNib:[UINib nibWithNibName:@"DeviceInfoTVCell" bundle:nil] forCellReuseIdentifier:@"DeviceInfoTVCell"];
        [self addSubview:self.tableView];
        self.tableView.scrollEnabled = NO;
    }
    return self;
}

-(void)initWithDataWithSort:(NSArray<DeviceInfoUsage *>*)sort withDouble:(NSArray<DeviceInfoUsage *> *)doubleA{
    sortArray = sort;
    doubleArray = doubleA;
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 55) animated:NO];
}
-(void)initTitleData:(NSArray *)array{
    [JL_Tools mainTask:^{
        self->titleArray = array;
        [self->_tableView reloadData];
    }];
}

- (void)setFuncDict:(NSDictionary *)funcDict{
    _funcDict = funcDict;
    
    NSArray *arr0 = funcDict[@"key_settings"][@"key_action"];
    NSMutableArray *mtArray = [NSMutableArray new];
    for (NSDictionary *item in arr0) {
        NSEnumerator *enumerator = [item[@"title"] keyEnumerator];
        NSString *key;
        NSString *value;
        while ((key = [enumerator nextObject])) {
            if ([kJL_GET hasPrefix:key]) {
                value = item[@"title"][key];
                break;
            }else{
                value = item[@"title"][@"en"];
            }
        }
        if (value == nil) {
            value = @"unKnow";
            NSLog(@"unKnow value funcKey:%@",key);
        }
        [mtArray addObject:value];
    }
    [self initTitleData:mtArray];
}



-(NSString *)keySetting:(int)num withKey:(NSString *)func_key{
    NSArray *arr0 = self.funcDict[@"key_settings"][func_key];
    for (NSDictionary *item in arr0) {
        if ([item[@"value"] intValue] == num) {
            NSEnumerator *enumerator = [item[@"title"] keyEnumerator];
            NSString *key;
            NSString *value;
            while ((key = [enumerator nextObject])) {
                if ([kJL_GET hasPrefix:key]) {
                    value = item[@"title"][key];
                    return value;
                    break;
                }else{
                    value = item[@"title"][@"en"];
                }
                if (value == nil) {
                    value = @"unKnow";
                    NSLog(@"unKnow value：num %d, funcKey:%@",num,func_key);
                }
                return value;
            }
            break;
        }
    }
    NSLog(@"unKnow value2：num %d, funcKey:%@",num,func_key);
    if ([func_key isEqualToString:@"key_function"]) {
        if (num == 255) {
            return kJL_TXT("noise_control");
        }
    }
    return @"unKnow";
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
    lab.font = [UIFont fontWithName:(@"PingFangSC-Medium") size:13];
    lab.textColor = [UIColor colorWithRed:152/255.0 green:152/255.0 blue:152/255.0 alpha:1.0];
    if(titleArray.count>section){
        lab.text = titleArray[section];
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
    
    cell.funcTitle.text = [self keySetting:usage.directionType+1 withKey:@"key_num"];
    cell.detailTitle.text = [self keySetting:usage.value withKey:@"key_function"];//usage.type;
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
