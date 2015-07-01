//
//  QLAssetFullScreenBaseViewController.m
//  PengBei
//
//  Created by xuqianlong on 15/6/23.
//  Copyright (c) 2015年 夕阳栗子. All rights reserved.
//

#import "QLAssetFullScreenBaseViewController.h"
#import "QLAssetsModel.h"
#import "QLAssetScrollImageView.h"
#import "QLAssetManager.h"
#import "QLAssetsMemoryCache.h"

NSString *const QLAssetFullScreenSelectViewControllerIdentifier = @"QLAssetFullScreenSelectViewControllerIdentifier";

@interface QLAssetFullScreenBaseViewController ()

@property (nonatomic, strong) NSMutableArray  *modelArr;
@property (nonatomic, copy)   QLAssetManagerFinishBlock finishBlcok;
@property (nonatomic, strong) UITapGestureRecognizer *doubleGesture;

@end

@implementation QLAssetFullScreenBaseViewController

- (instancetype)initWithQLAssetsModels:(NSArray *)modelArr beforeBackRevokeSelBlock:(QLAssetManagerFinishBlock)finiBlock
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = QLAssetFullScreenSelectViewControllerPageMargin;
    CGSize size = [UIScreen mainScreen].bounds.size;
    size.width -= QLAssetFullScreenSelectViewControllerPageMargin;
    layout.itemSize = size;
    layout.sectionInset = UIEdgeInsetsMake(0,QLAssetFullScreenSelectViewControllerPageMargin,0,QLAssetFullScreenSelectViewControllerPageMargin);
    
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.modelArr = [NSMutableArray arrayWithArray:modelArr];
        self.finishBlcok = finiBlock;
    }
    return self;
}

- (NSUInteger)totalCount
{
    return self.modelArr.count;
}

- (UIBarButtonItem *)preparebackItem
{
    UIImage *indicatorImage = [UIImage imageNamed:kQLAssetFileName(@"navBackArrow")];
    indicatorImage = [indicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:indicatorImage style:UIBarButtonItemStylePlain target:self action:@selector(backViewControllerAction)];
    
    return item;
}

- (NSArray *)fetchSelectedImages
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.isSelected != %@",@(NO)];
    return [self.modelArr filteredArrayUsingPredicate:predicate];
}

- (void)backViewControllerAction
{
    if (self.finishBlcok) {
        NSArray *arr = [self fetchSelectedImages];
        self.finishBlcok(arr);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doubleClickAction:(UITapGestureRecognizer *)sender
{
    if ([self isVaildIndex:_currentShowIndex]) {
        QLAssetScrollImageView *imgView = (QLAssetScrollImageView *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_currentShowIndex inSection:0]];
        [imgView handleDoubleTap:sender];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _modelArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    QLAssetScrollImageView *cell = [collectionView dequeueReusableCellWithReuseIdentifier:QLAssetFullScreenSelectViewControllerIdentifier forIndexPath:indexPath];
    
    if (![self isVaildIndex:self.currentShowIndex]) {
        self.currentShowIndex = 0;
    }
    [cell turnOffZoom];
    [self cell:cell loadImageForQLAssertScrollImageView:indexPath.item];
    
    return cell;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat currentOffset = scrollView.contentOffset.x + width/2;
    NSInteger idx = ceil(currentOffset/width)-1;
    if (idx != _currentShowIndex) {
        bool flag = idx > _currentShowIndex;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if (flag) {
                //            往左滑动；卸载左侧的，加载右侧的；
                [self clearCacheForIdx:_currentShowIndex - 3];
                [self fetchImage2CacheForIdx:_currentShowIndex + 3];
            }else{
                [self clearCacheForIdx:_currentShowIndex + 3];
                [self fetchImage2CacheForIdx:_currentShowIndex - 3];
            }
        });
        _currentShowIndex = idx;
        [self scrollOtherPageNeedUpdateUI];
    }
}

- (void)scrollOtherPageNeedUpdateUI
{
   [self updateTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self  fetch5Image2Cache];
    });
}

- (void)fetch5Image2Cache
{
    NSUInteger begin = _currentShowIndex - 2;
    NSUInteger end = (_currentShowIndex + 2 < self.totalCount)?(_currentShowIndex + 2):self.totalCount;
    
    for (; begin < end; begin ++) {
        [self fetchImage2CacheForIdx:begin];
    }
}

- (void)fetchImage2CacheForIdx:(NSUInteger)idx
{
    if([self isVaildIndex:idx]){
        QLAssetsModel *model = [self.modelArr objectAtIndex:idx];
        [QLAssetManager fetchFullsreenImagewithURL:model.url resultBlcok:^(UIImage *image) {
            [[QLAssetsMemoryCache sharedMemoryCache]cacheImage:image forURL:[[model.url absoluteString]stringByAppendingString:@"big" ]];
        }];
    }
}

- (void)clearCacheForIdx:(NSUInteger)idx
{
    if ([self isVaildIndex:idx]) {
        QLAssetsModel *model = [self.modelArr objectAtIndex:idx];
        [[QLAssetsMemoryCache sharedMemoryCache]removeImageForURL:[[model.url absoluteString]stringByAppendingString:@"big"]];
    }
}

- (void)cell:(QLAssetScrollImageView *)cell loadImageForQLAssertScrollImageView:(NSUInteger)idx
{
    QLAssetsModel *model = [self.modelArr objectAtIndex:idx];
    __weak QLAssetScrollImageView *imgView = cell;
    
    UIImage *image = [[QLAssetsMemoryCache sharedMemoryCache]imageFromMemoryCacheForURL:[[model.url absoluteString]stringByAppendingString:@"big"]];
    if (image) {
        [imgView updateImage:image];
    }else{
        [imgView updateImage:model.thumbnail];
        
        [QLAssetManager fetchFullsreenImagewithURL:model.url resultBlcok:^(UIImage *image) {
            [[QLAssetsMemoryCache sharedMemoryCache]cacheImage:image forURL:[[model.url absoluteString]stringByAppendingString:@"big" ]];
            if (imgView) {
                if (image) {
                    [imgView updateImage:image];
                }else{
                    [imgView updateImage:nil];
                }
            }
        }];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [self  fetch5Image2Cache];
    });
    
    self.view.backgroundColor = [UIColor blackColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.collectionView.bounces = NO;
    
    [self.collectionView registerClass:[QLAssetScrollImageView class] forCellWithReuseIdentifier:QLAssetFullScreenSelectViewControllerIdentifier];
    
    _doubleGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleClickAction:)];
    _doubleGesture.numberOfTapsRequired = 2;
    [self.collectionView addGestureRecognizer:_doubleGesture];
    
    self.navigationItem.leftBarButtonItem = [self preparebackItem];
    
    [self updateTitle];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentShowIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (BOOL)isVaildIndex:(NSInteger)idx
{
    return idx >= 0 && idx < self.totalCount;
}

- (QLAssetsModel *)fetchCurrentShowIdxModel
{
    if ([self isVaildIndex:self.currentShowIndex]) {
        return self.modelArr[self.currentShowIndex];
    }
    return nil;
}

- (void)updateTitle
{
    self.title = [NSString stringWithFormat:@"%zi/%zi",_currentShowIndex + 1,self.totalCount];
}

@end
