//
//  FlashCell.m
//  TestUIDemo
//
//  Created by 杰理科技 on 2020/6/30.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "FlashCell.h"

@interface FlashCell(){
    
    __weak IBOutlet UIImageView *selectImage;
}

@end

@implementation FlashCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)init
{
    self = [DFUITools loadNib:@"FlashCell"];
    if (self) {

    }
    return self;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (_isSelected == YES) {
        selectImage.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
    }else{
        selectImage.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
    }
    
}

+(NSString*)ID{
    return @"FLASHCELL";
}

@end
