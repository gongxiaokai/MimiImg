//
//  SCBaseViewModel.h
//  SeasonChoice_iOS
//
//  Created by gongwenkai on 2017/11/17.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Motis/Motis.h>
#import "GApiManger.h"

typedef enum : NSUInteger {

    GCellTypeHistory,                     //历史



} GCellType;

typedef enum : NSUInteger {
    XMHomeOptionTypeBanner          = 1,     //报修-类型选择

} GOptionType;


//基础跳转  所有点击封装

@interface GBaseItem : NSObject
@property (nonatomic, assign) GOptionType link;
@property (nonatomic, strong) id itemData;
//照片选择
@property (nonatomic, assign) NSInteger index;

- (instancetype)initWithLink:(GOptionType)link modelData:(id)itemData;

@end


//item
@interface GBaseViewModelItem : NSObject
@property (nonatomic, readonly) GCellType cellType;
@property (nonatomic, strong, readonly) id modelData;
- (instancetype)initWithType:(GCellType)cellType modelData:(id)modelData;
@end


//section
@interface GBaseViewModelSection : NSObject
@property (nonatomic, strong, readonly) NSMutableArray<GBaseViewModelItem *>* arrayItems;
@end



@interface GBaseViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *sendArray;

@property (nonatomic, strong, readonly) RACSubject *dataSignal;

@property (nonatomic, strong, readonly) RACSubject *errorSignal;
@property (nonatomic, strong, readonly) RACSubject *successSignal;


/**
 取消获取数据
 */
- (void)cancelData;


/**
 准备数据

 @param dataModel json
 */
-(void)processListData:(NSDictionary *)dataModel;
@end
