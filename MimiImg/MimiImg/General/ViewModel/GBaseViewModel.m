//
//  SCBaseViewModel.m
//  SeasonChoice_iOS
//
//  Created by gongwenkai on 2017/11/17.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "GBaseViewModel.h"



@implementation GBaseItem

- (instancetype)initWithLink:(GOptionType)link modelData:(id)itemData
{
    self = [super init];
    if (self) {
        self.link = link;
        self.itemData = itemData;
    }
    return self;
}
@end


@interface GBaseViewModelItem ()
@property (nonatomic, readwrite)  GCellType  cellType;
@property (nonatomic, strong, readwrite) id modelData;
@end
@implementation GBaseViewModelItem
- (instancetype)initWithType:(GCellType)cellType modelData:(id)modelData
{
    if (self = [super init]) {
        self.cellType = cellType;
        self.modelData = modelData;
    }
    return self;
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"SCBaseViewModelItem cellType :%ld modelData: %@ ",(long)self.cellType,self.modelData];
}

@end

@interface GBaseViewModelSection ()
@property (nonatomic, strong, readwrite) NSMutableArray<GBaseViewModelItem *>* arrayItems;

@end
@implementation GBaseViewModelSection
- (instancetype)init
{
    if (self = [super init]) {
        self.arrayItems = NSMutableArray.new;
    }
    return self;
}
@end
@interface GBaseViewModel ()
@property (nonatomic, strong, readwrite) RACSubject *dataSignal;
@property (nonatomic, strong, readwrite) RACSubject *errorSignal;
@property (nonatomic, strong, readwrite) RACSubject *successSignal;

@end

@implementation GBaseViewModel

- (RACSubject *)successSignal {
    if (!_successSignal) {
        _successSignal = [RACSubject subject];
    }
    return _successSignal;
}

- (RACSubject *)dataSignal {
    if (!_dataSignal) {
        _dataSignal = [RACSubject subject];
    }
    return _dataSignal;
}

- (RACSubject *)errorSignal {
    if (!_errorSignal) {
        _errorSignal = [RACSubject subject];
    }
    return _errorSignal;
}

- (void)cancelData {}

-(void)processListData:(NSDictionary *)dataModel {}
@end
