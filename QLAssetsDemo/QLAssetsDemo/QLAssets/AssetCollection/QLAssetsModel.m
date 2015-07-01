//
//  QLAssetsModel.m
//  HelloWorld
//
//  Created by xuqianlong on 15/6/16.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLAssetsModel.h"

@implementation QLAssetsModel

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        self.selThumbnail = self.thumbnail;
    }else{
        self.selThumbnail = nil;
    }
    _selected = selected;
}

@end
