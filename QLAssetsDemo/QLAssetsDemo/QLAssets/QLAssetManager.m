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

+ (ALAssetsLibrary *)assetsLibrary;

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

//保存图片；
static inline void SaveImage2Ablum(ALAssetsLibrary *lb,UIImage *image,ALAssetsGroup *group,void(^completed)(NSError *error))
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [lb writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error) {
            if (!error) {
                [lb assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    [group addAsset:asset];
                    dispatch_async(dispatch_get_main_queue(),^{
                        if (completed){
                            completed(nil);
                        }
                    });
                } failureBlock:completed];
            }else if (completed){
                dispatch_async(dispatch_get_main_queue(),^{
                    completed(nil);
                });
            }
        }];
    });
}

+ (void)savePhoto:(UIImage *)image toGroup:(NSString *)gName completed:(void(^)(NSError *err))cmpBlock
{
    switch ([ALAssetsLibrary authorizationStatus]) {
        case ALAuthorizationStatusDenied:
        {
            //        拒绝；
            if (cmpBlock) {
                NSError *err = [NSError errorWithDomain:@"com.xuqianlong" code:900000 userInfo:@{NSLocalizedDescriptionKey:@"请在设置－>隐私－>照片里打开访问权限"}];
                cmpBlock(err);
            }
        }
            break;
        case ALAuthorizationStatusNotDetermined:
        {
            NSLog(@"Not Determined");//第一次是这个；
        }
        case ALAuthorizationStatusAuthorized:
        {
            //        授权；
            NSLog(@"Already Determined");
        }
        case ALAuthorizationStatusRestricted:
        {
            NSLog(@"Restricted");
        }
        default:
        {
            __weak __typeof(self)weakSelf = self;
            
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    NSString *name = [group valueForProperty:ALAssetsGroupPropertyName];
                    if ([name isEqualToString:gName]) {
                        SaveImage2Ablum([weakSelf assetsLibrary], image, group, cmpBlock);
                        *stop = YES;
                    }
                }else{
                    if ((!(*stop)) && (!group)) {
                        [weakSelf.assetsLibrary addAssetsGroupAlbumWithName:gName resultBlock:^(ALAssetsGroup *group) {
                            SaveImage2Ablum([weakSelf assetsLibrary], image, group, cmpBlock);
                        } failureBlock:cmpBlock];
                    }
                }
            } failureBlock:^(NSError *error) {
                //ALAuthorizationStatusNotDetermined决绝的时候就失败了；
                if (cmpBlock) {
                    NSError *err = [NSError errorWithDomain:@"com.xuqianlong" code:900000 userInfo:@{NSLocalizedDescriptionKey:@"请在设置－>隐私－>照片里打开访问权限"}];
                    cmpBlock(err);
                }
            }];
        }
    }
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
