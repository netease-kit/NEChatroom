// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "UIImage+ListenTogether.h"

#import "NEListenTogetherUI.h"

@implementation UIImage (ListenTogether)

+ (UIImage *)voiceRoom_imageNamed:(NSString *)name {
  return [NEListenTogetherUI ne_listen_imageName:name];

  NSString *path = [[NSBundle mainBundle]
      pathForResource:@"Frameworks/NEListenTogetherUIKit.framework/NEListenTogetherUIKit"
               ofType:@"bundle"];
  NSBundle *bundle = [NSBundle bundleWithPath:path];
  if (!bundle) {
    bundle = [NSBundle mainBundle];
  }
  return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
}

@end
