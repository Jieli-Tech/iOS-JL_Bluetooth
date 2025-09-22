//
//  DhaWriteTipsView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2022/7/2.
//  Copyright © 2022 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DhaWritePtl <NSObject>

-(void)dhaWrite:(NSString *)name saveToDb:(BOOL)save;

@end

@interface DhaWriteTipsView : UIView

@property(nonatomic,assign)id<DhaWritePtl> delegate;

@property(nonatomic,strong)NSString *showText;

-(void)noNeedSave;

-(void)existTips;

@end

NS_ASSUME_NONNULL_END
