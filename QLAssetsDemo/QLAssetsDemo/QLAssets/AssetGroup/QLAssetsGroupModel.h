//
//  QLAssetsGroupModel.h
//  HelloWorld
//
//  Created by xuqianlong on 15/6/16.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QLAssetsGroupModel : NSObject

@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, strong)UIImage *posterImage;
@property (nonatomic, strong)NSArray *photoArr;

@end
