//
//  QLAssetsCommonHeader.h
//  HelloWorld
//
//  Created by xuqianlong on 15/6/17.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^QLAssetManagerFinishBlock)(NSArray *selArr);

FOUNDATION_EXPORT const CGFloat QLAssetsCollectionViewCellSelBtnTopMarin;
FOUNDATION_EXPORT const CGFloat QLAssetsCollectionViewCellSelBtnRightMarin;
FOUNDATION_EXPORT const CGFloat QLAssetsCollectionViewCellSelBtnWith;
FOUNDATION_EXPORT const CGFloat QLAssetsCollectionViewCellSelBtnHeight;
FOUNDATION_EXPORT const CGFloat QLAssetsCollectionViewCellCornerRadius;

FOUNDATION_EXPORT const CGFloat QLAssetsViewControllerToolBarHeight;
FOUNDATION_EXPORT const CGFloat QLAssetsViewControllerItemSpacing;
FOUNDATION_EXPORT const NSUInteger QLAssetsViewControllerColumns;

FOUNDATION_EXPORT const CGFloat QLAssetFullScreenSelectViewControllerPageMargin;
FOUNDATION_EXPORT const CGFloat QLAssetFullScreenSelectViewControllerSwitchWidth;
FOUNDATION_EXPORT const CGFloat QLAssetFullScreenSelectViewControllerSwitchHeight;

FOUNDATION_EXPORT NSString *const QLAssetsBundleName;

#define QLAssetsViewControllerToolBarBgColor [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1]

#define kQLAssetFileName(file) [QLAssetsBundleName stringByAppendingPathComponent:file]

#define kQLAssetSelectImageName     kQLAssetFileName(@"select_hig")
#define kQLAssetunSelectImageName   kQLAssetFileName(@"select_nor")

#define kQLAssetsGroupCellHeight 60
#define kQLAssetsGroupCellImgHeight (kQLAssetsGroupCellHeight - 10)
#define kQLAssetsGroupCellImgWidth  (kQLAssetsGroupCellHeight - 10)