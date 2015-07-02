//
//  QLAssetsGroupViewController.h
//  HelloWorld
//
//  Created by xuqianlong on 15/6/15.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QLAssetsCommonHeader.h"

@interface QLAssetsGroupViewController : UITableViewController

@property(nonatomic, assign) NSUInteger maxCountCanSelect;

- (id)initWithManagerFinishBlock:(QLAssetManagerFinishBlock)block;

@end
