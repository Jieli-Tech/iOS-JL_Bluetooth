//
//  SceneDelegate.h
//  NewJieliZhiNeng
//
//  Created by Ezio Chan on 2025/11/27.
//
//  Copyright © 2025 杰理科技. All rights reserved.
//
//  场景委托类，负责 iOS 13+ 的窗口与根控制器生命周期管理，
//  兼容现有 AppDelegate 的 UI 初始化逻辑，在多场景架构下保持一致行为。

#import <UIKit/UIKit.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;

@end

