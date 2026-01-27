//
//  TopView.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TopBlock_1)(void);
typedef void(^TopBlock_2)(void);

@interface TopView : UIView
@property (weak, nonatomic) IBOutlet UIButton *btnDevice;
@property (weak, nonatomic) IBOutlet UILabel *lbText;

- (instancetype)init;
- (void)onBLK_Device:(TopBlock_1)blk_1 BLK_Setting:(TopBlock_2)blk_2;
- (void)viewFirstLoad;
@end

NS_ASSUME_NONNULL_END
