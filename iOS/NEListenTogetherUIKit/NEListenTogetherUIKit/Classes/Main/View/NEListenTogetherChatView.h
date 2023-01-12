// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <M80AttributedLabel/M80AttributedLabel.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NEListenTogetherChatViewMessageType) {
  NEListenTogetherChatViewMessageTypeNormal = 0,
  NEListenTogetherChatViewMessageTypeReward,
  NEListenTogetherChatViewMessageTypeNotication,
};

@interface NEListenTogetherChatViewMessage : NSObject

/// 消息类型
@property(nonatomic, assign) NEListenTogetherChatViewMessageType type;
/// 消息size
@property(nonatomic, assign) CGSize size;

/// 文本消息
@property(nonatomic, copy) NSString *text;
@property(nonatomic, copy) NSString *sender;
/// 消息富文本
@property(nonatomic, readonly) NSAttributedString *formatMessage;
@property(nonatomic, assign) BOOL isAnchor;
/// 礼物消息
@property(nonatomic, assign) int giftId;
@property(nonatomic, copy) NSString *giftFrom;
/// 通知消息
@property(nonatomic, copy) NSString *notication;

///
/// 计算宽度
/// @param width - 宽度
///
- (void)caculate:(CGFloat)width;

///
/// 绘制富文本
/// @param label - 富文本容器
///
- (void)drawAttributeLabel:(M80AttributedLabel *)label;

@end

@interface NEListenTogetherChatCell : UITableViewCell

///
/// 实例化cell
/// @param tableView    - 展示控件
/// @param indexPath    - 展示indexPath
/// @param datas        - 展示数据集合
/// @return IM cell
///
+ (NEListenTogetherChatCell *)cellWithTableView:(UITableView *)tableView
                                      indexPath:(NSIndexPath *)indexPath
                                          datas:(NSArray<NEListenTogetherChatViewMessage *> *)datas;

///
/// 获取cell高度
/// @param indexPath    - 展示indexPath
/// @param datas        - 展示数据集合
///
+ (CGFloat)heightWithIndexPath:(NSIndexPath *)indexPath
                         datas:(NSArray<NEListenTogetherChatViewMessage *> *)datas;

@end

@interface NEListenTogetherChatView : UIView

- (void)addMessages:(NSArray<NEListenTogetherChatViewMessage *> *)messages;

@end

NS_ASSUME_NONNULL_END
