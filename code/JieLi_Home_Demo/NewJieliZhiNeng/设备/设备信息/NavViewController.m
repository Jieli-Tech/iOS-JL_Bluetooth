//
//  NavViewController.m
//  DVRunning16
//
//  Created by EzioChan on 2017/7/20.
//  Copyright © 2017年 Zhuhia Jieli Technology. All rights reserved.
//

#import "NavViewController.h"

@interface NavViewController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>{

}

@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak NavViewController *weakSelf = self;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
    /*
    NSDictionary *titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    if (@available(iOS 15.0, *)) {
        UINavigationBarAppearance * app = [UINavigationBarAppearance new];
        [app configureWithDefaultBackground];
        app.titleTextAttributes = titleTextAttributes;
        app.backgroundImageContentMode = UIViewContentModeScaleToFill;
        app.backgroundColor = [UIColor whiteColor];
        UIBarButtonItemAppearance *btnApp = [UIBarButtonItemAppearance new];
        app.buttonAppearance = btnApp;
        self.navigationItem.scrollEdgeAppearance = app;
        self.navigationItem.standardAppearance = app;
    }
     */
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    if(@available(iOS 15.0, *)) {
        //设置导航颜色
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        //设置标题字体颜色
        [appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkTextColor], NSFontAttributeName:[UIFont fontWithName:@"PingFangSC-Medium" size:18]}];
        //去掉导航栏线条
        appearance.shadowColor= [UIColor clearColor];
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = self.navigationBar.standardAppearance;
    }
}




#pragma mark UINavigationControllerDelegate


-(UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    return [super popViewControllerAnimated:YES];
}

#pragma mark UINavigationControllerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.childViewControllers count] == 1) {
        return NO;
    }
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(BOOL)shouldAutorotate{
    
    
    return NO;
    
}




-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    return UIInterfaceOrientationMaskPortrait;
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
