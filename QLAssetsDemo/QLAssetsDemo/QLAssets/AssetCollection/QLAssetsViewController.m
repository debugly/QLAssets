//
//  QLAssetsViewController.m
//  HelloWorld
//
//  Created by xuqianlong on 15/6/15.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLAssetsViewController.h"
#import "QLAssetsGroupModel.h"
#import "QLAssetsCollectionViewCell.h"
#import "QLAssetsModel.h"
#import "QLAssetFullScreenSelectViewController.h"
#import "QLAssetsCommonHeader.h"
#import "QLAssetsMemoryCache.h"

NSString *const kQLAssetsViewControllerInentifier = @"kQLAssetsViewControllerInentifier";

@interface QLAssetsViewController ()<QLAssetsCollectionViewCellDelegate,QLAssetFullScreenSelectViewControllerDelegate>
{
    BOOL didSetupConstraints;
}

@property (nonatomic, strong) NSMutableArray  *modelArr;
@property (nonatomic, strong) NSMutableArray  *selModelArr;
@property (nonatomic, strong) UIView *toolBar;
@property (nonatomic, strong) QLAssetsGroupModel *groupModel;
@property (nonatomic, strong) NSLayoutConstraint *toolBarBottonConstraint;
@end

@implementation QLAssetsViewController

//cache images
- (void)readImage2CachewithRevokeCount:(NSUInteger)count
{
    count = (count > self.groupModel.photoArr.count)?self.groupModel.photoArr.count:count;
    
    for (int i = 0; i < count; i ++) {
        ALAsset *result = self.groupModel.photoArr[i];
        NSString *url = [[[result defaultRepresentation]url]absoluteString];
        //        检查分组页面有没有缓存；如果没有缓存就读取缓存起来
        UIImage *image = [[QLAssetsMemoryCache sharedMemoryCache]imageFromMemoryCacheForURL:url];
        if(!image){
            image = [[UIImage alloc]initWithCGImage:[result thumbnail]];
            [[QLAssetsMemoryCache sharedMemoryCache]cacheImage:image forURL:url];
        }
        QLAssetsModel *model = self.modelArr[i];
        //        model并没有持有，只是使用，受到内存警告的时候就是nil；
        model.thumbnail = image;
    }
}

- (instancetype)initWithGroupModel:(QLAssetsGroupModel *)model
{
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width;
    
    UICollectionViewFlowLayout  *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = QLAssetsViewControllerItemSpacing;
    layout.minimumInteritemSpacing = QLAssetsViewControllerItemSpacing;
    CGFloat w = (maxWidth - (QLAssetsViewControllerColumns+1) * QLAssetsViewControllerItemSpacing) / QLAssetsViewControllerColumns;
    layout.itemSize = CGSizeMake(w, w);
    layout.sectionInset = UIEdgeInsetsMake(QLAssetsViewControllerItemSpacing, QLAssetsViewControllerItemSpacing ,QLAssetsViewControllerItemSpacing + QLAssetsViewControllerToolBarHeight,QLAssetsViewControllerItemSpacing);
    
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        self.title = model.groupName;
        self.groupModel = model;
        _selModelArr = [NSMutableArray array];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableArray *modelArr = [NSMutableArray array];
            for (int i = 0 ; i < model.photoArr.count ;i ++) {
                ALAsset *result = model.photoArr[i];
                ALAssetRepresentation *representation = [result defaultRepresentation];
                QLAssetsModel *model = [QLAssetsModel new];
                model.url = representation.url;
                [modelArr addObject:model];
            }
            self.modelArr = modelArr;
            if (self.isViewLoaded) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
            }
            [self readImage2CachewithRevokeCount:35];
        });
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[QLAssetsCollectionViewCell class] forCellWithReuseIdentifier:kQLAssetsViewControllerInentifier];
    self.navigationItem.hidesBackButton = YES;
    [self prepareToolBar];
    [self updateViewConstraints];
    [self updateToolBarItemStates];
    [self updateConutLabel];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationItem setLeftBarButtonItem:[self backBarButtonItem] animated:YES];
    [self.navigationItem setRightBarButtonItem:[self rightBarButtonItem] animated:YES];
    self.toolBarBottonConstraint.constant = 0;
    
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
    [UIView setAnimationDuration:0.35];
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - UI(toolBar) / Constraints

- (UIView *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIView alloc]init];
        _toolBar.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]CGColor];
        _toolBar.layer.borderWidth = .5;
        _toolBar.backgroundColor = QLAssetsViewControllerToolBarBgColor;
        _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _toolBar;
}

- (void)prepareToolBar
{
    [self.view addSubview:self.toolBar];
    
    UIButton *leftItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftItem setTitle:@"预览" forState:UIControlStateNormal];
    [leftItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftItem setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [leftItem.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [leftItem addTarget:self action:@selector(previewPhotosAction) forControlEvents:UIControlEventTouchUpInside];

    leftItem.tag = 10000;
    [self.toolBar addSubview:leftItem];

    UIButton *rightItem = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightItem setTitle:@"完成" forState:UIControlStateNormal];
    [rightItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightItem setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [rightItem.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rightItem addTarget:self action:@selector(finishSelectPhotosAction) forControlEvents:UIControlEventTouchUpInside];

    rightItem.tag = 20000;
    [self.toolBar addSubview:rightItem];
    
    leftItem.translatesAutoresizingMaskIntoConstraints = NO;
    rightItem.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *contLb = [UILabel new];
    contLb.textColor = [UIColor greenColor];
    contLb.font = [UIFont systemFontOfSize:13];
    contLb.tag = 30000;
    
    [self.toolBar addSubview:contLb];
    contLb.translatesAutoresizingMaskIntoConstraints = NO;
    
}

- (void)updateViewConstraints
{
    if (!didSetupConstraints) {
        didSetupConstraints = YES;
        self.toolBarBottonConstraint = [NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:QLAssetsViewControllerToolBarHeight];
        self.toolBarBottonConstraint.priority = UILayoutPriorityDefaultHigh;
        [self.view addConstraint:self.toolBarBottonConstraint];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:QLAssetsViewControllerToolBarHeight]];
        
        UIView *leftItem = [self.toolBar viewWithTag:10000];
        UIView *rightItem = [self.toolBar viewWithTag:20000];
        
        CGFloat ItemMargin = 14;
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:leftItem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:leftItem attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:leftItem attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeLeft multiplier:1 constant:ItemMargin]];
        
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:rightItem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:rightItem attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:rightItem attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeRight multiplier:1 constant:-ItemMargin]];
        
        UIView *contLb = [self.toolBar viewWithTag:30000];
        
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:contLb attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:rightItem attribute:NSLayoutAttributeLeft multiplier:1 constant:-8]];
        
        [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:contLb attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:rightItem attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }
    [super updateViewConstraints];
}

- (UIBarButtonItem *)backBarButtonItem
{
    UIImage *indicatorImage = [UIImage imageNamed:kQLAssetFileName(@"navBackArrow")];
    indicatorImage = [indicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:indicatorImage style:UIBarButtonItemStylePlain target:self action:@selector(backViewControllerAction)];
    
    return item;
}

- (UIBarButtonItem *)rightBarButtonItem
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancleAction)];
    return item;
}

#pragma mark - actions(back,cancle,finish,preview)

- (void)backViewControllerAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancleAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsViewControllerCancle:)]) {
        [self.delegate assetsViewControllerCancle:self];
    }
}

- (void)previewPhotosAction
{
    __weak __typeof(self)weakSelf = self;
    QLAssetFullScreenSelectViewController *fullVC = [[QLAssetFullScreenSelectViewController alloc]initWithQLAssetsModels:self.selModelArr beforeBackRevokeSelBlock:^(NSArray *selArr) {
         [weakSelf updateSelecemodelArr:selArr];
    }];
    fullVC.delegate = self;
    fullVC.maxCountCanSelect = self.maxCountCanSelect;
    [self.navigationController pushViewController:fullVC animated:YES];
}

- (void)finishSelectPhotosAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsViewController:finishedSelectPhotos:)]) {
        [self.delegate assetsViewController:self finishedSelectPhotos:self.selModelArr];
    }
}

#pragma mark - collection (dataSource/delegate)
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
    QLAssetsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQLAssetsViewControllerInentifier forIndexPath:indexPath];
    
    NSInteger item = indexPath.item;
    QLAssetsModel *model = self.modelArr[item];
    cell.delegate = self;
    
    if (!model.thumbnail) {
        //        检查分组页面有没有缓存；如果没有缓存就读取缓存起来
        UIImage *image = [[QLAssetsMemoryCache sharedMemoryCache]imageFromMemoryCacheForURL:[model.url absoluteString]];
        if (!image){
            ALAsset *result = self.groupModel.photoArr[item];
            NSString *url = [model.url absoluteString];
            image = [[UIImage alloc]initWithCGImage:[result thumbnail]];
            [[QLAssetsMemoryCache sharedMemoryCache]cacheImage:image forURL:url];
        }
        //        model并没有持有，只是使用，受到内存警告的时候就是nil；
        model.thumbnail = image;
    }
    cell.model = model;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak __typeof(self)weakSelf = self;
    QLAssetFullScreenSelectViewController *fullVC = [[QLAssetFullScreenSelectViewController alloc]initWithQLAssetsModels:self.modelArr beforeBackRevokeSelBlock:^(NSArray *selArr) {
        [weakSelf updateSelecemodelArr:selArr];
    }];
    fullVC.delegate = self;
    fullVC.currentShowIndex = indexPath.item;
    fullVC.maxCountCanSelect = self.maxCountCanSelect;
    [self.navigationController pushViewController:fullVC animated:YES];
}

#pragma mark - QLAssetsCollectionViewCell (delegate)
- (void)clickedSelectItemAction:(QLAssetsCollectionViewCell *)sender
{
    QLAssetsModel *model = sender.model;
    bool needStatus = !model.isSelected;
    
    if (needStatus) {
        if(self.selModelArr.count < self.maxCountCanSelect)
        {
            [model setSelected:needStatus];
            [self.selModelArr addObject:model];
        }
    }else{
        [model setSelected:needStatus];
        [self.selModelArr removeObject:model];
    }
    
    [self updateToolBarItemStates];
    [self updateConutLabel];
    
}

#pragma mark - QLAssetFullScreenSelectViewController(delegate)
- (void)browerViewController:(QLAssetFullScreenSelectViewController *)vc finishedSelectPhotos:(NSArray *)models
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsViewController:finishedSelectPhotos:)]) {
        [self.delegate assetsViewController:self finishedSelectPhotos:models];
    }
}

#pragma mark - update States
- (void)updateConutLabel
{
    UILabel *contLb = (UILabel *) [self.toolBar viewWithTag:30000];
    [contLb setText:[NSString stringWithFormat:@"%zi/%zi",self.selModelArr.count,self.maxCountCanSelect]];
}

- (void)updateSelecemodelArr:(NSArray *)selArr
{
    self.selModelArr = [NSMutableArray arrayWithArray:selArr];
    [self.collectionView reloadData];
    [self updateToolBarItemStates];
    [self updateConutLabel];
}

- (void)updateToolBarItemStates
{
    [[self.toolBar subviews]setValue:@(self.selModelArr.count > 0) forKeyPath:@"self.enabled"];
}

@end
