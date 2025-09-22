//
//  DevicesCardView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DevicesCardView : UIView

-(void)configPowerStatus:(NSDictionary *__nullable)dict;

@end

NS_ASSUME_NONNULL_END
