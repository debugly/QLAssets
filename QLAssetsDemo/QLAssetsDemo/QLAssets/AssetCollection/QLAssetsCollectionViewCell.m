//
//  QLAssetsCollectionViewCell.m
//  HelloWorld
//
//  Created by xuqianlong on 15/6/16.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLAssetsCollectionViewCell.h"
#import "QLAssetsModel.h"
#import "QLAssetsCommonHeader.h"
#import "QLAssetsMemoryCache.h"

@interface QLAssetsCollectionViewCell ()

@property (nonatomic, assign) bool didSetupConstraint;
@property (nonatomic, strong) UIButton *selBtn;
@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation QLAssetsCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (QLAssetsCollectionViewCellCornerRadius > 0) {
            self.contentView.layer.masksToBounds = YES;
            self.contentView.layer.cornerRadius = QLAssetsCollectionViewCellCornerRadius;
        }
        [self prepareSubviews];
    }
    return self;
}

- (void)prepareSubviews
{
    _imgView = [UIImageView new];
    _imgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_imgView];
    
    _selBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _selBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_selBtn];
    
    [_selBtn setBackgroundImage:[UIImage imageNamed:kQLAssetunSelectImageName] forState:UIControlStateNormal];
    [_selBtn setBackgroundImage:[UIImage imageNamed:kQLAssetSelectImageName] forState:UIControlStateSelected];
    
}

- (void)updateConstraints
{
    if (!_didSetupConstraint) {
        _didSetupConstraint = YES;
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_imgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_imgView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_imgView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];

        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_imgView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_selBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1 constant:QLAssetsCollectionViewCellSelBtnTopMarin]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_selBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:-QLAssetsCollectionViewCellSelBtnRightMarin]];
        
        [_selBtn addConstraint:[NSLayoutConstraint constraintWithItem:_selBtn attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:QLAssetsCollectionViewCellSelBtnWith]];
        
        [_selBtn addConstraint:[NSLayoutConstraint constraintWithItem:_selBtn attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:QLAssetsCollectionViewCellSelBtnHeight]];
        
        [_selBtn addTarget:self action:@selector(clickedSelectBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    [super updateConstraints];
}

- (void)setModel:(QLAssetsModel *)model
{
    if(_model != model){
        _model = model;
        self.imgView.image = model.thumbnail;;
        [self.selBtn setSelected:model.isSelected];
    }
}

- (void)clickedSelectBtn:(UIButton *)sender
{    
    if (_delegate && [_delegate respondsToSelector:@selector(clickedSelectItemAction:)]) {
        [_delegate clickedSelectItemAction:self];
    }
    bool isSel = self.model.isSelected;
    [self.selBtn setSelected:isSel];
}

@end
