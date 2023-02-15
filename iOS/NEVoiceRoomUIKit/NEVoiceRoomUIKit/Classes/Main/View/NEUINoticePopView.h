// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEUIBaseView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CallBack)(NSString *password, BOOL isCancel);

@interface NEUINoticePopView : NEUIBaseView

@property(nonatomic, copy) CallBack callBack;

@end

NS_ASSUME_NONNULL_END
