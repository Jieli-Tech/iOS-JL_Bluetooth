//
//  DevicesCell.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DeviceCellDelegate <NSObject>

-(void)deviceCellDidSelectWith:(int)indexPath;
-(void)deviceCellDidDelete;
-(void)deviceBtnLocation:(int)indexPath;
@end

@interface DevicesCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (assign,nonatomic) int index;
@property (weak, nonatomic) IBOutlet UILabel *connectStatusLab;
@property (weak, nonatomic) IBOutlet UIImageView *deviceImgv;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLab;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *myLocationBtn;
@property (weak, nonatomic)id<DeviceCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *connectStatusLablewidth;


@end

NS_ASSUME_NONNULL_END
