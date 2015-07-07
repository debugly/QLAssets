//
//  QLAssetsModel.h
//  HelloWorld
//
//  Created by xuqianlong on 15/6/16.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface QLAssetsModel : NSObject

@property (nonatomic, assign,getter=isSelected) BOOL selected;
@property (nonatomic, weak)   UIImage *thumbnail;
@property (nonatomic, strong) UIImage *selThumbnail;
@property (nonatomic, strong) NSURL *url; //asset's url

@end
