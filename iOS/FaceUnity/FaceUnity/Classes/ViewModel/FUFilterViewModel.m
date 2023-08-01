// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUFilterViewModel.h"
#import "FUFilterModel.h"

@interface FUFilterViewModel ()

@property (nonatomic, strong) FUBeauty *beauty;

@end


@implementation FUFilterViewModel

- (instancetype)initWithSelectedIndex:(NSInteger)selectedIndex needSlider:(BOOL)isNeedSlider {
  self = [super initWithSelectedIndex:selectedIndex needSlider:isNeedSlider];
  if (self) {
    self.model = [[FUFilterModel alloc] init];
    if ([FURenderKit shareRenderKit].beauty) {
      self.beauty = [FURenderKit shareRenderKit].beauty;
    } else {
      NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification" ofType:@"bundle"];
      self.beauty = [[FUBeauty alloc] initWithPath:path name:@"FUBeauty"];
      self.beauty.heavyBlur = 0;
      self.beauty.blurType = 3;
      self.beauty.faceShape = 4;
    }
    
    // 默认滤镜
    NSInteger index = selectedIndex;
    for (NSInteger i = 0; i < self.model.moduleData.count; i ++) {
      if (self.model.moduleData[i].isSelected) {
        index = i;
        self.selectedIndex = i;
        break;
      }
    }
    [self updateData:self.model.moduleData[index]];
  }
  return self;
}

#pragma mark - Override methods
- (void)startRender {
  [super startRender];
  if (![FURenderKit shareRenderKit].beauty) {
    [FURenderKit shareRenderKit].beauty = self.beauty;
  }
  if (![FURenderKit shareRenderKit].beauty.enable) {
    [FURenderKit shareRenderKit].beauty.enable = YES;
  }
}

- (void)stopRender {
  [super stopRender];
  [FURenderKit shareRenderKit].beauty.enable = NO;
  [FURenderKit shareRenderKit].beauty = nil;
}

- (void)updateData:(FUSubModel *)subModel {
  if (!subModel) {
    NSLog(@"FaceUnity：滤镜数据为空");
    return;
  }
  for (FUSubModel *sub in self.model.moduleData) {
    sub.isSelected = false;
  }
  subModel.isSelected = true;
  self.beauty.filterName = [self convertFilter:subModel.functionType];
  self.beauty.filterLevel = subModel.currentValue;
  [self.model save];
}

- (void)recover {
  self.selectedIndex = 1;
  for (FUSubModel *sub in self.model.moduleData) {
    sub.isSelected = false;
  }
  self.model.moduleData[self.selectedIndex].isSelected = true;
  self.beauty.filterName = [self convertFilter:self.model.moduleData[self.selectedIndex].functionType];
  self.beauty.filterLevel = self.model.moduleData[self.selectedIndex].currentValue;
  [self.model save];
}

- (FUFilter)convertFilter:(FUBeautyFilterItem)item {
  switch (item) {
      /// 原图
    case FUBeautyFilterItemNone: return FUFilterOrigin;
      /// 自然
    case FUBeautyFilterItemNatural1: return FUFilterZiRan1;
    case FUBeautyFilterItemNatural2: return FUFilterZiRan2;
      /// 质感灰
    case FUBeautyFilterItemTextureGrey1: return FUFilterZhiGanHui1;
    case FUBeautyFilterItemTextureGrey2: return FUFilterZhiGanHui2;
      /// 蜜桃
    case FUBeautyFilterItemNectarina1: return FUFilterMiTao1;
    case FUBeautyFilterItemNectarina2: return FUFilterMiTao2;
      /// 白亮
    case FUBeautyFilterItemBright1: return FUFilterBaiLiang1;
    case FUBeautyFilterItemBright2: return FUFilterBaiLiang2;
      /// 粉嫩
    case FUBeautyFilterItemPink1: return FUFilterFenNen1;
    case FUBeautyFilterItemPink2: return FUFilterFenNen2;
      /// 冷色调
    case FUBeautyFilterItemColdTone1: return FUFilterLengSeDiao1;
    case FUBeautyFilterItemColdTone2: return FUFilterLengSeDiao2;
      /// 暖色调
    case FUBeautyFilterItemWarmTone1: return FUFilterNuanSeDiao1;
    case FUBeautyFilterItemWarmTone2: return FUFilterNuanSeDiao2;
      /// 个性
    case FUBeautyFilterItemPersonal1: return FUFilterGeXing1;
    case FUBeautyFilterItemPersonal2: return FUFilterGeXing2;
      /// 小清新
    case FUBeautyFilterItemFresh1: return FUFilterXiaoQingXin1;
    case FUBeautyFilterItemFresh2: return FUFilterXiaoQingXin3;
      /// 黑白
    case FUBeautyFilterItemblackAndWhite1: return FUFilterHeiBai1;
    case FUBeautyFilterItemblackAndWhite2: return FUFilterHeiBai2;
      
    case FUBeautyFilterItemMax: return FUFilterOrigin;
  }
}

@end
