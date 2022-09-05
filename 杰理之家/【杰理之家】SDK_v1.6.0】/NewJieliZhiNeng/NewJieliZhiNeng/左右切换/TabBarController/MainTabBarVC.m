//
//  MainTabBarVC.m
//  CCSildeTabBarController
//
//  Created by wsk on 16/8/22.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "MainTabBarVC.h"
#import "TransitionAnimation.h"
#import "MultiMediaVC.h"
#import "EQSettingVC.h"
#import "DeviceVC.h"
#import "DeviceVC_2.h"
#import "UpgradeVC.h"
#import "JLUI_Cache.h"
#import "IACircularSlider.h"
#import "ShackHandler.h"


@interface MainTabBarVC ()<UITabBarControllerDelegate,LanguagePtl>{
    NSArray *arr_vc;
}

@property(nonatomic, strong)UISwipeGestureRecognizer *swipeLeft;
@property(nonatomic, strong)UISwipeGestureRecognizer *swipeRight;
@end

@implementation MainTabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LanguageCls share] add:self];
    [self addNote];
    [self initUI];
    [self addShacker];
}

- (UIImage *)imageAlwaysOriginal:(UIImage *)image{
    UIImage *img = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    return img;
}

-(void)viewWillAppear:(BOOL)animated
{
    NSString *uuid = [[JLUI_Cache sharedInstance] renameUUID];
    if(uuid.length == 0) {
        [JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];
    }
    [self.selectedViewController beginAppearanceTransition: YES animated: animated];
}

-(void) viewDidAppear:(BOOL)animated
{
    [self.selectedViewController endAppearanceTransition];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [JL_Tools post:kUI_JL_BLE_SCAN_CLOSE Object:nil];
    [self.selectedViewController beginAppearanceTransition: NO animated: animated];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [self.selectedViewController endAppearanceTransition];
}

-(void) initUI{
    MultiMediaVC *vc_1 = [[MultiMediaVC alloc] init];
    EQSettingVC  *vc_2 = [[EQSettingVC alloc] init];
    //DeviceVC     *vc_3 = [[DeviceVC alloc] init];
    DeviceVC_2   *vc_3 = [[DeviceVC_2 alloc] init];
    arr_vc = @[vc_1,vc_2,vc_3];
//    arr_vc = @[vc_1];
    
//    UIViewController *vc_1 = [[UIViewController alloc] init];
//    UIViewController *vc_2 = [[UIViewController alloc] init];
//    UIViewController *vc_3 = [[UIViewController alloc] init];
//    arr_vc = @[vc_3];
    

    NSArray *arr_txt = @[kJL_TXT("tab_multimedia"),kJL_TXT("tab_eq"),kJL_TXT("tab_device")];
    NSArray *arr_img = @[@"Theme.bundle/tab_icon_mul_nor",@"Theme.bundle/tab_icon_eq_nor",@"Theme.bundle/tab_icon_product_nor"];
    NSArray *arr_img_sel = @[@"Theme.bundle/tab_icon_mul_sel",@"Theme.bundle/tab_icon_eq_sel",@"Theme.bundle/tab_icon_product_sel"];
    

    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kDF_RGBA(70, 70, 70, 1.0), NSForegroundColorAttributeName, [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f],NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kColor_0000, NSForegroundColorAttributeName, [UIFont fontWithName:@"PingFangSC-Semibold" size:14.0f],NSFontAttributeName,nil] forState:UIControlStateSelected];
    
    
    for (int i = 0 ; i < arr_vc.count; i++) {
        UIViewController *uiviewController = arr_vc[i];
        /*--- TabBarItem的名字 ---*/
        uiviewController.tabBarItem.title = arr_txt[i];
        
        /*--- 使用原图片作为底部的TabBarItem ---*/
        NSString *str_img  = arr_img[i];
        NSString *str_img_sel = arr_img_sel[i];
        if (str_img.length == 0) str_img = @"nil";
        if (str_img_sel.length == 0) str_img_sel = @"nil";

        
        UIImage *image     = [UIImage imageNamed:str_img];
        UIImage *image_sel = [UIImage imageNamed:str_img_sel];
        uiviewController.tabBarItem.image         = [self imageAlwaysOriginal:image];
        uiviewController.tabBarItem.tag = i;
        uiviewController.tabBarItem.selectedImage = [self imageAlwaysOriginal:image_sel];
        
        /*--- 隐藏底部 ---*/
        [uiviewController.tabBarController.tabBar setHidden:NO];
    }
    
    self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    self.tabBar.tintColor     = kColor_0000;
    self.tabBar.barTintColor  = [UIColor whiteColor];
    self.viewControllers      = arr_vc;
    self.delegate = self;
    self.selectedIndex = 0;
    _swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedRightButton:)];
    [_swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:_swipeLeft];

    _swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(tappedLeftButton:)];
    [_swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:_swipeRight];
}

-(void)addShacker{
    [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
    [self becomeFirstResponder];
}

-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    [[ShackHandler sharedInstance] shackerHandle];
}


- (void) tappedRightButton:(id)sender
{
    self.selectedIndex ++;
    NSUInteger selectedIndex = self.selectedIndex;

    NSArray *aryViewController = self.tabBarController.viewControllers;

    if (selectedIndex < aryViewController.count - 1) {

        UIView *fromView = [self.tabBarController.selectedViewController view];
        UIView *toView = [[self.tabBarController.viewControllers objectAtIndex:selectedIndex + 1] view];

        [UIView transitionFromView:fromView toView:toView duration:0.2 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
             [self.tabBarController setSelectedIndex:selectedIndex + 1];
        }];
    }
}

- (void) tappedLeftButton:(id)sender
{
    self.selectedIndex --;
    NSUInteger selectedIndex = self.selectedIndex;
    
    if (selectedIndex > 0) {
        UIView *fromView = [self.tabBarController.selectedViewController view];

        UIView *toView = [[self.tabBarController.viewControllers objectAtIndex:selectedIndex - 1] view];

        [UIView transitionFromView:fromView toView:toView duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            if (finished) {
                [self.tabBarController setSelectedIndex:selectedIndex - 1];
            }
        }];
    }
}

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC{
    NSArray *viewControllers = tabBarController.viewControllers;
    if ([viewControllers indexOfObject:toVC] > [viewControllers indexOfObject:fromVC]) {
        return [[TransitionAnimation alloc] initWithTargetEdge:UIRectEdgeLeft];
    }
    else {
        return [[TransitionAnimation alloc] initWithTargetEdge:UIRectEdgeRight];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)begeinTouch{
    if(_swipeLeft){
        _swipeLeft.enabled = NO;
    }
    if(_swipeRight){
        _swipeRight.enabled = NO;
    }
}

-(void)endTouch{
    if(_swipeLeft){
        _swipeLeft.enabled = YES;
    }
    if(_swipeRight){
        _swipeRight.enabled = YES;
    }
}

-(void)noteShowOtaAlert:(NSNotification*)note{
    JL_RunSDK *bleSDK = [JL_RunSDK sharedMe];
    JL_EntityM *entity = note.object;
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:kJL_TXT("tips_0") message:nil
                                                                  preferredStyle:UIAlertControllerStyleAlert];
 
    UIAlertAction *btnCancel = [UIAlertAction actionWithTitle:kJL_TXT("断开设备") style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"---> OTA取消，断开连接:%@",entity.mItem);
        [bleSDK.mBleMultiple disconnectEntity:entity Result:^(JL_EntityM_Status status) {
            if (status == JL_EntityM_StatusDisconnectOk) {
                [JL_Tools post:kUI_JL_BLE_SCAN_OPEN Object:nil];
                NSLog(@"点击了取消");
            }
        }];
    }];
    UIAlertAction *btnConfirm = [UIAlertAction actionWithTitle:kJL_TXT("立即升级") style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
        UpgradeVC *vc = [[UpgradeVC alloc] init];
        vc.otaEntity  = entity;
        vc.rootNumber = 1;
        vc.modalPresentationStyle = 0;
        [self presentViewController:vc animated:YES completion:nil];
    }];
    [btnCancel setValue:kDF_RGBA(152, 152, 152, 1.0) forKey:@"_titleTextColor"];
    [actionSheet addAction:btnCancel];
    [actionSheet addAction:btnConfirm];
    [self presentViewController:actionSheet animated:YES completion:nil];
}



-(void)addNote{
    [JL_Tools add:@"MUSIC_PROGRESS_START" Action:@selector(begeinTouch) Own:self];
    [JL_Tools add:@"MUSIC_PROGRESS_END" Action:@selector((endTouch)) Own:self];
    [JL_Tools add:kUI_JL_EFCIRCULAR_BEGIN_TOUCH Action:@selector(begeinTouch) Own:self];
    [JL_Tools add:kUI_JL_EFCIRCULAR_END_TOUCH Action:@selector(endTouch) Own:self];
    [JL_Tools add:kUI_JL_DEVICE_SHOW_OTA  Action:@selector(noteShowOtaAlert:) Own:self];
    //添加摇一摇的功能
    [JL_Tools add:@"SHACK_RESET_NOTE" Action:@selector(addShacker) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

- (void)languageChange {
    NSArray *arr_txt = @[kJL_TXT("tab_multimedia"),kJL_TXT("tab_eq"),kJL_TXT("tab_device")];
    NSArray *arr_img = @[@"Theme.bundle/tab_icon_mul_nor",@"Theme.bundle/tab_icon_eq_nor",@"Theme.bundle/tab_icon_product_nor"];
    NSArray *arr_img_sel = @[@"Theme.bundle/tab_icon_mul_sel",@"Theme.bundle/tab_icon_eq_sel",@"Theme.bundle/tab_icon_product_sel"];
    for (int i = 0 ; i < arr_vc.count; i++) {
        UIViewController *uiviewController = arr_vc[i];
        /*--- TabBarItem的名字 ---*/
        uiviewController.tabBarItem.title = arr_txt[i];
        
        /*--- 使用原图片作为底部的TabBarItem ---*/
        NSString *str_img  = arr_img[i];
        NSString *str_img_sel = arr_img_sel[i];
        if (str_img.length == 0) str_img = @"nil";
        if (str_img_sel.length == 0) str_img_sel = @"nil";

        
        UIImage *image     = [UIImage imageNamed:str_img];
        UIImage *image_sel = [UIImage imageNamed:str_img_sel];
        uiviewController.tabBarItem.image         = [self imageAlwaysOriginal:image];
        uiviewController.tabBarItem.tag = i;
        uiviewController.tabBarItem.selectedImage = [self imageAlwaysOriginal:image_sel];
    }
    
}
@end
