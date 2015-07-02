//
//  QLAssetScrollImageView.m
//  HelloWorld
//
//  Created by xuqianlong on 15/6/16.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLAssetScrollImageView.h"

@interface QLAssetScrollImageView ()<UIScrollViewDelegate>

@property (nonatomic ,strong)UIImageView  *imageView;
@property (nonatomic ,strong)UIScrollView *scrollView;

@end

@implementation QLAssetScrollImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        [self.contentView addSubview:_scrollView];
        _scrollView.backgroundColor = self.backgroundColor;
        _scrollView.bouncesZoom = YES;
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 0.5;
        _scrollView.maximumZoomScale = 5;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        //获取不到图片的大小，所以就把imageView设为全屏的；
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = self.backgroundColor;
        
        [_scrollView addSubview:_imageView];
    }
    return self;
}
- (BOOL)isZoomed
{
    return !([self.scrollView zoomScale] == 1);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [self.scrollView frame].size.height / scale;
    zoomRect.size.width  = [self.scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


- (void)zoomToLocation:(CGPoint)location
{
    float newScale;
    CGRect zoomRect;
    if ([self isZoomed]) {
        zoomRect = [self.scrollView bounds];
    } else {
        newScale = [self.scrollView maximumZoomScale];
        zoomRect = [self zoomRectForScale:newScale withCenter:location];
    }
    
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

- (void)turnOffZoom
{
    if ([self isZoomed]) {
//        [self fitImageViewSize];
                [self.scrollView setZoomScale:1 animated:YES];
//                [self zoomToLocation:CGPointZero];
    }
}

- (void)updateImage:(UIImage *)img
{
    self.imageView.image = img;
//    CGRect rect;
//    rect.origin = CGPointZero;
//    rect.size = [self.imageView sizeThatFits:self.scrollView.bounds.size];
//    self.imageView.frame = rect;
    
    [self.imageView setNeedsDisplay];
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap
{
    if(self.scrollView.minimumZoomScale == self.scrollView.maximumZoomScale) return;
    
    CGPoint touchPoint = [tap locationInView:self];
    if (self.scrollView.zoomScale >= self.scrollView.maximumZoomScale)
    {
        [self.scrollView setZoomScale:1 animated:YES];
    }
    else
    {
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.scrollView.bounds.size.width / newZoomScale;
        CGFloat ysize = self.scrollView.bounds.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self adjustScrollInsetsToCenterImage:YES];
}


- (void)setDownloadImageUrl:(NSString *)urlString
{
    
    self.imageView.image = [UIImage imageNamed:urlString];
    
    //    NSURL *url = [NSURL URLWithString:urlString];
    
    //    [self.imageView loadImageFromURLString:urlString];
    //    [self.imageView loadImageFromURL:url];
    [self fitImageViewSize];
}

- (void)unLoadImage
{
    self.imageView.image = nil;
}

- (void)fitImageViewSize
{
    [self.scrollView setZoomScale:1 animated:NO];
    CGSize imageSize = [self imageSizesizeThatFitsForImage:self.imageView.image];
    self.imageView.frame = CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.scrollView.contentSize = self.imageView.frame.size;
    [self adjustScrollInsetsToCenterImage:NO];
}

- (CGSize) imageSizesizeThatFitsForImage:(UIImage*) image {
    if (!image)
        return CGSizeZero;
    
    CGSize imageSize = image.size;
    CGFloat ratio = MIN(self.frame.size.width/imageSize.width, self.frame.size.height/imageSize.height);
    ratio = MIN(ratio, 1.0);//If the image is smaller than the screen let's not make it bigger
    return CGSizeMake(imageSize.width*ratio, imageSize.height*ratio);
}

- (void) adjustScrollInsetsToCenterImage:(BOOL)animation
{
    CGRect innerFrame = self.imageView.frame;
    CGRect scrollerBounds = self.bounds;
    CGPoint myScrollViewOffset = self.scrollView.contentOffset;
    
    if ( ( innerFrame.size.width < scrollerBounds.size.width ) || ( innerFrame.size.height < scrollerBounds.size.height ) )
    {
        CGFloat tempx = self.imageView.center.x - ( scrollerBounds.size.width / 2 );
        CGFloat tempy = self.imageView.center.y - ( scrollerBounds.size.height / 2 );
        myScrollViewOffset = CGPointMake( tempx, tempy);
    }
    
    UIEdgeInsets anEdgeInset = { 0, 0, 0, 0};
    if ( scrollerBounds.size.width > innerFrame.size.width )
    {
        anEdgeInset.left = (scrollerBounds.size.width - innerFrame.size.width) / 2;
        anEdgeInset.right = -anEdgeInset.left; // I don't know why this needs to be negative, but that's what works
    }
    if ( scrollerBounds.size.height > innerFrame.size.height )
    {
        anEdgeInset.top = (scrollerBounds.size.height - innerFrame.size.height) / 2;
        anEdgeInset.bottom = -anEdgeInset.top; // I don't know why this needs to be negative, but that's what works
    }
    
    [UIView animateWithDuration:animation?0.3:0 animations:^{
        self.scrollView.contentOffset = myScrollViewOffset;
        self.scrollView.contentInset = anEdgeInset;
    }];
    
}



@end
