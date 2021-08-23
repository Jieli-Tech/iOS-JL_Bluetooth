//
//  FunctionsView.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/5/14.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "FunctionsView.h"
#import "FunctionCell.h"
#import "FunctionModel.h"
#import "JLUI_Effect.h"
#import "JL_RunSDK.h"

@interface FunctionsView()<UICollectionViewDelegate,UICollectionViewDataSource>{
     
    FunctionsViewBlock blk;
}
@property (nonatomic, strong)UICollectionView *collectionView;
@end


@implementation FunctionsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _selectIndex = -1;
        float sW = frame.size.width;
        float sH = frame.size.height;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemW = (sW - 12)/ 3;
        CGFloat itemH = itemW;
        layout.itemSize = CGSizeMake(itemW, itemH);
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        
        CGRect rect = CGRectMake(0, 0, sW, sH);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        
        UINib *nib = [UINib nibWithNibName:@"FunctionCell" bundle:nil];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:@"FunctionCell"];
        [self addSubview:_collectionView];
    }
    return self;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataArray.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FunctionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FunctionCell" forIndexPath:indexPath];
    
    FunctionModel *model = _dataArray[indexPath.row];
    cell.mLabel.text = model.mName;
    
    //if (model.isEnable) {
    NSString *img = model.mImage_1;
    if (img.length == 0) img = @"nil";
        cell.mImageView.image = [UIImage imageNamed:img];
        
        if (_selectIndex == -1) {
            cell.mLabel.textColor = [UIColor blackColor];
            [JLUI_Effect addShadowOnView_1:cell.mSubView];
        }else{
            if (_selectIndex == indexPath.row) {
                //cell.mLabel.textColor = kDF_RGBA(122, 83, 233, 1.0);
                cell.mLabel.textColor = [UIColor blackColor];
                [JLUI_Effect addShadowOnView_2:cell.mSubView];
            }else{
                cell.mLabel.textColor = [UIColor blackColor];
                [JLUI_Effect addShadowOnView_1:cell.mSubView];
            }
        }
    //}else{
    //    cell.mLabel.textColor = kDF_RGBA(167, 167, 167, 1.0);
    //    cell.mImageView.image = [UIImage imageNamed:model.mImage_1];
    //    [JLUI_Effect addShadowOnView_1:cell.mSubView];
    //}
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.selectIndex = indexPath.row;
    FunctionModel *model = self.dataArray[indexPath.row];
    
    /*--- 蓝牙不连接，也能进入查找设备 ---*/
    NSInteger tp = model.type;
    if (tp == 8) {
        if (blk) { blk(model.type);}
        return;
    }

    JL_BLEMultiple *multiple = [[JL_RunSDK sharedMe] mBleMultiple];
    if (multiple.bleManagerState == CBManagerStatePoweredOff) {
        [DFUITools showText:kJL_TXT("蓝牙没有打开") onView:self delay:1.0];
        return;
    }

    if(multiple.bleConnectedArr.count<1){
        [DFUITools showText:kJL_TXT("请先连接设备") onView:self delay:1.0];
        return;
    }
    
    if (blk) { blk(model.type);}
    
    [_collectionView reloadData];
}

-(void)setFunctionsViewDataArray:(NSArray*)array{
    self.dataArray = array;
    [_collectionView reloadData];
}
-(void)setFunctionsViewSelectIndex:(NSInteger)index{
    
    for (int i = 0; i < _dataArray.count; i++) {
        FunctionModel *model = _dataArray[i];
        if (model.type == index) {
            self.selectIndex = i;
            break;
        }
    }
    [_collectionView reloadData];
}

-(void)onFunctionViewSelectIndex:(FunctionsViewBlock)block{
    blk = block;
}



@end
