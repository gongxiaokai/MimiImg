//
//  UIView+SCFrame.m
//  SeasonChoice_iOS
//
//  Created by gongwenkai on 2017/12/4.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "UIView+SCFrame.h"

@implementation UIView (SCFrame)

/** set 方法 */
- (void)setSc_width:(CGFloat)sc_width
{
    
    CGRect tmpFrame = self.frame;
    tmpFrame.size.width = sc_width;
    self.frame = tmpFrame;
    
}


- (void)setSc_height:(CGFloat)sc_height
{
    
    CGRect tmpFrame = self.frame;
    tmpFrame.size.height = sc_height;
    self.frame = tmpFrame;
    
}


- (void)setSc_x:(CGFloat)sc_x
{
    
    CGRect tmpFrame = self.frame;
    tmpFrame.origin.x = sc_x;
    self.frame = tmpFrame;
    
}

- (void)setSc_y:(CGFloat)sc_y
{
    
    CGRect tmpFrame = self.frame;
    tmpFrame.origin.y = sc_y;
    self.frame = tmpFrame;
    
}

- (void)setSc_size:(CGSize)sc_size
{
    
    CGRect tmpFrame = self.frame;
    tmpFrame.size = sc_size;
    self.frame = tmpFrame;
    
}

- (void)setSc_centerX:(CGFloat)sc_centerX
{
    CGPoint center = self.center;
    center.x = sc_centerX;
    self.center = center;
    
}


- (void)setSc_centerY:(CGFloat)sc_centerY
{
    CGPoint center = self.center;
    center.y = sc_centerY;
    self.center = center;
    
}

/** get 方法 */
- (CGFloat)sc_width
{
    
    return self.frame.size.width;
}

- (CGFloat)sc_height
{
    
    return self.frame.size.height;
}

- (CGFloat)sc_x
{
    
    return self.frame.origin.x;
}

- (CGFloat)sc_y
{
    
    return self.frame.origin.y;
}

- (CGSize)sc_size
{
    
    return self.frame.size;
}
- (CGFloat)sc_centerX
{
    
    return self.center.x;
}
- (CGFloat)sc_centerY
{
    
    return self.center.y;
}


@end
