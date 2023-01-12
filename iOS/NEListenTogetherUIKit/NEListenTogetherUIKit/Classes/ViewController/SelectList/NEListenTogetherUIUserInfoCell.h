// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEListenTogetherKit/NEListenTogetherKit-Swift.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 用户信息cell
@interface NEListenTogetherUIUserInfoCell : UITableViewCell
- (void)refresh:(NEListenTogetherMember *)member;
@end

NS_ASSUME_NONNULL_END
