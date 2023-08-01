// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUBeautySkinModel.h"

@implementation FUBeautySkinModel

@synthesize moduleData = _moduleData;

#pragma mark - Override properties
- (FUModuleType)type {
  return FUModuleTypeBeautySkin;
}

- (NSString *)name {
  return FaceUnityLocalizedString(@"美肤");
}

- (void)save {
  [NSUserDefaults.standardUserDefaults setObject:[self toJson] forKey:@"FUBeautySkinModel"];
}

- (double)getValueForKey:(FUBeautySkinItem)key array:(NSArray<NSDictionary *> *)array {
  for (NSDictionary *dic in array) {
    if ([((NSNumber *)[dic valueForKey:@"type"]) unsignedIntegerValue] == key) {
      return [[dic valueForKey:@"value"] doubleValue];
    }
  }
  // 没有存就用默认值
  switch (key) {
    case FUBeautySkinItemFineSmooth: return 4.2;
    case FUBeautySkinItemWhiten: return 0.3;
    case FUBeautySkinItemRuddy: return 0.3;
    case FUBeautySkinItemSharpen: return 0.2;
    case FUBeautySkinItemEyeBrighten: return 0.0;
    case FUBeautySkinItemToothWhiten: return 0.0;
    case FUBeautySkinItemCircles: return 0.0;
    case FUBeautySkinItemWrinkles: return 0.0;
    case FUBeautySkinItemMax: return 0.0;
  }
}

- (NSArray<FUSubModel *> *)moduleData {
  if (!_moduleData) {
    NSArray<NSDictionary *> *array = [NSUserDefaults.standardUserDefaults objectForKey:@"FUBeautySkinModel"];
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < FUBeautySkinItemMax; i++) {
      FUSubModel *model = [[FUSubModel alloc] init];
      model.functionType = i;
      model.currentValue = [self getValueForKey:i array:array];
      switch (i) {
        case FUBeautySkinItemFineSmooth:{
          model.title = FaceUnityLocalizedString(@"精细磨皮");
          model.imageName = @"精细磨皮";
          model.defaultValue = 4.2;
          model.ratio = 6.0;
        }
          break;
        case FUBeautySkinItemWhiten:{
          model.title = FaceUnityLocalizedString(@"美白");
          model.imageName = @"美白";
          model.defaultValue = 0.3;
          model.ratio = 1.0;
        }
          break;
        case FUBeautySkinItemRuddy:{
          model.title = FaceUnityLocalizedString(@"红润");
          model.imageName = @"红润";
          model.defaultValue = 0.3;
          model.ratio = 1.0;
        }
          break;
        case FUBeautySkinItemSharpen:{
          model.title = FaceUnityLocalizedString(@"锐化");
          model.imageName = @"锐化";
          model.defaultValue = 0.2;
          model.ratio = 1.0;
        }
          break;
        case FUBeautySkinItemEyeBrighten:{
          model.title = FaceUnityLocalizedString(@"亮眼");
          model.imageName = @"亮眼";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautySkinItemToothWhiten:{
          model.title = FaceUnityLocalizedString(@"美牙");
          model.imageName = @"美牙";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautySkinItemCircles:{
          model.title = FaceUnityLocalizedString(@"去黑眼圈");
          model.imageName = @"去黑眼圈";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautySkinItemWrinkles:{
          model.title = FaceUnityLocalizedString(@"去法令纹");
          model.imageName = @"去法令纹";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
      }
      [models addObject:model];
    }
    _moduleData = [models copy];
  }
  
  return _moduleData;
}


@end
