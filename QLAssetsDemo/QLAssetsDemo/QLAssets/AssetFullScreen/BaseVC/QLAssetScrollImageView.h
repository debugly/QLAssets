//
//  QLAssetScrollImageView.h
//  HelloWorld
//
//  Created by xuqianlong on 15/6/16.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QLAssetScrollImageView : UICollectionViewCell

@property (nonatomic ,strong, readonly)UIImageView *imageView;
@property (nonatomic, copy) NSString *url;

- (void)updateImage:(UIImage *)img;
- (void)turnOffZoom;
- (void)unLoadImage;
- (void)handleDoubleTap:(UITapGestureRecognizer *)tap;

@end
