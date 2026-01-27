//
//  HeadSetStatusView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    HeadSetType_L,
    HeadSetType_R,
    HeadSetType_C,
    HeadSetType_BOX,
    HeadSetType_SHENGKA
} HeadSetType;

@interface HeadSetStatusView : UIView
@property(nonatomic,assign)HeadSetType type;
@property(nonatomic,strong)NSDictionary *powerDict;
-(void)configUuid:(NSString*)uuid;
@end

NS_ASSUME_NONNULL_END
