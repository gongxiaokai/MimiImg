
//
//  XMHBaseCell.m
//  XMHelper
//
//  Created by gongwenkai on 2018/2/5.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "GBaseCell.h"

@implementation GBaseCell



- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = HexColor(0xffffff);
        [self setupStyle];
    }
    return self;
}
- (void)setupStyle {

}

+ (NSString *)cellReuseIdentifier {
    return NSStringFromClass(self.class);
}
@end
