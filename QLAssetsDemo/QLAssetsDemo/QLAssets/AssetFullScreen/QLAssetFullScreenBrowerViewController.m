//
//  QLAssetFullScreenBrowerViewController.m
//  PengBei
//
//  Created by xuqianlong on 15/6/23.
//  Copyright (c) 2015年 夕阳栗子. All rights reserved.
//

#import "QLAssetFullScreenBrowerViewController.h"

@interface QLAssetFullScreenBrowerViewController ()<UIActionSheetDelegate>


@end

@implementation QLAssetFullScreenBrowerViewController

- (void)prepareNavItem
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:kQLAssetunSelectImageName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:kQLAssetSelectImageName] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(showActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [btn setBounds:CGRectMake(0, 0, QLAssetFullScreenSelectViewControllerSwitchWidth, QLAssetFullScreenSelectViewControllerSwitchHeight)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
}

- (void)showActionSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:@"要删除这张照片吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles: nil];
    [sheet showInView:self.navigationController.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self deleteItemAction];
    }
}

- (void)deleteItemAction
{
    NSIndexPath *idx = [NSIndexPath indexPathForItem:self.currentShowIndex inSection:0];
    
    __weak __typeof(self)weakSelf = self;
    
    [self.collectionView performBatchUpdates:^{
        [weakSelf.collectionView deleteItemsAtIndexPaths:@[idx]];
        [weakSelf.modelArr removeObjectAtIndex:self.currentShowIndex];
        weakSelf.currentShowIndex -= 1;
    } completion:^(BOOL finished) {
        if (self.modelArr.count == 0) {
            [weakSelf backViewControllerAction];
        }else{
            [weakSelf updateTitle];
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self prepareNavItem];
}

@end
