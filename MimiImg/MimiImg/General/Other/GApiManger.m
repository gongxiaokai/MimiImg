//
//  GApiManger.m
//  XMHelper
//
//  Created by gongwenkai on 2018/2/5.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//
#import "GBaseModel.h"
#import "GApiManger.h"
#import <AFNetworking/AFNetworking.h>
#import <YYModel/YYModel.h>

#define SCHost              @"http://imgurl.xyz/api"
#define HostURL             SCHost @""
#define APIKEY              @"此处为API KEY"

@implementation GHTTPReq

@end

@implementation GApiManger

+ (GHTTPReq*)getAPIString:(GApiType)apiType withParam:(NSDictionary*)param{
    GHTTPReq *req = [GHTTPReq new];
    switch (apiType) {
        case GApiTypeUpload:{
            req.api = @"/1/upload";
            req.method = @"POST";
        }
            break;
        default:
            break;
    }
    return req;
}

/**
 请求入口
 
 @param apiType     接口类型
 @param param       请求参数
 @return            信号，订阅时才会发送
 */
+ (RACSignal*)sendApi:(GApiType)apiType withParam:(NSDictionary*)param {
    @weakify(self);
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self);
        
//        if ([param[@"uploadfile"] isKindOfClass:NSMutableArray.class]) {
            [self uploadImagApi:apiType param:param send:subscriber];
//        }else {
//            [self normalPostApi:apiType param:param send:subscriber];
//        }
        
        return nil;
    }];
    
    
}



/**
 普通post请求
 
 @param apiType     接口类型
 @param param       请求参数
 @param subscriber  信号处理
 */
+ (void)normalPostApi:(GApiType)apiType param:(NSDictionary*)param send:(id<RACSubscriber>)subscriber {
    NSLog(@"CBApiManager sendApi: %lu", (unsigned long)apiType);
    GHTTPReq *req = [self getAPIString:apiType withParam:param];
    NSString *urlStr = [HostURL stringByAppendingString:req.api];
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *encodUrlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:set];
    NSURL *apiUrl = [NSURL URLWithString:encodUrlStr] ;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:apiUrl];
    request.HTTPMethod = req.method;
    
    NSMutableData* bodyData = NSMutableData.new;
    BOOL isFail = NO;

    if (! param) {
        param = NSDictionary.new;
    }

    NSLog(@"请求参数%@%@",apiUrl.absoluteString,param);
    
    if (param) {
        NSError* jsonError = nil;

        NSString *jsonStr = param.yy_modelToJSONString;
        if (jsonError) {
            [subscriber sendError:jsonError];
            isFail = YES;
        } else {
            [bodyData appendData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }

    if (!isFail) {
        AFJSONResponseSerializer* jsonSerializer = AFJSONResponseSerializer.new;

        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = jsonSerializer;

        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

        
        request.HTTPBody = bodyData.copy;
        
        
        [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error response111: %@", error);
                
                [subscriber sendError:error];
            } else if (! responseObject) {
                NSLog(@"Empty response222");
                [subscriber sendError:[NSError errorWithDomain:@"服务不稳定" code:100 userInfo:nil]];
            }
        }] resume];
    }
}



/**
 上传图片
 
 @param functionType    图片类型
 @param param           上传参数
 @param subscriber      信号处理
 */
+ (void)uploadImagApi:(GApiType)functionType param:(NSDictionary*)param send:(id<RACSubscriber>)subscriber  {
    GHTTPReq *req = [self getAPIString:functionType withParam:param];
    NSDictionary *p = @{
                        @"action":@"upload",
                        @"key":APIKEY,
                        };
    
    NSString *apiUrl = [HostURL stringByAppendingString:req.api] ;
    //定义一个动态URL请求  使用[AFHTTPRequestSerializer serializer]中的方法
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:req.method URLString:apiUrl parameters:p constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        //设置fromData
        //设置类型
//        [formData appendPartWithFormData:[@"a7bb2b091e3f2961e59551a8cf6e05b2" dataUsingEncoding:NSUTF8StringEncoding] name:@"key"];
        [formData appendPartWithFormData:[@"upload" dataUsingEncoding:NSUTF8StringEncoding] name:@"action"];
        [param[@"uploadfile"] enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
            NSData  *imageData = UIImageJPEGRepresentation(image, 0.9);
            [formData appendPartWithFileData:imageData name:@"source" fileName:@"image" mimeType:@"image/png"];
        }];
    } error:nil];
    
    //    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    AFJSONResponseSerializer* jsonSerializer = AFJSONResponseSerializer.new;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = jsonSerializer;
    //        manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"text/html", nil];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html", nil];
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //使用经过封装的  request 请求 并开启上传任务
    [[manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //失败 成功进入 block回调
        if (error) {
            NSLog(@"Error response: %@", error);
            
            [subscriber sendError:error];
        } else {
            //基本数据模型设置
            GBaseModel* dataModel = GBaseModel.new;
            [dataModel mts_setValuesForKeysWithDictionary:responseObject];
            if ([dataModel.statusCode isEqualToString:@"200"]) {
                NSLog(@"Success: %@ %@", response, responseObject);
                [subscriber sendNext:responseObject];
            } else {
                NSLog(@"Error api, code: %@", dataModel.statusCode);
                [subscriber sendError:[NSError errorWithDomain:@"错误" code:99  userInfo:nil]];
            }
        }
    }] resume];
    
}
@end
