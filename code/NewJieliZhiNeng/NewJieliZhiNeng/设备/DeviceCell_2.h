//
//  DeviceCell_2.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/9/28.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"
#import "JLUI_Effect.h"
#import "SqliteManager.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString *kUI_DEVICE_CELL_LOCAL;
extern NSString *kUI_DEVICE_CELL_DELETE;
extern NSString *kUI_DEVICE_CELL_LONGPRESS;

@interface DeviceCell_2 : UITableViewCell
@property(nonatomic,weak)NSMutableDictionary *mPowerDict;
@property(nonatomic,assign)NSInteger    mIndex;
@property(nonatomic,strong)DeviceObjc   *mSubObject;
@property(nonatomic,assign)BOOL         isDelete;

+(float)cellHeightWithModel:(DeviceObjc*)model
                  PowerDict:(NSMutableDictionary*)powerDict;
+(NSString*)ID;

@end

NS_ASSUME_NONNULL_END
