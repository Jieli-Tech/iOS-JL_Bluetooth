//
//  ANCModeView.m
//  NewJieliZhiNeng
//
//  Created by 李放 on 2021/3/26.
//  Copyright © 2021 杰理科技. All rights reserved.
//

#import "ANCModeView.h"
#import "JL_RunSDK.h"
#import "AncModelCell.h"

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
    
    funArray = @[kJL_TXT("noise_mode_denoise"),kJL_TXT("noise_mode_transparent"),kJL_TXT("noise_mode_close")];
    funIndexArray = @[@(1),@(2),@(0)];
    detailFunArray = @[kJL_TXT("noise_mode_desc_denoise"),kJL_TXT("noise_mode_desc_transparent"),kJL_TXT("noise_mode_desc_close")];
    
    subTableView = [[UITableView alloc] init];
    subTableView.frame = CGRectMake(0, 0, sw-32, 270-60);
    subTableView.backgroundColor = [UIColor clearColor];
    subTableView.tableFooterView = [UIView new];
    subTableView.separatorColor = kDF_RGBA(238, 238, 238, 1.0);
    subTableView.showsVerticalScrollIndicator = NO;
    subTableView.rowHeight  = 70.0;
    subTableView.dataSource = self;
    subTableView.delegate   = self;
    [subTableView registerNib:[UINib nibWithNibName:@"AncModelCell" bundle:nil] forCellReuseIdentifier:@"AncModelCell"];
    
    [contentView addSubview:subTableView];
    
    
    UIView *fengeView = [[UIView alloc] initWithFrame:CGRectMake(0, 210, sw, 0.5)];
    [contentView addSubview:fengeView];
    fengeView.backgroundColor = kDF_RGBA(238, 238, 238, 1.0);
    
    sureBtn = [[UIButton alloc] initWithFrame:CGRectMake(0,210.5,contentView.frame.size.width,59.5)];
    [sureBtn setTitle:kJL_TXT("confirm") forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(sureBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [sureBtn setTitleColor:kColor_0000 forState:UIControlStateNormal];
    sureBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC" size:15];
    
    [contentView addSubview:sureBtn];
}

-(void)setMAncArray:(NSArray *)mAncArray{
    _mAncArray = mAncArray;
    mSelectArray = [NSMutableArray new];
    [mSelectArray setArray:mAncArray];
    [subTableView reloadData];
}

-(void)sureBtnAction:(UIButton *)btn{
    
    if(mSelectArray.count<2){
        [DFUITools showText:kJL_TXT("anc_mode_less_2") onView:self delay:1.0];
        return;
    }
    
    self.hidden = YES;
    
    if([_delegate respondsToSelector:@selector(onANCSure:)]){
        [_delegate onANCSure:mSelectArray];
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
    
    AncModelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AncModelCell" forIndexPath:indexPath];
    
    NSObject *objc = funIndexArray[indexPath.row];
    if([mSelectArray containsObject:objc]){
        cell.centerImgv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
    }else{
        cell.centerImgv.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
    }
    
    cell.titleLab.text = funArray[indexPath.row];
    cell.detailLab.text = detailFunArray[indexPath.row];
    
    cell.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    cell.layoutMargins = UIEdgeInsetsMake(0, 16, 0, 16);
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSObject *objc = funIndexArray[indexPath.row];
    if ([mSelectArray containsObject:objc]) {
        [mSelectArray removeObject:objc];
    }else{
        [mSelectArray addObject:objc];
    }
    [tableView reloadData];
    
}
@end
