//
//  KalaokModel.h
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/11/20.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KalaokModel : NSObject

@property(nonatomic,assign) BOOL hasEq;
@property(nonatomic,assign) BOOL paging;
@property(nonatomic,assign) BOOL group;

@property(nonatomic,strong) NSArray *mList;

@property(nonatomic,assign) NSInteger mId;
@property(nonatomic,assign) NSInteger column;
@property(nonatomic,assign) NSInteger row;

@property(nonatomic,strong) NSString *type;
@property(nonatomic,strong) NSString *icon_url;
@property(nonatomic,strong) NSString *zh_name;
@property(nonatomic,strong) NSString *en_name;


//@property(nonatomic,assign) NSDictionary *mTitle;

@end

NS_ASSUME_NONNULL_END
