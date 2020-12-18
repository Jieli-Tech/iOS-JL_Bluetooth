#import "ItemsView.h"
#import "ItemsCell.h"


@interface ItemsView()<UICollectionViewDelegate,
                       UICollectionViewDataSource>
{
    UICollectionView *collections;
    NSArray   *dataArr;
    NSDictionary     *txtDic;
    NSInteger        nowMode;
}

@end



@implementation ItemsView

- (instancetype)init
{
    self = (ItemsView*)[DFUITools loadNib:@"ItemsView"];
    if (self) {
        dataArr = @[kJL_TXT("自然"),kJL_TXT("摇滚"),kJL_TXT("流行"),kJL_TXT("经典"),kJL_TXT("爵士"),kJL_TXT("乡村"),kJL_TXT("自定义")];
        
        nowMode = -1;   //默认无模式
        
        //创建一个layout布局类
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection    = UICollectionViewScrollDirectionVertical;
        
        CGFloat itemW = 0.0;
        CGFloat itemH = 0.0;
        
        if([DFUITools screen_2_W] == 320.0){
            itemW = 57;
        }
        if([DFUITools screen_2_W] <= 375.0 &&  [DFUITools screen_2_W] > 320.0){
            itemW = 75;
        }
        if([DFUITools screen_2_W] > 375.0){
            itemW = 85;
        }
        itemH = 57;
        layout.itemSize = CGSizeMake(itemW, itemH);
        layout.sectionInset       = UIEdgeInsetsMake(0, 5, 0, 5);
        if([DFUITools screen_2_W] == 320.0){
            layout.minimumLineSpacing = 5;
        }else{
            layout.minimumLineSpacing = 15;
        }
        layout.minimumInteritemSpacing = 0;

        if (@available(iOS 13.0, *)) {
            UIColor *bgColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:18/255.0 green:19/255.0 blue:36/255.0 alpha:1.0];
                }
            }];
            [self setBackgroundColor:bgColor];
        } else {
            // Fallback on earlier versions
            [self setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
        }
        
        collections = [[UICollectionView alloc] initWithFrame:CGRectMake(7, 0, [DFUITools screen_2_W]-28-21, 170)
                                         collectionViewLayout:layout];
        collections.backgroundColor = [UIColor clearColor];
        collections.showsVerticalScrollIndicator   = NO;
        collections.showsHorizontalScrollIndicator = NO;
        collections.delegate   = self;
        collections.dataSource = self;

        //注册item类型 这里使用系统的类型
        UINib *nib = [UINib nibWithNibName:@"ItemsCell" bundle:nil];
        [collections registerNib:nib forCellWithReuseIdentifier:@"ITEM_CELL"];
        [self addSubview:collections];
        
        [collections reloadData];
    }
    return self;
}

#pragma mark 传入【当前模式】
-(void)setItemsMode:(NSInteger)mode
{
    nowMode = mode;
    [collections reloadData];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
    
-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return dataArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ItemsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ITEM_CELL"
                                                                 forIndexPath:indexPath];
    cell.subTxt.text = dataArr[indexPath.row];
    cell.subTxt.font = [UIFont systemFontOfSize:17];
    
    if(indexPath.row == nowMode){
        if (@available(iOS 13.0, *)) {
            UIColor *suTxtColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.7];
                }
            }];
           cell.subTxt.textColor = suTxtColor;
        } else {
            // Fallback on earlier versions
           cell.subTxt.textColor =  [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        }
        cell.subImv.image = [UIImage imageNamed:@"Theme.bundle/eq_bg_card_sel"];
    }else{
        if (@available(iOS 13.0, *)) {
            UIColor *senSuTxtColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
                if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
                    return [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
                }
                else {
                    return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.4];
                }
            }];
            cell.subTxt.textColor = senSuTxtColor;
        } else {
            // Fallback on earlier versions
            cell.subTxt.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
        }
        cell.subImv.image = [UIImage imageNamed:@"Theme.bundle/eq_bg_card_nor"];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView
       didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(onItemsView:didSelect:)])
    {
        NSString *str = dataArr[indexPath.row];
        [_delegate onItemsView:self didSelect:str];
    }
}

@end
