//
//  ECPickerView.h
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/7/10.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ECPickerViewDataSourse,ECPickerViewDelegate;

@interface ECPickerView : UIView

@property(nonatomic,unsafe_unretained)IBOutlet __nullable id<ECPickerViewDataSourse> datasourse;
@property(nonatomic,unsafe_unretained)IBOutlet __nullable id<ECPickerViewDelegate> delegate;

@property (nonatomic, readonly) NSInteger numberOfSections;
@property (nonatomic,readonly) NSArray *sectionArray;

-(void)scrollToDate:(NSDate *)date;


@end

@protocol ECPickerViewDataSourse <NSObject>

-(NSInteger)numberOfItemsInSection:(ECPickerView *)view;

-(NSArray *)pickerView:(ECPickerView *)view withSection:(NSInteger)section;

-(UIView *)pickerView:(ECPickerView *)view withSection:(NSInteger)section indexPath:(NSInteger)index;

-(CGFloat)pickerView:(ECPickerView *)view setHightForCell:(NSInteger)section indexPath:(NSInteger)index;

@end

@protocol ECPickerViewDelegate <NSObject>

-(void)cpickerViewMoveToItem:(NSArray *)selectArray;
-(void)cpickerViewMoveToItemEndAnimation:(NSArray *)selectArray;

@end


NS_ASSUME_NONNULL_END
