//
//  XMHBaseCell.h
//  XMHelper
//
//  Created by gongwenkai on 2018/2/5.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GBaseCell : UICollectionViewCell<GCellSetModelProtocol>
@property (copy, nonatomic) void (^actionBlockWithDataModel)(id dataModel);

+ (NSString *)cellReuseIdentifier;

- (void)setupStyle ;
@end
