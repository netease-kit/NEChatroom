// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEUIBaseModelProtocol.h"
#import "NEUIBaseViewProtocol.h"

@interface NEUIBaseView : UIView <NEUIBaseViewProtocol>

/**
 数据模型(对外只读，对内可修改)
 */
@property(nonatomic, readonly, strong) id model;

/**
 初始化对象(指定初始化方法)

 @param frame 布局
 @param model 数据模型
 @return 视图对象
 */
- (instancetype)initWithFrame:(CGRect)frame
                        model:(id<NEUIBaseModelProtocol>)model NS_DESIGNATED_INITIALIZER;

@end
