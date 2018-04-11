# 写在前面

前段时间闲着无聊和盆友就搞了个图床站[Chevereto-Free](https://github.com/Chevereto/Chevereto-Free)，忽然发现居然有API提供，而且很简单，只需要一个KEY就可以

觉得很适合当练手的项目，没几个页面，做的很快，就是被 2.1大礼包搞了好久才上线。[米米图床 AppStore](https://itunes.apple.com/cn/app/%E7%B1%B3%E7%B1%B3%E5%9B%BE%E5%BA%8A-%E8%B6%85%E7%BA%A7%E5%A5%BD%E7%94%A8%E7%9A%84%E5%9B%BE%E5%BA%8A%E5%B7%A5%E5%85%B7/id1353321904?mt=8)

跟盆友一起搞的小博客有兴趣的可以看看，此文也会同步过去，也包含一些服务器相关的内容。[个人站博客](http://www.xpblog.xyz/)

本文主要代码使用 [RAC](https://github.com/ReactiveCocoa/ReactiveCocoa)+MVVM 以及其他一些第三方库，做的比较急，代码结构没有特别注意

# 准备工作

- 你得有一台VPS
- 安装相关环境，可视化的[宝塔](https://bt.cn)套装还是挺不错的，或者直接安装[LNMP环境](https://lnmp.org/)
- 搭建[Chevereto-Free](https://github.com/Chevereto/Chevereto-Free) 前后台

![图床要求环境](https://upload-images.jianshu.io/upload_images/4009159-974c0e8923886957.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![宝塔面板](https://upload-images.jianshu.io/upload_images/4009159-c26b8cd34f504064.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![LNMP](https://upload-images.jianshu.io/upload_images/4009159-ec3827a4c5acefe4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

安装好图床的前后台就可以使用正常的web站进行上传图片了。
去后台打开API 获得API KEY
![API_KEY](https://upload-images.jianshu.io/upload_images/4009159-b4aa98ba33a4886f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

使用cocoaPods 管理第三方。
打开iCloud最简单的Key-Value存储功能
![iCloud](https://upload-images.jianshu.io/upload_images/4009159-dd44ed299b70a564.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


# 界面设计

准备工作都做完后我们就可以开始进行App设计了。
不用搞太复杂，几个页面就够
- 首页 ：主要功能入口，上传图片。上传完成后可以选择copy的内容，顺便再加个分享
- 历史 ：上传的历史记录，直接就使用iCloud来保存数据。同样有首页copy和分享功能
- 关于 ：一些免责声明，例如严禁上传小黄图啦之类的。

偷懒 直接截图了
![UI](https://upload-images.jianshu.io/upload_images/4009159-e89ff2848fdd9aba.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
页面很简单吧~

# 首页

首页就是个上传图片到后台，偷了个懒，没有使用RAC+MVVM，直接一堆写在VC里了
![](https://upload-images.jianshu.io/upload_images/4009159-df7c65c21a3bd66d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/200)

```Objective-C
- (void)viewDidLoad {
    [super viewDidLoad];
    self.customNavBar.title = @"首页";
    Reachability *reach = [Reachability reachabilityWithHostName:@"https://www.baidu.com"];
    reach.reachableBlock = ^(Reachability *reachability) {
        NSLog(@"REACHABLE!");
    };

    UIView *uploadView = [UIView new];
    [self.view addSubview:uploadView];
    [uploadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(uploadView.superview);
        make.size.equalTo(CGSizeMake(scaleHeight(200), scaleHeight(250)));
    }];
    uploadView.userInteractionEnabled = YES;
    @weakify(self);
    [uploadView bk_whenTapped:^{
        NSLog(@"click upload btn");
        @strongify(self);
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];

        imagePickerVc.allowPickingVideo = NO;

        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }];

    UIImageView *uploadImg = [UIImageView new];
    uploadImg.image = [UIImage imageNamed:@"hui"];
    [uploadView addSubview:uploadImg];
    [uploadImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(uploadImg.superview);
        make.height.equalTo(scaleHeight(200));
    }];
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = FontHeiti(14);
    titleLabel.textColor = [UIColor redColor];
    titleLabel.text = @"选择需要上传的图片";
    [uploadView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(titleLabel.superview);
        make.top.equalTo(uploadImg.mas_bottom);
    }];

}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    NSLog(@"photos=%@",photos);
    [SVProgressHUD showWithStatus:@"上传中..."];
    [self prepareUploadWithImage:photos.firstObject];

}
- (void)prepareUploadWithImage:(UIImage*)image {
    NSDictionary *sendParams = @{
                                 @"uploadfile":@[image],
                                 };
    @weakify(self);
    [[GApiManger sendApi:GApiTypeUpload withParam:sendParams] subscribeNext:^(id x) {
        NSLog(@"GApiManger result = %@",x);
        [SVProgressHUD showSuccessWithStatus:@"上传成功！"];

        HomeModel *homeModel = [HomeModel new];
        [homeModel mts_setValuesForKeysWithDictionary:x];
        @strongify(self);
        [self showSuccessViewWithData:homeModel image:image];
    } error:^(NSError *error) {
        NSLog(@"GApiManger error = %@",error);
    }];
}
```

上传成功后写入iCloud中, 弹出分享及其他内容

```Objective-C
- (void)showSuccessViewWithData:(HomeModel*)homeModel image:(UIImage*)image{
    NSDictionary *homeDict= homeModel.yy_modelToJSONObject;
    NSLog(@"homeDict=%@",homeDict);

    //iCloud存储
    NSUbiquitousKeyValueStore *myKeyValue = [NSUbiquitousKeyValueStore defaultStore];
    NSArray *iCloudData = [myKeyValue objectForKey:@"iCloudData"];
    NSMutableArray *newData = @[].mutableCopy;
    if (iCloudData) {
        newData = iCloudData.mutableCopy;
    }
    [newData addObject:homeDict];
    [myKeyValue setObject:newData forKey:@"iCloudData"];
    [myKeyValue synchronize];


    UIView *successView = [UIView new];
    successView.backgroundColor = HexColor(0xf3f3f3);
    [self.view addSubview:successView];
    [successView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(successView.superview).multipliedBy(0.8);
        make.centerX.equalTo(successView.superview);
        make.top.equalTo(self.customNavBar.mas_bottom).offset(scaleHeight(20));
    }];


    UIImageView *imageView = [UIImageView new];
    imageView.image = image;
    imageView.backgroundColor = HexColor(0xffffff);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [successView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(successView).multipliedBy(0.8);
        make.height.equalTo(successView).multipliedBy(0.6);
        make.centerX.equalTo(imageView.superview);
        make.top.equalTo(scaleHeight(20));
    }];

    successView.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        successView.hidden = NO;
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


    UIButton *uploadBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [uploadBtn setTitle:@"继续上传" forState:UIControlStateNormal];
//    [uploadBtn setTitleColor:HexColor(0x000000) forState:UIControlStateNormal];
    [successView addSubview:uploadBtn];
    [uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(copyBtn.mas_bottom).offset(scaleHeight(20));
        make.centerX.equalTo(uploadBtn.superview);
    }];

    [uploadBtn bk_addEventHandler:^(id sender) {
        [UIView animateWithDuration:0.5 animations:^{
            successView.alpha = 0;
        } completion:^(BOOL finished) {
            [successView removeFromSuperview];
        }];
    } forControlEvents:UIControlEventTouchUpInside];


    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
//    [shareBtn setTitleColor:HexColor(0x000000) forState:UIControlStateNormal];
    [successView addSubview:shareBtn];
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(uploadBtn.mas_bottom).offset(scaleHeight(20));
        make.centerX.equalTo(shareBtn.superview);
    }];

    [shareBtn bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self SystemShareWithTitle:@"" withText:@"" withImageUrl:homeModel.url withSiteUrl:homeModel.url withVC:self];
    } forControlEvents:UIControlEventTouchUpInside];

}

```


```Objective-c
//ios系统分享
-(void)SystemShareWithTitle:(NSString*)title withText:(NSString*)text withImageUrl:(NSString*)url withSiteUrl:(NSString*)siteurl withVC:(UIViewController*)VC
{
    NSString *titleText = title;
    NSString *shareText = text;
    NSURL *URL = [NSURL URLWithString:siteurl];
    UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    UIActivityViewController *a = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:titleText,shareText,URL,image, nil] applicationActivities:nil];
    [VC presentViewController:a animated:true completion:nil];
}
```
首页基本就完了。。。一个VC搞定。贴出来纯粹凑篇幅。
![](https://upload-images.jianshu.io/upload_images/4009159-f6568fb7b4993c5e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/200)


# 历史

>基本功能如下
>- 加载iCloud数据
>- 删除记录
>- 分享

这里使用了MVVM+RAC

- ViewModel 创建两个command, 获取数据，及删除数据

```Objective-c
@interface MMHistoryViewModel : GBaseViewModel
@property (nonatomic, strong, readonly) RACCommand *getMainData;
@property (nonatomic, strong, readonly) RACCommand *deleteCommand;
@end
```
- 编写功能

```Objective-C
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
```

>VC中就是一波代码, 展示collectionView 功能与首页如出一辙

![](https://upload-images.jianshu.io/upload_images/4009159-204911478c1aca77.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/200)


```Objective-C
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
        a.popoverPresentationController.sourceView = self.shareBtn;
        [self presentViewController:a animated:YES completion:nil];
    }else {
        [self presentViewController:a animated:YES completion:nil];
    }

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.collectionView.mj_header beginRefreshing];
}

```


# 关于

这个页面没什么好说的了。。。不管有没有用，免责声明写起来。

# 后记

其实手机上需要使用图床工具的其实也不多。毕竟还是比较麻烦，只是个备用选择，还是浏览器舒服，直接~~一脱~~一拖到浏览器就ok。

这种项目只能练练手，或者是说熟悉熟悉商家流程之类吧~

代码已上传 [Gayhub](https://github.com/gongxiaokai/MimiImg)
>注意需要修改API_KEY
