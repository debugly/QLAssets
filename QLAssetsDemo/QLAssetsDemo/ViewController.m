//
//  ViewController.m
//  QLAssetsDemo
//
//  Created by xuqianlong on 15/7/1.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "QLAssetManager.h"
#import "QLAssetsModel.h"

@interface ViewController ()<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.sectionInset = UIEdgeInsetsMake(20, 0, 20, 0);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    
    _dataSource = [[NSMutableArray alloc]initWithCapacity:3];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (self.dataSource.count < 9)?(self.dataSource.count + 1):self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellID" forIndexPath:indexPath];
    if (indexPath.item == self.dataSource.count) {
        cell.backgroundColor = [UIColor greenColor];
        cell.imageView.image = nil;
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        QLAssetsModel *model = self.dataSource[indexPath.item];
        cell.imageView.image = model.selThumbnail;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((collectionView.bounds.size.width - 41)/3, 120);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item < self.dataSource.count) {
        [QLAssetManager showAssetFullScreenBrowerView:self.navigationController presentAnimation:YES currentShowIndex:indexPath.item assetsModels:self.dataSource finishSelBlock:^(NSArray *selArr) {
            [self.dataSource removeAllObjects];
            [self.dataSource addObjectsFromArray:selArr];
            [self.collectionView reloadData];
        }];
    }else{
        [QLAssetManager showAssetGroupViewOnViewController:self presentAnimation:YES maxCountCanSelect:9 - self.dataSource.count finishSelBlock:^(NSArray *selArr) {
            [self.dataSource addObjectsFromArray:selArr];
            [self.collectionView reloadData];
        }];
    }
}

@end
