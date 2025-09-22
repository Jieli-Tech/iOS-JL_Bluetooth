//
//  DeviceChangeCell.h
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DFUnits/DFUnits.h>
        
NS_ASSUME_NONNULL_BEGIN

@protocol DeviceChangeCellDelegate <NSObject>
@optional
-(void)onDeviceInfoBtnTag:(NSInteger)tag;
@end


@interface DeviceChangeCell : UITableViewCell
@property (nonatomic, strong)UIImageView *mImageView;
@property (nonatomic, strong)UILabel     *mLabelName;
@property (nonatomic, strong)UILabel     *mLabelStatus;
@property (nonatomic, strong)UIActivityIndicatorView *activeView;
@property (nonatomic, assign)BOOL        isConnect;
@property (nonatomic, assign)BOOL        isWorking;
@property (nonatomic, assign)NSInteger   mTag;
@property (nonatomic, strong)NSString    *uuid;
@property (nonatomic, weak)id<DeviceChangeCellDelegate>delegate;
-(void)setCellIsConnect:(BOOL)isOk;

@end

NS_ASSUME_NONNULL_END
