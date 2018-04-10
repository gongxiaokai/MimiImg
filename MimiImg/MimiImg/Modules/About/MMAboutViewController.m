//
//  MMAboutViewController.m
//  MimiImg
//
//  Created by gongwenkai on 2018/2/26.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "MMAboutViewController.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import <BlocksKit/A2DynamicDelegate.h>
#import <SDWebImage/SDImageCache.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <RDVTabBarController/RDVTabBarController.h>
@interface MMAboutViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong)NSArray *dataArray;
@end

@implementation MMAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customNavBar.title = @"关于";
    
    UIImageView *iconImg = [UIImageView new];
    iconImg.image = [UIImage imageNamed:@"mimi512"];
    [self.view addSubview:iconImg];
    [iconImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(scaleHeight(150), scaleHeight(150)));
        make.centerX.equalTo(iconImg.superview);
        make.top.equalTo(self.customNavBar.mas_bottom);
    }];
    
    UILabel *verLabel = [UILabel new];
    verLabel.font = FontHeiti(13);
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    verLabel.textColor = [UIColor grayColor];
    verLabel.text = [NSString stringWithFormat:@"米米图床 v%@",infoDictionary[@"CFBundleShortVersionString"]];
    [self.view addSubview:verLabel];
    [verLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(verLabel.superview);
        make.top.equalTo(iconImg.mas_bottom);
    }];
    
    UILabel *mianzeshengmingTitle = [UILabel new];
    mianzeshengmingTitle.font = FontBoldHeiti(17);
    mianzeshengmingTitle.text = @"免责声明";
    [self.view addSubview:mianzeshengmingTitle];
    [mianzeshengmingTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scaleHeight(10));
        make.top.equalTo(verLabel.mas_bottom).offset(scaleHeight(10));
    }];
    
    UILabel *mianzeshengming = [UILabel new];
    mianzeshengming.font = FontHeiti(14);
    mianzeshengming.numberOfLines = 0;
    mianzeshengming.text =
                           @"在法律的允许范围内，请随意使用本图床；\n"
                           @"请勿上传违反中国大陆和香港法律的图片，违者后果自负。\n";
    [self.view addSubview:mianzeshengming];
    [mianzeshengming mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scaleHeight(10));
        make.top.equalTo(mianzeshengmingTitle.mas_bottom).offset(scaleHeight(10));
    }];
    
    UILabel *banTitle = [UILabel new];
    banTitle.font = FontBoldHeiti(17);
    banTitle.text = @"严禁上传以下类型图片";
    [self.view addSubview:banTitle];
    [banTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scaleHeight(10));
        make.top.equalTo(mianzeshengming.mas_bottom).offset(scaleHeight(10));
    }];
    
    UILabel *banLab = [UILabel new];
    banLab.font = FontHeiti(14);
    banLab.numberOfLines = 0;
    banLab.text =
    @"含有色情、暴力、宣扬恐怖主义的图片；\n"
    @"侵犯版权、未经授权的图片；\n"
    @"其他违反中华人民共和国法律的图片。";
    [self.view addSubview:banLab];
    [banLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(scaleHeight(10));
        make.top.equalTo(banTitle.mas_bottom).offset(scaleHeight(10));
    }];
    

//    self.dataArray = @[@"吐槽",@"清除缓存",@"米米出品"];
    self.dataArray = @[@"清除缓存"];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = HexColor(0xffffff);
    [self.view addSubview:self.tableView];
    self.tableView.estimatedSectionHeaderHeight = 0;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(banLab.mas_bottom).offset(scaleHeight(10));
        make.bottom.left.right.equalTo(self.view);
    }];
    
    A2DynamicDelegate *delegate = self.tableView.bk_dynamicDelegate;
    A2DynamicDelegate *dataSource = self.tableView.bk_dynamicDataSource;
    
    
    @weakify(self);
    //MARK: row个数
    [dataSource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^NSInteger(UITableView *tableView,NSInteger section){
        @strongify(self);
        return self.dataArray.count;
    }];
    
    //MARK: cell配置
    [dataSource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^UITableViewCell*(UITableView *tableView, NSIndexPath *indexPath){
        //可复用单元格ID
        //尝试获取可复用的单元格
        UITableViewCell* cell = cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellID"];
        }
        @strongify(self);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = self.dataArray[indexPath.row];
        cell.textLabel.font = FontHeiti(15);
        return cell;
    }];
//    UIViewController*(^detailVC)(NSInteger flag) = ^UIViewController*(NSInteger flag){
//        NSArray *array = @[
////                           [[TJULMineAddressManageViewController alloc] init] ,
////                           [[TJULMineQualificationViewController alloc] init] ,
////                           [[TJULMineSecurityViewController alloc] init] ,
////                           [[TJULMinePersonalInfoViewController alloc] init] ,
//                           ];
//        return array[flag];
//    };
    //MARK: 点击事件
    [delegate implementMethod:@selector(tableView:didSelectRowAtIndexPath:) withBlock:^(UITableView *tableView,NSIndexPath *indexPath){
//        if (indexPath.row == 0) {
//
//            NSString*url =@"itms-apps://itunes.apple.com/cn/app/id1353321904?mt=8";//把http://带上
//            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
//        }else if (indexPath.row == 1){
            [SVProgressHUD showWithStatus:@"清理中..."];
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                [SVProgressHUD showSuccessWithStatus:@"清理成功"];
            }];
//        }else if (indexPath.row == 2){
//            NSString*url =@"https://dl.xpblog.xyz";//把http://带上
//            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:url]];
//        }
    }];
    
    [delegate implementMethod:@selector(tableView:heightForHeaderInSection:) withBlock:^CGFloat(UITableView *tableView, NSInteger section){
        return 0.1;
    }];
    
    
    self.tableView.dataSource = (id)dataSource;
    self.tableView.delegate = (id)delegate;
    
    // Do any additional setup after loading the view.
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
