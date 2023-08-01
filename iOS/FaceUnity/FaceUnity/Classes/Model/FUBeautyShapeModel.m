// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUBeautyShapeModel.h"
#import "FUManager.h"

@implementation FUBeautyShapeModel

@synthesize moduleData = _moduleData;

#pragma mark - Override properties
- (FUModuleType)type {
  return FUModuleTypeBeautyShape;
}

- (NSString *)name {
  return FaceUnityLocalizedString(@"美型");
}

- (void)save {
  [NSUserDefaults.standardUserDefaults setObject:[self toJson] forKey:@"FUBeautyShapeModel"];
}

- (double)getValueForKey:(FUBeautyShapeItem)key array:(NSArray<NSDictionary *> *)array {
  for (NSDictionary *dic in array) {
    if ([((NSNumber *)[dic valueForKey:@"type"]) unsignedIntegerValue] == key) {
      return [[dic valueForKey:@"value"] doubleValue];
    }
  }
  // 没有存就用默认值
  switch (key) {
    case FUBeautyShapeItemCheekThinning: return 0.0;
    case FUBeautyShapeItemCheekV: return 0.5;
    case FUBeautyShapeItemCheekNarrow: return 0.0;
    case FUBeautyShapeItemCheekShort: return 0.0;
    case FUBeautyShapeItemCheekSmall: return 0.0;
    case FUBeautyShapeItemCheekBones: return 0.0;
    case FUBeautyShapeItemLowerJaw: return 0.0;
    case FUBeautyShapeItemEyeEnlarging: return 0.4;
    case FUBeautyShapeItemEyeCircle: return 0.0;
    case FUBeautyShapeItemChin: return 0.3;
    case FUBeautyShapeItemForehead: return 0.3;
    case FUBeautyShapeItemNose: return 0.5;
    case FUBeautyShapeItemMouth: return 0.4;
    case FUBeautyShapeItemCanthus: return 0.0;
    case FUBeautyShapeItemEyeSpace: return 0.5;
    case FUBeautyShapeItemEyeRotate: return 0.5;
    case FUBeautyShapeItemLongNose: return 0.5;
    case FUBeautyShapeItemPhiltrum: return 0.5;
    case FUBeautyShapeItemSmile: return 0.0;
    case FUBeautyShapeItemBrowHeight: return 0.5;
    case FUBeautyShapeItemBrowSpace: return 0.5;
    case FUBeautyShapeItemMax: return 0.0;
  }
}

- (NSArray<FUSubModel *> *)moduleData {
  if (!_moduleData) {
    NSArray<NSDictionary *> *array = [NSUserDefaults.standardUserDefaults objectForKey:@"FUBeautyShapeModel"];
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < FUBeautyShapeItemMax; i++) {
      FUSubModel *model = [[FUSubModel alloc] init];
      model.functionType = i;
      model.currentValue = [self getValueForKey:i array:array];
      switch (i) {
        case FUBeautyShapeItemCheekThinning:{
          model.title = FaceUnityLocalizedString(@"瘦脸");
          model.imageName = @"瘦脸";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemCheekV:{
          model.title = FaceUnityLocalizedString(@"v脸");
          model.imageName = @"v脸";
          model.defaultValue = 0.5;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemCheekNarrow:{
          model.title = FaceUnityLocalizedString(@"窄脸");
          model.imageName = @"窄脸";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemCheekShort:{
          model.title = FaceUnityLocalizedString(@"短脸");
          model.imageName = @"短脸";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemCheekSmall:{
          model.title = FaceUnityLocalizedString(@"小脸");
          model.imageName = @"小脸";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemCheekBones:{
          model.title = FaceUnityLocalizedString(@"瘦颧骨");
          model.imageName = @"瘦颧骨";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemLowerJaw:{
          model.title = FaceUnityLocalizedString(@"瘦下颌骨");
          model.imageName = @"瘦下颌骨";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemEyeEnlarging:{
          model.title = FaceUnityLocalizedString(@"大眼");
          model.imageName = @"大眼";
          model.defaultValue = 0.4;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemEyeCircle:{
          model.title = FaceUnityLocalizedString(@"圆眼");
          model.imageName = @"圆眼";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemChin:{
          model.title = FaceUnityLocalizedString(@"下巴");
          model.imageName = @"下巴";
          model.defaultValue = 0.3;
          model.ratio = 1.0;
          model.isBidirection = YES;
        }
          break;
        case FUBeautyShapeItemForehead:{
          model.title = FaceUnityLocalizedString(@"额头");
          model.imageName = @"额头";
          model.defaultValue = 0.3;
          model.ratio = 1.0;
          model.isBidirection = YES;
        }
          break;
        case FUBeautyShapeItemNose:{
          model.title = FaceUnityLocalizedString(@"瘦鼻");
          model.imageName = @"瘦鼻";
          model.defaultValue = 0.5;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemMouth:{
          model.title = FaceUnityLocalizedString(@"嘴型");
          model.imageName = @"嘴型";
          model.defaultValue = 0.4;
          model.ratio = 1.0;
          model.isBidirection = YES;
        }
          break;
        case FUBeautyShapeItemCanthus:{
          model.title = FaceUnityLocalizedString(@"开眼角");
          model.imageName = @"开眼角";
          model.defaultValue = 0.0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemEyeSpace:{
          model.title = FaceUnityLocalizedString(@"眼距");
          model.imageName = @"眼距";
          model.defaultValue = 0.5;
          model.ratio = 1.0;
          model.isBidirection = YES;
        }
          break;
        case FUBeautyShapeItemEyeRotate:{
          model.title = FaceUnityLocalizedString(@"眼睛角度");
          model.imageName = @"眼睛角度";
          model.defaultValue = 0.5;
          model.ratio = 1.0;
          model.isBidirection = YES;
        }
          break;
        case FUBeautyShapeItemLongNose:{
          model.title = FaceUnityLocalizedString(@"长鼻");
          model.imageName = @"长鼻";
          model.defaultValue = 0.5;
          model.ratio = 1.0;
          model.isBidirection = YES;
        }
          break;
        case FUBeautyShapeItemPhiltrum:{
          model.title = FaceUnityLocalizedString(@"缩人中");
          model.imageName = @"缩人中";
          model.defaultValue = 0.5;
          model.ratio = 1.0;
          model.isBidirection = YES;
        }
          break;
        case FUBeautyShapeItemSmile:{
          model.title = FaceUnityLocalizedString(@"微笑嘴角");
          model.imageName = @"微笑嘴角";
          model.defaultValue = 0;
          model.ratio = 1.0;
        }
          break;
        case FUBeautyShapeItemBrowHeight:{
          model.title = FaceUnityLocalizedString(@"眉毛上下");
          model.imageName = @"眉毛上下";
          model.defaultValue = 0.5;
          model.ratio = 1.0;
          model.isBidirection = YES;
          // 低性能手机禁用眉毛上下
          model.disabled = [FUManager shareManager].devicePerformanceLevel != FUDevicePerformanceLevelHigh;
        }
          break;
        case FUBeautyShapeItemBrowSpace:{
          model.title = FaceUnityLocalizedString(@"眉间距");
          model.imageName = @"眉间距";
          model.defaultValue = 0.5;
          model.ratio = 1.0;
          model.isBidirection = YES;
          // 低性能手机禁用眉间距
          model.disabled = [FUManager shareManager].devicePerformanceLevel != FUDevicePerformanceLevelHigh;
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
