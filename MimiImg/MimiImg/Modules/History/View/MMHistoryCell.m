//
//  MMHistoryCell.m
//  MimiImg
//
//  Created by gongwenkai on 2018/2/26.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "MMHistoryCell.h"
#import "MMHistoryViewModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface MMHistoryCell()
@property (nonatomic, weak) UIImageView *imageView;
@end
@implementation MMHistoryCell
- (void)setupStyle {
    UIImageView *imageView = [UIImageView new];
    [self.contentView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(imageView.superview.mas_height);
        make.height.equalTo(imageView.superview);
        make.centerX.equalTo(imageView.superview);
    }];
    self.imageView = imageView;
}

- (void)renderWithModel:(GBaseViewModelItem*)model {
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.modelData[@"thumbUrl"]] placeholderImage:[UIImage imageNamed:@"placehold"]];
}
@end
