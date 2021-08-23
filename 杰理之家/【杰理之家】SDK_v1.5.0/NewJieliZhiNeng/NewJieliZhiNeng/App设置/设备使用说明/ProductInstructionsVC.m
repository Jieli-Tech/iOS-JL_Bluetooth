//
//  ProductInstructionsVC.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/7/23.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "ProductInstructionsVC.h"
#import "JL_RunSDK.h"
#import "JLUI_Cache.h"

@interface ProductInstructionsVC ()<UIScrollViewDelegate>{
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIView *subTitleView;
    __weak IBOutlet UIButton *backBtn;
    
    //底部srollView
    UIScrollView *imgScroll;
    //显示图片
    UIImageView *myImageView;
    //空图片
    UIImageView *noneImv;
    //空文字1
    UILabel *noneLab_1; //网络异常/暂无数据
    //空文字2
    UILabel *noneLab_2; //请检查您的网络连接并稍后再试
    
    DFTips *loadingTp;
    
    NSData *productInstrData;
    BOOL  productNoUpload;
    
    JL_RunSDK *bleSDK;
}

@end

@implementation ProductInstructionsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    bleSDK = [JL_RunSDK sharedMe];
    [self addNote];
    [self initUI];
    
    AFNetworkReachabilityManager *net = [AFNetworkReachabilityManager sharedManager];
    AFNetworkReachabilityStatus st = net.networkReachabilityStatus;
    if (st == AFNetworkReachabilityStatusReachableViaWWAN ||
        st == AFNetworkReachabilityStatusReachableViaWiFi ) {
        [self downloadInfoImage];
    }
}

-(void)initUI{
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    productNoUpload = NO;
    //CGFloat w = self.view.frame.size.width;
    //CGFloat h = self.view.frame.size.height;
    
    float sw = [DFUITools screen_2_W];
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("设备使用说明");
    titleName.bounds = CGRectMake(0, 0, 230, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    noneImv = [[UIImageView alloc] initWithFrame:CGRectMake([DFUITools screen_2_W]/2-230.0/2, [DFUITools screen_2_H]/2-186.5/2, 230.0, 186.5)];
    noneImv.contentMode = UIViewContentModeCenter;
    noneImv.image = [UIImage imageNamed:@"Theme.bundle/product_img_no_network"];
    [self.view addSubview:noneImv];
    noneImv.hidden = YES;
    
    noneLab_1 = [[UILabel alloc] initWithFrame:CGRectMake([DFUITools screen_2_W]/2-60.0, noneImv.frame.origin.y+noneImv.frame.size.height-30, 120.0, 25.0)];
    noneLab_1.textColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0];
    noneLab_1.textAlignment = NSTextAlignmentCenter;
    noneLab_1.font = [UIFont systemFontOfSize:15];
    noneLab_1.text = kJL_TXT("网络异常");
    [self.view addSubview:noneLab_1];
    noneLab_1.hidden=YES;
    
    noneLab_2 = [[UILabel alloc] initWithFrame:CGRectMake([DFUITools screen_2_W]/2-400/2, noneLab_1.frame.origin.y+noneLab_1.frame.size.height+10, 400, 25.0)];
    noneLab_2.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    noneLab_2.textAlignment = NSTextAlignmentCenter;
    noneLab_2.font = [UIFont systemFontOfSize:15];
    noneLab_2.text = kJL_TXT("请检查您的网络连接并稍后再试");
    [self.view addSubview:noneLab_2];
    noneLab_2.hidden=YES;
    
    [self handleUIRefresh];
    [self networkCheck];
}

#pragma mark 处理界面刷新
-(void)handleUIRefresh{
    [self imgScroll];
    [self myImageView];
}

#pragma mark 更新UI
-(void)downloadInfoImage{
    
    if(bleSDK.mBleEntityM){
        if (bleSDK.mBleEntityM.mVID.length == 0) return;
        if (bleSDK.mBleEntityM.mPID.length == 0) return;
        
        NSNumber *vidNumber = [NSNumber numberWithLong:strtoul(bleSDK.mBleEntityM.mVID.UTF8String, 0, 16)];
        NSString *vidStr = [vidNumber stringValue];
        
        NSNumber *pidNumber = [NSNumber numberWithLong:strtoul(bleSDK.mBleEntityM.mPID.UTF8String, 0, 16)];
        NSString *pidStr = [pidNumber stringValue];
        
        NSArray *itemArr = @[@"PRODUCT_INSTRUCTIONS_EN",@"PRODUCT_INSTRUCTIONS_CN"];
        
        __weak typeof(self) wSelf = self;
        [self startLoadingView:@"加载中..." Delay:10];
        [bleSDK.mBleEntityM.mCmdManager cmdRequestDeviceImageVid:vidStr Pid:pidStr
                                                       ItemArray:itemArr Result:^(NSMutableDictionary * _Nullable dict) {
            if (dict.allKeys.count>0) {
                self->productNoUpload = NO;
                NSDictionary *dict_1 = [NSDictionary dictionaryWithDictionary:dict];
                if([kJL_GET hasPrefix:@"zh"]){
                    self->productInstrData = dict_1[@"PRODUCT_INSTRUCTIONS_CN"][@"IMG"];
                }else{
                    self->productInstrData = dict_1[@"PRODUCT_INSTRUCTIONS_EN"][@"IMG"];
                }
            }else{
                self->productNoUpload = YES;
                
                [JL_Tools mainTask:^{
                    [wSelf mProductNoUpload];
                }];
            }

            [JL_Tools mainTask:^{
                [wSelf closeLoadingView];
                [wSelf handleUIRefresh];
            }];
        }];
    }
}

-(UIScrollView *)imgScroll {
    if (!imgScroll) {
        imgScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kJL_HeightNavBar, [DFUITools screen_2_W], [DFUITools screen_2_H]-kJL_HeightNavBar)];
        imgScroll.delegate = self;
        //底部不要透明，否则图片缩小的时候会看到被遮住的界面
        imgScroll.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:imgScroll];
        CGFloat imgH = [self imgContentHeight];
        imgScroll.contentSize = CGSizeMake(0,imgH);
    }
    return imgScroll;
}

-(UIImageView *)myImageView {
    if (!myImageView) {
        CGFloat imgH = [self imgContentHeight];
        if(imgH>0){
            myImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [DFUITools screen_2_W], imgH)];
            myImageView.backgroundColor = [UIColor clearColor];
            myImageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.imgScroll addSubview:myImageView];
        }
    }
    myImageView.image = [UIImage imageWithData:productInstrData];
    return myImageView;
}

#pragma mark - 内容的高度
-(CGFloat)imgContentHeight{
    
    UIImage *img;
     if (bleSDK.mBleEntityM.mType == 1) { //耳机
         img = [UIImage imageNamed:@"Theme.bundle/product_headset.jpg"];
     }else{
        img = [UIImage imageNamed:@"Theme.bundle/product_soundbox.jpg"];
     }
    CGFloat imgHeight = img.size.height;
    CGFloat imgWidth = img.size.width;
    CGFloat imgH = imgHeight * ([DFUITools screen_2_W] / imgWidth);
    return imgH;
}

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI加载框
-(void)startLoadingView:(NSString*)text Delay:(NSTimeInterval)delay{
    [loadingTp removeFromSuperview];
    loadingTp = nil;
    
    loadingTp = [DFUITools showHUDWithLabel:text onView:self.view alpha:0.8
                                      color:[UIColor blackColor]
                             labelTextColor:[UIColor whiteColor]//kDF_RGBA(36, 36, 36, 1.0)
                     activityIndicatorColor:[UIColor whiteColor]];
    [loadingTp hide:YES afterDelay:delay];
}

-(void)setLoadingText:(NSString*)text Delay:(NSTimeInterval)delay{
    loadingTp.labelText = text;
    [loadingTp hide:YES afterDelay:delay];
    [JL_Tools delay:delay+0.5 Task:^{
        [self->loadingTp removeFromSuperview];
        self->loadingTp = nil;
    }];
}

-(void)closeLoadingView{
    [loadingTp hide:YES];
    [loadingTp removeFromSuperview];
    loadingTp = nil;
}



-(void)mProductNoUpload{
    imgScroll.hidden = YES;
    noneImv.hidden = NO;
    noneLab_1.hidden = NO;
    noneLab_1.text = kJL_TXT("暂无数据");
    noneLab_2.hidden = YES;
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLUuidType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


-(void)noteNetworkStatus:(NSNotification*)note{
    [self networkCheck];
}

-(void)networkCheck{
    if (productInstrData.length > 0) return;

    AFNetworkReachabilityManager *net = [AFNetworkReachabilityManager sharedManager];
    AFNetworkReachabilityStatus st = net.networkReachabilityStatus;
    
    noneLab_1.text = kJL_TXT("网络异常");
    if (st == AFNetworkReachabilityStatusNotReachable) {
        imgScroll.hidden = YES;
        noneImv.hidden = NO;
        noneLab_1.hidden = NO;
        noneLab_2.hidden = NO;
    }
    if (st == AFNetworkReachabilityStatusUnknown) {
        imgScroll.hidden = YES;
        noneImv.hidden = NO;
        noneLab_1.hidden = NO;
        noneLab_2.hidden = NO;
    }
    if (st == AFNetworkReachabilityStatusReachableViaWWAN) {
        imgScroll.hidden = NO;
        [imgScroll setContentOffset:CGPointZero animated:YES];
        noneImv.hidden = YES;
        noneLab_1.hidden = YES;
        noneLab_2.hidden = YES;
    }
    if (st == AFNetworkReachabilityStatusReachableViaWiFi) {
        imgScroll.hidden = NO;
        [imgScroll setContentOffset:CGPointZero animated:YES];
        noneImv.hidden = YES;
        noneLab_1.hidden = YES;
        noneLab_2.hidden = YES;
        
        if (productInstrData.length == 0) {
            [self downloadInfoImage];
        }
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
    [JL_Tools add:AFNetworkingReachabilityDidChangeNotification Action:@selector(noteNetworkStatus:) Own:self];

}

-(void)dealloc{
    [self closeLoadingView];
    [JL_Tools remove:nil Own:self];
}
@end
