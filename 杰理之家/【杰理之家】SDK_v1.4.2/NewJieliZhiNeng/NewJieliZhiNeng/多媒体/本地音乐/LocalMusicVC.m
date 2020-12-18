//
//  LocalMusicVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2020/5/15.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "LocalMusicVC.h"
#import "MindListView.h"


@interface LocalMusicVC (){    
    __weak IBOutlet UILabel *titleName;
    MindListView *mindListView;
    __weak IBOutlet NSLayoutConstraint *headHeight;
}

@end

@implementation LocalMusicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self addNote];
}

-(void)initUI{
    headHeight.constant = kJL_HeightNavBar+10;
    //名称
    titleName.text = kJL_TXT("本地");
    mindListView = [[MindListView alloc] initWithFrame:CGRectMake(0, headHeight.constant+10, [DFUITools screen_2_W],  [DFUITools screen_2_H]-headHeight.constant-10)];
//    mindListView.layer.shadowOffset = CGSizeMake(0,1);
//    mindListView.layer.shadowOpacity = 1;
//    mindListView.layer.shadowRadius = 8;
//    mindListView.layer.cornerRadius = 13;
    [self.view addSubview:mindListView];
}

- (IBAction)backExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType type = [note.object intValue];
    if (type == JLDeviceChangeTypeInUseOffline ||
        type == JLDeviceChangeTypeSomethingConnected ||
        type == JLDeviceChangeTypeBleOFF) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [mindListView scrollToNowMusic];
}

-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}
-(void)dealloc{
    [JL_Tools remove:nil Own:self];
}
@end
