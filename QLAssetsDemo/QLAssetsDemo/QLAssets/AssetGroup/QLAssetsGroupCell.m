//
//  QLAssetsGroupCell.m
//  HelloWorld
//
//  Created by xuqianlong on 15/6/16.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "QLAssetsGroupCell.h"
#import "QLAssetsGroupModel.h"
#import "QLAssetsCommonHeader.h"

@interface QLAssetsGroupCell ()

@property (nonatomic, strong) UIImageView *posterImgView;
@property (nonatomic, strong) UILabel *groupNameLb;
@property (nonatomic, strong) UILabel *totalPhotoLb;
@property (nonatomic, strong) UIView  *line;
@property (nonatomic, assign) bool didSetupConstraint;

@end

@implementation QLAssetsGroupCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self prepareSubviews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)prepareSubviews
{
    _posterImgView = [[UIImageView alloc]init];
    _posterImgView.translatesAutoresizingMaskIntoConstraints = NO;
    _posterImgView.contentMode = UIViewContentModeScaleAspectFill;
    _posterImgView.layer.cornerRadius = 4;
    _posterImgView.layer.masksToBounds = YES;
    
    [self.contentView addSubview:_posterImgView];
    
    _groupNameLb = [[UILabel alloc]init];
    _groupNameLb.translatesAutoresizingMaskIntoConstraints = NO;
    _groupNameLb.font = [UIFont boldSystemFontOfSize:14];
    [self.contentView addSubview:_groupNameLb];
    
    _totalPhotoLb = [[UILabel alloc]init];
    _totalPhotoLb.translatesAutoresizingMaskIntoConstraints = NO;
    _totalPhotoLb.font = [UIFont systemFontOfSize:12];
    _totalPhotoLb.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:_totalPhotoLb];
    
    _line = [[UIView alloc]init];
    _line.translatesAutoresizingMaskIntoConstraints = NO;
    _line.backgroundColor = [UIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1];
    [self.contentView addSubview:_line];
}

- (void)updateConstraints
{
    if (!_didSetupConstraint) {
        _didSetupConstraint = YES;
        
        //        [_posterImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.top.equalTo(@0);
        //        }];
        //        [_posterImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.centerY.equalTo(self.contentView.mas_centerY);
        //        }];
        //
        //        [_posterImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.width.and.height.equalTo(@(kQLAssetsGroupCellHeight));
        //        }];
        
        
        //        layout constraint add 2 super
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_posterImgView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1 constant:(kQLAssetsGroupCellHeight-kQLAssetsGroupCellImgWidth)/2.0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_posterImgView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        //        size constraint add 2 self
        [_posterImgView addConstraint:[NSLayoutConstraint constraintWithItem:_posterImgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kQLAssetsGroupCellImgHeight]];
        
        [_posterImgView addConstraint:[NSLayoutConstraint constraintWithItem:_posterImgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kQLAssetsGroupCellImgWidth]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_groupNameLb attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_posterImgView attribute:NSLayoutAttributeRight multiplier:1 constant:10]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_groupNameLb attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_totalPhotoLb attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_groupNameLb attribute:NSLayoutAttributeRight multiplier:1 constant:5]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_totalPhotoLb attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_line attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_groupNameLb attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_line attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        
        [_line addConstraint:[NSLayoutConstraint constraintWithItem:_line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:.5]];
        
    }
    [super updateConstraints];
}

- (void)setModel:(QLAssetsGroupModel *)model
{
    if (_model != model) {
        _model = model;
        _posterImgView.image = model.posterImage;
        _groupNameLb.text = model.groupName;
        _totalPhotoLb.text = [NSString stringWithFormat:@"(%zi)",model.photoArr.count];
    }
}

@end
