//
//  Headphonecell.h
//  IntelligentBox
//
//  Created by kaka on 2019/7/24.
//  Copyright © 2019 Zhuhia Jieli Technology. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Headphonecell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cellLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cellImv;

+(NSString*)ID;

@end

