//
//  MapListCell.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/8/18.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *mImageView;
@property (weak, nonatomic) IBOutlet UILabel *mLabel_0;
@property (weak, nonatomic) IBOutlet UILabel *mLabel_1;
@property (weak, nonatomic) IBOutlet UILabel *mLabel_2;

+(NSString*)ID;

@end

NS_ASSUME_NONNULL_END
