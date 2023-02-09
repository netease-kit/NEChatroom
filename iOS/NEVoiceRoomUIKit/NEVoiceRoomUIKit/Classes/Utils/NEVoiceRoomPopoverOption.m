// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEVoiceRoomPopoverOption.h"

@implementation NEVoiceRoomPopoverOption

- (instancetype)init {
  if (self = [super init]) {
    _arrowSize = CGSizeMake(10, 7);
    _offset = 0.0;
    _animationIn = 0.6;
    _animationOut = 0.3;
    _cornerRadius = 2.0;
    _sideEdge = 5.0;
    _autoAjustDirection = YES;
    _popoverType = NEVoiceRoomPopoverTypeUp;
    _preferedType = NEVoiceRoomPopoverTypeUp;
    _blackOverlayColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    _popoverColor = [UIColor lightGrayColor];
    _dismissOnBlackOverlayTap = YES;
    _showBlackOverlay = YES;
    _springDamping = 0.7;
    _initialSpringVelocity = 3.0;
    _highlightFromView = NO;
    _highlightCornerRadius = 0.0;
  }
  return self;
}

@end
