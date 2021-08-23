//
//  DeviceMusicVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/9/2.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "DeviceMusicVC.h"
#import "TabCollectionCell.h"
#import "SongListCell.h"
#import "DMusicHandler.h"
#import "NetworkPlayer.h"
#import "MJRefresh.h"

@interface DeviceMusicVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITableViewDelegate,UITableViewDataSource,DMHandlerDelegate>{
    UIView *sd_1_view; //SD卡1的view
    UIView *sd_2_view; //SD卡2的view
    UILabel *sdFirstTitle; //SD卡1的Label
    UILabel *sdSecondTitle; //SD卡2的Label
    NSArray *titleArray;
    NSArray *itemArray;
    uint32_t clusNow;
}
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headHeight;
@property (weak, nonatomic) IBOutlet UICollectionView *TabCollectView;
@property (weak, nonatomic) IBOutlet UITableView *FileTableView;
@property (weak, nonatomic) IBOutlet UIView *nullView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLab;

@end

@implementation DeviceMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
    [self initUI];
}

- (IBAction)backBtnAction:(id)sender {
    [self removeNote];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateMusicState{
    [self.FileTableView reloadData];
}

#pragma mark ///通知
-(void)addNote{
    [JLModel_Device observeModelProperty:@"playStatus" Action:@selector(updateMusicState) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)removeNote{
    [JL_Tools remove:kUI_JL_DEVICE_CHANGE Own:self];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeSomethingConnected ||
        type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeBleOFF) {
       [self backBtnAction:nil];
    }
}


-(void)initUI{
    _headHeight.constant = kJL_HeightNavBar;
    self.tipsLab.text = kJL_TXT("空文件夹");
    NSArray *suportArray = self.devel.cardArray;
    [[DMusicHandler sharedInstance] setDelegate:self];
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    if (entity) {
        [[DMusicHandler sharedInstance] setNowEntity:entity];
    }
    UICollectionViewFlowLayout *fl = [[UICollectionViewFlowLayout alloc] init];
    fl.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    fl.minimumLineSpacing = 0;
    fl.minimumInteritemSpacing = 0;
    self.TabCollectView.collectionViewLayout = fl;
    self.TabCollectView.delegate = self;
    self.TabCollectView.dataSource = self;
    [self.TabCollectView registerNib:[UINib nibWithNibName:@"TabCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"TabCollectionCell"];
    [self.TabCollectView setShowsHorizontalScrollIndicator:NO];
    
    self.FileTableView.delegate = self;
    self.FileTableView.dataSource = self;
    self.FileTableView.rowHeight = 50;
    self.FileTableView.tableFooterView = [UIView new];
    self.FileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.FileTableView addFooterWithCallback:^{
        [[DMusicHandler sharedInstance] requestModelBy:20];
    }];
    self.FileTableView.footerReleaseToRefreshText = kJL_TXT("松开立即加载更多");
    self.FileTableView.footerRefreshingText = kJL_TXT("正在加载更多的数据...");
    
    switch (self.type) {
        case 0:{//USB
            _titleLab.text = kJL_TXT("U盘");
            [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeUSB];
        }break;
        case 1:{//SD card
            if([suportArray containsObject:@(JL_CardTypeSD_0)]){
                _titleLab.text = kJL_TXT("SD卡");
                [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_0];
            }else if ([suportArray containsObject:@(JL_CardTypeSD_1)]){
                _titleLab.text = kJL_TXT("SD卡2");
                [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_1];
            }else if ([suportArray containsObject:@(JL_CardTypeSD_0)]&&[suportArray containsObject:@(JL_CardTypeSD_1)]){
                [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_0];
                [self initWithTitile];
            }
        }break;
            
        default:
            break;
    }
    
}


-(void)initWithTitile{
    //SD卡0和SD卡1同时存在
    sdFirstTitle = [[UILabel alloc] init];
    sdFirstTitle.frame = CGRectMake(118.5,_headView.frame.size.height/2+17/2,55,17);
    sdFirstTitle.numberOfLines = 0;
    [self.view addSubview:sdFirstTitle];
    
    NSMutableAttributedString *sdFirstStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡1") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    
    sdFirstTitle.attributedText = sdFirstStr;
    
    UITapGestureRecognizer *sdFirstRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sdFirstClick)];
    [sdFirstTitle addGestureRecognizer:sdFirstRecognizer];
    sdFirstTitle.userInteractionEnabled=YES;
    
    sd_1_view = [[UIView alloc] init];
    sd_1_view.frame = CGRectMake(sdFirstTitle.frame.origin.x+8.5,sdFirstTitle.frame.origin.y+sdFirstTitle.frame.size.height+8.5,35,3);
    sd_1_view.backgroundColor = [UIColor colorWithRed:134/255.0 green:101/255.0 blue:243/255.0 alpha:1.0];
    sd_1_view.layer.cornerRadius = 1.5;
    [self.view addSubview:sd_1_view];
    
    sdSecondTitle = [[UILabel alloc] init];
    sdSecondTitle.frame = CGRectMake(sdFirstTitle.frame.origin.x+sdFirstTitle.frame.size.width+44,_headView.frame.size.height/2+17/2,55,17);
    sdSecondTitle.numberOfLines = 0;
    [self.view addSubview:sdSecondTitle];
    
    NSMutableAttributedString *sdSecondStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡2") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:0.7]}];
    
    sdSecondTitle.attributedText = sdSecondStr;
    
    UITapGestureRecognizer *sdSecondTitleRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sdSecondClick)];
    [sdSecondTitle addGestureRecognizer:sdSecondTitleRecognizer];
    sdSecondTitle.userInteractionEnabled=YES;
    
    sd_2_view = [[UIView alloc] init];
    sd_2_view.frame = CGRectMake(sdSecondTitle.frame.origin.x+8.5,sdSecondTitle.frame.origin.y+sdSecondTitle.frame.size.height+8.5,35,3);
    sd_2_view.backgroundColor = [UIColor colorWithRed:134/255.0 green:101/255.0 blue:243/255.0 alpha:1.0];
    sd_2_view.layer.cornerRadius = 1.5;
    [self.view addSubview:sd_2_view];
    sd_2_view.hidden = YES;
}

-(void)sdFirstClick{
    sd_1_view.hidden = NO;
    sd_2_view.hidden = YES;
    
    NSMutableAttributedString *sdFirstStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡1") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    
    sdFirstTitle.attributedText = sdFirstStr;
    
    NSMutableAttributedString *sdSecondStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡2") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:0.7]}];
    
    sdSecondTitle.attributedText = sdSecondStr;
    _type = 1;
    [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_0];
}

-(void)sdSecondClick{
    sd_1_view.hidden = YES;
    sd_2_view.hidden = NO;
    
    NSMutableAttributedString *sdFirstStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡2") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    
    sdSecondTitle.attributedText = sdFirstStr;
    NSMutableAttributedString *sdSecondStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("SD卡1") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 15],NSForegroundColorAttributeName: [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:0.7]}];
    sdFirstTitle.attributedText = sdSecondStr;
    _type = 2;
    [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_1];
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
    JLFileModel *model = titleArray[indexPath.row];
    cell.titleLab.text = model.folderName;
    cell.titleLab.textColor = [UIColor colorWithRed:139.0/255.0 green:139.0/255.0 blue:139.0/255.0 alpha:1];
    if (indexPath.row == titleArray.count-1 && titleArray.count != 1) {
        cell.titleLab.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1];
    }
   
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    JLModel_File *model = titleArray[indexPath.row];
    [[DMusicHandler sharedInstance] tabArraySelect:model];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    JLModel_File *model = titleArray[indexPath.row];
    CGFloat width = [self getWidthWithText:model.folderName height:46 font:14]+15;
    return CGSizeMake(width, 46);
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return titleArray.count;
}

#pragma mark ///TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return itemArray.count;;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SongListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"songListCell"];
    if (cell == nil) {
        cell = [[SongListCell alloc] init];
        cell.songName.frame = CGRectMake(53,cell.frame.size.height/2-15, [DFUITools screen_2_W]-80, 20);
        cell.artistLab.hidden = YES;
        cell.numberLab.hidden = YES;
    }
    
    JLModel_File *model = itemArray[indexPath.row];
    cell.songName.text = [NSString stringWithFormat:@" %@",model.fileName];
    cell.songName.textColor = [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0];
    if (model.fileType == JL_BrowseTypeFolder) {
        cell.animateImgv.image = [UIImage imageNamed:@"Theme.bundle/list_icon_file"];
    }else{
        JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
        JLModel_Device *currentModel = [entity.mCmdManager outputDeviceModel];
        if (model.fileClus == currentModel.currentClus) {
            cell.songName.textColor = kColor_0000;
            cell.animateImgv.animationImages = @[[UIImage imageNamed:@"Theme.bundle/list_play_01"],
                                               [UIImage imageNamed:@"Theme.bundle/list_play_02"],
                                               [UIImage imageNamed:@"Theme.bundle/list_play_03"],
                                               [UIImage imageNamed:@"Theme.bundle/list_play_04"]];
            cell.animateImgv.animationDuration = 0.7;
            cell.animateImgv.animationRepeatCount = 0;
            if(currentModel.playStatus == JL_MusicStatusPlay){
                [cell.animateImgv startAnimating];
            }
            if(currentModel.playStatus == 0x02){
                currentModel.playStatus = 0x00;
            }
            if(currentModel.playStatus == JL_MusicStatusPause || currentModel.currentFunc!=JL_FunctionCodeMUSIC){
                [cell.animateImgv stopAnimating];
                [cell.animateImgv setImage:[UIImage imageNamed:@"Theme.bundle/list_play_01"]];
            }
        }else{
            [cell.animateImgv stopAnimating];
            cell.animateImgv.image = [UIImage imageNamed:@"Theme.bundle/list_icon_music"];//文件
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JLModel_File *model = itemArray[indexPath.row];
    if(model.fileType == JL_BrowseTypeFile){
        /*--- 关闭本地\网络音乐 ---*/
        [DFAudioPlayer didAllPause];
        [[NetworkPlayer sharedMe] didStop];
    }
    [[DMusicHandler sharedInstance] requestWith:model Number:20];
}

#pragma mark ///数据返回
-(void)dmHandleWithPlayItemOK{
    [self.FileTableView reloadData];
}
-(void)dmHandleWithTabTitleArray:(NSArray<JLFileModel *> *)modelA{
    titleArray = modelA;
    [self.TabCollectView reloadData];
    if (titleArray.count>0) {
        [self.TabCollectView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:titleArray.count-1 inSection:0] atScrollPosition:(UICollectionViewScrollPositionLeft) animated:YES];
    }
}
-(void)dmHandleWithItemModelArray:(NSArray<JLFileModel *> *)modelB{
    itemArray = modelB;
    if (itemArray.count>0) {
        self.nullView.hidden = YES;
    }else{
        self.nullView.hidden = NO;
    }
    [self.FileTableView reloadData];
    if (self.FileTableView.isFooterRefreshing) {
        [self.FileTableView footerEndRefreshing];
    }
}
- (void)dmLoadFailed:(DM_ERROR)err{
    switch (err) {
        case DM_ERROR_Max_Fold:{
            [DFUITools showText:kJL_TXT("超出可读层级") onView:self.view delay:2];
        }break;
            
        default:
            break;
    }
}
- (void)dmCardMessageDismiss:(NSArray *)nowArray{
    if ([nowArray containsObject:@(self.type)]) {
        if (self.type == 1) {
            if ([nowArray containsObject:@(JL_CardTypeSD_0)]&&[nowArray containsObject:@(JL_CardTypeSD_1)]){
                [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_0];
                if (!sd_1_view) {
                    [self initWithTitile];
                }else{
                    sd_1_view.hidden = NO;
                    sd_2_view.hidden = NO;
                    _titleLab.hidden = YES;
                }
            }else{
                if (sd_1_view) {
                    sd_1_view.hidden = YES;
                    sd_2_view.hidden = YES;
                }
                if([nowArray containsObject:@(JL_CardTypeSD_0)]){
                    _titleLab.text = kJL_TXT("SD卡1");
                    [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_0];
                }else if ([nowArray containsObject:@(JL_CardTypeSD_1)]){
                    _titleLab.text = kJL_TXT("SD卡2");
                    [[DMusicHandler sharedInstance] loadModeData:JL_CardTypeSD_1];
                }
            }
        }
    }else{
        [self backBtnAction:nil];
    }
}
@end
