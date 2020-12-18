//
//  AppAboutVC.m
//  NewJieliZhiNeng
//
//  Created by kaka on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "AppAboutVC.h"
#import "UserProfileVC.h"
#import "PrivacyPolicyVC.h"

@interface AppAboutVC ()<UITableViewDelegate,UITableViewDataSource>{
    UIImageView *topImv;
    __weak IBOutlet UIButton *backBtn;
    __weak IBOutlet UILabel *titleName;
    __weak IBOutlet UIView *subTitleView;
    
    UIView *currentVerUIView; //当前版本View
    UITableView *aboutTableView; //列表TableView
    NSMutableArray *itemArray;
    __weak IBOutlet NSLayoutConstraint *headHeight;
}

@end

@implementation AppAboutVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNote];
    [self initUI];
}

-(void)initUI{
    
    self.view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
    
    float sw = [DFUITools screen_2_W];
    subTitleView.frame = CGRectMake(0, 0, sw, kJL_HeightStatusBar+44);
    backBtn.frame  = CGRectMake(4, kJL_HeightStatusBar, 44, 44);
    titleName.text = kJL_TXT("关于");
    titleName.bounds = CGRectMake(0, 0, 200, 20);
    titleName.center = CGPointMake(sw/2.0, kJL_HeightStatusBar+20);
    
    
    //名称
//    NSMutableAttributedString *titleNameStr = [[NSMutableAttributedString alloc] initWithString:kJL_TXT("关于") attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 18],NSForegroundColorAttributeName: [UIColor colorWithRed:36/255.0 green:36/255.0 blue:36/255.0 alpha:1.0]}];
//    titleName.attributedText = titleNameStr;
    
    //顶部图标
    topImv = [[UIImageView alloc] initWithFrame:CGRectMake([DFUITools screen_2_W]/2-118/2,180,118,118)];
    topImv.image = [UIImage imageNamed:@"Theme.bundle/logo_1"];
    topImv.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:topImv];
    
    aboutTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,topImv.frame.origin.y+topImv.frame.size.height+80,[DFUITools screen_2_W],55*3)];
    aboutTableView.delegate      = self;
    aboutTableView.dataSource    = self;
    aboutTableView.scrollEnabled = NO;
    aboutTableView.tag = 0 ;
    aboutTableView.rowHeight = 55;
    [aboutTableView setSeparatorColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
    [self.view addSubview:aboutTableView];
    
    NSArray *tmpArray = @[kJL_TXT("当前版本"),kJL_TXT("用户服务协议"),kJL_TXT("隐私政策")];
    
    [itemArray removeAllObjects];
    itemArray = nil;
    
    itemArray = [NSMutableArray arrayWithArray:tmpArray];
    [aboutTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return itemArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* IDCell = @"lcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDCell];
    }
//    if (@available(iOS 13.0, *)) {
//        UIColor *cellColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trainCollection) {
//            if ([trainCollection userInterfaceStyle] == UIUserInterfaceStyleLight) {
//                return [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
//            }
//            else {
//                return [UIColor colorWithRed:18/255.0 green:19/255.0 blue:36/255.0 alpha:1.0];;
//            }
//        }];
//        [cell.contentView setBackgroundColor:cellColor];
//    } else {
        // Fallback on earlier versions
        [cell.contentView setBackgroundColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0]];
//    }
    cell.textLabel.text = itemArray[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"PingFang SC" size: 14];
    cell.textLabel.textColor = kDF_RGBA(36, 36, 36, 1);
    
    if (@available(iOS 12.0, *)) {
        if(self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            cell.textLabel.alpha  = 0.7;
        }else{
            cell.textLabel.alpha  = 1.0;
        }
    } else {
        // Fallback on earlier versions
        cell.textLabel.alpha  = 1.0;
    }
    
    if(indexPath.row == 0){
        UILabel *currentVerCodeLabel = [[UILabel alloc] init];
        currentVerCodeLabel.frame = CGRectMake(self.view.frame.size.width-14.5-24.5,22.5,30,11);
        currentVerCodeLabel.numberOfLines = 0;
        [cell addSubview:currentVerCodeLabel];
        
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
        NSMutableAttributedString *currentVerCodeStr = [[NSMutableAttributedString alloc] initWithString:appVersion attributes:@{NSFontAttributeName: [UIFont fontWithName:@"PingFang SC" size: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:152/255.0 green:152/255.0 blue:152/255.0 alpha:1.0]}];
        
        currentVerCodeLabel.attributedText = currentVerCodeStr;
    }else{
        UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-32,22.5,24.5,11)];
        [nextBtn setImage:[UIImage imageNamed:@"Theme.bundle/icon_app_settings_next"] forState:UIControlStateNormal];
        [cell addSubview:nextBtn];
    }
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1){
        UserProfileVC *vc = [[UserProfileVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
    if(indexPath.row == 2){
        PrivacyPolicyVC *vc = [[PrivacyPolicyVC alloc] init];
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

#pragma mark 退出关于界面
- (IBAction)backExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLUuidType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}
     
-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}

@end
