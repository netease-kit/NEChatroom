// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <NEUIKit/NEUIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// web 控制器
@interface NEUIWebViewController : NEUIBaseViewController
- (instancetype)initWithUrlString:(NSString *)urlString;
@end

NS_ASSUME_NONNULL_END
