//
//  GApiManger.h
//  XMHelper
//
//  Created by gongwenkai on 2018/2/5.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHTTPReq : NSObject

@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *api;
@end

typedef enum : NSUInteger {
    GApiTypeUpload                        = 1,        //登录
} GApiType;


@interface GApiManger : NSObject

/**
 请求入口
 
 @param apiType     接口类型
 @param param       请求参数
 @return            信号，订阅时才会发送结果
 */
+ (RACSignal*)sendApi:(GApiType)apiType withParam:(NSDictionary*)param;


@end
