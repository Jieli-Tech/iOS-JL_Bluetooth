//
//  ColorScreenSetVC.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/12/5.
//  Copyright © 2023 杰理科技. All rights reserved.
//

#import "BasicViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ScreenLightBlock)(uint8_t value);

@interface ColorScreenSetVC : BasicViewController

-(void)initDataAction:(void(^)(BOOL status))block;

-(void)showAlbumView;

@end

NS_ASSUME_NONNULL_END
