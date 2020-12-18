//
//  MapViewController.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/3.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import "SqliteManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController

@property(nonatomic,retain) DeviceObjc *deviceObjc;
@property(nonatomic,retain) NSMutableDictionary *powerDict;
@property(nonatomic,retain) NSString *deviceUUID;
@end

NS_ASSUME_NONNULL_END
