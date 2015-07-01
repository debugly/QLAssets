//
//  QLAssetsCollectionViewCell.h
//  HelloWorld
//
//  Created by xuqianlong on 15/6/16.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QLAssetsCollectionViewCell,QLAssetsModel;
@protocol QLAssetsCollectionViewCellDelegate  <NSObject>

@optional
///
/**
 *  回调点击事件，回调完毕后，取modle的isSelected状态作为UI的选种状态
 */
- (void)clickedSelectItemAction:(QLAssetsCollectionViewCell *)sender;

@end

@interface QLAssetsCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) QLAssetsModel *model;
@property (nonatomic, weak) id<QLAssetsCollectionViewCellDelegate> delegate;

@end