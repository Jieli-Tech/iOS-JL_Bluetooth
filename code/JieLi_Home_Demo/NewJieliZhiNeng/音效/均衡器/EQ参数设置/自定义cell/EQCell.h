//
//  EQCell.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/6/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>

NS_ASSUME_NONNULL_BEGIN
@class BezierView;
@interface EQCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *eqImv;
@property (weak, nonatomic) IBOutlet UILabel *eqLabel;
@property (nonatomic,strong)BezierView *bzLine;
+(NSString*)ID;
-(void)setEqLine:(int)index;
@end

NS_ASSUME_NONNULL_END
