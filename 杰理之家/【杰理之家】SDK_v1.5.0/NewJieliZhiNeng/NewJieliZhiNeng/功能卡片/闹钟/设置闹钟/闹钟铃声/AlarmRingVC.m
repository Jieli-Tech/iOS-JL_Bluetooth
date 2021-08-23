//
//  AlarmRingVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/6/29.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AlarmRingVC.h"
#import "AlarmRingCell.h"
#import "JL_RunSDK.h"
#import "RingSelectView.h"
#import "AlarmBottomView.h"

@interface AlarmRingVC ()<AlarmBottomDelegate,UIScrollViewDelegate,RingSelectDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (strong, nonatomic) UITableView *ringTable;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headViewH;
@property (nonatomic,strong) NSArray *itemRing;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) AlarmBottomView *btmView;
@property (nonatomic,strong) NSMutableArray *pageArray;
@property (nonatomic,strong) NSMutableArray *cardArray;
@property (nonatomic,strong) NSArray *cardBottomArray;
@end

@implementation AlarmRingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    _pageArray = [NSMutableArray new];
    [self initWithData];
    [self initWithUI];
    [self addNote];
}

-(void)initWithData{
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    JLModel_Device *model = [entity.mCmdManager outputDeviceModel];
    NSMutableArray *ringItem = [NSMutableArray new];
    for (JLModel_Ring *ring in model.rtcDfRings) {
        [ringItem addObject:ring];
    }
    _itemRing = ringItem;
    
    _titleLab.text = kJL_TXT("铃声");
    _cardArray = [[NSMutableArray alloc] initWithArray:model.cardArray];
    _cardBottomArray = @[kJL_TXT("默认")];
    NSMutableArray *newArray = [NSMutableArray new];
    [newArray addObject:kJL_TXT("默认")];
    for (NSNumber *number in _cardArray) {
        switch ([number intValue]) {
            case JL_CardTypeUSB:{
                [newArray addObject:kJL_TXT("U盘")];
            }break;
            case JL_CardTypeSD_0:{
                [newArray addObject:kJL_TXT("SD卡")];
            }break;
            case JL_CardTypeSD_1:{
                [newArray addObject:kJL_TXT("SD卡2")];
            }break;
            default:
                break;
        }
    }
    _cardBottomArray = newArray;
}

-(void)initWithUI{
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    if (_cardBottomArray.count == 1) {
        _bottomHeight.constant = 0;
    }else{
        _bottomHeight.constant = kJL_HeightTabBar;
    }
    _headViewH.constant = kJL_HeightNavBar;
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar+8, w, h-8-_bottomHeight.constant-kJL_HeightNavBar)];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(w*(_cardBottomArray.count), h-8-_bottomHeight.constant-kJL_HeightNavBar);
    [self.view addSubview:self.scrollView];
    
    RingSelectView *view1 = [[RingSelectView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
    view1.rtcModel = self.rtcModel;
    view1.delegate = self;
    view1.dfArray = _itemRing;
    view1.type = -1;
    [_scrollView addSubview:view1];
    [_pageArray addObject:view1];
    for (int i = 0;i<_cardArray.count;i++) {
        RingSelectView *view = [[RingSelectView alloc] initWithFrame:CGRectMake((i+1)*w, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height)];
        view.rtcModel = self.rtcModel;
        view.delegate = self;
        view.type = [_cardArray[i] intValue];
        [_scrollView addSubview:view];
        [_pageArray addObject:view];
    }
    _btmView = [[AlarmBottomView alloc] initWithFrame:CGRectMake(0, 0, w, 49)];
    _btmView.delegate = self;
    [_btmView setButtonsArray:_cardBottomArray];
    [_bottomView addSubview:_btmView];
    if (_cardBottomArray.count == 1) {
        _bottomView.hidden = YES;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [JL_Tools remove:nil Own:self];
    
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdRtcAudition:self.rtcModel Option:NO result:^(NSArray * _Nullable array) {
        
    }];
}

- (IBAction)leftBtnAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ///AlarmDelegate
-(void)bottomDidSelected:(NSInteger)index{
    CGFloat width = [UIScreen mainScreen].bounds.size.width*index;
    RingSelectView *view = _pageArray[index];
       [view startLoad];
    [_scrollView setContentOffset:CGPointMake(width, 0) animated:YES];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"scrollView.w:%f",scrollView.contentOffset.x);
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    int index = scrollView.contentOffset.x/width;
    RingSelectView *view = _pageArray[index];
    [view startLoad];
    [_btmView btnSelect:index];
}
#pragma mark ///Ring Select Delegate
-(void)ringSelect:(RingSelectView *)view{
    self.rtcModel = view.rtcModel;
    for (RingSelectView *view in _pageArray) {
        view.rtcModel = self.rtcModel;
        [view reloadView];
    }
    JL_EntityM *entity = [[JL_RunSDK sharedMe] mBleEntityM];
    [entity.mCmdManager cmdRtcAudition:self.rtcModel Option:YES result:^(NSArray * _Nullable array) {
        
    }];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline || tp == JLDeviceChangeTypeBleOFF) {
        [self.presentingViewController.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

@end
