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

@property (nonatomic, strong) NSArray  *photoArr;
@property (nonatomic, strong) NSMutableArray  *modelArr;
@property (nonatomic, strong) NSMutableArray  *selModelArr;
@property (nonatomic, strong) UIView *toolBar;

@end

@implementation QLAssetsViewController

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
        self.photoArr = model.photoArr;
        
        _modelArr = [NSMutableArray array];
        _selModelArr = [NSMutableArray array];
        
        for (int i = 0 ; i < model.photoArr.count ;i ++) {
            ALAsset *result = model.photoArr[i];
            ALAssetRepresentation *representation = [result defaultRepresentation];
            QLAssetsModel *model = [QLAssetsModel new];
            model.url = representation.url;
            [_modelArr addObject:model];
        }
    }
    return self;
}

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
    [leftItem addTarget:self action:@selector(preLookPhotosAction) forControlEvents:UIControlEventTouchUpInside];

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
    [super updateViewConstraints];
        
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
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

- (UIBarButtonItem *)backBarButtonItem
{
    UIImage *indicatorImage = [UIImage imageNamed:kQLAssetFileName(@"navBackArrow")];
    indicatorImage = [indicatorImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithImage:indicatorImage style:UIBarButtonItemStylePlain target:self action:@selector(backViewControllerAction)];
    
    return item;
}

- (void)backViewControllerAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[QLAssetsCollectionViewCell class] forCellWithReuseIdentifier:kQLAssetsViewControllerInentifier];
    
    self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancleAction)];
    
    [self prepareToolBar];
    [self updateViewConstraints];
    [self updateToolBarItemStates];
    [self updateConutLabel];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self  readImage2Cache];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self  readImage2Cache];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    });
}

- (void)readImage2Cache
{
    for (ALAsset *result in self.photoArr) {
        UIImage *image = [[UIImage alloc]initWithCGImage:[result thumbnail]];
        NSString *url = [[[result defaultRepresentation]url]absoluteString];
        [[QLAssetsMemoryCache sharedMemoryCache]cacheImage:image forURL:url];
    }
}

- (void)cancleAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsViewControllerCancle:)]) {
        [self.delegate assetsViewControllerCancle:self];
    }
}

- (void)preLookPhotosAction
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

- (void)updateToolBarItemStates
{
    [[self.toolBar subviews]setValue:@(self.selModelArr.count > 0) forKeyPath:@"self.enabled"];
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
    QLAssetsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kQLAssetsViewControllerInentifier forIndexPath:indexPath];
    
    NSInteger item = indexPath.item;
    QLAssetsModel *model = self.modelArr[item];
    cell.model = model;
    cell.delegate = self;
    if (!cell.model.thumbnail) {
        ALAsset *result = self.photoArr[item];
        UIImage *image = [[UIImage alloc]initWithCGImage:[result thumbnail]];
        model.thumbnail = image;
        cell.model = model;
    }
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)clickedSelectItemAction:(QLAssetsCollectionViewCell *)sender
{
    QLAssetsModel *model = sender.model;
    bool needStatus = !model.isSelected;

    if (needStatus) {
        if(self.selModelArr.count >= self.maxCountCanSelect)
        {
            
        }else{
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

- (void)browerViewController:(QLAssetFullScreenSelectViewController *)vc finishedSelectPhotos:(NSArray *)models
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(assetsViewController:finishedSelectPhotos:)]) {
        [self.delegate assetsViewController:self finishedSelectPhotos:models];
    }
}

@end
