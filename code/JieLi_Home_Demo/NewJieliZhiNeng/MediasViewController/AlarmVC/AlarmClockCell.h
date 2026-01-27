//
//  AlarmClockCell.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/29.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AlarmClockCellDelegate <NSObject>

-(void)alarmClockCellDidSelect:(NSInteger)index status:(BOOL)status;

@end

@interface AlarmClockCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ClockLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UISwitch *select;
@property (weak, nonatomic) id<AlarmClockCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
