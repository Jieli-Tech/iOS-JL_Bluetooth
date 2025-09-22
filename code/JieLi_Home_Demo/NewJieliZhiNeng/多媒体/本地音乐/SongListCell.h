//
//  SongListCell.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

NS_ASSUME_NONNULL_BEGIN

@interface SongListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *animateImgv;
@property (weak, nonatomic) IBOutlet UILabel *numberLab;
//@property (weak, nonatomic) IBOutlet UILabel *songName;
@property (strong, nonatomic) DFLabel *songName;
@property (weak, nonatomic) IBOutlet UILabel *artistLab;


@end

NS_ASSUME_NONNULL_END
