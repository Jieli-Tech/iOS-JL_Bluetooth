//
//  FmManageView.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/1.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "FmManageView.h"

@interface FmManageView(){
    float sW;
    float sH;
    BOOL  isManger;
    
    uint16_t        fm_current;
    NSInteger       fm_index;
    
    UIButton        *btnManager;
    NSMutableArray  *dataArray;
    UIScrollView    *subSrollView;

    FmManageSelectBlock mBlkSelect;
    FmManageDeleteBlock mBlkDelete;
}

@end

@implementation FmManageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        fm_current = 0;
        isManger = YES;
        self.frame = frame;
        sW = frame.size.width;
        sH = frame.size.height;
        
        UILabel *lb = [UILabel new];
        lb.frame = CGRectMake(20.0, 10.0, 80.0, 20.0);
        lb.font = [UIFont systemFontOfSize:14.0];
        lb.textColor = [UIColor blackColor];
        lb.text = @"频点收藏";
        [self addSubview:lb];
        
        btnManager = [UIButton new];
        btnManager.frame = CGRectMake(sW-75.0, 10.0, 80, 20.0);
        btnManager.titleLabel.font = [UIFont systemFontOfSize:14.0];
        btnManager.titleLabel.textAlignment = NSTextAlignmentRight;
        [btnManager setTitle:@"管理" forState:UIControlStateNormal];
        [btnManager setTitleColor:kColor_0000 forState:UIControlStateNormal];
        [btnManager addTarget:self action:@selector(onManagerAciton)
             forControlEvents:UIControlEventTouchUpInside];
        btnManager.tag = -1;
        [self addSubview:btnManager];
        
        subSrollView = [UIScrollView new];
        subSrollView.frame = CGRectMake(0, 30.0, sW, sH-30.0);
        subSrollView.contentSize = CGSizeMake(sW, 100.0);
        subSrollView.showsVerticalScrollIndicator = YES;
        subSrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:subSrollView];
    }
    return self;
}

-(void)onManagerAciton{
    if (isManger) {
        [btnManager setTitle:@"完成" forState:UIControlStateNormal];
        isManger = NO;
    }else{
        [btnManager setTitle:@"管理" forState:UIControlStateNormal];
        isManger = YES;
    }
    [self updateBtnIsDelete:isManger];
}

-(void)updateBtnIsDelete:(BOOL)isDel{
    for (UIView *view in subSrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)view;
            if (btn.tag >= 250) {
//                NSInteger sTag = btn.tag - 250;
//                if (sTag == fm_index) {
//                    btn.hidden = YES;
//                }else{
                    btn.hidden = isDel;
                //}
            }
        }
    }
}

-(void)cleanAllBtn{
    for (UIView *view in subSrollView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)view;
            if (btn.tag >= 0) [btn removeFromSuperview];
        }
    }
}

-(void)setCurrentFM:(uint16_t)fm{
    fm_current = fm;
    fm_index = -1;
    for (int i = 0; i < dataArray.count; i++) {
        JLModel_FM *md = dataArray[i];
        if (md.fmFrequency == fm) {
            fm_index = i;
            break;
        }
    }
}

-(CGSize)setFmArray:(NSArray*)array CurrentFM:(uint16_t)fm{
    float gap = 20.0;
    float btn_h = 38;
    float btn_w = (sW-gap*4.0)/3.0;
    int num_hang = 0;
    int num_lie  = 0;
    
    [self cleanAllBtn];
    
    dataArray = [NSMutableArray arrayWithArray:array];
    
    [self setCurrentFM:fm];

    for (int i = 0; i < dataArray.count; i++) {
        JLModel_FM *fmModel = dataArray[i];
        NSString *txt = [NSString stringWithFormat:@"%.1fMHz",fmModel.fmFrequency/10.0f];
        
        if (i%3==0) num_hang = i/3;
        num_lie = i%3;
        
        UIButton *btn = [UIButton new];
        btn.bounds = CGRectMake(0, 0, btn_w, btn_h);
        btn.center = CGPointMake(gap+btn_w/2.0+num_lie*(gap+btn_w), 20+btn_h/2.0+num_hang*(gap+btn_h));
        [btn setTitle:txt forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        btn.layer.cornerRadius = 2.5;
        btn.tag = i;
        [btn addTarget:self action:@selector(onBtnAction:)
                      forControlEvents:UIControlEventTouchUpInside];
        [subSrollView addSubview:btn];
        
        if (fmModel.fmFrequency == fm_current) {
            [btn setTitleColor:kDF_RGBA(255, 255, 255, 1.0) forState:UIControlStateNormal];
            btn.backgroundColor = kColor_0000;
        }else{
            [btn setTitleColor:kDF_RGBA(76, 76, 76, 1.0) forState:UIControlStateNormal];
            btn.backgroundColor = kDF_RGBA(234, 236, 238, 1.0);
        }

        UIButton *btnDel = [UIButton new];
        btnDel.bounds = CGRectMake(0, 0, 30.0, 30.0);
        btnDel.center = CGPointMake(btn.frame.origin.x, btn.frame.origin.y);
        [btnDel setImage:[UIImage imageNamed:@"Theme.bundle/mul_icon_delete"] forState:UIControlStateNormal];
        btnDel.titleLabel.font = [UIFont systemFontOfSize:14.0];
        btnDel.tag = i+250;
//        if (i == fm_index) {
//            btnDel.hidden = YES;
//        }else{
            btnDel.hidden = isManger;
        //}
        [btnDel addTarget:self action:@selector(onBtnDelAction:)
                     forControlEvents:UIControlEventTouchUpInside];
        [subSrollView addSubview:btnDel];
    }
    
    CGSize sizeSrollView = CGSizeMake(sW, 100.0+num_hang*(btn_h+20.0));
    
    if (num_hang >= 5 ) num_hang = 4;
    CGSize size = CGSizeMake(sW, 100.0+num_hang*(btn_h+20.0));
    self.frame  = CGRectMake(self.frame.origin.x, self.frame.origin.y, sW, size.height);
    
    subSrollView.frame = CGRectMake(0, 30.0, sW, size.height-30.0);
    subSrollView.contentSize = CGSizeMake(sW, sizeSrollView.height-30.0);
    
    return size;
}

-(void)onBtnAction:(UIButton*)sender{
    NSInteger tag = sender.tag;
    JLModel_FM *md = dataArray[tag];
    if (mBlkSelect) mBlkSelect(md.fmFrequency);
}

-(void)onBtnDelAction:(UIButton*)sender{
    NSInteger tag = sender.tag;
    JLModel_FM *md = dataArray[tag-250];
    if (mBlkDelete) mBlkDelete(md.fmFrequency);

    [dataArray removeObjectAtIndex:(tag-250)];
    [self setFmArray:dataArray CurrentFM:fm_current];
}

-(void)setFmManagerSelect:(FmManageSelectBlock)blkSelect
                   Delete:(FmManageDeleteBlock)blkDelete{
    mBlkSelect = blkSelect;
    mBlkDelete = blkDelete;
}


@end
