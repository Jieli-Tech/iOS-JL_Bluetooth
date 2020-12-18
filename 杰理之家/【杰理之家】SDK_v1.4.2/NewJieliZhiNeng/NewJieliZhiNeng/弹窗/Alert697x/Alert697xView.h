//
//  Alert697xView.h
//  Alert697x
//
//  Created by EzioChan on 2020/5/29.
//  Copyright © 2020 Ezio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JL_BLEKit/JL_BLEKit.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString *kUI_JL_ELSATICVIEW_BTN;

typedef void(^JL_IMAGE_LOAD_BK)(void);

@interface Alert697xView : UIView

-(void)refresh:(JL_EntityM *)entity;

@end

NS_ASSUME_NONNULL_END
