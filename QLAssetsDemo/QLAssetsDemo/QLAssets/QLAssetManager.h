//
//  QLAssetManager.h
//  HelloWorld
//
//  Created by xuqianlong on 15/6/17.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLAssetsCommonHeader.h"
#import <UIKit/UIKit.h>

@interface QLAssetManager : NSObject

///
/**
 *  根据URL fetch FullScreen image
 *
 *  @param url         ALAsset url
 *  @param resultBlock image
 */
+ (void)fetchFullsreenImagewithURL:(NSURL *)url resultBlcok:(void(^)(UIImage *img))resultBlock;

///
/**
 *  模态分组视图控制器
 *
 *  @param ownvc             from which viewcontrollser
 *  @param animi             is need animation
 *  @param maxCountCanSelect the max count can select
 *  @param finiBlock         selected model array
 */
+ (void)showAssetGroupViewOnViewController:(UIViewController *)ownvc
                          presentAnimation:(BOOL)animi
                         maxCountCanSelect:(NSUInteger)maxCountCanSelect
                            finishSelBlock:(QLAssetManagerFinishBlock)finiBlock;

///全屏浏览图片可删除；删除完毕自动pop出来；
+ (void)showAssetFullScreenBrowerView:(UINavigationController *)ownvc
                     presentAnimation:(BOOL)animi
                     currentShowIndex:(NSUInteger)currentShowIndex
                         assetsModels:(NSArray *)assetsModels
                       finishSelBlock:(QLAssetManagerFinishBlock)finiBlock;

@end
