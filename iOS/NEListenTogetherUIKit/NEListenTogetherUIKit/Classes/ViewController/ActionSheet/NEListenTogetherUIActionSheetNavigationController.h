// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEListenTogetherUIActionSheetNavigationController : UINavigationController

/**
 是否点击外侧消失
 */
@property(nonatomic, assign) BOOL dismissOnTouchOutside;

@end

NS_ASSUME_NONNULL_END
