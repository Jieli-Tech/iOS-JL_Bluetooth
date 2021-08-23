//
//  DanyinView.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/11/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DanyinView.h"
#import "JL_RunSDK.h"
#import "Headphonecell.h"

@interface DanyinView()<UITableViewDelegate,UITableViewDataSource>{
    float  sW;
    float  sH;
    
    UITableView *subTableView;
    NSArray     *dataArray;
    NSArray     *indexArray;
    UIButton    *closeBtn;
    JL_RunSDK   *bleSDK;
    
    BOOL selectFlag;
    NSIndexPath *clickIndexPath;
}
@end

@implementation DanyinView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = frame;
        sW = frame.size.width;
        sH = frame.size.height;
        selectFlag = NO;
        [self addNote];
        bleSDK = [JL_RunSDK sharedMe];
    }
    return self;
}

-(void)loadDanyinList:(NSArray *)danYinArray{
    subTableView = [[UITableView alloc] init];
    subTableView.layer.cornerRadius = 10;
    subTableView.layer.masksToBounds= YES;
    subTableView.frame = CGRectMake(0, sH, sW, 580.0);
    subTableView.backgroundColor = [UIColor whiteColor];
    subTableView.tableFooterView = [UIView new];
    subTableView.showsVerticalScrollIndicator = NO;
    subTableView.rowHeight  = 60.0;
    subTableView.dataSource = self;
    subTableView.delegate   = self;
    [self addSubview:subTableView];
    
    NSMutableArray *array = [NSMutableArray new];
    NSMutableArray *mIndexArray = [NSMutableArray new];
    for (NSDictionary *dic in danYinArray) {
        NSString *name;
        if([kJL_GET hasPrefix:@"zh"]){
            name = dic[@"title"][@"zh"];
        }else{
            name = dic[@"title"][@"en"];
        }
        [array addObject:name];
        if(dic[@"index"]!=nil){
            [mIndexArray addObject:dic[@"index"]];
        }
    }
    
    dataArray = array;
    indexArray = mIndexArray;
    
    self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.3];
    
    closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,subTableView.frame.origin.y+subTableView.frame.size.height-55,sW,55)];
    [closeBtn setTitle:kJL_TXT("关闭") forState:UIControlStateNormal];
    
    [subTableView setTableFooterView:closeBtn];

    closeBtn.backgroundColor = [UIColor whiteColor];
    [closeBtn setTitleColor: kDF_RGBA(36, 36, 36, 1.0) forState:UIControlStateNormal];
    [closeBtn.titleLabel setFont:[UIFont fontWithName:@"System" size:15]];
    [closeBtn addTarget:self action:@selector(dismissMe:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *topBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,[DFUITools screen_2_W],self->sH-580.0)];
    [topBtn addTarget:self action:@selector(dismissMe:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:topBtn];
    topBtn.backgroundColor = [UIColor clearColor];
}

-(void)showMe{
    [UIView animateWithDuration:0.2 animations:^{
        self->subTableView.frame = CGRectMake(0, self->sH-580.0, self->sW, 580.0);
    }];
}

-(void)dismissMe:(UIButton *)btn{
    [UIView animateWithDuration:0.2 animations:^{
        self->subTableView.frame = CGRectMake(0, self->sH, self->sW, 580.0);
    } completion:^(BOOL finished) {
        self.alpha = 0.0;
        [self removeFromSuperview];
    }];
}

#pragma mark // TableView Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    Headphonecell *cell = [tableView dequeueReusableCellWithIdentifier:[Headphonecell ID]];
    if (cell == nil) {
        cell = [[Headphonecell alloc] init];
    }
    
    cell.tag = (long)[indexArray[indexPath.row] integerValue];
    
    if(selectFlag == NO){
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        BOOL selected = ((model.kalaokMask>>cell.tag) & 0x01) == 0x01;
        
        if(selected){
            NSIndexPath *selectedIndexPath = [NSIndexPath indexPathForRow:(long)indexPath.row inSection:0];
            [subTableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        }
        if (selected) {
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
        }else{
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
        }
    }
    if(selectFlag == YES){
        if (clickIndexPath.row == indexPath.row) {
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
        }else{
            cell.cellImv.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
        }
    }
    
    cell.cellLabel.text = dataArray[indexPath.row];
    [cell.cellLabel setFont:[UIFont fontWithName:@"System" size:15]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectFlag = YES;
    clickIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];        
    [bleSDK.mBleEntityM.mCmdManager cmdSetKalaokIndex:(long)[indexArray[indexPath.row] integerValue] Value:0];
    
    [tableView reloadData];
}

-(void)noteDianYing{
    if(selectFlag == NO){
        [subTableView reloadData];
    }
}

-(void)addNote{
    [JLModel_Device observeModelProperty:@"kalaokMask" Action:@selector(noteDianYing) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}
@end
