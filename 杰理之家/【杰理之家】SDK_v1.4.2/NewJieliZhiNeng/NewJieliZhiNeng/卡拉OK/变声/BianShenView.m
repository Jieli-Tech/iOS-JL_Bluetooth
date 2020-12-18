//
//  KalaokView.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/11/19.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "BianShenView.h"
#import "FenYeCell.h"
#import "JL_RunSDK.h"
#import "DanyinView.h"
#import "HorizontallyFlowLayout.h"

@interface BianShenView()<UICollectionViewDelegate,UICollectionViewDataSource>{
    BianShenViewBlock      subBlock;
    BianShenViewGroupBlock subGroupBlock;
    UICollectionView *collectionView;
    NSArray     *dataArray;
    NSArray     *indexArray;
    float sW;
    float sH;
    DanyinView *danYinView;
    
    CGFloat   kMaxRowCount;
    CGFloat   kItemCountPerRow;
    int       index;
    BOOL      group;
    UIImageView *imgv;
    int       clickIndex;
    NSMutableArray *clickArray;
    NSInteger groupIndex;
}

@end
@implementation BianShenView

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

    for (int i= 0;i<_bianShenArray.count;i++) {
        NSString *name;
        NSDictionary *dic = _bianShenArray[i];
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
        
        if((long)[dic[@"group"] integerValue] == 1){
            groupIndex = i;
        }
    }
    
    dataArray = array;
    indexArray = mIndexArray;
    
    HorizontallyFlowLayout *layout;
    if(layout == nil){
        layout = [[HorizontallyFlowLayout alloc] initWithItemCountPerRow:kItemCountPerRow maxRowCount:kMaxRowCount itemCountTotal:dataArray.count];
    }
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.frame) / kItemCountPerRow, 38);
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
    
    UINib *nib = [UINib nibWithNibName:@"FenYeCell" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"FenYeCell"];
    [self addSubview:collectionView];
    
    NSArray *tempArray =  [[self getShengKaIndex] copy];
    clickIndex = -1;
    if(tempArray.count>0){
        clickIndex = [tempArray[0] intValue];
        [collectionView reloadData];
    }
    
    [self updateCollections];
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
        
        group = _bianShenArray[indexPath.row][@"group"];
        
        float btn_W = ([DFUITools screen_2_W]-4*20.0)/3.0;
        
        cell.bounds = CGRectMake(0, 0, btn_W, 38);
        cell.layer.cornerRadius = 5;
        cell.cellLabel.font = [UIFont systemFontOfSize:15];
        
        if(indexPath.item < indexArray.count){
            cell.tag = (long)[indexArray[indexPath.row] integerValue];
            
            JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
            JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
            BOOL selected = ((model.kalaokMask>>cell.tag) & 0x01) == 0x01;
            
            if (selected) {
                clickIndex = -1;
                cell.cellLabel.textColor = kDF_RGBA(255, 255, 255, 1.0);
                cell.backgroundColor = kColor_0000;
                cell.layer.borderWidth  = 0.0;
            }else{
                cell.cellLabel.textColor = kDF_RGBA(36, 36, 36, 1.0);
                cell.backgroundColor = [UIColor whiteColor];
                cell.layer.borderColor = kDF_RGBA(234, 236, 238, 1.0).CGColor;
                cell.layer.borderWidth = 1.0;
            }
        }
        
        if(group){
            cell.tag = -1;
            
            imgv = [[UIImageView alloc] initWithFrame:CGRectMake(cell.frame.size.width*0.7, cell.frame.size.height/2, 6, 4.5)];
            imgv.image = [UIImage imageNamed:@"Theme.bundle/kalaok_icon_up"];
            [cell addSubview:imgv];
            imgv.hidden = NO;
            
            if(clickIndex == indexPath.row){
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
            imgv.hidden = YES;
        }
        
        cell.cellLabel.text = dataArray[indexPath.item];
    }else{
        cell.cellLabel.text = @"";
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    group = _bianShenArray[indexPath.row][@"group"];
    
    clickIndex = (int)indexPath.row;
    
    if(clickArray == nil){
        clickArray = [NSMutableArray new];
    }
    
    if(!group && subBlock){
        [clickArray removeAllObjects];
        clickArray = nil;
        subBlock((long)[indexArray[indexPath.row] integerValue]);
    }
    if(group && subBlock){
        [clickArray addObject:@(clickIndex)];
        subGroupBlock(group);
    }
    
    [self saveShengKaIndex];
}

-(void)onBianShenViewBlock:(BianShenViewBlock) block{
    subBlock = block;
}

-(void)onBianShenViewGroupBlock:(BianShenViewGroupBlock) groupBlock{
    subGroupBlock = groupBlock;
}

-(void)noteBianShen{
    [self updateCollections];
}

#pragma mark 存储声卡选中索引
-(void)saveShengKaIndex{
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *arrayData = [NSKeyedArchiver archivedDataWithRootObject:[clickArray copy]];
    NSString *key = [NSString stringWithFormat:@"SHENGKA_INDEX_%@",bleSDK.mBleUUID];
    
    if (arrayData) [userDefaults setObject:arrayData forKey:key];
    [userDefaults synchronize];
}

#pragma mark 取出声卡选中索引
-(NSArray *)getShengKaIndex{
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"SHENGKA_INDEX_%@",bleSDK.mBleUUID];
    NSData *arrayData = [userDefaults  objectForKey:key];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
    return array;
}

#pragma mark 更新UICollections
-(void)updateCollections{
    NSMutableArray *dianYingArray;
    if(dianYingArray == nil){
        dianYingArray = [NSMutableArray new];
    }
    
    for (int i=0;i<_dianYinArray.count;i++) {
        NSDictionary *dic = _dianYinArray[i];
        NSInteger tag = (long)[dic[@"index"] integerValue];
        
        JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
        JLModel_Device *model = [bleSDK.mBleEntityM.mCmdManager outputDeviceModel];
        
        if(((model.kalaokMask>>tag) & 0x01) == 0x01){
            [dianYingArray addObject:@(1)];
        }else{
            [dianYingArray addObject:@(0)];
        }
    }
    
    if([dianYingArray containsObject:@(1)]){
        clickIndex = (int)groupIndex;
    }
    if(![dianYingArray containsObject:@(1)]){
        clickIndex = -1;
    }
    
    [collectionView reloadData];
}

-(void)addNote{
    [JLModel_Device observeModelProperty:@"kalaokMask" Action:@selector(noteBianShen) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}
@end
