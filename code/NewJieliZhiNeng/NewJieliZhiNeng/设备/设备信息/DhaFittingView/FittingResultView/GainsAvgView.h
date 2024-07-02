//
//  GainsAvgView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/1.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GainsAvgView : UIView

@property(nonatomic,assign)double leftDb;

@property(nonatomic,assign)double rightDb;

-(void)resetByLeft:(float)value Type:(DhaChannel)channel;

@end

NS_ASSUME_NONNULL_END
