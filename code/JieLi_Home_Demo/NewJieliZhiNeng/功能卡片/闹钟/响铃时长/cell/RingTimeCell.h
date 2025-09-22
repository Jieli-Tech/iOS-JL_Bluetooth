//
//  RingTimeCell.h
//  JieliJianKang
//
//  Created by 李放 on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RingTimeCell : UITableViewCell

@property (assign,nonatomic) NSInteger subIndex;
@property (strong, nonatomic) UIButton *cellBtn;
@property (strong, nonatomic) UILabel  *cellLabel;

@end

NS_ASSUME_NONNULL_END
