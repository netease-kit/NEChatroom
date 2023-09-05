// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEVoiceRoomKit/NEVoiceRoomKit-Swift.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 用户信息cell
@interface NEUIUserInfoCell : UITableViewCell
- (void)refresh:(NEVoiceRoomMember *)member;
@end

NS_ASSUME_NONNULL_END
