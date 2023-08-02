// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUBeautySkinViewModel.h"
#import "FUBeautySkinModel.h"

@interface FUBeautySkinViewModel ()

@property (nonatomic, strong) FUBeauty *beauty;

@end

@implementation FUBeautySkinViewModel

- (instancetype)initWithSelectedIndex:(NSInteger)selectedIndex needSlider:(BOOL)isNeedSlider {
  self = [super initWithSelectedIndex:selectedIndex needSlider:isNeedSlider];
  if (self) {
    self.model = [[FUBeautySkinModel alloc] init];
    if ([FURenderKit shareRenderKit].beauty) {
      self.beauty = [FURenderKit shareRenderKit].beauty;
    } else {
      NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification" ofType:@"bundle"];
      self.beauty = [[FUBeauty alloc] initWithPath:path name:@"FUBeauty"];
      self.beauty.heavyBlur = 0;
      self.beauty.blurType = 3;
      self.beauty.faceShape = 4;
    }
    
    // 默认美肤
    for (FUSubModel *subModel in self.model.moduleData) {
      [self updateData:subModel];
    }
  }
  return self;
}

#pragma mark - Override
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
    NSLog(@"FaceUnity：美肤数据为空");
    return;
  }
  switch (subModel.functionType) {
    case FUBeautySkinItemFineSmooth:
      self.beauty.blurLevel = subModel.currentValue;
      break;
    case FUBeautySkinItemWhiten:
      self.beauty.colorLevel = subModel.currentValue;
      break;
    case FUBeautySkinItemRuddy:
      self.beauty.redLevel = subModel.currentValue;
      break;
    case FUBeautySkinItemSharpen:
      self.beauty.sharpen = subModel.currentValue;
      break;
    case FUBeautySkinItemEyeBrighten:
      self.beauty.eyeBright = subModel.currentValue;
      break;
    case FUBeautySkinItemToothWhiten:
      self.beauty.toothWhiten = subModel.currentValue;
      break;
    case FUBeautySkinItemCircles:
      self.beauty.removePouchStrength = subModel.currentValue;
      break;
    case FUBeautySkinItemWrinkles:
      self.beauty.removeNasolabialFoldsStrength = subModel.currentValue;
      break;
    default:
      break;
  }
  [self.model save];
}

- (void)recover {
  for (FUSubModel *subModel in self.model.moduleData) {
    subModel.currentValue = subModel.defaultValue;
    [self updateData:subModel];
  }
}

- (BOOL)isDefaultValue {
  for (FUSubModel *subModel in self.model.moduleData) {
    int currentIntValue = subModel.isBidirection ? (int)(subModel.currentValue / subModel.ratio * 100 - 50) : (int)(subModel.currentValue / subModel.ratio * 100);
    int defaultIntValue = subModel.isBidirection ? (int)(subModel.defaultValue / subModel.ratio * 100 - 50) : (int)(subModel.defaultValue / subModel.ratio * 100);
    if (currentIntValue != defaultIntValue) {
      return NO;
    }
  }
  return YES;
}

@end
