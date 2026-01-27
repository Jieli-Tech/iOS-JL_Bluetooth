//
//  UpgradeCell.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UpgradeCellDelegate <NSObject>

-(void)upgradeCellDidTouch:(NSInteger)index;
-(void)checkUpdateCellDidTouch;

@end
NS_ASSUME_NONNULL_BEGIN

@interface UpgradeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *checkingView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UILabel *presentLab;
@property (weak, nonatomic) id <UpgradeCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *lastVersionLab;
@property (assign, nonatomic)NSInteger index;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkBtnWidth;
@end

NS_ASSUME_NONNULL_END
