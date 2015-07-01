//
//  QLAssetFullScreenBaseViewController.h
//  PengBei
//
//  Created by xuqianlong on 15/6/23.
//  Copyright (c) 2015年 夕阳栗子. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLAssetsCommonHeader.h"

@class QLAssetsModel;
@interface QLAssetFullScreenBaseViewController : UICollectionViewController

@property (nonatomic, strong,readonly) NSMutableArray  *modelArr;

@property (nonatomic, assign) NSUInteger currentShowIndex;//当前需要展示的索引，默认0；

- (NSArray *)fetchSelectedImages;
- (QLAssetsModel *)fetchCurrentShowIdxModel;
- (void)scrollOtherPageNeedUpdateUI;
- (void)updateTitle;
- (void)backViewControllerAction;
///
/**
 *  全屏浏览
 *
 *  @param modelArr  model数组
 *  @param finiBlock 选择结果数组
 *
 */
- (instancetype)initWithQLAssetsModels:(NSArray *)modelArr beforeBackRevokeSelBlock:(QLAssetManagerFinishBlock)finiBlock;

@end
