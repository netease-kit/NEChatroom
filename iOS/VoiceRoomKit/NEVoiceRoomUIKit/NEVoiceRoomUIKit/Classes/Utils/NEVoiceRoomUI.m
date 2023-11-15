// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomUI.h"

@implementation NEVoiceRoomUI
+ (UIImage *)ne_voice_imageName:(NSString *)imageName {
  NSBundle *bundle = [NSBundle bundleForClass:self.class];
  if (@available(iOS 13.0, *)) {
    UIImage *image = [UIImage imageNamed:imageName inBundle:bundle withConfiguration:nil];
    return image;
  }
  return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
}
+ (NSBundle *_Nullable)ne_voice_sourceBundle {
  NSBundle *bundle = [NSBundle bundleForClass:self.class];
  return bundle;
}

/// 状态栏 高度
+ (CGFloat)ne_statusBarHeight {
  CGFloat statusBarHeight = 0.0;
  if (@available(iOS 13.0, *)) {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    statusBarHeight = window.windowScene.statusBarManager.statusBarFrame.size.height;
  } else {
    statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
  }
  return statusBarHeight;
}

/// 边距
+ (CGFloat)margin {
  return 30.0;
}
/// 麦位水平间距
+ (CGFloat)seatItemSpace {
  return 30.0;
}
/// 麦位垂直间距
+ (CGFloat)seatLineSpace {
  return 10.0;
}
@end
