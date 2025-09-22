//
//  FlashDeviceVC.m
//  NewJieliZhiNeng
//
//  Created by 杰理科技 on 2020/8/6.
//  Copyright © 2020 杰理科技. All rights reserved.
//

#import "FlashDeviceVC.h"
#import "FlashDeviceCell.h"

@interface FlashDeviceVC ()<UITableViewDelegate,UITableViewDataSource>{
    
    __weak IBOutlet NSLayoutConstraint *topViewH;
    __weak IBOutlet NSLayoutConstraint *tableViewH;
    __weak IBOutlet UITableView *subTableView;
    
    __weak IBOutlet UILabel *subLabel;
    BOOL isEffect;
    
    NSArray *arrayScene;
    NSArray *arrayEffect;
    NSInteger   sceneIndex;
    NSInteger   effectIndex;
    
    JL_RunSDK   *bleSDK;
    NSString    *bleUUID;
    JL_DeviceType bleType;
}

@end

@implementation FlashDeviceVC

- (void)viewDidLoad {
    [super viewDidLoad];

    bleSDK = [JL_RunSDK sharedMe];
    bleUUID = bleSDK.mBleEntityM.mUUID;
    bleType = bleSDK.mBleEntityM.mType;
    
    [self setupUI];
    [self addNote];
}


-(void)setupUI{
    isEffect = NO;
    sceneIndex  = 0;
    effectIndex = -1;
    
    topViewH.constant = kJL_HeightNavBar;
    tableViewH.constant = kJL_HeightTabBar+100;
    
    subLabel.text = kJL_TXT("led_settings");
    
    subTableView.rowHeight = 55;
    subTableView.backgroundColor = [UIColor clearColor];
    subTableView.separatorColor = kDF_RGBA(238, 238, 238, 1.0);
    subTableView.tableFooterView = [UIView new];
    subTableView.dataSource = self;
    subTableView.delegate = self;
    
    arrayScene = self.jsonDict[@"led_settings"][@"scene"];
    arrayEffect= self.jsonDict[@"led_settings"][@"effect"];
    [subTableView reloadData];
}
- (IBAction)btn_back:(id)sender {
    if (isEffect == NO) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        isEffect = NO;
        subLabel.text = kJL_TXT("led_settings");
        [subTableView reloadData];
    }
}

/*
 "led_settings": {
 "scene": [
 {
 "value": 1,
 "title": {
 "zh": "未配对",
 "en": "unpaired"
 }
 },
 ],
 "effect": [
 {
 "value": 0,
 "title": {
 "zh": "全灭",
 "en": "All light off"
 }
 },
 */


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isEffect == NO) {
        return arrayScene.count;
    }else{
        return arrayEffect.count;
    }
}

//NSMutableArray *ledArr = [NSMutableArray new];
//for (int i = 0 ; i < data.length/2; i++) {
//    uint8_t ledScene = [JL_Tools dataToInt:[JL_Tools data:data R:i*2 L:1]];
//    uint8_t ledEffect = [JL_Tools dataToInt:[JL_Tools data:data R:i*2+1 L:1]];
//    NSDictionary *ledDict = @{@"LED_SCENE":@(ledScene),
//                              @"LED_EFFECT":@(ledEffect)};
//    [ledArr addObject:ledDict];
//}
//[mDict setObject:ledArr forKey:@"LED_SETTING"];

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FlashDeviceCell *cell = (FlashDeviceCell*)[tableView dequeueReusableCellWithIdentifier:[FlashDeviceCell ID]];
    if (cell == nil) {
        cell = [[FlashDeviceCell alloc] init];
    }
    if (isEffect == NO) {
        if (bleType != 1) { //音箱
            if(indexPath.row==3 || indexPath.row==5){
                subTableView.rowHeight = 65;
                UIView  *view = [[UIView alloc] init];
                view.frame = CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,10);
                view.backgroundColor = kDF_RGBA(248, 250, 252, 1.0);
                [cell addSubview:view];
            }else{
                subTableView.rowHeight = 55;
            }
        }
        NSDictionary *dict = arrayScene[indexPath.row];
        NSArray *settingArr = self.infoDict[@"LED_SETTING"];
        int scene =  [dict[@"value"] intValue];
        
        cell.sceneImage.hidden = NO;
        cell.sceneLabel_1.hidden = NO;
        cell.effectImage.hidden = YES;
        if([kJL_GET hasPrefix:@"zh"]){
            cell.sceneLabel_0.text = dict[@"title"][@"zh"];
        }else{
            cell.sceneLabel_0.text = dict[@"title"][@"en"];
        }
        
        for (NSDictionary * effectDict in settingArr) {
            int led_scene = [effectDict[@"LED_SCENE"] intValue];
            if (scene == led_scene) {
                int led_effect= [effectDict[@"LED_EFFECT"] intValue];
                
                for (NSDictionary *effectDict_1 in arrayEffect) {
                    int effectValue = [effectDict_1[@"value"] intValue];
                    
                    if (led_effect == effectValue) {
                        if([kJL_GET hasPrefix:@"zh"]){
                            cell.sceneLabel_1.text = effectDict_1[@"title"][@"zh"];
                        }else{
                            cell.sceneLabel_1.text = effectDict_1[@"title"][@"en"];
                        }
                        break;
                    }
                }
                break;
            }
        }
    }else{
        NSDictionary *dict = arrayEffect[indexPath.row];
        
        cell.sceneImage.hidden = YES;
        cell.sceneLabel_1.hidden = YES;
        cell.effectImage.hidden = NO;
        
        if([kJL_GET hasPrefix:@"zh"]){
            cell.sceneLabel_0.text = dict[@"title"][@"zh"];
        }else{
            cell.sceneLabel_0.text = dict[@"title"][@"en"];
        }
        int scene = [dict[@"value"] intValue];
        
        if (scene == effectIndex) {
            cell.effectImage.image = [UIImage imageNamed:@"Theme.bundle/icon_sel"];
        }else{
            cell.effectImage.image = [UIImage imageNamed:@"Theme.bundle/icon_nor"];
        }
        
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (isEffect == NO) {
        NSDictionary *dict = arrayScene[indexPath.row];
        NSArray *settingArr = self.infoDict[@"LED_SETTING"];
        sceneIndex = [dict[@"value"] intValue];
        if([kJL_GET hasPrefix:@"zh"]){
            subLabel.text = dict[@"title"][@"zh"];
        }else{
            subLabel.text = dict[@"title"][@"en"];
        }
        
        for (NSDictionary * effectDict in settingArr) {
            int led_scene = [effectDict[@"LED_SCENE"] intValue];
            if (sceneIndex == led_scene) {
                int led_effect= [effectDict[@"LED_EFFECT"] intValue];
                
                for (NSDictionary *effectDict_1 in arrayEffect) {
                    int effectValue = [effectDict_1[@"value"] intValue];
                    if (led_effect == effectValue) {
                        effectIndex = led_effect;
                        break;
                    }
                }
                break;
            }
        }
        isEffect = YES;
        [tableView reloadData];
    }else{
        NSDictionary *dict = arrayEffect[indexPath.row];
        effectIndex = [dict[@"value"] intValue];
        
        NSArray *settingArr = self.infoDict[@"LED_SETTING"];
        NSMutableArray *settingArrM = [NSMutableArray new];
        
        for (NSDictionary * effectDict in settingArr) {
            int led_scene = [effectDict[@"LED_SCENE"] intValue];
            if (led_scene == sceneIndex) {
                NSDictionary *ledDict = @{@"LED_SCENE":@(led_scene),@"LED_EFFECT":@(effectIndex)};
                [settingArrM addObject:ledDict];
            }else{
                NSDictionary *ledDict = [NSDictionary dictionaryWithDictionary:effectDict];
                [settingArrM addObject:ledDict];
            }
        }
        NSMutableDictionary *infoDictM = [NSMutableDictionary dictionaryWithDictionary:self.infoDict];
         [infoDictM setObject:settingArrM forKey:@"LED_SETTING"];
        self.infoDict = infoDictM;
        [tableView reloadData];
        
        [bleSDK.mBleEntityM.mCmdManager.mTwsManager cmdHeadsetLedSettingScene:(uint8_t)sceneIndex
                                                           Effect:(uint8_t)effectIndex];
    }
}

-(void)noteDeviceChange:(NSNotification*)note{
    JLDeviceChangeType tp = [note.object intValue];
    if (tp == JLDeviceChangeTypeInUseOffline) {
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}


-(void)addNote{
    [JL_Tools add:kUI_JL_DEVICE_CHANGE Action:@selector(noteDeviceChange:) Own:self];
}

-(void)viewWillDisappear:(BOOL)animated{
    [JL_Tools remove:nil Own:self];
}

@end
