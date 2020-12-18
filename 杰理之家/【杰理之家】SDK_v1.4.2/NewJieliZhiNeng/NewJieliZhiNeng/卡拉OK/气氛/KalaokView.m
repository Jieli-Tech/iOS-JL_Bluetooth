//
//  KalaokView.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/11/18.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "KalaokView.h"
#import "QifenCell.h"
#import "JL_RunSDK.h"
#import "HorizontallyFlowLayout.h"
#import "UIImageView+WebCache.h"

//static const CGFloat kMaxRowCount = 2.f;
//static const CGFloat kItemCountPerRow = 4.f;

@interface KalaokView()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>{
    UICollectionView *collectionView;
    
    NSArray     *dataArray;
    NSArray     *imageArray;
    NSArray     *indexArray;
    
    CGFloat kMaxRowCount;
    CGFloat kItemCountPerRow;
    
    UIButton *btn_1;
    UIButton *btn_2;
    float    sW;
    float    sH;
    JL_RunSDK   *bleSDK;
        
    BOOL selectFlag;
    NSIndexPath *clickIndexPath;
}

@end
@implementation KalaokView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        sW = frame.size.width;
        sH = frame.size.height;
        
        [self addNote];
        bleSDK = [JL_RunSDK sharedMe];
        
        selectFlag = NO;
    }
    return self;
}

-(void)setKMaxRowCount:(NSInteger) maxRowCount WithItemCountPerRow:(NSInteger) itemCountPerRow{
    NSMutableArray *array = [NSMutableArray new];
    NSMutableArray *mIndexArray = [NSMutableArray new];
    NSMutableArray *mImageArray = [NSMutableArray new];

    for (NSDictionary *dic in _qiFenArray) {
        NSString *name;
        if([kJL_GET hasPrefix:@"en"]){
            name = dic[@"title"][@"en"];
        }
        if([kJL_GET hasPrefix:@"zh"]){
            name = dic[@"title"][@"zh"];
        }
        [array addObject:name];
        if(dic[@"index"]!=nil){
            [mIndexArray addObject:dic[@"index"]];
        }
        if(dic[@"icon_url"]!=nil){
            [mImageArray addObject:dic[@"icon_url"]];
        }
    }
    
    kMaxRowCount = maxRowCount;
    kItemCountPerRow = itemCountPerRow;
    
    dataArray = array;
    indexArray = mIndexArray;
    imageArray = mImageArray;
    
    HorizontallyFlowLayout *layout;
    if(layout == nil){
        layout = [[HorizontallyFlowLayout alloc] initWithItemCountPerRow:kItemCountPerRow maxRowCount:kMaxRowCount
                                                          itemCountTotal:dataArray.count];
    }
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.frame) / kItemCountPerRow
                                 , CGRectGetWidth(self.frame) / kItemCountPerRow);
    layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    
    CGRect rect = CGRectMake(0, 0, sW, sH);
    if(collectionView == nil){
        collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
    }
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.alwaysBounceVertical = YES;
    [collectionView setAlwaysBounceHorizontal:NO];
    [collectionView setShowsHorizontalScrollIndicator:NO];
    
    UINib *nib = [UINib nibWithNibName:@"QifenCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"QifenCell"];
    [self addSubview:collectionView];
        
    UIView *cicleView = [[UIView alloc] initWithFrame:CGRectMake([DFUITools screen_2_W]/2-26/2, collectionView.frame.origin.y+collectionView.frame.size.height+21.5, 26, 8)];
    [self addSubview:cicleView];
    cicleView.backgroundColor = [UIColor clearColor];
    
    btn_1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];

    btn_1.layer.masksToBounds = YES;
    btn_1.layer.cornerRadius = 4;
    btn_1.backgroundColor = [UIColor colorWithRed:255/255.0 green:154/255.0 blue:36/255.0 alpha:1.0];
    [cicleView addSubview:btn_1];
    
    btn_2 = [[UIButton alloc]initWithFrame:CGRectMake(18, 0, 8, 8)];

    btn_2.layer.masksToBounds = YES;
    btn_2.layer.cornerRadius = 4;
    btn_2.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    [cicleView addSubview:btn_2];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger itemCount;

    if (dataArray.count == 0) {
        itemCount = 0;
    } else if (dataArray.count / (kMaxRowCount * kItemCountPerRow) > 1) {
        // 超过一页
        itemCount = kMaxRowCount * kItemCountPerRow * ceilf(dataArray.count / (kMaxRowCount * kItemCountPerRow));
    } else {
        itemCount = ceilf(dataArray.count / kItemCountPerRow) * kItemCountPerRow;
    }
    return itemCount;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    QifenCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"QifenCell" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];

    if(indexPath.item < dataArray.count){
        NSString *imageURL = _qiFenArray[indexPath.row][@"icon_url"];
        
        //NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        cell.tag = (long)[indexArray[indexPath.row] integerValue];
        
//        if(selectFlag == YES){
//            if(clickIndexPath.row == indexPath.row){
//                cell.mLabel.textColor = kColor_0000;
//            }else{
//                cell.mLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
//            }
//        }
        
        if(selectFlag == NO){
            JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
            JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
            BOOL selected = ((model.kalaokMask>>cell.tag) & 0x01) == 0x01;
            
            if (selected) {
                cell.mLabel.textColor = kColor_0000;
            }else{
                cell.mLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
            }
        }
        
        if([imageURL containsString:@("https")]){
            [cell.mImageView sd_setImageWithShengKaURL:[NSURL URLWithString:imageArray[indexPath.row]] placeholderImage:[UIImage imageNamed:@"Theme.bundle/img_default.png"]];
        }else{
            cell.mImageView.image = [self OriginImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",imageURL]] scaleToSize:CGSizeMake(60, 60)];
        }
        [cell.mLabel setText:dataArray[indexPath.row]];
        cell.hidden = NO;
    }else{
        cell.hidden = YES;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    clickIndexPath = indexPath;
    
    selectFlag = YES;
    
    [bleSDK.mBleEntityM.mCmdManager cmdSetKalaokIndex:[indexArray[indexPath.row] integerValue] Value:0];
    
    [collectionView reloadData];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    float x = scrollView.contentOffset.x;
    float scale = x/(2.0*self.frame.size.width);
    if(scale>=0 && scale<0.25){
        btn_1.backgroundColor = [UIColor colorWithRed:255/255.0 green:154/255.0 blue:36/255.0 alpha:1.0];
        btn_2.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
    }
    if(scale >=0.25 && scale<=0.5){
        btn_1.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        btn_2.backgroundColor = [UIColor colorWithRed:255/255.0 green:154/255.0 blue:36/255.0 alpha:1.0];
    }
}

-(UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;   //返回的就是已经改变的图片
}

-(void)noteBianSheng{
    if(selectFlag == NO){
        [collectionView reloadData];
    }
}

-(void)addNote{
    [JLModel_Device observeModelProperty:@"kalaokMask" Action:@selector(noteBianSheng) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}
@end
