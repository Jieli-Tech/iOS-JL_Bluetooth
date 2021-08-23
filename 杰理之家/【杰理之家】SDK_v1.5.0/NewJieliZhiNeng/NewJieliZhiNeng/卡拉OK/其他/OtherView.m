//
//  KalaokView.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/11/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "OtherView.h"
#import "FenYeCell.h"
#import "JL_RunSDK.h"
#import "HorizontallyFlowLayout.h"

@interface OtherView()<UICollectionViewDelegate,UICollectionViewDataSource>{
    OtherViewBlock subBlock;
    UICollectionView *collectionView;
    NSArray     *dataArray;
    NSArray     *indexArray;
    float sW;
    float sH;
    
    CGFloat kMaxRowCount;
    CGFloat kItemCountPerRow;
}

@end
@implementation OtherView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        sW = frame.size.width;
        sH = frame.size.height;
        
        [self addNote];
    }
    return self;
}

-(void)setKMaxRowCount:(NSInteger) maxRowCount WithItemCountPerRow:(NSInteger) itemCountPerRow{
    kMaxRowCount = maxRowCount;
    kItemCountPerRow = itemCountPerRow;
    
    NSMutableArray *array = [NSMutableArray new];
    NSMutableArray *mIndexArray = [NSMutableArray new];
    for (NSDictionary *dic in _otherArray) {
        NSString *name;
        if([kJL_GET hasPrefix:@"zh"]){
            name = dic[@"title"][@"zh"];
        }else{
            name = dic[@"title"][@"en"];
        }
        [array addObject:name];
        if(dic[@"index"]!=nil){
            [mIndexArray addObject:dic[@"index"]];
        }
    }
    
    dataArray = array;
    indexArray = mIndexArray;
    
    HorizontallyFlowLayout *layout;
    if(layout == nil){
        layout = [[HorizontallyFlowLayout alloc] initWithItemCountPerRow:kItemCountPerRow maxRowCount:kMaxRowCount itemCountTotal:dataArray.count];
        layout.itemSize = CGSizeMake(CGRectGetWidth(self.frame) / kItemCountPerRow, 38);
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
    }
    
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
    
    UINib *nib = [UINib nibWithNibName:@"FenYeCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"FenYeCell"];
    [self addSubview:collectionView];
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
    FenYeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FenYeCell" forIndexPath:indexPath];
    
    if(indexPath.item < dataArray.count){
        float btn_W = ([DFUITools screen_2_W]-4*20.0)/3.0;
        cell.bounds = CGRectMake(0, 0, btn_W, 38);
        cell.layer.cornerRadius = 5;
        cell.cellLabel.text = dataArray[indexPath.item];

        cell.tag = (long)[indexArray[indexPath.row] integerValue];
        cell.cellLabel.font = [UIFont systemFontOfSize:15];

        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        BOOL selected = ((model.kalaokMask>>cell.tag) & 0x01) == 0x01;
        
        if (selected) {
            cell.cellLabel.textColor = kDF_RGBA(255, 255, 255, 1.0);
            cell.backgroundColor = kColor_0000;
            cell.layer.borderWidth  = 0.0;
        }else{
            cell.cellLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
            cell.backgroundColor = [UIColor whiteColor];
            cell.layer.borderColor = kDF_RGBA(234, 236, 238, 1.0).CGColor;
            cell.layer.borderWidth = 1.0;
        }
    }else{
        cell.cellLabel.text = @"";
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (subBlock)subBlock([indexArray[indexPath.row] integerValue]);
}

-(void)onOtherViewBlock:(OtherViewBlock)block{
    subBlock = block;
}

-(void)noteOther{
    [collectionView reloadData];
}

-(void)addNote{
    [JLModel_Device observeModelProperty:@"kalaokMask" Action:@selector(noteOther) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

@end
