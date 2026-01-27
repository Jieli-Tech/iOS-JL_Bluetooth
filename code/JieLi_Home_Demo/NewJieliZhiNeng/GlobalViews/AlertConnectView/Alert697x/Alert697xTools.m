//
//  Alert697xTools.m
//  newAPP
//
//  Created by EzioChan on 2020/5/30.
//  Copyright © 2020 Ezio. All rights reserved.
//

#import "Alert697xTools.h"


@implementation Alert697xTools


+(UIImage *)getPowerImg:(int)power{
    UIImage *image;
    //电量为0到20
    if(power>0 && power<=20){
        image = [UIImage imageNamed:@"Theme.bundle/icon_elastic_1"];
    }
    //电量为21到35
    if(power>20 && power<=35){
        image = [UIImage imageNamed:@"Theme.bundle/icon_elastic_2"];
    }
    //电量为36到50
    if(power>35 && power<=50){
        image = [UIImage imageNamed:@"Theme.bundle/icon_elastic_3"];
    }
    //电量为51到75
    if(power>50 && power<=75){
        image = [UIImage imageNamed:@"Theme.bundle/icon_elastic_4"];
    }
    //电量为76到100
    if(power>75 && power<=100){
        image = [UIImage imageNamed:@"Theme.bundle/icon_elastic_5"];
    }
    //充电中
    if(power == -1){
        image = [UIImage imageNamed:@"Theme.bundle/icon_elastic_6"];
    }
    return image;
}



@end
