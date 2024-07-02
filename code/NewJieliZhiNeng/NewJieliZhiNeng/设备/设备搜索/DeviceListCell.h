//
//  DeviceListCell.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLab;
@property (weak, nonatomic) IBOutlet UIImageView *statusImgv;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImgv;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeView;

@end

NS_ASSUME_NONNULL_END
