//
//  SCBaseModel.h
//  SeasonChoice_iOS
//
//  Created by gongwenkai on 2017/11/17.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Motis/Motis.h>



@interface GBaseModel : NSObject<NSCoding>
//{
//    "code": "0",
//    "data": "6348408101632217088",
//    "message": "登录成功",
//    "success": true
//}

@property (nonatomic, copy)   NSString *statusCode;
//@property (nonatomic, copy)   NSString *message;
//@property (nonatomic, assign)   BOOL success;
//@property (nonatomic, strong)   NSDictionary *retBody;

- (NSData*)archiveToData;

+ (instancetype)unarchiveFromData:(NSData*)data;

- (BOOL)isEqual:(GBaseModel*)object;


@end
