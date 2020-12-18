//
//  FmManageView.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/1.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FmManageSelectBlock)(uint16_t fmSelect);
typedef void(^FmManageDeleteBlock)(uint16_t fmDelete);


@interface FmManageView : UIView
-(void)setCurrentFM:(uint16_t)fm;
-(CGSize)setFmArray:(NSArray*)array CurrentFM:(uint16_t)fm;
-(void)setFmManagerSelect:(FmManageSelectBlock)blkSelect
                   Delete:(FmManageDeleteBlock)blkDelete;
@end

NS_ASSUME_NONNULL_END
