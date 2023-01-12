// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CallBack)(NSString *password, BOOL isCancel);

@interface NEListenTogetherNoticePopView : NEListenTogetherUIBaseView

@property(nonatomic, copy) CallBack callBack;

@end

NS_ASSUME_NONNULL_END
