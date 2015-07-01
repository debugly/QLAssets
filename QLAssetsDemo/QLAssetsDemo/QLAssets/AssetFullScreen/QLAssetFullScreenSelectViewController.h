//
//  QLAssetFullScreenSelectViewController.h
//  HelloWorld
//
//  Created by xuqianlong on 15/6/16.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//全屏浏览选择／取消；

#import <UIKit/UIKit.h>
#import "QLAssetsCommonHeader.h"
#import "QLAssetFullScreenBaseViewController.h"

@class QLAssetFullScreenSelectViewController;
@protocol QLAssetFullScreenSelectViewControllerDelegate <NSObject>

- (void)browerViewController:(QLAssetFullScreenSelectViewController *)vc finishedSelectPhotos:(NSArray *)models;

@end

@interface QLAssetFullScreenSelectViewController : QLAssetFullScreenBaseViewController

@property(nonatomic, assign) NSUInteger maxCountCanSelect;
@property (nonatomic, weak) id<QLAssetFullScreenSelectViewControllerDelegate>delegate;

@end
