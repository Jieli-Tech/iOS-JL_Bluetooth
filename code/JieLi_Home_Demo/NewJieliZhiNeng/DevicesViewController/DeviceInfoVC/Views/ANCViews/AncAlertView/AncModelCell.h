//
//  AncModelCell.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/5/24.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AncModelCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UIImageView *centerImgv;

@end

NS_ASSUME_NONNULL_END
