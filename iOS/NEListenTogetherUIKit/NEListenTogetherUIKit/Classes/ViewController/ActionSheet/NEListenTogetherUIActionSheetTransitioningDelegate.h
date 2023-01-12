// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEListenTogetherUIActionSheetTransitioningDelegate
    : NSObject <UIViewControllerTransitioningDelegate>

/**
 是否点击外侧区域自动关闭. 默认为NO.
 */
@property(nonatomic, assign) BOOL dismissOnTouchOutside;

/**
 响应驱动消失手势驱动的距离. 默认30.
 */
@property(nonatomic, assign) CGFloat interactiveDismissalDistance;

/**
 创建默认对象，使用方则不需要管理生命周期
 */
+ (instancetype)defaultInstance;

@end

NS_ASSUME_NONNULL_END
