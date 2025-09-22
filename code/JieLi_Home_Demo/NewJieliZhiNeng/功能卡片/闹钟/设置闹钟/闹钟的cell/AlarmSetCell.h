//
//  AlarmSetCell.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/29.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlarmSetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *typeImg;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;

@end

NS_ASSUME_NONNULL_END
