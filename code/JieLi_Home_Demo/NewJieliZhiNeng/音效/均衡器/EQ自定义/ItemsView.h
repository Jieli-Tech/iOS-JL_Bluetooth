#import <UIKit/UIKit.h>
#import "JL_RunSDK.h"

@class ItemsView;
@protocol ItemsViewDelegate <NSObject>
@optional
-(void)onItemsView:(ItemsView*)view didSelect:(NSString*)info;

@end


@interface ItemsView : UIView
@property(nonatomic,weak)id<ItemsViewDelegate>delegate;
-(void)setItemsMode:(NSInteger)mode;
@end
