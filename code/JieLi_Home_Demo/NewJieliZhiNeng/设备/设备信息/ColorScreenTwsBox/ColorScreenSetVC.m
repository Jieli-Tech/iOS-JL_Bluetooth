//
//  ColorScreenSetVC.m
//  NewJieliZhiNeng
//
//  Created by EzioChan on 2023/12/5.
//  Copyright © 2023 杰理科技. All rights reserved.
//

#import "ColorScreenSetVC.h"
#import "CutImageView/HQImageEditViewController.h"
#import "ImageTools.h"
#import "JLWeatherSync.h"

@interface ColorScreenSetVC ()<UIImagePickerControllerDelegate,HQImageEditViewControllerDelegate,UINavigationControllerDelegate>{
    UIScrollView *scrollV;
    UIView  *contentView;
    ScreenLightSetView *lightSetView;
    ScreenProtectSetView *protectSetView;
    ScreenBgPaperView *bgPaperView;
    ScreenAnimationView *animationView;
    ShowSelectAlbumView *albumView;
    UIImagePickerController *imagePickerController;
    PublicSettingViewModel *publicSetting;
}

@end

@implementation ColorScreenSetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.naviView.titleLab.text = kJL_TXT("Charging Case Setting");
    
    scrollV = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:scrollV];
    
    [scrollV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.naviView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    contentView = [UIView new];
    contentView.backgroundColor = [UIColor clearColor];
    [scrollV addSubview:contentView];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollV);
        make.width.equalTo(scrollV);
    }];
    
    
    lightSetView = [[ScreenLightSetView alloc] initWithFrame:CGRectZero];
    lightSetView.publicSetting = publicSetting;
    [lightSetView addHandle];
    [contentView addSubview:lightSetView];
    
    [lightSetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView).inset(8);
        make.top.equalTo(contentView).offset(10);
        make.height.equalTo(@106);
    }];
    
    protectSetView = [[ScreenProtectSetView alloc] init];
    protectSetView.publicSetting = publicSetting;
    protectSetView.contextView = self;
    [contentView addSubview:protectSetView];
    
    [protectSetView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(contentView).inset(8);
        make.top.equalTo(lightSetView.mas_bottom).offset(10);
        make.height.equalTo(@252);
    }];
 
    __weak typeof(self)weakSelf = self;
    
    if ([publicSetting wallPaperMode]) {
        bgPaperView = [[ScreenBgPaperView alloc] initWithFrame:CGRectZero];
        bgPaperView.publicSetting = publicSetting;
        bgPaperView.viewController = self;
        [contentView addSubview:bgPaperView];
        
        [bgPaperView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(contentView).inset(8);
            make.top.equalTo(protectSetView.mas_bottom).offset(10);
            make.height.equalTo(@252);
        }];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(bgPaperView.mas_bottom).offset(10);
        }];
    }else {
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(protectSetView.mas_bottom).offset(10);
        }];
    }
    
    
    if ([publicSetting sdkInfo].projectId == 0x01 &&
        [publicSetting sdkInfo].projectId == 0x01 &&
        [publicSetting sdkInfo].chipId == 0x01) {
        
        animationView = [[ScreenAnimationView alloc] init];
        [contentView addSubview:animationView];
        [animationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(contentView).inset(8);
            make.top.equalTo(protectSetView.mas_bottom).offset(10);
            make.height.equalTo(@158);
        }];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(animationView.mas_bottom).offset(10);
        }];
    }
    
  
    
    
    albumView = [[ShowSelectAlbumView alloc] init];
    UIWindow *windows = [[UIApplication sharedApplication] windows].firstObject;
    [windows addSubview:albumView];
    [albumView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(windows);
    }];
    albumView.hidden = YES;
    
    albumView.selectBlock = ^(NSInteger index) {
        __strong typeof(self)strongSelf = weakSelf;
        strongSelf->albumView.hidden = true;
        if (index == 0) {
            [strongSelf makePickerImage:UIImagePickerControllerSourceTypeCamera];
        } else if (index == 1) {
            [strongSelf makePickerImage:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
        }
    };
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([SettingDefault getWeatherPush]) {
        [[JLWeatherSync share] startSyncWeather];
    }
    
    JL_ManagerM *cmdMgr = [[JL_RunSDK sharedMe] mBleEntityM].mCmdManager;
    [DialManager openDialFileSystemWithCmdManager:cmdMgr withResult:^(DialOperateType type, float progress) {
    }];
    [protectSetView updateByModel:[publicSetting screenSaverMode]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [publicSetting getScreenLight];
}

-(void)showAlbumView {
    albumView.hidden = false;
}



-(void)initDataAction:(void(^)(BOOL status))block {
    publicSetting = [[PublicSettingViewModel alloc] init];
    publicSetting.isFinish = block;
}





#pragma mark - - - UIImagePickerControllerDelegate

-(void)makePickerImage:(UIImagePickerControllerSourceType)type{
    imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.sourceType = type;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
    imagePickerController.delegate = self;
    imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    [picker dismissViewControllerAnimated:NO completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        JLDialInfoExtentedModel *md = [[JL_RunSDK sharedMe] dialInfoExtentedModel];
        CGSize imageSize = CGSizeMake(320, 172);
        if([md size].width != 0){
            imageSize = [md size];
        }
        HQImageEditViewController *vc = [[HQImageEditViewController alloc] init];
        vc.originImage = image;
        vc.delegate = self;
        vc.maskViewAnimation = YES;
        vc.editViewSize = CGSizeMake(imageSize.width, imageSize.height);
        vc.model = [[JL_RunSDK sharedMe] dialInfoExtentedModel];
        [self.navigationController pushViewController:vc animated:true];
    }];
}

//MARK: - handle crop Image
- (void)editController:(HQImageEditViewController *)vc finishiEditShotImage:(UIImage *)image originSizeImage:(UIImage *)originSizeImage {
    ProtectPreviewVC *vc1 = [[ProtectPreviewVC alloc] init];
    UIImage *targetImg = [ImageTools machRadius:image];
    vc1.showImage = targetImg;
    vc1.fileName = @"VIE_CST";
    vc1.publicSettingVM = publicSetting;
    [self.navigationController pushViewController:vc1 animated:YES];
}

- (void)editControllerDidClickCancel:(HQImageEditViewController *)vc {
    [vc.navigationController popViewControllerAnimated:YES];
}


@end
