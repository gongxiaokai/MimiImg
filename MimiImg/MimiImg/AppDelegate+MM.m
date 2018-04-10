//
//  AppDelegate+MM.m
//  MimiImg
//
//  Created by gongwenkai on 2018/2/26.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "AppDelegate+MM.h"
#import "GBaseViewController.h"
#import "GTabBarViewController.h"
//#import "XMHNewFeatureViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

@implementation AppDelegate (MM)
//MARK: 配置delegate
- (void)configAppDelegate {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    IQKeyboardManager.sharedManager.enable = YES;
    IQKeyboardManager.sharedManager.enableAutoToolbar = YES;
    IQKeyboardManager.sharedManager.shouldResignOnTouchOutside = YES;
    
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    
    // 如果程序是第一次更新或下载,根控制器为新特征控制器,否则为主控制器.
    // 获取应用程序的版本号
    NSString *currentCersion = [NSBundle mainBundle].infoDictionary[(NSString *) kCFBundleVersionKey];
    NSLog(@"currentVersion:%@",currentCersion);
    //取出存储在沙盒的版本号
//    NSString *saveVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"saveVersion"];
//    if ([saveVersion isEqualToString:currentCersion]) {
        self.window.rootViewController = GTabBarViewController.new;
//    } else {
//        XMHNewFeatureViewController* guideVC = XMHNewFeatureViewController.new;
//        @weakify(self);
//        guideVC.completed = ^{
//            [[NSUserDefaults standardUserDefaults] setValue:currentCersion forKey:@"saveVersion"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            @strongify(self);
//            self.window.rootViewController = XMHNewFeatureViewController.new;
//        };
//        self.window.rootViewController = guideVC;
//    }
    
    [self.window makeKeyAndVisible];
    
    //配置导航栏
    [self configNav];
    
}

//MARK: 配置导航栏
- (void)configNav {
    //    //配置导航栏基础色
    //    UINavigationBar.appearance.barTintColor = HexColor(0xffffff);
    //    UINavigationBar.appearance.titleTextAttributes = @{
    //                                                       NSForegroundColorAttributeName : HexColor(0x727070),
    //                                                       NSFontAttributeName            : FontBoldHeiti(17),
    //                                                       };
    //    UINavigationBar.appearance.tintColor = HexColor(0x727070);
    
    
    //自定义back
    //    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    //    barButton.title = @"返回"; // blank or any other title
    //    UINavigationBar.appearance.topItem.backBarButtonItem.title = @" ";
    
    
    //    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:nil action:nil];
    //    barButton.title = @"";
    //    UINavigationBar.appearance.topItem.backBarButtonItem = barButton;
    
}

@end
