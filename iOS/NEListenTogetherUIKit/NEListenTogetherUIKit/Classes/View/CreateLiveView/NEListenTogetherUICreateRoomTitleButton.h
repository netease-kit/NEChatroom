// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEListenTogetherUICreateRoomTitleButton : UIButton

- (instancetype)initWithImage:(NSString *)imageName content:(NSString *)content;

- (void)setLableFont:(UIFont *)lableFont;
// 设置内容
- (void)setContent:(NSString *)content;

- (void)setLeftMargin:(CGFloat)leftMargin imageSize:(CGSize)imageSize;
@end

NS_ASSUME_NONNULL_END
