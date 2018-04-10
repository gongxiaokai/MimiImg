//
//  HistoryViewController.m
//  MimiImg
//
//  Created by gongwenkai on 2018/2/26.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "MMHistoryViewController.h"
#import "MMHistoryCell.h"
#import "MMHistoryViewModel.h"
#import "HomeModel.h"
#import <YYModel/YYModel.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <MJRefresh/MJRefresh.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <KLCPopup/KLCPopup.h>
@interface MMHistoryViewController ()
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<GBaseViewModelSection*> *listSection;
@property (nonatomic, strong) MMHistoryViewModel *viewModel;
@property (nonatomic, strong)  KLCPopup *pop;
@property (nonatomic, weak)  UIView *successView;
@property (nonatomic, weak)  UIView *backgroundView;
@property (nonatomic, weak) UIButton *shareBtn;
@end

@implementation MMHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customNavBar.title = @"上传历史";
    [self setupStyle];
    [self bindData];
    
    
}

- (void)setupStyle {
    //    self.view.backgroundColor = [UIColor greenColor];
    
    UICollectionView* collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    collectionView.backgroundColor = HexColor(0xffffff);
    [self.view addSubview:collectionView];
    collectionView.alwaysBounceVertical = YES;
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.mas_bottomLayoutGuide);
        make.top.equalTo(self.customNavBar.mas_bottom);
    }];
    
    //MARK: 注册cell
    [collectionView registerClass:[MMHistoryCell class] forCellWithReuseIdentifier:[MMHistoryCell cellReuseIdentifier]];
    
    
    // block style toolbox ...
    @weakify(self);
    
    //MARK: 获得list的model
    NSArray<GBaseViewModelSection *>* (^listSectionFromNow)(void) = ^NSArray<GBaseViewModelSection *>* {
        @strongify(self);
        return self.listSection;
    };
    //MARK: 获得section的model
    GBaseViewModelSection* (^oneSectionFromSectionIndexBlock)(NSInteger) = ^GBaseViewModelSection* (NSInteger sectionIndex) {
        NSArray<GBaseViewModelSection *>* listSection = listSectionFromNow();
        
        GBaseViewModelSection* oneSection = nil;
        if (sectionIndex < listSection.count) {
            oneSection = listSection[sectionIndex];
        }
        return oneSection;
    };
    
    //MARK: 获取每个item的model
    GBaseViewModelItem* (^rowModelFromIndexPathBlock)(NSIndexPath *) = ^GBaseViewModelItem*(NSIndexPath *indexPath) {
        GBaseViewModelSection * oneSection = oneSectionFromSectionIndexBlock(indexPath.section);
        NSArray<GBaseViewModelItem*>* modelList = oneSection.arrayItems;
        
        GBaseViewModelItem* rowModel = nil;
        if (indexPath.row < modelList.count) {
            rowModel = modelList[indexPath.row];
        }
        return rowModel;
    };
    
    
    NSDictionary *dictCellType = @{
                                   @(GCellTypeHistory):[MMHistoryCell class],
                                   };
    //MARK: 获取cell class
    Class(^cellClassFromIndexPathBlock)(NSIndexPath *indexPath) = ^Class(NSIndexPath *indexPath) {
        GBaseViewModelItem* rowModel = rowModelFromIndexPathBlock(indexPath);
        return dictCellType[@(rowModel.cellType)];
    };
    
    A2DynamicDelegate *dataSource = collectionView.bk_dynamicDataSource;
    A2DynamicDelegate *delegate = collectionView.bk_dynamicDelegate;
    
    //MARK: item个数
    [dataSource implementMethod:@selector(collectionView:numberOfItemsInSection:) withBlock:^NSInteger(UICollectionView *collectionView, NSInteger section) {
        GBaseViewModelSection* oneSection= oneSectionFromSectionIndexBlock(section);
        return oneSection.arrayItems.count;
    }];
    
    //MARK: section个数
    [dataSource implementMethod:@selector(numberOfSectionsInCollectionView:) withBlock:^NSInteger(UICollectionView *collectionView) {
        NSArray<GBaseViewModelSection *>* listSection = listSectionFromNow();
        return listSection.count;
    }];
    
    //MARK: item配置
    [dataSource implementMethod:@selector(collectionView:cellForItemAtIndexPath:) withBlock:^UICollectionViewCell*(UICollectionView *collectionView,NSIndexPath *indexPath) {
        
        id<GCellSetModelProtocol> cell = nil;
        Class cellClass = cellClassFromIndexPathBlock(indexPath);
        if (cellClass) {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:[cellClass cellReuseIdentifier] forIndexPath:indexPath];
            //            TJULLog(@"----%@",cell);
            if ([cell respondsToSelector:@selector(renderWithModel:)]) {
                [cell renderWithModel:rowModelFromIndexPathBlock(indexPath)];
            }
            
            // action block
            NSString* stringProperty = NSStringFromSelector(@selector(actionBlockWithDataModel));
            NSString* setterStr = [NSString stringWithFormat:@"set%@%@:",
                                   [[stringProperty substringToIndex:1] capitalizedString],
                                   [stringProperty substringFromIndex:1]];
            @weakify(self);
            if ([cell respondsToSelector:NSSelectorFromString(setterStr)]) {
                cell.actionBlockWithDataModel = ^(id dataModel){
                    // action
                    @strongify(self);
                    [self doAction:dataModel];
                };
            }
            
        }
        [UIView performWithoutAnimation:^{
            [((UICollectionViewCell*)cell) layoutIfNeeded];
        }];
        
        return (UICollectionViewCell *)cell;
    }];
    
    
    //MARK: item size
    [delegate implementMethod:@selector(collectionView:layout:sizeForItemAtIndexPath:) withBlock:^CGSize(UICollectionView *collectionView, UICollectionViewLayout *layout, NSIndexPath *indexPath){
        return CGSizeMake(scaleHeight(100), scaleHeight(100));
    }];
    
    //MARK: section 行间距
    [delegate implementMethod:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:) withBlock:^CGFloat(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section){
        GBaseViewModelSection* oneSection = oneSectionFromSectionIndexBlock(section);
        GCellType cellType = oneSection.arrayItems.firstObject.cellType;
        
        CGFloat sectionGap = 1;
        switch (cellType) {
            case GCellTypeHistory:
                sectionGap = scaleHeight(10);
                break;
            default:
                break;
        }
        return sectionGap;
    }];
    
//    //MARK: section 列间距
//    [delegate implementMethod:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:) withBlock:^CGFloat(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section){
//        GBaseViewModelSection* oneSection = oneSectionFromSectionIndexBlock(section);
//        GCellType cellType = oneSection.arrayItems.firstObject.cellType;
//
//        CGFloat sectionGap = 1;
//        switch (cellType) {
//            case GCellTypeHistory:
//                sectionGap = scaleHeight(10);
//                break;
//            default:
//                break;
//        }
//        return sectionGap;
//    }];
    
    //MARL: 边距
    [delegate implementMethod:@selector(collectionView:layout:insetForSectionAtIndex:) withBlock:^UIEdgeInsets(UICollectionView *collectionView, UICollectionViewLayout *layout, NSInteger section){
        return UIEdgeInsetsMake(scaleHeight(10), scaleHeight(10), 0, scaleHeight(10));
    }];
    
    //MARK: 点击事件
    [delegate implementMethod:@selector(collectionView:didSelectItemAtIndexPath:) withBlock:^(UICollectionView *collectionView, NSIndexPath *indexPath){
        @strongify(self);
        GBaseViewModelItem *item = rowModelFromIndexPathBlock(indexPath);
        [self doAction:item];
    }];
    
    
    collectionView.delegate = (id)delegate;
    collectionView.dataSource = (id)dataSource;
    
    self.collectionView = collectionView;
    
}

- (MMHistoryViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[MMHistoryViewModel alloc] init];
    }
    return _viewModel;
}

- (void)bindData {
//    self.viewModel = [[MMHistoryViewModel alloc] init];
    @weakify(self);
    [self.viewModel.dataSignal subscribeNext:^(id x) {
        @strongify(self);
        self.listSection = x;
        [self.collectionView.mj_header endRefreshing];
        [self.collectionView reloadData];
    }];
    
    [self.viewModel.errorSignal subscribeNext:^(NSError *error) {
        @strongify(self);
        [self.collectionView.mj_header endRefreshing];
        NSLog(@"%@",error.domain);
        if (![error.domain isEqualToString:@"没有更多的数据"]) {
            [SVProgressHUD showErrorWithStatus:error.domain];
        }
    }];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self.viewModel.getMainData execute:nil];
    }];
    
    [self.viewModel.getMainData execute:nil];
    
}

- (void)doAction:(id)model {
    NSLog(@"doAction=%@",model);
    if ([model isKindOfClass:[GBaseViewModelItem class]]){
        [self doCellAction:model];
    }
}

- (void)doCellAction:(GBaseViewModelItem*)model {
    NSLog(@"doCellAction=%lu",(unsigned long)model.cellType);
    
    HomeModel *homeModel = [HomeModel new];
    [homeModel yy_modelSetWithDictionary:model.modelData];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = HexColorA(0x000000, 0.2);
    [self.view addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(backgroundView.superview);
        make.top.equalTo(self.mas_topLayoutGuideTop);
        make.bottom.equalTo(self.mas_bottomLayoutGuideTop);
    }];
    backgroundView.userInteractionEnabled = YES;
    self.backgroundView = backgroundView;
    UIView *successView = [self showSuccessViewWithData:homeModel ];
    self.successView = successView;
//    successView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds)*0.8, CGRectGetHeight(self.view.bounds)*0.8);
//    KLCPopup *pop = [KLCPopup popupWithContentView:successView showType:KLCPopupShowTypeBounceIn dismissType:KLCPopupDismissTypeBounceOut maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
//    [pop show];
//    self.pop = pop;
    
    [backgroundView addSubview:successView];
    [successView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(successView.superview).multipliedBy(0.8);
        make.centerX.equalTo(successView.superview);
        make.top.equalTo(self.customNavBar.mas_bottom).offset(scaleHeight(20));
    }];
    
    // 第一步：将view宽高缩至无限小（点）
    successView.transform = CGAffineTransformScale(CGAffineTransformIdentity,CGFLOAT_MIN, CGFLOAT_MIN);
    [UIView animateWithDuration:0.3 animations:^{
        // 第二步： 以动画的形式将view慢慢放大至原始大小的1.2倍
        successView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            // 第三步： 以动画的形式将view恢复至原始大小
            successView.transform = CGAffineTransformIdentity;
        }];
    }];
    
    [backgroundView bk_whenTapped:^{
        [UIView animateWithDuration:0.1 animations:^{
            successView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                successView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);;
            } completion:^(BOOL finished) {
                [successView removeFromSuperview];
                [backgroundView removeFromSuperview];
            }];
        }];
    }];
}



- (UIView*)showSuccessViewWithData:(HomeModel*)homeModel{
    NSDictionary *homeDict= homeModel.yy_modelToJSONObject;
    NSLog(@"homeDict=%@",homeDict);
    
    UIView *successView = [UIView new];
    successView.backgroundColor = HexColor(0xf3f3f3);
//    [self.view addSubview:successView];
//    [successView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.equalTo(successView.superview).multipliedBy(0.8);
//        make.centerX.equalTo(successView.superview);
//        make.top.equalTo(self.customNavBar.mas_bottom).offset(scaleHeight(20));
//    }];
//    successView.hidden = YES;
//    [UIView animateWithDuration:0.5 animations:^{
//        successView.hidden = NO;
//    }];
    
    
    UIImageView *imageView = [UIImageView new];
    [imageView sd_setImageWithURL:[NSURL URLWithString:homeModel.url]];
    imageView.backgroundColor = HexColor(0xffffff);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [successView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(successView).multipliedBy(0.8);
        make.height.equalTo(successView).multipliedBy(0.6);
        make.centerX.equalTo(imageView.superview);
        make.top.equalTo(scaleHeight(20));
    }];
    
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageView addSubview:activity];
    [activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(activity.superview);
    }];
    [activity startAnimating];
    [imageView sd_setImageWithURL:[NSURL URLWithString:homeModel.url] placeholderImage:nil completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        [activity removeFromSuperview];
    }];
    
    UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [copyBtn setTitle:@"选择图片地址样式" forState:UIControlStateNormal];
    //    [copyBtn setTitleColor:HexColor(0x000000) forState:UIControlStateNormal];
    [successView addSubview:copyBtn];
    [copyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).offset(scaleHeight(20));
        make.centerX.equalTo(copyBtn.superview);
    }];
    @weakify(self);
    [copyBtn bk_addEventHandler:^(id sender) {
        @strongify(self);
        UIActionSheet *sheet = [UIActionSheet bk_actionSheetWithTitle:@"请选择需要复制的样式"];
        [sheet bk_addButtonWithTitle:@"复制地址" handler:^{
            NSString *url = homeModel.url;
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:url];
        }];
        
        [sheet bk_addButtonWithTitle:@"复制Markdown" handler:^{
            NSString *markdown = [NSString stringWithFormat:@"![image](%@)",homeModel.url];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:markdown];
        }];
        
        [sheet bk_setCancelButtonWithTitle:@"取消" handler:^{
            
        }];
        [sheet showInView:self.view];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [shareBtn setTitle:@"分享地址" forState:UIControlStateNormal];
    //    [shareBtn setTitleColor:HexColor(0x000000) forState:UIControlStateNormal];
    [successView addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(copyBtn.mas_bottom).offset(scaleHeight(10));
        make.centerX.equalTo(shareBtn.superview);
    }];
    
    [shareBtn bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self SystemShareWithTitle:@"" withText:@"" withImageUrl:homeModel.url withSiteUrl:homeModel.url withVC:self];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.shareBtn = shareBtn;
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [deleteBtn setTitle:@"删除记录" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [successView addSubview:deleteBtn];
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shareBtn.mas_bottom).offset(scaleHeight(10));
        make.centerX.equalTo(deleteBtn.superview);
    }];
    
    [deleteBtn bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        [self.viewModel.deleteCommand execute:homeDict];
        
        [UIView animateWithDuration:0.1 animations:^{
            self.successView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.successView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);;
            } completion:^(BOOL finished) {
                [self.successView removeFromSuperview];
                [self.backgroundView removeFromSuperview];
            }];
        }];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
    
    
    
    UIImageView *closeImg = [UIImageView new];
    closeImg.image = [UIImage imageNamed:@"close"];
    [successView addSubview:closeImg];
    [closeImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(deleteBtn.mas_bottom).offset(scaleHeight(10));
        make.centerX.equalTo(closeImg.superview);
    }];
    
    return successView;
}

//ios系统分享
-(void)SystemShareWithTitle:(NSString*)title withText:(NSString*)text withImageUrl:(NSString*)url withSiteUrl:(NSString*)siteurl withVC:(UIViewController*)VC
{
    
    
    NSString *titleText = title;
    NSString *shareText = text;
    NSURL *URL = [NSURL URLWithString:siteurl];
    UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    UIActivityViewController *a = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:titleText,shareText,URL,image, nil] applicationActivities:nil];
    a.modalPresentationStyle = UIModalPresentationPopover;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        a.popoverPresentationController.sourceView = self.view;
        a.popoverPresentationController.sourceView = self.shareBtn;
//        UIPopoverController *poper = [[UIPopoverController alloc] initWithContentViewController:a];
//        CGRect rect = CGRectMake(self.view.center.x, CGRectGetMaxY(self.shareBtn.frame), self.shareBtn.frame.size.width, self.shareBtn.frame.size.height);
//        [poper presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
        [self presentViewController:a animated:YES completion:nil];

    }else {
        [self presentViewController:a animated:YES completion:nil];
    }

}





- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView.mj_header beginRefreshing];
}


@end
