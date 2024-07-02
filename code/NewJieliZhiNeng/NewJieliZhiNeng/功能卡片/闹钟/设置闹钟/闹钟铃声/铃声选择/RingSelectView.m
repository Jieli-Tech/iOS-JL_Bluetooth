//
//  RingSelectView.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/7.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "RingSelectView.h"
#import "MJRefresh.h"
#import "DMusicHandler.h"
#import "TabCollectionCell.h"
#import "AlarmRingCell.h"
#import "NetworkPlayer.h"


@interface RingSelectView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,DMHandlerDelegate>{
    NSArray *titleArray;
    NSArray *itemArray;
    UIView *nullView;
    DMusicHandler *handler;
    BOOL isFirstLoad;
}
@property(nonatomic,strong)UICollectionView *TabCollectView;
@property(nonatomic,strong)UITableView *FileTableView;
@end

@implementation RingSelectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isFirstLoad = YES;
    }
    return self;
}
- (void)setType:(NSInteger)type{
    _type = type;
    [self initUi];
}


-(void)startLoad{
    if (self.type == -1) {
        return;
    }
    handler.delegate = self;
    [handler loadModeData:self.type];
    NSLogEx(@"%@",self);
}

-(void)reloadView{
    [_FileTableView reloadData];
}


-(void)initUi{
    CGFloat y = 0;
    if (self.type != -1) {
        UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
        fl.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        fl.minimumLineSpacing = 0;
        fl.minimumInteritemSpacing = 0;
        self.TabCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width-20, 46) collectionViewLayout:fl];
        self.TabCollectView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:250.0/255.0 blue:252.0/255.0 alpha:1.0];
        self.TabCollectView.delegate = self;
        self.TabCollectView.dataSource = self;
        [self.TabCollectView registerNib:[UINib nibWithNibName:@"TabCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"TabCollectionCell"];
        [self.TabCollectView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:self.TabCollectView];
        y = self.TabCollectView.frame.size.height;
    }else{
         y = 0;
    }
    self.FileTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width, self.frame.size.height-y)];
    self.FileTableView.delegate = self;
    self.FileTableView.dataSource = self;
    self.FileTableView.rowHeight = 50;
    self.FileTableView.tableFooterView = [UIView new];
    //self.FileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.FileTableView.backgroundColor = [UIColor colorWithRed:248.0/255.0 green:250.0/255.0 blue:252.0/255.0 alpha:1.0];
    //self.FileTableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    self.FileTableView.separatorColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    if (self.type!=-1) {
        handler = [[DMusicHandler alloc] init];
        [handler setNowEntity:[[JL_RunSDK sharedMe] mBleEntityM]];
        [self.FileTableView addFooterWithCallback:^{
            [self->handler requestModelBy:20];
        }];
//        handler.delegate = self;
        self.FileTableView.footerReleaseToRefreshText = kJL_TXT("loosen_load_more");
        self.FileTableView.footerRefreshingText = kJL_TXT("loading_more_data");
    }
    [self addSubview:self.FileTableView];
    
    nullView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-94, 100, 188, 194)];
    nullView.backgroundColor = [UIColor clearColor];
    [self addSubview:nullView];
    UIImageView *imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 188, 164)];
    imgv.image = [UIImage imageNamed:@"Theme.bundle/device_nil"];
    [nullView addSubview:imgv];
    UILabel *nulLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 164, 188, 30)];
    nulLab.textColor = [UIColor colorWithRed:89.0/255.0 green:89.0/255.0 blue:89.0/255.0 alpha:1.0];
    nulLab.textAlignment = NSTextAlignmentCenter;
    nulLab.text = kJL_TXT("empty_folder");
    nulLab.font = [UIFont systemFontOfSize:16];
    [nullView addSubview:nulLab];
    nullView.hidden = YES;
    
}



/// 计算宽度
/// @param text 文字
/// @param height 高度
/// @param font 字体
- (CGFloat)getWidthWithText:(NSString *)text height:(CGFloat)height font:(CGFloat)font{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:font]} context:nil];
    return rect.size.width;
}

#pragma mark ///CollectionView delegate
-(__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TabCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TabCollectionCell" forIndexPath:indexPath];
    if (titleArray.count == 1 || indexPath.row == (titleArray.count-1)) {
        cell.nextImgv.hidden = YES;
    }else{
        cell.nextImgv.hidden = NO;
    }
    JLModel_File *model = titleArray[indexPath.row];
    cell.titleLab.text = model.folderName;
    cell.titleLab.textColor = [UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1];
    if (indexPath.row == titleArray.count-1 && titleArray.count != 1) {
        cell.titleLab.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1];
    }
   
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    JLModel_File *model = titleArray[indexPath.row];
    [handler tabArraySelect:model];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    JLModel_File *model = titleArray[indexPath.row];
    CGFloat width = [self getWidthWithText:model.folderName height:46 font:14]+15;
    return CGSizeMake(width, 46);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return titleArray.count;
}

#pragma mark TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.type == -1) {
        return self.dfArray.count;
    }else{
        return itemArray.count;;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlarmRingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlarmRingCell"];
    if (cell == nil) {
        cell = [[AlarmRingCell alloc] init];
    }
    cell.animaLab.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
    if (self.type == -1) {
        cell.songImgv.image = [UIImage imageNamed:@"Theme.bundle/list_icon_music"];//文件
        JLModel_Ring *ring = self.dfArray[indexPath.row];
        cell.animaLab.text = ring.name;
        if (ring.index == self.rtcModel.ringInfo.clust) {
            cell.selectImgv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
        }else{
            cell.selectImgv.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
        }
    }else{
        JLModel_File *model = itemArray[indexPath.row];
        cell.animaLab.text = [NSString stringWithFormat:@" %@",model.fileName];
        if (model.fileType == JL_BrowseTypeFolder) {
            cell.songImgv.image = [UIImage imageNamed:@"Theme.bundle/list_icon_file"];
            cell.selectImgv.hidden = YES;
        }else{
            cell.selectImgv.hidden = NO;
            cell.songImgv.image = [UIImage imageNamed:@"Theme.bundle/list_icon_music"];//文件
        }
        if (model.fileClus == self.rtcModel.ringInfo.clust) {
            cell.selectImgv.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
        }else{
            cell.selectImgv.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
        }
    }
    
    cell.separatorInset = UIEdgeInsetsMake(0, 20, 0, 0);
    cell.layoutMargins = UIEdgeInsetsMake(0, 20, 0, 0);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.type == -1) {
        JLModel_Ring *ring = self.dfArray[indexPath.row];
        self.rtcModel.ringInfo.type = 0;
        self.rtcModel.ringInfo.dev = 0;
        self.rtcModel.ringInfo.clust = ring.index;
        self.rtcModel.ringInfo.data = [ring.name dataUsingEncoding:NSUTF8StringEncoding];
        self.rtcModel.ringInfo.len = self.rtcModel.ringInfo.data.length;
        if ([_delegate respondsToSelector:@selector(ringSelect:)]) {
            [_delegate ringSelect:self];
        }
    }else{
        JLModel_File *model = itemArray[indexPath.row];
        if(model.fileType == JL_BrowseTypeFile){
            /*--- 关闭本地\网络音乐 ---*/
            [DFAudioPlayer didAllPause];
            [[NetworkPlayer sharedMe] didStop];
        }
        if (model.fileType == JL_BrowseTypeFolder) {
            [handler requestWith:model Number:20];
        }else{
            self.rtcModel.ringInfo.type = 0x01;
            self.rtcModel.ringInfo.dev = model.cardType;
            self.rtcModel.ringInfo.clust = model.fileClus;
            NSString *name = [self sortByName:model.fileName];
            self.rtcModel.ringInfo.data = [name dataUsingEncoding:NSUTF8StringEncoding];
            self.rtcModel.ringInfo.len = self.rtcModel.ringInfo.data.length;
            if ([_delegate respondsToSelector:@selector(ringSelect:)]) {
                [_delegate ringSelect:self];
            }
        }
    }
    [self.FileTableView reloadData];
    
}
#pragma mark ///数据返回
-(void)dmHandleWithPlayItemOK{
    [self.FileTableView reloadData];
}
-(void)dmHandleWithTabTitleArray:(NSArray<JLModel_File *> *)modelA{
    titleArray = modelA;
    [self.TabCollectView reloadData];
    [self.TabCollectView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:titleArray.count-1 inSection:0] atScrollPosition:(UICollectionViewScrollPositionLeft) animated:YES];
}
-(void)dmHandleWithItemModelArray:(NSArray<JLModel_File *> *)modelB{
    itemArray = modelB;
    if (itemArray.count>0) {
        nullView.hidden = YES;
    }else{
        nullView.hidden = NO;
    }
    [self.FileTableView reloadData];
    if (self.FileTableView.isFooterRefreshing) {
        [self.FileTableView footerEndRefreshing];
    }
}
- (void)dmLoadFailed:(DM_ERROR)err{
    switch (err) {
        case DM_ERROR_Max_Fold:{
            [DFUITools showText:kJL_TXT("msg_read_file_err_beyond_max_depth") onView:self.superview delay:2];
        }break;
            
        default:
            break;
    }
}
- (void)dmCardMessageDismiss:(NSArray *)nowArray{
    
}


-(NSString *)sortByName:(NSString *)baseStr{
    NSData *dt = [baseStr dataUsingEncoding:NSUTF8StringEncoding];
    if (dt.length<=32) {
        return [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
    }else{
        return [self sortByName:[baseStr substringToIndex:baseStr.length-1]];
    }
}
-(BOOL)isZh_CN:(NSString *)str{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:str];
}

@end
