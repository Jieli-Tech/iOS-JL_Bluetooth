//
//  FlashCell.h
//  TestUIDemo
//
//  Created by 杰理科技 on 2020/6/30.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlashCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *subImage_0;
@property (weak, nonatomic) IBOutlet UILabel *subText;
@property (assign,nonatomic)BOOL isSelected;
+(NSString*)ID;
@end

NS_ASSUME_NONNULL_END
