// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

/**
 * to avoid event collision between button click and pan,here touch event is adopted
 * to deal with both click and pan event
 */
@protocol UIDragButtonDelegate <NSObject>

- (void)dragButtonClicked:(UIButton *)sender;

@end

@interface NEVoiceRoomDraggableButton : UIButton

@property(nonatomic, strong) UIView *rootView;
@property(nonatomic, weak) id<UIDragButtonDelegate> buttonDelegate;
@property(nonatomic, assign) UIInterfaceOrientation initOrientation;
@property(nonatomic, assign) CGAffineTransform originTransform;

- (void)buttonRotate;

- (void)setNetImage:(NSString *)icon;

@end
