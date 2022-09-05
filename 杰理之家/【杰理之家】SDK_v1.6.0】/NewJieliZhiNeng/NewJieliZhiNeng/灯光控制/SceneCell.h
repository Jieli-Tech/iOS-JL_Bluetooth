//
//  SceneCell.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/9/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SceneCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *cellView;
@property (weak, nonatomic) IBOutlet UIImageView *cellImv;
@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTop;
@end

NS_ASSUME_NONNULL_END
