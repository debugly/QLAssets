//
//  QLAssetsGroupViewController.m
//  HelloWorld
//
//  Created by xuqianlong on 15/6/15.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLAssetsGroupViewController.h"
#import "QLAssetsGroupModel.h"
#import "QLAssetsGroupCell.h"
#import "QLAssetsViewController.h"
#import "QLAssetsMemoryCache.h"
#import "QLAssetsModel.h"
#import "QLAssetManager.h"

NSString *const kQLAssetsGroupCellIdentifier = @"kQLAssetsGroupCellIdentifier";

@interface QLAssetsGroupViewController ()<QLAssetsViewControllerDelegate>

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *groupArr;
@property (nonatomic, copy) QLAssetManagerFinishBlock finishBlcok;

@end

@implementation QLAssetsGroupViewController

- (id)initWithManagerFinishBlock:(QLAssetManagerFinishBlock)block
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.title = @"照片";
        self.finishBlcok = block;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    [self.tableView registerClass:[QLAssetsGroupCell class] forCellReuseIdentifier:kQLAssetsGroupCellIdentifier];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancleAction)];

    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self  readAssetsGroup];
    });
    
}

- (void)prepareNoAccessView
{
    UILabel *lb = [[UILabel alloc]initWithFrame:CGRectZero];
    NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    if(!bundleName)bundleName = @"";
    lb.text = [NSString stringWithFormat:@"\n\n\n请在%@的“设置－隐私－照片”选项中，\n允许%@访问你的相册",[[UIDevice currentDevice]model],bundleName];
    lb.font = [UIFont systemFontOfSize:13];
    lb.textColor = [UIColor lightGrayColor];
    lb.textAlignment = NSTextAlignmentCenter;
    lb.numberOfLines = 0;
    [lb sizeToFit];
    self.tableView.tableHeaderView = lb;
}

- (void)cancleAction
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (ALAssetsLibrary *)assetsLibrary
{
    if (!_assetsLibrary) {
        _assetsLibrary = [[ALAssetsLibrary alloc]init];
    }
    return _assetsLibrary;
}

- (void)readAssetsGroup
{
    _groupArr = [[NSMutableArray alloc]initWithCapacity:3];
    
    switch ([ALAssetsLibrary authorizationStatus]) {
        case ALAuthorizationStatusDenied:
        {
            //        拒绝；
            dispatch_async(dispatch_get_main_queue(), ^{
                [self prepareNoAccessView];
            });
        }
            break;
        case ALAuthorizationStatusNotDetermined:
        {
            NSLog(@"Not Determined");//第一次是这个；
        }
        case ALAuthorizationStatusAuthorized:
        {
            //        授权；
            NSLog(@"Already Determined");
        }
        case ALAuthorizationStatusRestricted:
        {
            NSLog(@"Restricted");
        }
        default:
        {
            [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                if (group && group.numberOfAssets > 0) {
                    QLAssetsGroupModel *gModel = [QLAssetsGroupModel new];
                    gModel.groupName = [group valueForProperty:ALAssetsGroupPropertyName];
                    gModel.posterImage = [UIImage imageWithCGImage:[group posterImage]];
                    
                    @autoreleasepool {
                        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                        NSMutableArray *assetArr = [[NSMutableArray alloc]initWithCapacity:10];
                        
                        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                            if (!result) {
                                NSLog(@"--system is keng! Bacause it is nil--");
                            }else if (result && [result isKindOfClass:[ALAsset class]])
                            {
                                [assetArr addObject:result];
                            }
                            if (index + 1 == group.numberOfAssets) {
                                gModel.photoArr = [NSArray arrayWithArray:assetArr];
                            }
                        }];
                    }
                    [self.groupArr addObject:gModel];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.tableView reloadData];
                    });
                    [self readImage2Cache];
                }
            } failureBlock:^(NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self prepareNoAccessView];
                });
                //        NSLog(@"failure");ALAuthorizationStatusNotDetermined决绝的时候就失败了；
            }];

        }
    }
}

- (void)readImage2Cache
{
    for (QLAssetsGroupModel *gModel in self.groupArr) {
        NSUInteger maxLoop = gModel.photoArr.count < 30 ? gModel.photoArr.count:30;
        
        for (NSUInteger i = 0; i < maxLoop ; i ++) {
            ALAsset *result = gModel.photoArr[i];
            UIImage *image = [[UIImage alloc]initWithCGImage:[result thumbnail]];
            NSString *url = [[[result defaultRepresentation]url]absoluteString];
            [[QLAssetsMemoryCache sharedMemoryCache]cacheImage:image forURL:url];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groupArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kQLAssetsGroupCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QLAssetsGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:kQLAssetsGroupCellIdentifier forIndexPath:indexPath];

    cell.model = self.groupArr[indexPath.row];
    
    // 确保cell的约束被更新，因为它可能刚刚才被创建好,或者被拿来重用了。
    // 使用下面两行代码，前提是假设你已经在cell的updateConstraints方法中设置好了约束：
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.groupArr.count) {
        QLAssetsGroupModel *model = self.groupArr[indexPath.row];
        QLAssetsViewController *vc = [[QLAssetsViewController alloc]initWithGroupModel:model];
        vc.delegate = self;
        vc.maxCountCanSelect = self.maxCountCanSelect;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)assetsViewControllerCancle:(QLAssetsViewController *)vc
{
    [self cancleAction];
}

- (void)assetsViewController:(QLAssetsViewController *)vc finishedSelectPhotos:(NSArray *)models
{
    if(models && self.finishBlcok)
    {
        self.finishBlcok(models);
        [self cancleAction];
    }
}

@end
