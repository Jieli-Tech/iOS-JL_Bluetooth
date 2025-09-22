//
//  NetworkView.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/8.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
#import "NetworkCell.h"
#import "JL_RunSDK.h"


NS_ASSUME_NONNULL_BEGIN

typedef void(^NetworkViewBlock)(NSInteger index);

@interface NetworkView : UIView
@property(nonatomic,strong)NSArray *dataArray;
@property(nonatomic,assign)BOOL isDelete;
-(void)setNetworkViewDataArray:(NSArray*)array;
-(void)onNetworkViewBlock:(NetworkViewBlock)block;
@end

NS_ASSUME_NONNULL_END
