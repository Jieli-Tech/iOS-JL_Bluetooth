//
//  MapViewController.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/3.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController

@property(nonatomic,strong) DeviceObjc *deviceObjc;
@property(nonatomic,strong) TwsElectricity *energy;
@end

NS_ASSUME_NONNULL_END
