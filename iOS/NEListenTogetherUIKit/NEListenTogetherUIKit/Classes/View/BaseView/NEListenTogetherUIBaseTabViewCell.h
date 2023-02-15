// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "NEListenTogetherUIBaseModelProtocol.h"
#import "NEListenTogetherUIBaseTabViewCellProtocol.h"

@interface NEListenTogetherUIBaseTabViewCell
    : UITableViewCell <NEListenTogetherUIBaseTabViewCellProtocol>

/**
 数据模型(对外只读，对内可修改)
 */
@property(nonatomic, readonly, strong) id model;

/**
 分割线显示还是隐藏, yes是隐藏
 */
@property(nonatomic, assign) BOOL splitLineStyle;

/**
 初始化方法

 @param style 样式
 @param reuseIdentifier 标记id
 @param model 数据模型
 @return 视图对象
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<NEListenTogetherUIBaseModelProtocol>)model
    NS_DESIGNATED_INITIALIZER;

@end
