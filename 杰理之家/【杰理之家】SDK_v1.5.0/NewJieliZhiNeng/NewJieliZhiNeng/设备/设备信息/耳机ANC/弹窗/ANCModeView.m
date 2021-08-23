//
//  ANCModeView.m
//  NewJieliZhiNeng
//
//  Created by 李放 on 2021/3/26.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "ANCModeView.h"
#import "JL_RunSDK.h"
#import "ANCModel.h"

@interface ANCModeView()<UITableViewDelegate,UITableViewDataSource>{
    float sw;
    float sh;
    
    UIView *bgView;
    UIView *contentView;
    
    UITableView *subTableView;
    
    NSArray *funArray;
    NSArray *funIndexArray;
    NSArray *detailFunArray;
    
    UIButton *sureBtn;
    
    NSMutableArray *mSelectArray;//选中数据的数组
    NSMutableArray *indexArray;
    JLModel_ANC    *currentANCModel;
}
@end

@implementation ANCModeView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        sw = frame.size.width;
        sh = frame.size.height;
                
        [self initUI];
    }
    return self;
}

-(void)initUI{
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sw, sh)];
    [self addSubview:bgView];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.2;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(16, sh/2-270/2, sw-32, 270)];
    contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:contentView];
    contentView.layer.cornerRadius = 12;
    contentView.layer.masksToBounds = YES;
    
    funArray = @[kJL_TXT("关闭"),kJL_TXT("降噪"),kJL_TXT("通透模式")];
    funIndexArray = @[@(0),@(1),@(2)];
    detailFunArray = @[kJL_TXT("阻隔外部声音"),kJL_TXT("允许外部声音"),kJL_TXT("关闭降噪和通透模式")];
    
    subTableView = [[UITableView alloc] init];
    subTableView.frame = CGRectMake(0, 0, sw-32, 270-60);
    subTableView.backgroundColor = [UIColor clearColor];
    subTableView.tableFooterView = [UIView new];
    subTableView.separatorColor = kDF_RGBA(238, 238, 238, 1.0);
    subTableView.showsVerticalScrollIndicator = NO;
    subTableView.rowHeight  = 70.0;
    subTableView.dataSource = self;
    subTableView.delegate   = self;
    [contentView addSubview:subTableView];
    
    UIView *fengeView = [[UIView alloc] initWithFrame:CGRectMake(0, 210, sw, 0.5)];
    [contentView addSubview:fengeView];
    fengeView.backgroundColor = kDF_RGBA(238, 238, 238, 1.0);
    
    sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,210.5,contentView.frame.size.width,59.5)];
    [sureBtn setTitle:kJL_TXT("确定") forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitleColor:kColor_0000 forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC" size:15];
    
    [contentView addSubview:sureBtn];
}

-(void)setMAncArray:(NSMutableArray *)mAncArray{
    if(mSelectArray == nil){
        mSelectArray = [NSMutableArray array];
    }
    
    if(mSelectArray.count>0){
        [mSelectArray removeAllObjects];
    }
    
    if(indexArray == nil){
        indexArray = [NSMutableArray array];
    }
    
    if(indexArray.count>0){
        [indexArray removeAllObjects];
    }
    
    if(mAncArray.count>0){
        for (int i = 0;i<funIndexArray.count;i++) {
            ANCModel *model = [ANCModel new];
            if(funIndexArray.count == mAncArray.count && mAncArray.count ==3){
                model.isSelct = YES;
            }
            if(mAncArray.count ==2 &&[mAncArray containsObject:@0] && [mAncArray containsObject:@1]){
                if(i== 0||i ==1){
                    model.isSelct = YES;
                }
                if(i==2){
                    model.isSelct = NO;
                }
            }
            if(mAncArray.count ==2 &&[mAncArray containsObject:@0] && [mAncArray containsObject:@2]){
                if(i== 0||i ==2){
                    model.isSelct = YES;
                }
                if(i==1){
                    model.isSelct = NO;
                }
            }
            if(mAncArray.count ==2 &&[mAncArray containsObject:@1] && [mAncArray containsObject:@2]){
                if(i== 1||i ==2){
                    model.isSelct = YES;
                }
                if(i==0){
                    model.isSelct = NO;
                }
            }
            model.mAncMode = (UInt8)i;
            [mSelectArray addObject:model];
            [indexArray addObject:model];
        }
        [subTableView reloadData];
    }
}

-(void)sureBtnAction:(UIButton *)btn{
    NSMutableArray *sendArray;
    if(sendArray == nil){
        sendArray = [NSMutableArray new];
    }
    if(sendArray.count>0){
        [sendArray removeAllObjects];
    }
    for (ANCModel *mAncModel in indexArray) {
        int ancMode = (int)mAncModel.mAncMode;
        if(mAncModel.isSelct){
            [sendArray addObject:@(ancMode)];
        }
    }
    
    NSArray *result = [[sendArray copy] valueForKeyPath:@"@distinctUnionOfObjects.self"];
    
    if(result.count<2){
        [DFUITools showText:kJL_TXT("当前ANC模式不能少于2个") onView:self delay:1.0];
        return;
    }
    
    self.hidden = YES;
    
    if([_delegate respondsToSelector:@selector(onANCSure:)]){
        [_delegate onANCSure:result];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.hidden = YES;
}

#pragma mark <- tableView Delegate ->
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return funArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* IDCell = @"lcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDCell];
    }
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor=[UIColor clearColor];
    cell.selectedBackgroundView = view;
    
    if(mSelectArray.count >0 && mSelectArray.count>indexPath.row){
        ANCModel *ancModel = mSelectArray[indexPath.row];

        if(ancModel.isSelct){
            cell.imageView.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
        }else{
            cell.imageView.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
        }
        
        UILabel *funLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 20.5, cell.frame.size.width-55, 14.5)];
        funLabel.text = funArray[indexPath.row];
        funLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
        funLabel.textColor = kDF_RGBA(36, 36, 36, 1);
        [cell addSubview:funLabel];
        
        UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, funLabel.frame.origin.y+funLabel.frame.size.height+5, cell.frame.size.width-55, 13.5)];
        detailLabel.text = detailFunArray[indexPath.row];
        detailLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        detailLabel.textColor = kDF_RGBA(152, 152, 152, 1);
        [cell addSubview:detailLabel];
        
        cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
        cell.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 16);
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(mSelectArray.count > indexPath.row){
        ANCModel *ancModel = mSelectArray[indexPath.row];
        if(ancModel.isSelct){
            ancModel.isSelct = NO;
            
            [indexArray removeObject:ancModel];
        }else{
            ancModel.isSelct = YES;
            
            [indexArray addObject:ancModel];
        }
        [tableView reloadData];
    }
}
@end
