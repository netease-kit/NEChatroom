// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUFilterModel.h"

@implementation FUFilterModel

@synthesize moduleData = _moduleData;

#pragma mark - Override properties
- (FUModuleType)type {
  return FUModuleTypeFilter;
}

- (NSString *)name {
  return FaceUnityLocalizedString(@"滤镜");
}

- (double)getValueForKey:(FUBeautyFilterItem)key array:(NSArray<NSDictionary *> *)array {
  for (NSDictionary *dic in array) {
    if ([((NSNumber *)[dic valueForKey:@"type"]) unsignedIntegerValue] == key) {
      return [[dic valueForKey:@"value"] doubleValue];
    }
  }
  // 没有存就用默认值
  return 0.4;
}

- (BOOL)getSelectedForKey:(FUBeautyFilterItem)key array:(NSArray<NSDictionary *> *)array {
  for (NSDictionary *dic in array) {
    if ([((NSNumber *)[dic valueForKey:@"type"]) unsignedIntegerValue] == key) {
      return [[dic valueForKey:@"isSelected"] boolValue];
    }
  }
  // 没有存就用默认值
  return key == FUBeautyFilterItemNatural1;
}

- (void)save {
  [NSUserDefaults.standardUserDefaults setObject:[self toJson] forKey:@"FUFilterModel"];
}

- (NSArray<FUSubModel *> *)moduleData {
  if (!_moduleData) {
    NSArray *params = @[
      @{@"origin" : @"原图"},
      @{@"demo_icon_natural_1" : @"自然1"},
      @{@"demo_icon_natural_2" : @"自然2"},
      @{@"demo_icon_texture_gray1" : @"质感灰1"},
      @{@"demo_icon_texture_gray2" : @"质感灰2"},
      @{@"demo_icon_peach1" : @"蜜桃1"},
      @{@"demo_icon_peach2" : @"蜜桃2"},
      @{@"demo_icon_bailiang1" : @"白亮1"},
      @{@"demo_icon_bailiang2" : @"白亮2"},
      @{@"demo_icon_fennen1" : @"粉嫩1"},
      @{@"demo_icon_fennen2" : @"粉嫩2"},
      @{@"demo_icon_lengsediao1" : @"冷色调1"},
      @{@"demo_icon_lengsediao2" : @"冷色调2"},
      @{@"demo_icon_nuansediao1" : @"暖色调1"},
      @{@"demo_icon_nuansediao2" : @"暖色调2"},
      @{@"demo_icon_gexing1" : @"个性1"},
      @{@"demo_icon_gexing2" : @"个性2"},
      @{@"demo_icon_xiaoqingxin1" : @"小清新1"},
      @{@"demo_icon_xiaoqingxin2" : @"小清新2"},
      @{@"demo_icon_heibai1" : @"黑白1"},
      @{@"demo_icon_heibai2" : @"黑白2"},
    ];
    NSArray<NSDictionary *> *array = [NSUserDefaults.standardUserDefaults objectForKey:@"FUFilterModel"];
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < FUBeautyFilterItemMax; i++) {
      NSDictionary *param = params[i];
      FUSubModel *model = [[FUSubModel alloc] init];
      model.functionType = i;
      model.currentValue = [self getValueForKey:i array:array];
      model.imageName = param.allKeys[0];
      model.title = FaceUnityLocalizedString(param.allValues[0]);
      model.defaultValue = 0.4;
      model.isSelected = [self getSelectedForKey:i array:array];
      [models addObject:model];
    }
    _moduleData = [models copy];
  }
  return _moduleData;
}

@end
