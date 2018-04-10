//
//  UITextField+SCLeftPadding.m
//  SeasonChoice_iOS
//
//  Created by gongwenkai on 2017/12/4.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "UITextField+SCLeftPadding.h"

@implementation UITextField (SCLeftPadding)




- (void)showLeftPadding {
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
}

@end
