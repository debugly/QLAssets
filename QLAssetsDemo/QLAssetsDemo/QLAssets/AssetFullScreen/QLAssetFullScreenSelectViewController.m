//
//  QLAssetFullScreenSelectViewController.m
//  HelloWorld
//
//  Created by xuqianlong on 15/6/16.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLAssetFullScreenSelectViewController.h"
#import "QLAssetsModel.h"

@interface QLAssetFullScreenSelectViewController ()<UIScrollViewDelegate>

@property (nonatomic, weak)   UIButton *itemBtn;
@property (nonatomic, strong) UIView *toolBar;

@end

@implementation QLAssetFullScreenSelectViewController

- (void)prepareNavItem
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:kQLAssetunSelectImageName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:kQLAssetSelectImageName] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(switchItemAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBounds:CGRectMake(0, 0, QLAssetFullScreenSelectViewControllerSwitchWidth, QLAssetFullScreenSelectViewControllerSwitchHeight)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    _itemBtn = btn;
}

- (UIView *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIView alloc]init];
        _toolBar.layer.borderColor = [[UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1]CGColor];
        _toolBar.layer.borderWidth = .5;
        _toolBar.backgroundColor = QLAssetsViewControllerToolBarBgColor;
        _toolBar.alpha = 0.7;
        _toolBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _toolBar;
}

- (void)prepareToolBar
{
    [self.view addSubview:self.toolBar];
    
    UIButton *rightItem = [UIButton buttonWithType:UIButtonTypeCustom];
    rightItem.translatesAutoresizingMaskIntoConstraints = NO;
    [rightItem setTitle:@"完成" forState:UIControlStateNormal];
    [rightItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightItem setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [rightItem.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [rightItem addTarget:self action:@selector(finishSelectPhotosAction) forControlEvents:UIControlEventTouchUpInside];
    [rightItem setEnabled:NO];
    rightItem.tag = 20000;
    [self.toolBar addSubview:rightItem];
    
    UILabel *contLb = [UILabel new];
    contLb.textColor = [UIColor greenColor];
    contLb.font = [UIFont systemFontOfSize:13];
    contLb.tag = 30000;
    
    [self.toolBar addSubview:contLb];
    contLb.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)updateToolBarItemStates
{
    [[self.toolBar subviews]setValue:@([self fetchSelectedImages].count > 0) forKeyPath:@"self.enabled"];
}

- (void)finishSelectPhotosAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(browerViewController:finishedSelectPhotos:)]) {
         NSArray *arr = [self fetchSelectedImages];
        [self.delegate browerViewController:self finishedSelectPhotos:arr];
    }
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:_toolBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:QLAssetsViewControllerToolBarHeight]];
    
    UIView *rightItem = [self.toolBar viewWithTag:20000];
    
    CGFloat ItemMargin = 14;
    
    [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:rightItem attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:rightItem attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:rightItem attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_toolBar attribute:NSLayoutAttributeRight multiplier:1 constant:-ItemMargin]];
    
    UIView *contLb = [self.toolBar viewWithTag:30000];
    
    [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:contLb attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:rightItem attribute:NSLayoutAttributeLeft multiplier:1 constant:-8]];
    
    [_toolBar addConstraint:[NSLayoutConstraint constraintWithItem:contLb attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:rightItem attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

}

- (void)prepareSubviews
{
    [self prepareNavItem];
    [self prepareToolBar];
}

- (void)updateConutLabel
{
    UILabel *contLb = (UILabel *) [self.toolBar viewWithTag:30000];
    [contLb setText:[NSString stringWithFormat:@"%zi/%zi",[self fetchSelectedImages].count,self.maxCountCanSelect]];
}

- (void)updateNavItem
{
    QLAssetsModel *model = [self fetchCurrentShowIdxModel];
    [self.itemBtn setSelected:model.isSelected];
}

- (void)scrollOtherPageNeedUpdateUI
{
    [super scrollOtherPageNeedUpdateUI];
    [self updateNavItem];
}

- (void)switchItemAction:(UIButton *)sender
{
    BOOL needStatus = !sender.isSelected;

    QLAssetsModel *model = [self fetchCurrentShowIdxModel];
    if (model) {
        if(needStatus && [self fetchSelectedImages].count >= self.maxCountCanSelect)
        {
            NSLog(@"tap max ");
        }else{
            [model setSelected:needStatus];
            [sender setSelected:needStatus];
        }
    }
    [self updateToolBarItemStates];
    [self updateConutLabel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self prepareSubviews];
    [self updateToolBarItemStates];
    [self updateViewConstraints];
    [self updateConutLabel];
    [self updateNavItem];
}

@end
