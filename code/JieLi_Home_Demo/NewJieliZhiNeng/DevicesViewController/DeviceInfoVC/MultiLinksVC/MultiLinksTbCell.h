//
//  MultiLinksTbCell.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/9/5.
//  Copyright © 2023 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MultiLinksTbCell : UITableViewCell

@property(nonatomic,strong)UILabel *mainLab;
@property(nonatomic,strong)UIImageView *mainImgv;
@property(nonatomic,strong)UILabel *isLocalLab;
@property(nonatomic,assign)BOOL isShow;

@end

NS_ASSUME_NONNULL_END
