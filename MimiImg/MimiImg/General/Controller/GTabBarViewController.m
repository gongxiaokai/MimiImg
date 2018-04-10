//
//  XMHTabBarViewController.m
//  XMHelper
//
//  Created by gongwenkai on 2018/2/5.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "GTabBarViewController.h"
#import <RDVTabBarItem.h>
#import "MMHomeViewController.h"
#import "MMAboutViewController.h"
#import "MMHistoryViewController.h"
@interface GTabBarViewController ()<RDVTabBarControllerDelegate>

@end

@implementation GTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupStyle];
    }
    return self;
}



- (void)setupStyle {
    
    self.delegate = self;
    self.viewControllers = @[
                             [[UINavigationController alloc] initWithRootViewController:[[MMHomeViewController alloc] init]],
                             [[UINavigationController alloc] initWithRootViewController:[[MMHistoryViewController alloc] init]],
                             [[UINavigationController alloc] initWithRootViewController:[[MMAboutViewController alloc] init]],
                             ];
    
    
    NSArray *itemsArray = @[@"上传",@"历史",@"关于"];
    NSArray *itemsImagesArray = @[@"upload",
                                  @"history",
                                  @"about"
                                  ];
    
    [self.tabBar.items enumerateObjectsUsingBlock:^(__kindof RDVTabBarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //        obj.badgeTextColor = HexColor(0xd4d4d4);
        obj.title = itemsArray[idx];
        [obj setUnselectedTitleAttributes:@{NSFontAttributeName:FontBoldHeiti(12),
                                            NSForegroundColorAttributeName:HexColor(0x999999),
                                            }];
        [obj setSelectedTitleAttributes:@{NSFontAttributeName:FontBoldHeiti(12),
                                          NSForegroundColorAttributeName:HexColor(0x25a4f8),}];
        NSString* stringIconNormal = [NSString stringWithFormat:@"%@_normal", itemsImagesArray[idx]];
        NSString* stringIconSelected = [NSString stringWithFormat:@"%@_selected", itemsImagesArray[idx]];
        if (CURRENTSCREEN_HEIGHT == 812.f) {
            obj.imagePositionAdjustment = UIOffsetMake(0, -IPHONEX_ADD/3);
        }
        [obj setFinishedSelectedImage:[UIImage imageNamed:stringIconSelected]
          withFinishedUnselectedImage:[UIImage imageNamed:stringIconNormal]];
    }];
    
    if (CURRENTSCREEN_HEIGHT == 812.f) {
        [self.tabBar setHeight:44+IPHONEX_ADD];
    }
    
}

//- (BOOL)tabBarController:(RDVTabBarController *)tabBarController shouldSelectViewController:(UINavigationController *)viewController
//{
//    SCLog(@"lololoololloo");
//    BOOL canSelected = YES;
//
//
//
//    if ([viewController.viewControllers.firstObject isKindOfClass:SCMineViewController.class] ||
//        [viewController.viewControllers.firstObject isKindOfClass:SCShoppingCarViewController.class]
//        ) {
//        if (TJLULoginCenterStateLogin != TJLULoginCenter.instance.loginState) {
//            NSUInteger indexOfVC = [self.viewControllers indexOfObject:viewController];
//            [TJLULoginCenter.instance loginWithBlock:^(BOOL loginSuccess) {
//                if (loginSuccess) {
//                    if (NSNotFound != indexOfVC) {
//                        // switch tab to NeighborVC
//                        //                        self.selectedIndex = indexOfVC;
//                    }
//                }
//            }];
//            canSelected = NO;
//        }
//    }
//    return canSelected;
//}

-(void)tabBar:(RDVTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index{
    
    [super tabBar:tabBar didSelectItemAtIndex:index];
}

@end
