//
//  HomeModel.m
//  MimiImg
//
//  Created by gongwenkai on 2018/2/26.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "HomeModel.h"

@implementation HomeModel
+ (NSDictionary *)mts_mapping {
    return @{
             @"image.display_url":mts_key(url),
             @"image.date":mts_key(date),
             @"image.size_formatted":mts_key(size),
             @"image.thumb.url":mts_key(thumbUrl),
             @"image.md5":mts_key(md5),
             };
}
@end



