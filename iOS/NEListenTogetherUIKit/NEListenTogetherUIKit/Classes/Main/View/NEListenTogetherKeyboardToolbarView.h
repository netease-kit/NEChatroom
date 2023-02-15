// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherUIBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NEUIKeyboardToolbarDelegate <NSObject>

/**
 点击工具条发送文字
 @param text    - 文本
 */
- (void)didToolBarSendText:(NSString *)text;

@end

@interface NEListenTogetherKeyboardToolbarView : NEListenTogetherUIBaseView

@property(nonatomic, weak) id<NEUIKeyboardToolbarDelegate> cusDelegate;

////相应成为第一响应者
- (void)becomeFirstResponse;

- (void)setUpInputContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
