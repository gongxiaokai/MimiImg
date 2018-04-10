//
//  MMHistoryViewModel.m
//  MimiImg
//
//  Created by gongwenkai on 2018/2/26.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "MMHistoryViewModel.h"

@interface MMHistoryViewModel()
@property (nonatomic, strong, readwrite) RACCommand *getMainData;
@property (nonatomic, strong, readwrite) RACCommand *deleteCommand;

@end

@implementation MMHistoryViewModel

- (RACCommand *)getMainData {
    if (!_getMainData) {
        @weakify(self);
        _getMainData = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {

                [subscriber sendNext:nil];
                [subscriber sendCompleted];
                return nil;
            }] doNext:^(NSDictionary *json) {
                @strongify(self);
                [self processListData:json];
                
            }] takeUntil:[self rac_signalForSelector:@selector(cancelData)]] ;
        }];
    }
    return _getMainData;
}

- (void)processListData:(NSDictionary *)dataModel {
    //从iCloud中获取数据
    NSUbiquitousKeyValueStore *myKeyValue = [NSUbiquitousKeyValueStore defaultStore];
    NSArray *iCloudData = [myKeyValue objectForKey:@"iCloudData"];
    
    if (!iCloudData) {
        [self.errorSignal sendNext:[NSError errorWithDomain:@"未有上传历史" code:999 userInfo:nil]];
    }else {
        NSMutableArray *res = iCloudData.mutableCopy;
        iCloudData = [[res reverseObjectEnumerator] allObjects];
        
        NSMutableArray *sendArray = @[].mutableCopy;
        GBaseViewModelSection *section = [GBaseViewModelSection new];
        [iCloudData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GBaseViewModelItem *item = [[GBaseViewModelItem alloc] initWithType:GCellTypeHistory modelData:obj];
            [section.arrayItems addObject:item];
        }];
        [sendArray addObject:section];
        [self.dataSignal sendNext:sendArray];
    }
    

}

- (RACCommand *)deleteCommand {
    if (!_deleteCommand) {
        @weakify(self);
        _deleteCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:input];
                [subscriber sendCompleted];
                return nil;
            }]doNext:^(id x) {
                @strongify(self);
                [self deleteData:x];
            }] ;
        }];
    }
    return _deleteCommand;
}

- (void)deleteData:(NSDictionary*)data {
    //从iCloud中获取数据
    NSUbiquitousKeyValueStore *myKeyValue = [NSUbiquitousKeyValueStore defaultStore];
    NSArray *iCloudData = [myKeyValue objectForKey:@"iCloudData"];
    NSMutableArray *res = iCloudData.mutableCopy;
    [res removeObject:data];
    iCloudData = res;
    [myKeyValue setObject:iCloudData forKey:@"iCloudData"];

    res = [[res reverseObjectEnumerator] allObjects].mutableCopy;
    iCloudData = res;

    
    NSMutableArray *sendArray = @[].mutableCopy;
    GBaseViewModelSection *section = [GBaseViewModelSection new];
    [iCloudData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GBaseViewModelItem *item = [[GBaseViewModelItem alloc] initWithType:GCellTypeHistory modelData:obj];
        [section.arrayItems addObject:item];
    }];
    [sendArray addObject:section];
    [self.dataSignal sendNext:sendArray];
}
@end
