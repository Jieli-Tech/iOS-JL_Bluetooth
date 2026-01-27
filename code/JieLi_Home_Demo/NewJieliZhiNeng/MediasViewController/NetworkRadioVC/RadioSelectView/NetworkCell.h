//
//  NetworkCell.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/8.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *kNETWORK_CELL_DELETE;

@interface NetworkCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *subImageView;
@property (weak, nonatomic) IBOutlet UILabel *subText;
@property (weak, nonatomic) IBOutlet UIButton *subDeleteBtn;
@property (assign,nonatomic)NSInteger subTag;
@end

NS_ASSUME_NONNULL_END
