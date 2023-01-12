// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEListenTogetherUIMoreItem : NSObject
/// 启用图片
@property(nonatomic, strong) UIImage *onImage;
/// 禁用图片
@property(nonatomic, strong) UIImage *offImage;
/// 名称
@property(nonatomic, copy) NSString *title;
/// 是否开启
@property(nonatomic, assign) BOOL on;
/// 当前状态图片
@property(nonatomic, readonly) UIImage *currentImage;
/// 标签
@property(nonatomic, assign) NSInteger tag;

- (NEListenTogetherUIMoreItem * (^)(BOOL))open;
/// 初始化方法
/// @param title 名称
/// @param onImage 启用图片
/// @param offImage 禁用图片
/// @param tag 标签
+ (instancetype)itemWithTitle:(NSString *)title
                      onImage:(UIImage *)onImage
                     offImage:(nullable UIImage *)offImage
                          tag:(NSInteger)tag;
@end

NS_ASSUME_NONNULL_END
