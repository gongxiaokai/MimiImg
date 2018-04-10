//
//  HomeModel.h
//  MimiImg
//
//  Created by gongwenkai on 2018/2/26.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "GBaseModel.h"

@interface HomeModel : GBaseModel
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *thumbUrl;
@property (nonatomic, copy) NSString *md5;
@end

