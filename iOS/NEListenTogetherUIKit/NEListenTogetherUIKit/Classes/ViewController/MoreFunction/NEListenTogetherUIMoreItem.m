// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIMoreItem.h"

@implementation NEListenTogetherUIMoreItem
+ (instancetype)itemWithTitle:(NSString *)title
                      onImage:(UIImage *)onImage
                     offImage:(UIImage *)offImage
                          tag:(NSInteger)tag {
  NEListenTogetherUIMoreItem *item = [[self alloc] init];
  item.title = title;
  item.onImage = onImage;
  item.offImage = offImage;
  item.tag = tag;
  return item;
}
- (instancetype)init {
  self = [super init];
  if (self) {
    self.on = YES;
  }
  return self;
}

- (UIImage *)currentImage {
  return self.on ? self.onImage : self.offImage;
}

- (NEListenTogetherUIMoreItem *_Nonnull (^)(BOOL))open {
  return ^NEListenTogetherUIMoreItem *(BOOL isOpen) {
    self.on = isOpen;
    return self;
  };
}
@end
