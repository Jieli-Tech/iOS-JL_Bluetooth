//
//  AlarmRingCell.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/7.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
NS_ASSUME_NONNULL_BEGIN

@interface AlarmRingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *songImgv;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgv;
@property (nonatomic,strong)DFLabel *animaLab;
@end

NS_ASSUME_NONNULL_END
