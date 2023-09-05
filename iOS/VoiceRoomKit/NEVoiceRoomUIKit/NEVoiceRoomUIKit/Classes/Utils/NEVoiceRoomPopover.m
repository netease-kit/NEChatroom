// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomPopover.h"

@interface NEVoiceRoomPopover ()

@property(nonatomic, weak) UIView *containerView;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, assign) CGPoint arrowShowPoint;

@property(nonatomic, strong) UIControl *blackOverLay;

@property(nonatomic, assign) CGRect cacheFrame;

@end

@implementation NEVoiceRoomPopover

- (instancetype)init {
  if (self = [super init]) {
    self.option = [[NEVoiceRoomPopoverOption alloc] init];
    self.backgroundColor = [UIColor clearColor];
    self.accessibilityViewIsModal = YES;
  }
  return self;
}

- (instancetype)initWithOption:(NEVoiceRoomPopoverOption *)option {
  if (!option) {
    return [self init];
  } else {
    if (self = [super init]) {
      _option = option;
      self.backgroundColor = [UIColor clearColor];
      self.accessibilityViewIsModal = YES;
    }
    return self;
  }
}

#pragma - public

- (void)show:(UIView *)contentView fromView:(UIView *)fromView {
  [self show:contentView fromView:fromView inView:[self getWindow]];
}

- (UIWindow *)getWindow {
  id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
  if (delegate && [delegate respondsToSelector:@selector(window)]) {
    UIWindow *window = [delegate window];
    return window;
  }
  return [UIApplication sharedApplication].keyWindow;
}

- (void)show:(UIView *)contentView fromView:(UIView *)fromView inView:(UIView *)inView {
  if (_option.autoAjustDirection) {
    CGPoint downPoint = [self arrowPointWithView:contentView
                                        fromView:fromView
                                          inView:inView
                                     popoverType:NEVoiceRoomPopoverTypeDown];
    CGPoint upPoint = [self arrowPointWithView:contentView
                                      fromView:fromView
                                        inView:inView
                                   popoverType:NEVoiceRoomPopoverTypeUp];
    BOOL canBeUp = (upPoint.y - _option.arrowSize.height - contentView.bounds.size.height > 0);
    BOOL canBeDown = downPoint.y + _option.arrowSize.height + contentView.bounds.size.height <
                     inView.bounds.size.height;

    if (canBeUp && !canBeDown) {
      _option.popoverType = NEVoiceRoomPopoverTypeUp;
    } else if (!canBeUp && canBeDown) {
      _option.popoverType = NEVoiceRoomPopoverTypeDown;
    } else {
      _option.popoverType = _option.preferedType;
    }
  }
  CGPoint point = [self arrowPointWithView:contentView
                                  fromView:fromView
                                    inView:inView
                               popoverType:_option.popoverType];
  if (self.option.highlightFromView) {
    [self createHighlightLayerFromView:fromView inView:inView];
  }
  [self show:contentView atPoint:point inView:inView];
}

- (void)show:(UIView *)contentView atPoint:(CGPoint)point {
  [self show:contentView atPoint:point inView:[self getWindow]];
}

- (void)show:(UIView *)contentView atPoint:(CGPoint)point inView:(UIView *)inView {
  _cacheFrame = contentView.frame;
  if (_option.dismissOnBlackOverlayTap || _option.showBlackOverlay) {
    self.blackOverLay.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blackOverLay.frame = inView.bounds;
    [inView addSubview:self.blackOverLay];

    if (_option.showBlackOverlay) {
      if (_option.overlayBlur) {
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] init];
        effectView.effect = _option.overlayBlur;
        effectView.frame = self.blackOverLay.bounds;
        effectView.userInteractionEnabled = NO;
        [self.blackOverLay addSubview:effectView];
      } else {
        if (!_option.highlightFromView) {
          self.blackOverLay.backgroundColor = _option.blackOverlayColor;
        }
        self.blackOverLay.alpha = 0;
      }
      if (_option.dismissOnBlackOverlayTap) {
        [self.blackOverLay addTarget:self
                              action:@selector(dismiss)
                    forControlEvents:UIControlEventTouchUpInside];
      }
    }
  }
  self.containerView = inView;
  self.contentView = contentView;
  self.contentView.backgroundColor = [UIColor clearColor];
  self.contentView.layer.cornerRadius = _option.cornerRadius;
  self.contentView.layer.masksToBounds = YES;
  self.arrowShowPoint = point;
  [self show];
}

- (void)dismiss {
  if (self.superview) {
    if (self.willDismissHandler) {
      self.willDismissHandler();
    }
    [UIView animateWithDuration:_option.animationOut
        animations:^{
          self.transform = CGAffineTransformMakeScale(0.0001, 0.0001);
          self.blackOverLay.alpha = 0;
        }
        completion:^(BOOL finished) {
          [self.contentView removeFromSuperview];
          [self.blackOverLay removeFromSuperview];
          [self removeFromSuperview];
          self.transform = CGAffineTransformIdentity;
          if (self.didDismissHandler) {
            self.didDismissHandler();
          }
          _contentView.frame = self.cacheFrame;
        }];
  }
}

- (CGPoint)originArrowPointWithView:(UIView *)contentView fromView:(UIView *)fromView {
  return [self arrowPointWithView:contentView
                         fromView:fromView
                           inView:[self getWindow]
                      popoverType:_option.popoverType];
}

- (CGPoint)arrowPointWithView:(UIView *)contentView
                     fromView:(UIView *)fromView
                       inView:(UIView *)inView
                  popoverType:(NEVoiceRoomPopoverType)type {
  CGPoint point = CGPointZero;
  switch (type) {
    case NEVoiceRoomPopoverTypeUp: {
      point = [inView
          convertPoint:CGPointMake(fromView.frame.origin.x + (fromView.frame.size.width / 2),
                                   fromView.frame.origin.y)
              fromView:fromView.superview];
      point = CGPointMake(point.x, point.y - fabs(_option.offset));
    } break;

    case NEVoiceRoomPopoverTypeDown: {
      point = [inView
          convertPoint:CGPointMake(fromView.frame.origin.x + (fromView.frame.size.width / 2),
                                   fromView.frame.origin.y + fromView.frame.size.height)
              fromView:fromView.superview];
      point = CGPointMake(point.x, point.y + fabs(_option.offset));
    } break;
  }
  return point;
}

#pragma - private

- (void)createHighlightLayerFromView:(UIView *)fromView inView:(UIView *)inView {
  UIBezierPath *path = [UIBezierPath bezierPathWithRect:inView.bounds];
  CGRect highlightRect = [inView convertRect:fromView.frame fromView:fromView.superview];
  UIBezierPath *highlightPath =
      [UIBezierPath bezierPathWithRoundedRect:highlightRect
                                 cornerRadius:_option.highlightCornerRadius];
  [path appendPath:highlightPath];
  path.usesEvenOddFillRule = YES;
  CAShapeLayer *fillLayer = [CAShapeLayer layer];
  fillLayer.path = path.CGPath;
  fillLayer.fillRule = kCAFillRuleEvenOdd;
  fillLayer.fillColor = _option.blackOverlayColor.CGColor;
  [self.blackOverLay.layer addSublayer:fillLayer];
}

- (void)show {
  [self setNeedsDisplay];
  CGRect frame = self.contentView.frame;
  frame.origin.x = 0;
  switch (_option.popoverType) {
    case NEVoiceRoomPopoverTypeUp: {
      frame.origin.y = 0.0;
      self.contentView.frame = frame;
    } break;

    case NEVoiceRoomPopoverTypeDown: {
      frame.origin.y = _option.arrowSize.height;
      self.contentView.frame = frame;
    } break;
  }
  [self addSubview:self.contentView];
  [self.containerView addSubview:self];

  [self create];
  self.transform = CGAffineTransformMakeScale(0.0, 0.0);
  if (self.willShowHandler) {
    self.willShowHandler();
  }
  [UIView animateWithDuration:_option.animationIn
      delay:0.0
      usingSpringWithDamping:_option.springDamping
      initialSpringVelocity:_option.initialSpringVelocity
      options:0
      animations:^{
        self.transform = CGAffineTransformIdentity;
      }
      completion:^(BOOL finished) {
        if (self.didShowHandler) {
          self.didShowHandler();
        }
      }];
  [UIView animateWithDuration:_option.animationIn / 3
                   animations:^{
                     self.blackOverLay.alpha = 1;
                   }];
}

- (void)create {
  CGRect frame = self.contentView.frame;
  frame.origin.x = self.arrowShowPoint.x - frame.size.width * 0.5;
  CGFloat sideEdge = 0.0;
  if (frame.size.width < self.containerView.frame.size.width) {
    sideEdge = _option.sideEdge;
  }
  CGFloat outerSideEdge = CGRectGetMaxX(frame) - self.containerView.bounds.size.width;
  if (outerSideEdge > 0) {
    frame.origin.x -= (outerSideEdge + sideEdge);
  } else {
    if (CGRectGetMinX(frame) < 0) {
      frame.origin.x += fabs(CGRectGetMinX(frame)) + sideEdge;
    }
  }
  self.frame = frame;

  CGPoint arrowPoint = [self.containerView convertPoint:self.arrowShowPoint toView:self];
  CGPoint anchorPoint = CGPointZero;
  switch (_option.popoverType) {
    case NEVoiceRoomPopoverTypeUp: {
      frame.origin.y = self.arrowShowPoint.y - frame.size.height - _option.arrowSize.height;
      anchorPoint = CGPointMake(arrowPoint.x / frame.size.width, 1);
    }; break;
    case NEVoiceRoomPopoverTypeDown: {
      frame.origin.y = self.arrowShowPoint.y;
      anchorPoint = CGPointMake(arrowPoint.x / frame.size.width, 0);
    }; break;
  }

  if (!_option.arrowSize.width || !_option.arrowSize.height) {
    anchorPoint = CGPointMake(0.5, 0.5);
  }

  CGPoint lastAnchor = self.layer.anchorPoint;
  self.layer.anchorPoint = anchorPoint;
  CGFloat x = self.layer.position.x + (anchorPoint.x - lastAnchor.x) * self.layer.bounds.size.width;
  CGFloat y =
      self.layer.position.y + (anchorPoint.y - lastAnchor.y) * self.layer.bounds.size.height;
  self.layer.position = CGPointMake(x, y);

  frame.size.height += _option.arrowSize.height;
  self.frame = frame;
}

- (BOOL)isCornerLeftArrow {
  return self.arrowShowPoint.x == self.frame.origin.x;
}

- (BOOL)isCornerRightArrow {
  return self.arrowShowPoint.x == self.frame.origin.x + self.bounds.size.width;
}

- (CGFloat)radiansDerees:(CGFloat)degrees {
  return M_PI * degrees / 180;
}

#pragma - override

- (void)drawRect:(CGRect)rect {
#define ArrowAddLineToPoint(x, y) [arrow addLineToPoint:CGPointMake(x, y)]
#define radians(x) [self radiansDerees:x]
#define selfWidth self.bounds.size.width
#define selfHeight self.bounds.size.height
#define selfArrowWidth _option.arrowSize.width
#define selfArrowHeight _option.arrowSize.height
#define selfCornerRadius _option.cornerRadius
  [super drawRect:rect];
  UIBezierPath *arrow = [UIBezierPath bezierPath];
  UIColor *color = _option.popoverColor;
  CGPoint arrowPoint = [self.containerView convertPoint:self.arrowShowPoint toView:self];
  switch (_option.popoverType) {
    case NEVoiceRoomPopoverTypeUp: {
      [arrow moveToPoint:CGPointMake(arrowPoint.x, selfHeight)];
      ArrowAddLineToPoint(arrowPoint.x - selfArrowWidth * 0.5, [self isCornerLeftArrow]
                                                                   ? selfArrowHeight
                                                                   : selfHeight - selfArrowHeight);
      ArrowAddLineToPoint(selfCornerRadius, selfHeight - selfArrowHeight);
      [arrow addArcWithCenter:CGPointMake(selfCornerRadius,
                                          selfHeight - selfArrowHeight - selfCornerRadius)
                       radius:selfCornerRadius
                   startAngle:radians(90)
                     endAngle:radians(180)
                    clockwise:YES];
      ArrowAddLineToPoint(0, selfCornerRadius);
      [arrow addArcWithCenter:CGPointMake(selfCornerRadius, selfCornerRadius)
                       radius:selfCornerRadius
                   startAngle:radians(180)
                     endAngle:radians(270)
                    clockwise:YES];
      ArrowAddLineToPoint(selfWidth - selfCornerRadius, 0);
      [arrow addArcWithCenter:CGPointMake(selfWidth - selfCornerRadius, selfCornerRadius)
                       radius:selfCornerRadius
                   startAngle:radians(270)
                     endAngle:radians(0)
                    clockwise:YES];
      ArrowAddLineToPoint(selfWidth, selfHeight - selfArrowHeight - selfCornerRadius);
      [arrow addArcWithCenter:CGPointMake(selfWidth - selfCornerRadius,
                                          selfHeight - selfArrowHeight - selfCornerRadius)
                       radius:selfCornerRadius
                   startAngle:radians(0)
                     endAngle:radians(90)
                    clockwise:YES];
      ArrowAddLineToPoint(arrowPoint.x + selfArrowWidth * 0.5, [self isCornerRightArrow]
                                                                   ? selfArrowHeight
                                                                   : selfHeight - selfArrowHeight);
    } break;

    case NEVoiceRoomPopoverTypeDown: {
      [arrow moveToPoint:CGPointMake(arrowPoint.x, 0)];
      ArrowAddLineToPoint(arrowPoint.x + selfArrowWidth * 0.5, [self isCornerRightArrow]
                                                                   ? selfArrowHeight + selfHeight
                                                                   : selfArrowHeight);
      ArrowAddLineToPoint(selfWidth - selfCornerRadius, selfArrowHeight);
      [arrow addArcWithCenter:CGPointMake(selfWidth - selfCornerRadius,
                                          selfArrowHeight + selfCornerRadius)
                       radius:selfCornerRadius
                   startAngle:radians(270)
                     endAngle:radians(0)
                    clockwise:YES];
      ArrowAddLineToPoint(selfWidth, selfHeight - selfCornerRadius);
      [arrow
          addArcWithCenter:CGPointMake(selfWidth - selfCornerRadius, selfHeight - selfCornerRadius)
                    radius:selfCornerRadius
                startAngle:radians(0)
                  endAngle:radians(90)
                 clockwise:YES];
      ArrowAddLineToPoint(0, selfHeight);
      [arrow addArcWithCenter:CGPointMake(selfCornerRadius, selfHeight - selfCornerRadius)
                       radius:selfCornerRadius
                   startAngle:radians(90)
                     endAngle:radians(180)
                    clockwise:YES];
      ArrowAddLineToPoint(0, selfArrowHeight + selfCornerRadius);
      [arrow addArcWithCenter:CGPointMake(selfCornerRadius, selfArrowHeight + selfCornerRadius)
                       radius:selfCornerRadius
                   startAngle:radians(180)
                     endAngle:radians(270)
                    clockwise:YES];
      ArrowAddLineToPoint(arrowPoint.x - selfArrowWidth * 0.5, [self isCornerLeftArrow]
                                                                   ? selfArrowHeight + selfHeight
                                                                   : selfArrowHeight);
    } break;
  }
  [color setFill];
  [arrow fill];
}

//- (void)layoutSubviews {
//  [super layoutSubviews];
//  self.contentView.frame = self.bounds;
//}

- (BOOL)accessibilityPerformEscape {
  [self dismiss];
  return YES;
}

- (UIControl *)blackOverLay {
  if (!_blackOverLay) {
    _blackOverLay = [[UIControl alloc] init];
  }
  return _blackOverLay;
}

@end
