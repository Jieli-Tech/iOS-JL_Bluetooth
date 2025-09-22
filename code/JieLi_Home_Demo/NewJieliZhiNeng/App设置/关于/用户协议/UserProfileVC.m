//
//  UserProfileVC.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/5/16.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "UserProfileVC.h"


//用户服务协议的URL
#define USER_PROFILE_URL  @"http://cam.jieliapp.com:28111/app/app.user.service.protocol.html"

@interface UserProfileVC ()<WKNavigationDelegate>{
    WKWebView *webView;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UIView *subTitleView;
    //空图片
    UIImageView *noneImv;
    //空文字1
    UILabel *noneLab_1; //网络异常/暂无数据
    //空文字2
    UILabel *noneLab_2; //请检查您的网络连接并稍后再试
}

@end

@implementation UserProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
    [self initUI];
}

-(void)initUI{
    
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    float sw = [UIScreen mainScreen].bounds.size.width;
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("user_agreement");
    titleName.bounds = CGRectMake(0, 0, 200, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    //名称
    //    titleName.numberOfLines = 0;
    //    NSMutableAttributedString *titleNameStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("user_agreement") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
    //    titleName.attributedText = titleNameStr;
    
    
    if([UIScreen mainScreen].bounds.size.height >= 812.0){
        //请求网络地址
        webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kJL_HeightStatusBar+44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-70)];
    }else{
        //请求网络地址
        webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kJL_HeightStatusBar+44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64)];
    }
    
    noneImv = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-230.0/2,[UIScreen mainScreen].bounds.size.height/2-186.5/2, 230.0, 186.5)];
    noneImv.contentMode = UIViewContentModeCenter;
    noneImv.image = [UIImage imageNamed:@"Theme.bundle/product_img_no_network"];
    [self.view addSubview:noneImv];
    noneImv.hidden = YES;
    
    //CGFloat w = self.view.frame.size.width;
    
    noneLab_1 = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-60.0, noneImv.frame.origin.y+noneImv.frame.size.height-30, 120.0, 25.0)];
    noneLab_1.textColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:1.0];
    noneLab_1.textAlignment = NSTextAlignmentCenter;
    noneLab_1.font = [UIFont systemFontOfSize:15];
    noneLab_1.text = kJL_TXT("网络异常");
    [self.view addSubview:noneLab_1];
    
    noneLab_2 = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-400/2, noneLab_1.frame.origin.y+noneLab_1.frame.size.height+10, 400, 25.0)];
    noneLab_2.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
    noneLab_2.textAlignment = NSTextAlignmentCenter;
    noneLab_2.font = [UIFont systemFontOfSize:15];
    noneLab_2.text = kJL_TXT("network_exception_tips");
    [self.view addSubview:noneLab_2];
    
    /*--- 网络监测 ---*/
    AFNetworkReachabilityManager *net = [AFNetworkReachabilityManager sharedManager];
    [self actionNetStatus:net.networkReachabilityStatus];
    
    [net setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [self actionNetStatus:status];
    }];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    webView.hidden = YES;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [JL_Tools delay:0.2 Task:^{
        webView.hidden = NO;
    }];
    
    [ webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '270%'" completionHandler:nil];
    
    [ webView evaluateJavaScript:@"var script = document.createElement('script');"
     
     "script.type = 'text/javascript';"
     
     "script.text = \"function ResizeImages() { "
     
     "var myimg,oldwidth;"
     
     "var maxwidth = 1000.0;"
     
     "for(i=1;i <document.images.length;i++){"
     
     "myimg = document.images[i];"
     
     "oldwidth = myimg.width;"
     
     "myimg.width = maxwidth;"
     
     "}"
     
     "}\";"
     
     "document.getElementsByTagName('head')[0].appendChild(script);ResizeImages();" completionHandler:nil];
}

- (IBAction)backExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 网络监测
-(void)actionNetStatus:(AFNetworkReachabilityStatus)status{
    if (status == AFNetworkReachabilityStatusNotReachable) {
        //kJLLog(JLLOG_DEBUG,@"---> AFNetworkReachabilityStatusNotReachable");
        if(webView) [webView removeFromSuperview];
        noneImv.hidden = NO;
        noneLab_1.hidden = NO;
        noneLab_2.hidden = NO;
    }
    if (status == AFNetworkReachabilityStatusUnknown) {
        //kJLLog(JLLOG_DEBUG,@"---> AFNetworkReachabilityStatusUnknown");
        if(webView) [webView removeFromSuperview];
        noneImv.hidden = NO;
        noneLab_1.hidden = NO;
        noneLab_2.hidden = NO;
    }
    if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        //kJLLog(JLLOG_DEBUG,@"---> AFNetworkReachabilityStatusReachableViaWWAN");
        if(self->webView)[self->webView removeFromSuperview];
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:USER_PROFILE_URL]];
        self->webView.scrollView.bounces=NO;
        if ([self->webView isKindOfClass:[WKWebView class]]) {
            ((WKWebView *) self->webView).allowsBackForwardNavigationGestures = NO;
        }
        [self.view addSubview: self->webView];
        [webView loadRequest:request];
        webView.navigationDelegate = self;
        webView.hidden = NO;
        
        noneImv.hidden = YES;
        noneLab_1.hidden = YES;
        noneLab_2.hidden = YES;
    }
    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        //kJLLog(JLLOG_DEBUG,@"---> AFNetworkReachabilityStatusReachableViaWiFi");
        if(self->webView)[self->webView removeFromSuperview];
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:USER_PROFILE_URL]];
        self->webView.scrollView.bounces=NO;
        if ([self->webView isKindOfClass:[WKWebView class]]) {
            ((WKWebView *) self->webView).allowsBackForwardNavigationGestures = NO;
        }
        [self.view addSubview: self->webView];
        [webView loadRequest:request];
        webView.navigationDelegate = self;
        webView.hidden = NO;
        
        noneImv.hidden = YES;
        noneLab_1.hidden = YES;
        noneLab_2.hidden = YES;
    }
}

-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (error.code==-999) {
        return;
    }
}


-(void)noteDeviceChange:(NSNotification*)note{
    JLUuidType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline) {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}
@end
