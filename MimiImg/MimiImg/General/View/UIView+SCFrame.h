//
//  UIView+SCFrame.h
//  SeasonChoice_iOS
//
//  Created by gongwenkai on 2017/12/4.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SCFrame)
/* 自定义宽度 */
@property (assign ,nonatomic) CGFloat sc_width;
/* 自定义高度 */
@property (assign ,nonatomic) CGFloat sc_height;
/* 自定义x */
@property (assign ,nonatomic) CGFloat sc_x;
/* 自定义y */
@property (assign ,nonatomic) CGFloat sc_y;
/* 自定义size */
@property (assign ,nonatomic) CGSize sc_size;
/* 自定义centerX */
@property (assign ,nonatomic) CGFloat sc_centerX;
/* 自定义centerY */
@property (assign ,nonatomic) CGFloat sc_centerY;
@end
