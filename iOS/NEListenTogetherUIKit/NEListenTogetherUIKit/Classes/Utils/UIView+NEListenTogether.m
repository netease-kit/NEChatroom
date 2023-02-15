// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "UIView+NEListenTogether.h"

@implementation UIView (NEListenTogetherVoiceRoom)

- (void)cutViewRounded:(UIRectCorner)roundingCorners cornerRadii:(CGSize)cornerRadii {
  UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                 byRoundingCorners:roundingCorners
                                                       cornerRadii:cornerRadii];
  CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
  // 设置大小
  maskLayer.frame = self.bounds;
  // 设置图形样子
  maskLayer.path = maskPath.CGPath;
  self.layer.mask = maskLayer;
}

@end
