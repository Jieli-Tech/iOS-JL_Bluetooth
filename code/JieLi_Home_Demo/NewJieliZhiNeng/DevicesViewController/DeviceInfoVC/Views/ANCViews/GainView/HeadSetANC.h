//
//  HeadSetANC.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/27.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol HeadsetDenoisePtl <NSObject>

-(void)headSetDenoiseMore:(JLModel_ANC * _Nullable) deviceModelAnc;

@end

@interface HeadSetANC : UIView

@property(nonatomic,weak)id<HeadsetDenoisePtl> delegate;

-(void)createData;


@end

NS_ASSUME_NONNULL_END
