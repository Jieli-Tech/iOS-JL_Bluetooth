//
//  FmSearchView.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "FmSearchView.h"
#import "JL_RunSDK.h"


@interface FmSearchView(){
    __weak IBOutlet NSLayoutConstraint *view_x;
    __weak IBOutlet NSLayoutConstraint *view_y;
    
    __weak IBOutlet UIView *viewSearch;
    __weak IBOutlet UIView *viewCollected;
    __weak IBOutlet UIImageView *imageCollected;
    __weak IBOutlet UILabel *labelCollected;
}

@end

@implementation FmSearchView

- (instancetype)initSearchView
{
    self = [DFUITools loadNib:@"FmSearchView"];
    if (self) {
        float sW = [DFUITools screen_2_W];
        float sH = [DFUITools screen_2_H];
        self.frame = CGRectMake(0, 0, sW, sH);
        self.hidden = YES;
        
        viewSearch.hidden = NO;
        viewCollected.hidden = YES;
        viewCollected.layer.cornerRadius = 10;
        
        view_x.constant = 21;
        view_y.constant = kJL_HeightStatusBar+88;
        
        UIWindow *win = [DFUITools getWindow];
        [win addSubview:self];
        
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onDismiss)];
        [gr setNumberOfTapsRequired:1];
        [gr setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:gr];
    }
    return self;
}

- (instancetype)initCollectionView
{
    self = [DFUITools loadNib:@"FmSearchView"];
    if (self) {
        float sW = [DFUITools screen_2_W];
        float sH = [DFUITools screen_2_H];
        self.frame = CGRectMake(0, 0, sW, sH);
        self.hidden = YES;
        
        viewSearch.hidden = YES;
        viewCollected.hidden = NO;
        viewCollected.layer.cornerRadius = 10;
        
        view_x.constant = 21;
        view_y.constant = kJL_HeightStatusBar+88;
        
        UIWindow *win = [DFUITools getWindow];
        [win addSubview:self];
        
        
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(onDismiss)];
        [gr setNumberOfTapsRequired:1];
        [gr setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:gr];
    }
    return self;
}


-(void)onDismiss{
    [self removeFromSuperview];
    ME = nil;
}

static FmSearchView *ME = nil;
static FmSearchViewtBlock fmBlk = NULL;
+(void)showMeWithBlock:(FmSearchViewtBlock)blk{
    fmBlk = blk;
    ME = [[FmSearchView alloc] initSearchView];
    ME.hidden = NO;
}

- (IBAction)onBtnAction:(UIButton *)sender {
    if (fmBlk) {
        fmBlk(sender.tag);
        fmBlk = nil;
        [self onDismiss];
    }
}

static FmSearchView *ME_1 = nil;
+(void)showMeCollectedView:(BOOL)type{
    ME_1 = [[FmSearchView alloc] initCollectionView];
    ME_1.hidden = NO;
    if (type == YES) {
        ME_1->imageCollected.image = [UIImage imageNamed:@"Theme.bundle/mul_icon_success"];
        ME_1->labelCollected.text = @"收藏成功";
    }
    if (type == NO) {
        ME_1->imageCollected.image = [UIImage imageNamed:@"Theme.bundle/mul_icon_tip"];
        ME_1->labelCollected.text = @"已收藏!";
    }
    
    [DFAction delay:1.0 Task:^{
        [ME_1 onDismiss];
    }];
}

@end
