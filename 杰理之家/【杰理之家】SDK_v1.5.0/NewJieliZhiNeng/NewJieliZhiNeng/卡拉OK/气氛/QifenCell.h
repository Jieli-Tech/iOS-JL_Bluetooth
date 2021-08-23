//
//  QifenCell.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/11/18.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QifenCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mImageView;
@property (weak, nonatomic) IBOutlet UILabel *mLabel;
@property (weak, nonatomic) IBOutlet UIView *mSubView;

@end

NS_ASSUME_NONNULL_END
