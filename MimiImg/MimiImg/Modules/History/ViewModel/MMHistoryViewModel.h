//
//  MMHistoryViewModel.h
//  MimiImg
//
//  Created by gongwenkai on 2018/2/26.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "GBaseViewModel.h"

@interface MMHistoryViewModel : GBaseViewModel
@property (nonatomic, strong, readonly) RACCommand *getMainData;
@property (nonatomic, strong, readonly) RACCommand *deleteCommand;

@end
