//
//  DeviceChangeModel.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceChangeModel : NSObject
@property(nonatomic,strong)NSString *mImageName;
@property(nonatomic,strong)NSString *mName;
@property(nonatomic,strong)NSString *uuid;
@property(nonatomic,assign)BOOL isConnect;
@end

NS_ASSUME_NONNULL_END
