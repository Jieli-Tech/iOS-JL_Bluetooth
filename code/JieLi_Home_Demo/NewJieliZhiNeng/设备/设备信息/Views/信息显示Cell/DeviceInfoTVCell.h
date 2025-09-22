//
//  DeviceInfoTVCell.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfoTVCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgv;
@property (weak, nonatomic) IBOutlet UILabel *funcTitle;
@property (weak, nonatomic) IBOutlet UILabel *detailTitle;

@end

NS_ASSUME_NONNULL_END
