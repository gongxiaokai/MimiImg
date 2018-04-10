//
//  SCBaseViewController.m
//  Space_iOS
//
//  Created by gongwenkai on 2017/12/18.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "GBaseViewController.h"
#import "WRNavigationBar.h"

@interface GBaseViewController ()

@end

@implementation GBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNavBar];
    

}

- (void)setupNavBar
{
    [self.view addSubview:self.customNavBar];
    
    // 设置自定义导航栏背景图片
    self.customNavBar.barBackgroundImage = [UIImage imageNamed:@"navbar"];
    
    // 设置自定义导航栏标题颜色
    self.customNavBar.titleLabelColor = [UIColor whiteColor];
    [self.customNavBar wr_setBottomLineHidden:YES];

    if (self.navigationController.childViewControllers.count != 1) {
        [self.customNavBar wr_setLeftButtonWithImage:[UIImage imageNamed:@"nav_back"]];
    @weakify(self);
    self.customNavBar.onClickLeftButton = ^{
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
    }
}

- (WRCustomNavigationBar *)customNavBar
{
    if (_customNavBar == nil) {
        _customNavBar = [WRCustomNavigationBar CustomNavigationBar];
    }
    return _customNavBar;
}

@end
