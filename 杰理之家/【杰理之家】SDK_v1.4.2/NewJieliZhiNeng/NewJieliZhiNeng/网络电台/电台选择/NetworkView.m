//
//  NetworkView.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/7/8.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "NetworkView.h"
#import "UIImageView+WebCache.h"


@interface NetworkView()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NetworkViewBlock subBlock;
    float sW;
    float sH;
}
@property (nonatomic, strong)UICollectionView *collectionView;
@end


@implementation NetworkView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isDelete = NO;
        sW = frame.size.width;
        sH = frame.size.height;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat itemW = (sW - 12)/ 3;
        CGFloat itemH = itemW+30.0;
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
        
        UINib *nib = [UINib nibWithNibName:@"NetworkCell" bundle:nil];
        [_collectionView registerNib:nib forCellWithReuseIdentifier:@"NetworkCell"];
        [self addSubview:_collectionView];
    }
    return self;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NetworkCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NetworkCell" forIndexPath:indexPath];
    
    /*
     {   description = "";
         explain = "";
         icon = "http://cnvod.cnr.cn/audio2017/ondemand/img/1100/20190709/1562667945305.png";
         id = 1278136977654984706;
         name = "\U5317\U4eac\U4ea4\U901a\U5e7f\U64ad";
         placeId = 1278133984025042946;
         stream = "http://cnlive.cnr.cn/hls/bjjtgb.m3u8";
         updateTime = "2020-07-01 09:22:56";
         uuid = "76857685-9704-48f6-9299-314a38dcc0b0";}
     */
    
    
    NSDictionary *infoDict = _dataArray[indexPath.row];
    
    NSString *url = infoDict[@"icon"];
    NSString *url_1 = [DFHttp encodeURL:url];
    NSString *name= infoDict[@"name"];
    UIImage  *imagePlace = [UIImage imageNamed:@"Theme.bundle/img_placeholder"];

    [cell.subImageView sd_setImageWithURL:[NSURL URLWithString:url_1] placeholderImage:imagePlace];
    cell.subDeleteBtn.hidden = !self.isDelete;
    cell.subText.text = name;
    cell.subText.textColor = [UIColor blackColor];
    cell.subTag = indexPath.row;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isDelete == YES) return;
    [DFAudioPlayer didAllPause];
    if (subBlock)subBlock(indexPath.row);
    
    /*--- 执行动画 ---*/
    [self makeAnimationCollectionView:collectionView IndexPath:indexPath];
}

-(void)makeAnimationCollectionView:(UICollectionView *)collectionView IndexPath:(NSIndexPath *)indexPath{
    
    [JL_Tools post:@"kUI_FUNCTION_ACTION" Object:@(9)];

    BOOL isOK = [DFAction setMinExecutionGap:0.72];
    if (isOK == NO) return;
    
    float win_h = [DFUITools screen_2_H];
    NetworkCell *cell = (NetworkCell*)[collectionView cellForItemAtIndexPath:indexPath];

    [UIView animateWithDuration:0.08 animations:^{
        cell.transform = CGAffineTransformMakeScale(0.9, 0.9);
        cell.alpha = 0.9;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.08 animations:^{
            cell.transform = CGAffineTransformMakeScale(1.0, 1.0);
            cell.alpha = 1.0;
        } completion:^(BOOL finished) {
            /*--- 执行动画 ---*/
            CGRect cellRect = [collectionView convertRect:cell.frame toView:collectionView];
            UIWindow* window=[[[UIApplication sharedApplication] delegate] window];
            CGRect rect2 = [collectionView convertRect:cellRect toView:window];
              
            UIImageView *imgView = [UIImageView new];
            imgView.layer.cornerRadius = 7;
            imgView.image = cell.subImageView.image;
            imgView.frame = rect2;
            [window addSubview:imgView];
            
            [UIView animateWithDuration:0.35 animations:^{
                imgView.transform = CGAffineTransformMakeScale(0.4, 0.4);
            }];
              
            CAKeyframeAnimation *keyframeAnimation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
            CGMutablePathRef path = CGPathCreateMutable();
            CGPathMoveToPoint(path, NULL, imgView.layer.position.x, imgView.layer.position.y);//移动到起始点
            CGPathAddQuadCurveToPoint(path, NULL, imgView.layer.position.x-50, imgView.layer.position.y, 33, win_h-kJL_HeightTabBar-10+33);
            keyframeAnimation.path = path;
            CGPathRelease(path);
            keyframeAnimation.duration = 0.55;
            [imgView.layer addAnimation:keyframeAnimation forKey:@"KCKeyframeAnimation_Position"];
            
            [DFAction delay:0.45 Task:^{
                [imgView removeFromSuperview];
            }];
        }];
    }];
}


-(void)setNetworkViewDataArray:(NSArray*)array{
    self.dataArray = array;
    [_collectionView reloadData];
}

-(void)onNetworkViewBlock:(NetworkViewBlock)block{
    subBlock = block;
}

-(void)setIsDelete:(BOOL)isDelete{
    _isDelete = isDelete;
    [_collectionView reloadData];
}

@end
