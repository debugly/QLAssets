//
//  QLAssetManager.m
//  HelloWorld
//
//  Created by xuqianlong on 15/6/17.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLAssetManager.h"
#import "QLAssetsGroupViewController.h"
#import "QLAssetFullScreenBrowerViewController.h"

@interface QLAssetManager ()

@end

@implementation QLAssetManager

+ (ALAssetsLibrary *)assetsLibrary
{
    static ALAssetsLibrary *assetsLibrary;
    @synchronized(self){
        if (!assetsLibrary) {
            assetsLibrary = [[ALAssetsLibrary alloc]init];
        }
    }
    return assetsLibrary;
}

+ (void)fetchFullsreenImagewithURL:(NSURL *)url resultBlcok:(void(^)(UIImage *img))resultBlock
{
    __block UIImage *image = nil;
    [self.assetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        if (asset != 0x00 && asset) {
            image = [[UIImage alloc]initWithCGImage:[asset defaultRepresentation].fullScreenImage];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
            if (imageData.length > 600*1024) {
                imageData = UIImageJPEGRepresentation(image, 0.5);
            }else if (imageData.length > 500*1024){
                imageData = UIImageJPEGRepresentation(image, 0.6);
            }else if (imageData.length > 400*1024){
                imageData = UIImageJPEGRepresentation(image, 0.7);
            }else if (imageData.length > 300*1024){
                imageData = UIImageJPEGRepresentation(image, 0.8);
            }
            image = [[UIImage alloc]initWithData:imageData];
            if (resultBlock) {
                resultBlock(image);
            }
        }
    } failureBlock:^(NSError *error) {
        if (resultBlock) {
            resultBlock(nil);
        }
    }];
}

+ (void)showAssetGroupViewOnViewController:(UIViewController *)ownvc
                          presentAnimation:(BOOL)animi
                         maxCountCanSelect:(NSUInteger)maxCountCanSelect
                            finishSelBlock:(QLAssetManagerFinishBlock)finiBlock
{
    QLAssetsGroupViewController *vc = [[QLAssetsGroupViewController alloc]initWithManagerFinishBlock:finiBlock];
    vc.maxCountCanSelect = maxCountCanSelect;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:vc];
    
    [ownvc presentViewController:nav animated:animi completion:NULL];
}

+ (void)showAssetFullScreenBrowerView:(UINavigationController *)ownvc
                     presentAnimation:(BOOL)animi
                     currentShowIndex:(NSUInteger)currentShowIndex
                         assetsModels:(NSArray *)assetsModels
                       finishSelBlock:(QLAssetManagerFinishBlock)finiBlock
{
    QLAssetFullScreenBrowerViewController *vc = [[QLAssetFullScreenBrowerViewController alloc]initWithQLAssetsModels:assetsModels beforeBackRevokeSelBlock:finiBlock];
    vc.currentShowIndex = currentShowIndex;
    [ownvc pushViewController:vc animated:animi];
}

@end
