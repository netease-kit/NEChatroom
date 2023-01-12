// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NEUIConnectAlertViewBtnBlock)(void);

@interface NEListenTogetherUIConnectAlertView : UIView
/// 按钮点击事件回调
@property(nonatomic, copy) NEUIConnectAlertViewBtnBlock actionBlock;
@property(nonatomic, strong) UIButton *showConnectListBtn;
/// 更新链接数
- (void)updateConnectCount:(NSUInteger)connectCount;
/// 刷新alertView
- (void)refreshAlertView:(BOOL)listViewPushed;
@end

NS_ASSUME_NONNULL_END
