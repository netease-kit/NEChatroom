// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@protocol NEListenTogetherUIBaseTabViewCellProtocol <NSObject>

@optional

/**
 子视图添加
 */
- (void)ntes_setupViews;

/**
 业务逻辑绑定
 */
- (void)ntes_bindViewModel;

@end
