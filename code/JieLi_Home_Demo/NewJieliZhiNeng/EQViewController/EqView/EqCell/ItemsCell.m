#import "ItemsCell.h"
#import "JLUI_Effect.h"

@implementation ItemsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.clipsToBounds = YES;
    [JLUI_Effect addShadowOnView:self];
}

@end
