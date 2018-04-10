//
//  MMHomeViewController.m
//  MimiImg
//
//  Created by gongwenkai on 2018/2/26.
//  Copyright © 2018年 gongwenkai. All rights reserved.
//

#import "MMHomeViewController.h"
#import "HomeModel.h"
#import "GApiManger.h"
#import "Reachability.h"

#import <YYModel/YYModel.h>
#import <BlocksKit/BlocksKit+UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <TZImagePickerController/TZImagePickerController.h>
@interface MMHomeViewController ()<TZImagePickerControllerDelegate>

@end

@implementation MMHomeViewController

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
    
    
//    @weakify(self);
//    [btn bk_addEventHandler:^(id sender) {
//        NSLog(@"click upload btn");
//        @strongify(self);
//
//        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
//        imagePickerVc.allowPickingVideo = NO;
//        [self presentViewController:imagePickerVc animated:YES completion:nil];
//
////        [self showSuccessView];
//    } forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
