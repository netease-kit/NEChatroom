// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomDraggableButton.h"
#import "NEVoiceRoomUI.h"

#define NEVoiceRoom_ScreenH [UIScreen mainScreen].bounds.size.height
#define NEVoiceRoom_ScreenW [UIScreen mainScreen].bounds.size.width

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface NEVoiceRoomDraggableButton ()

@property(nonatomic, assign) CGPoint touchStartPosition;

@end

@implementation NEVoiceRoomDraggableButton

typedef NS_ENUM(NSInteger, NEVoiceRoom_FloatWindowDirection) {
  NEVoiceRoom_FloatWindowLEFT,
  NEVoiceRoom_FloatWindowRIGHT,
  NEVoiceRoom_FloatWindowTOP,
  NEVoiceRoom_FloatWindowBOTTOM
};

typedef NS_ENUM(NSInteger, NEVoiceRoom_ScreenChangeOrientation) {
  NEVoiceRoom_Change2Origin,
  NEVoiceRoom_Change2Upside,
  NEVoiceRoom_Change2Left,
  NEVoiceRoom_Change2Right
};

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
  UITouch *touch = [touches anyObject];
  self.touchStartPosition = [touch locationInView:_rootView];
  if (IS_IPHONE) self.touchStartPosition = [self ConvertDir:_touchStartPosition];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint curPoint = [touch locationInView:_rootView];
  if (IS_IPHONE) curPoint = [self ConvertDir:curPoint];
  self.superview.center = curPoint;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  [self touchesEnded:touches withEvent:event];
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint curPoint = [touch locationInView:_rootView];
  if (IS_IPHONE) curPoint = [self ConvertDir:curPoint];
  // if the start touch point is too close to the end point, take it as the click event and notify
  // the click delegate
  if (pow((_touchStartPosition.x - curPoint.x), 2) + pow((_touchStartPosition.y - curPoint.y), 2) <
      1) {
    [self.buttonDelegate dragButtonClicked:self];
    return;
  }
  [self buttonAutoAdjust:curPoint];
}

- (void)buttonAutoAdjust:(CGPoint)curPoint {
  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
  CGFloat W = NEVoiceRoom_ScreenW;
  CGFloat H = NEVoiceRoom_ScreenH;
  // (1,2->3,4 | 3,4->1,2)
  NSInteger judge = orientation + _initOrientation;
  if (IS_IPHONE && orientation != _initOrientation && judge != 3 && judge != 7) {
    W = NEVoiceRoom_ScreenH;
    H = NEVoiceRoom_ScreenW;
  }
  // distances to the four screen edges
  CGFloat left = curPoint.x;
  CGFloat right = IS_IPHONE ? (W - curPoint.x) : (NEVoiceRoom_ScreenW - curPoint.x);
  //  CGFloat top = curPoint.y;
  //  CGFloat bottom = IS_IPHONE ? (H - curPoint.y) : (NEVoiceRoom_ScreenH - curPoint.y);
  // find the direction to go
  NEVoiceRoom_FloatWindowDirection minDir = NEVoiceRoom_FloatWindowLEFT;
  //    CGFloat minDistance = left;
  if (right < left) {
    //    minDistance = right;
    minDir = NEVoiceRoom_FloatWindowRIGHT;
  }
  /// 不做上下贴边，只做左右
  //    if (top < minDistance) {
  //        minDistance = top;
  //        minDir = NEVoiceRoom_FloatWindowTOP;
  //    }
  //    if (bottom < minDistance) {
  //        minDir = NEVoiceRoom_FloatWindowBOTTOM;
  //    }

  switch (minDir) {
    case NEVoiceRoom_FloatWindowLEFT: {
      [UIView animateWithDuration:0.3
                       animations:^{
                         self.superview.center = CGPointMake(
                             self.superview.frame.size.width / 2,
                             (self.superview.center.y <= self.superview.frame.size.height / 2)
                                 ? (self.superview.frame.size.height / 2)
                             : self.superview.center.y > (H - self.superview.frame.size.height / 2)
                                 ? (H - self.superview.frame.size.height / 2)
                                 : self.superview.center.y);
                       }];
      break;
    }
    case NEVoiceRoom_FloatWindowRIGHT: {
      [UIView animateWithDuration:0.3
                       animations:^{
                         self.superview.center = CGPointMake(
                             W - self.superview.frame.size.width / 2,
                             (self.superview.center.y <= self.superview.frame.size.height / 2)
                                 ? (self.superview.frame.size.height / 2)
                             : self.superview.center.y > (H - self.superview.frame.size.height / 2)
                                 ? (H - self.superview.frame.size.height / 2)
                                 : self.superview.center.y);
                       }];
      break;
    }
    case NEVoiceRoom_FloatWindowTOP: {
      [UIView
          animateWithDuration:0.3
                   animations:^{
                     if (@available(iOS 11.0, *)) {
                       if ([UIApplication sharedApplication].keyWindow.safeAreaInsets.top > 20) {
                         /// 刘海屏
                         self.superview.center = CGPointMake(
                             self.superview.center.x, self.superview.frame.size.height / 2 + 50);
                       } else {
                         self.superview.center = CGPointMake(self.superview.center.x,
                                                             self.superview.frame.size.height / 2);
                       }
                     } else {
                       self.superview.center = CGPointMake(self.superview.center.x,
                                                           self.superview.frame.size.height / 2);
                     }
                   }];
      break;
    }
    case NEVoiceRoom_FloatWindowBOTTOM: {
      [UIView animateWithDuration:0.3
                       animations:^{
                         self.superview.center = CGPointMake(
                             self.superview.center.x, H - self.superview.frame.size.height / 2);
                       }];
      break;
    }
    default:
      break;
  }
}

- (void)buttonRotate {
  [self buttonAutoAdjust:self.center];

  if (IS_IPHONE) {
    NEVoiceRoom_ScreenChangeOrientation change2orien = [self screenChange];
    switch (change2orien) {
      case NEVoiceRoom_Change2Origin:
        self.transform = _originTransform;
        break;
      case NEVoiceRoom_Change2Left:
        self.transform = _originTransform;
        self.transform = CGAffineTransformMakeRotation(-90 * M_PI / 180.0);
        break;
      case NEVoiceRoom_Change2Right:
        self.transform = _originTransform;
        self.transform = CGAffineTransformMakeRotation(90 * M_PI / 180.0);
        break;
      case NEVoiceRoom_Change2Upside:
        self.transform = _originTransform;
        self.transform = CGAffineTransformMakeRotation(180 * M_PI / 180.0);
        break;
      default:
        break;
    }
  }
}

/**
 *  convert to the origin coordinate
 *
 *  UIInterfaceOrientationPortrait           = 1
 *  UIInterfaceOrientationPortraitUpsideDown = 2
 *  UIInterfaceOrientationLandscapeRight     = 3
 *  UIInterfaceOrientationLandscapeLeft      = 4
 */
- (CGPoint)ConvertDir:(CGPoint)p {
  NEVoiceRoom_ScreenChangeOrientation change2orien = [self screenChange];
  // covert
  switch (change2orien) {
    case NEVoiceRoom_Change2Left:
      return [self LandscapeLeft:p];
      break;
    case NEVoiceRoom_Change2Right:
      return [self LandscapeRight:p];
      break;
    case NEVoiceRoom_Change2Upside:
      return [self UpsideDown:p];
      break;
    default:
      //      NSLog(@"LandscapeLeft --- %@ ", NSStringFromCGPoint(p));
      return p;
      break;
  }
}

- (NEVoiceRoom_ScreenChangeOrientation)screenChange {
  UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

  // 1. NEVoiceRoom_Change2Origin(1->1 | 2->2 | 3->3 | 4->4)
  if (_initOrientation == orientation) return NEVoiceRoom_Change2Origin;

  // 2. NEVoiceRoom_Change2Upside(1->2 | 2->1 | 4->3 | 3->4)
  NSInteger isUpside = orientation + _initOrientation;
  if (isUpside == 3 || isUpside == 7) return NEVoiceRoom_Change2Upside;

  // 3. NEVoiceRoom_Change2Left(1->4 | 4->2 | 2->3 | 3->1)
  // 4. NEVoiceRoom_Change2Right(1->3 | 3->2 | 2->4 | 4->1)
  NEVoiceRoom_ScreenChangeOrientation change2orien = 0;
  switch (_initOrientation) {
    case UIInterfaceOrientationPortrait:
      if (orientation == UIInterfaceOrientationLandscapeLeft)
        change2orien = NEVoiceRoom_Change2Left;
      else if (orientation == UIInterfaceOrientationLandscapeRight)
        change2orien = NEVoiceRoom_Change2Right;
      break;
    case UIInterfaceOrientationPortraitUpsideDown:
      if (orientation == UIInterfaceOrientationLandscapeRight)
        change2orien = NEVoiceRoom_Change2Left;
      else if (orientation == UIInterfaceOrientationLandscapeLeft)
        change2orien = NEVoiceRoom_Change2Right;
      break;
    case UIInterfaceOrientationLandscapeRight:
      if (orientation == UIInterfaceOrientationPortrait)
        change2orien = NEVoiceRoom_Change2Left;
      else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
        change2orien = NEVoiceRoom_Change2Right;
      break;
    case UIInterfaceOrientationLandscapeLeft:
      if (orientation == UIInterfaceOrientationPortraitUpsideDown)
        change2orien = NEVoiceRoom_Change2Left;
      else if (orientation == UIInterfaceOrientationPortrait)
        change2orien = NEVoiceRoom_Change2Right;
      break;

    default:
      break;
  }
  return change2orien;
}

- (CGPoint)UpsideDown:(CGPoint)p {
  NSLog(@"UpsideDown --- %@ \n after:%@", NSStringFromCGPoint(p),
        NSStringFromCGPoint(CGPointMake(NEVoiceRoom_ScreenW - p.x, NEVoiceRoom_ScreenH - p.y)));
  return CGPointMake(NEVoiceRoom_ScreenW - p.x, NEVoiceRoom_ScreenH - p.y);
}

- (CGPoint)LandscapeLeft:(CGPoint)p {
  NSLog(@"LandscapeLeft --- %@ \n after:%@", NSStringFromCGPoint(p),
        NSStringFromCGPoint(CGPointMake(p.y, NEVoiceRoom_ScreenW - p.x)));
  return CGPointMake(p.y, NEVoiceRoom_ScreenW - p.x);
}

- (CGPoint)LandscapeRight:(CGPoint)p {
  NSLog(@"LandscapeLeft --- %@ \n after:%@", NSStringFromCGPoint(p),
        NSStringFromCGPoint(CGPointMake(NEVoiceRoom_ScreenH - p.y, p.x)));
  return CGPointMake(NEVoiceRoom_ScreenH - p.y, p.x);
}

- (void)setNetImage:(NSString *)icon {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:icon]]]
          forState:UIControlStateNormal];
  });
}
@end
