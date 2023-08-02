// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUBeautyFunctionView.h"
#import "FUSquareButton.h"
#import "FUTipHUD.h"

#import "FUViewModel.h"

static NSString * const kFUBeautyCellIdentifierKey = @"FUBeautyCellIdentifier";

@interface FUBeautyFunctionView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

/// 恢复按钮
@property (nonatomic, strong) FUSquareButton *recoverButton;

@end

@implementation FUBeautyFunctionView

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame viewModel:(FUViewModel *)viewModel {
  self = [super initWithFrame:frame viewModel:viewModel];
  if (self) {
    [self configureUI];
    
    [self refreshSubviews];
  }
  return self;
}

#pragma mark - UI
- (void)configureUI {
  [self addSubview:self.recoverButton];
  
  NSLayoutConstraint *recoverLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.recoverButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:17];
  NSLayoutConstraint *recoverBottomConstraint = [NSLayoutConstraint constraintWithItem:self.recoverButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:-19];
  NSLayoutConstraint *recoverWidthConstraint = [NSLayoutConstraint constraintWithItem:self.recoverButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:44];
  NSLayoutConstraint *recoverHeightConstraint = [NSLayoutConstraint constraintWithItem:self.recoverButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:60];
  
  [self addConstraints:@[recoverLeadingConstraint, recoverBottomConstraint]];
  [self.recoverButton addConstraints:@[recoverWidthConstraint, recoverHeightConstraint]];
  
  // 分割线
  UIView *verticalLine = [[UIView alloc] init];
  verticalLine.backgroundColor = [UIColor colorWithRed:229/255.f green:229/255.f blue:229/255.f alpha:0.2];
  verticalLine.translatesAutoresizingMaskIntoConstraints = NO;
  [self addSubview:verticalLine];
  NSLayoutConstraint *lineLeadingConstraint = [NSLayoutConstraint constraintWithItem:verticalLine attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.recoverButton attribute:NSLayoutAttributeTrailing multiplier:1 constant:14];
  NSLayoutConstraint *lineCenterYConstraint = [NSLayoutConstraint constraintWithItem:verticalLine attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.recoverButton attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
  NSLayoutConstraint *lineWidthConstraint = [NSLayoutConstraint constraintWithItem:verticalLine attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:1];
  NSLayoutConstraint *lineHeightConstraint = [NSLayoutConstraint constraintWithItem:verticalLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:24];
  [self addConstraints:@[lineLeadingConstraint, lineCenterYConstraint]];
  [verticalLine addConstraints:@[lineWidthConstraint, lineHeightConstraint]];
  
  [self addSubview:self.collectionView];
  NSLayoutConstraint *collectionLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:76];
  NSLayoutConstraint *collectionTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
  NSLayoutConstraint *collectionBottomConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
  NSLayoutConstraint *collectionHeightConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:98];
  [self addConstraints:@[collectionLeadingConstraint, collectionTrailingConstraint, collectionBottomConstraint]];
  [self.collectionView addConstraint:collectionHeightConstraint];
}

#pragma mark - Instance methods
- (void)refreshSubviews {
  [super refreshSubviews];
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.viewModel.isDefaultValue) {
      self.recoverButton.alpha = 0.6;
      self.recoverButton.userInteractionEnabled = NO;
    } else {
      self.recoverButton.alpha = 1;
      self.recoverButton.userInteractionEnabled = YES;
    }
    [self.collectionView reloadData];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.viewModel.selectedIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
  });
}

#pragma mark - Event response
- (void)recoverAction {
  if (self.delegate && [self.delegate respondsToSelector:@selector(functionViewDidClickRecover:)]) {
    [self.delegate functionViewDidClickRecover:self];
  }
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.viewModel.model.moduleData.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  FUBeautyFunctionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFUBeautyCellIdentifierKey forIndexPath:indexPath];
  FUSubModel *subModel = self.viewModel.model.moduleData[indexPath.item];
  cell.subModel = subModel;
  cell.fuTitleLabel.text = subModel.title;
  cell.selected = indexPath.item == self.viewModel.selectedIndex;
  return cell;
}

#pragma mark - Collection view delegate
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  FUSubModel *subModel = self.viewModel.model.moduleData[indexPath.item];
  if (subModel.disabled) {
    NSString *tipString = [NSString stringWithFormat:NSLocalizedString(@"该功能只支持在高端机使用", nil), NSLocalizedString(subModel.title, nil)];
    [FUTipHUD showTips:tipString dismissWithDelay:1];
    return NO;
  }
  return YES;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.item == self.viewModel.selectedIndex) {
    return;
  }
  
  // 手动取消选中之前的cell
  FUBeautyFunctionCell *oldCell = (FUBeautyFunctionCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.viewModel.selectedIndex inSection:0]];
  if (oldCell.selected) {
    oldCell.selected = NO;
  }
  
  // 选择时更新Slider状态
  if (self.slider.hidden) {
    // 显示Slider
    self.frame = CGRectMake(0, CGRectGetMinY(self.frame) - FUFunctionSliderHeight, CGRectGetWidth(self.frame), FUFunctionViewHeight + FUFunctionSliderHeight);
    self.slider.hidden = NO;
  }
  FUSubModel *subModel = self.viewModel.model.moduleData[indexPath.item];
  self.slider.bidirection = subModel.isBidirection;
  self.slider.value = subModel.currentValue / subModel.ratio;
  if (self.delegate && [self.delegate respondsToSelector:@selector(functionView:didSelectFunctionAtIndex:)]) {
    [self.delegate functionView:self didSelectFunctionAtIndex:indexPath.item];
  }
}

#pragma mark - Collection view delegate flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(44, 74);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  return UIEdgeInsetsMake(16, 16, 6, 16) ;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  return 22.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  return 22.f;
}

#pragma mark - Getters
- (UICollectionView *)collectionView {
  if (!_collectionView) {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [_collectionView registerClass:[FUBeautyFunctionCell class] forCellWithReuseIdentifier:kFUBeautyCellIdentifierKey];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _collectionView;
}

- (FUSquareButton *)recoverButton {
  if (!_recoverButton) {
    _recoverButton = [[FUSquareButton alloc] initWithFrame:CGRectMake(0, 0, 44, 60)];
    [_recoverButton setTitle:FaceUnityLocalizedString(@"恢复") forState:UIControlStateNormal];
    [_recoverButton setImage:[UIImage imageNamed:@"recover" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    _recoverButton.alpha = 0.6;
    _recoverButton.userInteractionEnabled = NO;
    [_recoverButton addTarget:self action:@selector(recoverAction) forControlEvents:UIControlEventTouchUpInside];
    _recoverButton.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _recoverButton;
}

@end


@implementation FUBeautyFunctionCell

#pragma mark - Setters
- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  if (self.subModel.disabled) {
    self.fuImageView.image = [UIImage imageNamed:[self.subModel.imageName stringByAppendingString:@"-0"] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    self.fuImageView.alpha = 0.7;
    self.fuTitleLabel.alpha = 0.7;
  } else {
    BOOL changed = NO;
    if (self.subModel.isBidirection) {
      changed = fabs(self.subModel.currentValue - 0.5) > 0.01;
    }else{
      changed = self.subModel.currentValue > 0.01;
    }
    if (selected) {
      self.fuImageView.image = changed ? [UIImage imageNamed:[NSString stringWithFormat:@"%@-3", self.subModel.imageName] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] : [UIImage imageNamed:[NSString stringWithFormat:@"%@-2", self.subModel.imageName] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
      self.fuTitleLabel.textColor = [UIColor colorWithRed:94/255.f green:199/255.f blue:254/255.f alpha:1];
    } else {
      self.fuImageView.image = changed ? [UIImage imageNamed:[NSString stringWithFormat:@"%@-1", self.subModel.imageName] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] : [UIImage imageNamed:[NSString stringWithFormat:@"%@-0", self.subModel.imageName] inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
      self.fuTitleLabel.textColor = [UIColor whiteColor];
    }
  }
}

@end
