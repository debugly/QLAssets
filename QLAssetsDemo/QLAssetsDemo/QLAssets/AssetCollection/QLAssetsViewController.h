//
//  QLAssetsViewController.h
//  HelloWorld
//
//  Created by xuqianlong on 15/6/15.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QLAssetsGroupModel,QLAssetsViewController;

@protocol QLAssetsViewControllerDelegate <NSObject>

- (void)assetsViewController:(QLAssetsViewController *)vc finishedSelectPhotos:(NSArray *)models;
- (void)assetsViewControllerCancle:(QLAssetsViewController *)vc;

@end

@interface QLAssetsViewController : UICollectionViewController

@property (nonatomic, weak) id<QLAssetsViewControllerDelegate>delegate;
@property(nonatomic, assign) NSUInteger maxCountCanSelect;

- (instancetype)initWithGroupModel:(QLAssetsGroupModel *)model;

@end