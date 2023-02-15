// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NEUIToastState) {
  NEUIToastStateSuccess = 0,
  NEUIToastStateFail,
  NEUIToastCancel,
};

@interface UIView (NEUIToast)

- (void)showToastWithMessage:(NSString *)message state:(NEUIToastState)state;

- (void)showToastWithMessage:(NSString *)message
                       state:(NEUIToastState)state
                 autoDismiss:(BOOL)autoDismiss;

- (void)showToastWithMessage:(NSString *)message
                       state:(NEUIToastState)state
                      cancel:(nullable dispatch_block_t)cancel;

- (void)dismissToast;

@end

NS_ASSUME_NONNULL_END
