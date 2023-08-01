// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "FUModel.h"

@implementation FUSubModel

- (instancetype)init {
  self = [super init];
  if (self) {
    _isBidirection = NO;
    _ratio = 1.0;
  }
  return self;
}

- (NSDictionary *)toJson {
  return @{@"value": @(_currentValue), @"type": @(_functionType), @"isSelected": @(_isSelected)};
}

@end

@implementation FUModel

- (NSString *)tip {
  return FaceUnityLocalizedString(@"未检测到人脸");
}

- (NSArray<NSDictionary *> *)toJson {
  NSMutableArray *array = [NSMutableArray array];
  for (FUSubModel *model in self.moduleData) {
    [array addObject:model.toJson];
  }
  return array;
}

- (void)save {
  
}

@end


