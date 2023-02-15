// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "UIImage+VoiceRoom.h"

#import "NEVoiceRoomUI.h"

@implementation UIImage (VoiceRoom)

+ (UIImage *)nevoiceRoom_imageNamed:(NSString *)name {
  return [NEVoiceRoomUI ne_imageName:name];

  NSString *path = [[NSBundle mainBundle]
      pathForResource:@"Frameworks/NEVoiceRoomUIKit.framework/NEVoiceRoomUIKit"
               ofType:@"bundle"];
  NSBundle *bundle = [NSBundle bundleWithPath:path];
  if (!bundle) {
    bundle = [NSBundle mainBundle];
  }
  return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
