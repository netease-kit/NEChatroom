// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUOthersFunctionView.h"

#import "FUViewModel.h"

static NSString * const kFUOthersCellIdentifierKey = @"FUBeautyCellIdentifier";

@interface FUOthersFunctionView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation FUOthersFunctionView

#pragma mark - Initializer
- (instancetype)initWithFrame:(CGRect)frame viewModel:(FUViewModel *)viewModel {
  self = [super initWithFrame:frame viewModel:viewModel];
  if (self) {
    [self configureUI];
  }
  return self;
}

#pragma mark - UI
- (void)configureUI {
  [self addSubview:self.collectionView];
  NSLayoutConstraint *collectionLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
  NSLayoutConstraint *collectionTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
  NSLayoutConstraint *collectionBottomConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
  NSLayoutConstraint *collectionHeightConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:98];
  [self addConstraints:@[collectionLeadingConstraint, collectionTrailingConstraint, collectionBottomConstraint]];
  [self.collectionView addConstraint:collectionHeightConstraint];
  
  if (self.viewModel.model.moduleData.count > 0 && self.viewModel.selectedIndex >= 0) {
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.viewModel.selectedIndex inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
  }
  
}

#pragma mark - Collection view data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return self.viewModel.model.moduleData.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  FUOthersFunctionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFUOthersCellIdentifierKey forIndexPath:indexPath];
  FUSubModel *model = self.viewModel.model.moduleData[indexPath.item];
  cell.fuTitleLabel.text = model.title;
  cell.fuImageView.image = [UIImage imageNamed:model.imageName inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
  return cell;
}

#pragma mark - Collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.item == self.viewModel.selectedIndex) {
    return;
  }
  if (self.viewModel.isNeedSlider) {
    if (indexPath.item == 0) {
      if (!self.slider.hidden) {
        // 隐藏Slider
        self.slider.hidden = YES;
        self.frame = CGRectMake(0, CGRectGetMinY(self.frame) + FUFunctionSliderHeight, CGRectGetWidth(self.frame), FUFunctionViewHeight);
      }
    } else {
      // 选择时更新Slider状态
      if (self.slider.hidden) {
        // 显示Slider
        self.frame = CGRectMake(0, CGRectGetMinY(self.frame) - FUFunctionSliderHeight, CGRectGetWidth(self.frame), FUFunctionViewHeight + FUFunctionSliderHeight);
        self.slider.hidden = NO;
      }
      FUSubModel *subModel = self.viewModel.model.moduleData[indexPath.item];
      self.slider.value = subModel.currentValue / subModel.ratio;
    }
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(functionView:didSelectFunctionAtIndex:)]) {
    [self.delegate functionView:self didSelectFunctionAtIndex:indexPath.item];
  }
}

#pragma mark - Collection view delegate flow layout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  return CGSizeMake(54, 74);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
  return UIEdgeInsetsMake(16, 18, 6, 18) ;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
  return 16.f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
  return 16.f;
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
    [_collectionView registerClass:[FUOthersFunctionCell class] forCellWithReuseIdentifier:kFUOthersCellIdentifierKey];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return _collectionView;
}

@end

@implementation FUOthersFunctionCell

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.fuImageView.layer.masksToBounds = YES;
    self.fuImageView.layer.cornerRadius = 3;
  }
  return self;
}

#pragma mark - Setters
- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  self.fuImageView.layer.borderWidth = selected ? 2 : 0;
  self.fuImageView.layer.borderColor = selected ? [UIColor colorWithRed:94/255.f green:199/255.f blue:254/255.f alpha:1].CGColor : [UIColor clearColor].CGColor;
  self.fuTitleLabel.textColor = selected ? [UIColor colorWithRed:94/255.f green:199/255.f blue:254/255.f alpha:1] : [UIColor whiteColor];
}

@end
