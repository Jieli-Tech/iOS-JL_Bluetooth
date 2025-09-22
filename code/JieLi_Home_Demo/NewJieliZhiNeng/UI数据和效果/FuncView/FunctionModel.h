//
//  FunctionModel.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FunctionModel : NSObject
@property(nonatomic,strong) NSString *mName;
@property(nonatomic,strong) NSString *mImage_1;
@property(nonatomic,strong) NSString *mImage_2;
@property(nonatomic,assign) BOOL isEnable;
@property(nonatomic,assign) NSInteger type;
@end

NS_ASSUME_NONNULL_END
