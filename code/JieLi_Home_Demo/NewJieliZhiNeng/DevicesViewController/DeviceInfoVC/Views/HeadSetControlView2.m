//
//  HeadSetControlView2.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/5/18.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import "HeadSetControlView2.h"
#import "DeviceInfoTVCell.h"
#import "JL_RunSDK.h"
#import "DeviceInfoTools.h"
#import "HeadTitleView.h"

@interface HeadSetControlView2()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *sortArray;
    NSArray *doubleArray;
    NSArray *titleArray;
    NSArray *centerArray;
    NSDictionary *myFuncDict;
    HeadTitleView *headView;
}

@end

@implementation HeadSetControlView2

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        titleArray = @[kJL_TXT("key_func_setting")];
        headView = [[HeadTitleView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45.0)];
    }
    return self;
}

-(void)initWithDataWithSort:(NSArray<DeviceInfoUsage *>*)sort withDouble:(NSArray<DeviceInfoUsage *> *)doubleA{
    centerArray = @[sort[0],doubleA[0]];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointMake(0, 55) animated:NO];
}
-(void)initTitleData:(NSArray *)array{
    [JL_Tools mainTask:^{
        self->titleArray = array;
        [self.tableView reloadData];
    }];
}




- (void)setFuncDict:(NSDictionary *)funcDict{
    myFuncDict = funcDict;
    NSArray *arr0 = funcDict[@"key_settings"][@"key_num"];
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
        }
        [mtArray addObject:value];
    }
    [self initTitleData:mtArray];
}



-(NSString *)keySetting:(int)num withKey:(NSString *)func_key{
    NSArray *arr0 = myFuncDict[@"key_settings"][func_key];
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
                    if([[JL_RunSDK sharedMe] mBleEntityM].mProtocolType == PTLVersion){
                        return kJL_TXT("noise_control");
                    }
                }
                return value;
            }
            break;
        }
    }
    if([[JL_RunSDK sharedMe] mBleEntityM].mProtocolType == PTLVersion){
        return kJL_TXT("noise_control");
    }
    return @"unKnow";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
      return centerArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    headView.titleStr = titleArray[section];
    
    return headView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 45.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceInfoTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceInfoTVCell" forIndexPath:indexPath];
    DeviceInfoUsage *usage = centerArray[indexPath.row];
    
    if (indexPath.row == 0) {
        cell.imgv.image = [UIImage imageNamed:@"Theme.bundle/icon_click"];
    }else{
        cell.imgv.image = [UIImage imageNamed:@"Theme.bundle/icon_dblclick"];
    }
    
    cell.funcTitle.font = [UIFont systemFontOfSize:14];
    cell.funcTitle.text = [self keySetting:(int)indexPath.row+1 withKey:@"key_action"];
    cell.detailTitle.text = [self keySetting:usage.value withKey:@"key_function"];//usage.type;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.backgroundColor = [UIColor whiteColor];
    return cell;
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DeviceInfoUsage *usage = centerArray[indexPath.row];
    usage.titleStr = titleArray[0];
    usage.tapNameStr = [self keySetting:(int)indexPath.row+1 withKey:@"key_action"];
    if ([self.delegate respondsToSelector:@selector(headSetControlDidTouch:)]) {
        [self.delegate headSetControlDidTouch:usage];
    }
    
}


@end
