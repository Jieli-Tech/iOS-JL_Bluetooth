//
//  FlashDeviceCell.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/8/6.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlashDeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *sceneLabel_0;
@property (weak, nonatomic) IBOutlet UILabel *sceneLabel_1;
@property (weak, nonatomic) IBOutlet UIImageView *sceneImage;
@property (weak, nonatomic) IBOutlet UIImageView *effectImage;

+(NSString*)ID;
@end

NS_ASSUME_NONNULL_END
