// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEVoiceRoomPopoverOption.h"

typedef void (^NEVoiceRoomPopoverBlock)(void);

@interface NEVoiceRoomPopover : UIView

@property(nonatomic, copy) NEVoiceRoomPopoverBlock willShowHandler;
@property(nonatomic, copy) NEVoiceRoomPopoverBlock willDismissHandler;
@property(nonatomic, copy) NEVoiceRoomPopoverBlock didShowHandler;
@property(nonatomic, copy) NEVoiceRoomPopoverBlock didDismissHandler;

@property(nonatomic, strong) NEVoiceRoomPopoverOption *option;

- (instancetype)initWithOption:(NEVoiceRoomPopoverOption *)option;

- (void)dismiss;

- (void)show:(UIView *)contentView fromView:(UIView *)fromView;
- (void)show:(UIView *)contentView fromView:(UIView *)fromView inView:(UIView *)inView;
- (void)show:(UIView *)contentView atPoint:(CGPoint)point;
- (void)show:(UIView *)contentView atPoint:(CGPoint)point inView:(UIView *)inView;

- (CGPoint)originArrowPointWithView:(UIView *)contentView fromView:(UIView *)fromView;
- (CGPoint)arrowPointWithView:(UIView *)contentView
                     fromView:(UIView *)fromView
                       inView:(UIView *)inView
                  popoverType:(NEVoiceRoomPopoverType)type;

@end
