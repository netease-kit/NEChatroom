// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEListenTogetherChatView.h"
#import <NEUIKit/UIColor+NEUIExtension.h>
#import "NEListenTogetherUIGiftModel.h"
#import "UIImage+ListenTogether.h"

@interface NEListenTogetherChatViewMessage ()

/// 昵称
@property(nonatomic, assign) NSRange nickRange;
/// 文字区间
@property(nonatomic, assign) NSRange textRange;

@property(nonatomic, copy) NSString *giftIcon;

@end

@implementation NEListenTogetherChatViewMessage

- (void)caculate:(CGFloat)width {
  dispatch_sync(dispatch_get_main_queue(), ^{
    M80AttributedLabel *label = NTESCaculateLabel();
    [self drawAttributeLabel:label];
    CGFloat tmpW = self.isAnchor ? (width - 32) : width;
    CGSize size = [label sizeThatFits:CGSizeMake(tmpW, CGFLOAT_MAX)];
    if (self.isAnchor) {
      size = CGSizeMake(size.width, size.height);
    }
    self->_size = size;
  });
}

- (void)drawAttributeLabel:(M80AttributedLabel *)label {
  if ([label.attributedText length] > 0) {
    NSAttributedString *empty = [[NSAttributedString alloc] initWithString:@""];
    [label setAttributedText:empty];
  }

  if (self.isAnchor) {
    UIImage *authorIco = [UIImage voiceRoom_imageNamed:@"anthor_ico"];
    [label appendImage:authorIco
               maxSize:CGSizeMake(32, 16)
                margin:UIEdgeInsetsZero
             alignment:M80ImageAlignmentCenter];
    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" "];
    [label appendAttributedText:space];
  }
  [label appendAttributedText:self.formatMessage];
  if (self.giftIcon.length) {
    UIImage *rewardIco = [UIImage voiceRoom_imageNamed:self.giftIcon];
    [label appendImage:rewardIco
               maxSize:CGSizeMake(20, 20)
                margin:UIEdgeInsetsZero
             alignment:M80ImageAlignmentCenter];
  }
}

- (NSAttributedString *)formatMessage {
  NSString *showMessage = [self showMessage];
  NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:showMessage];
  switch (_type) {
    case NEListenTogetherChatViewMessageTypeNormal:
    case NEListenTogetherChatViewMessageTypeReward: {
      [text setAttributes:@{
        NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.6],
        NSFontAttributeName : [UIFont systemFontOfSize:14]
      }
                    range:_nickRange];
      [text setAttributes:@{
        NSForegroundColorAttributeName : [UIColor ne_colorWithHex:0xffffff],
        NSFontAttributeName : [UIFont systemFontOfSize:14]
      }
                    range:_textRange];
    } break;
    case NEListenTogetherChatViewMessageTypeNotication: {
      [text setAttributes:@{
        NSForegroundColorAttributeName : [UIColor ne_colorWithHex:0xffffff],
        NSFontAttributeName : [UIFont systemFontOfSize:14]
      }
                    range:_textRange];
    } break;
    default:
      break;
  }
  return text;
}

- (NSRange)textRange {
  NSString *showMessage = [self showMessage];
  return NSMakeRange(showMessage.length - self.text.length, self.text.length);
}

- (NSString *)showMessage {
  NSString *showMessage;
  switch (_type) {
    case NEListenTogetherChatViewMessageTypeNormal: {
      showMessage = [NSString stringWithFormat:@"%@: %@", self.sender, self.text];
      _textRange = NSMakeRange(showMessage.length - self.text.length, self.text.length);
      _nickRange = NSMakeRange(0, showMessage.length - self.text.length);
      break;
    }
    case NEListenTogetherChatViewMessageTypeReward: {
      NEListenTogetherUIGiftModel *reward =
          [NEListenTogetherUIGiftModel getRewardWithGiftId:self.giftId];
      self.giftIcon = reward.icon;
      NSString *msg = @"赠送礼物x1 ";
      showMessage = [NSString stringWithFormat:@"%@: %@", self.giftFrom, msg];
      _textRange = NSMakeRange(showMessage.length - msg.length, msg.length);
      _nickRange = NSMakeRange(0, showMessage.length - msg.length);
      break;
    }
    case NEListenTogetherChatViewMessageTypeNotication: {
      showMessage = [NSString stringWithFormat:@"%@", self.notication];
      _textRange = NSMakeRange(0, showMessage.length);
      _nickRange = NSMakeRange(0, 0);
      break;
    }
    default: {
      showMessage = [NSString stringWithFormat:@"%@: %@", self.sender, self.text];
      _textRange = NSMakeRange(showMessage.length - self.text.length, self.text.length);
      _nickRange = NSMakeRange(0, showMessage.length - self.text.length);
      break;
    }
  }
  return showMessage;
}

M80AttributedLabel *NTESCaculateLabel() {
  static M80AttributedLabel *label;
  if (!label) {
    label = [[M80AttributedLabel alloc] init];
    label.font = [UIFont systemFontOfSize:14];
    label.numberOfLines = 0;
    label.lineBreakMode = kCTLineBreakByCharWrapping;
  }
  return label;
}

@end

@interface NEListenTogetherChatCell () {
  CGRect _preRect;
}

/// 消息模型
@property(nonatomic, strong) NEListenTogetherChatViewMessage *model;
/// 富文本控件
@property(nonatomic, strong) M80AttributedLabel *attributedLabel;

@end

@implementation NEListenTogetherChatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    self.contentView.layer.cornerRadius = 14.0;
    [self.contentView addSubview:self.attributedLabel];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.contentView.frame = CGRectMake(0, 0, _model.size.width + 8 * 2, _model.size.height + 10.0);
  _attributedLabel.frame = CGRectMake(8, 5, _model.size.width, _model.size.height);
}

- (void)installWithModel:(NEListenTogetherChatViewMessage *)model
               indexPath:(NSIndexPath *)indexPath {
  [model drawAttributeLabel:self.attributedLabel];

  _model = model;

  switch (model.type) {
    case NEListenTogetherChatViewMessageTypeNormal:
    case NEListenTogetherChatViewMessageTypeReward:
      self.contentView.backgroundColor = [UIColor ne_colorWithHex:0x000000 alpha:0.6];
      break;
    case NEListenTogetherChatViewMessageTypeNotication: {
      self.contentView.backgroundColor = [UIColor clearColor];
      break;
    }
    default:
      break;
  }

  [self setNeedsLayout];
}

+ (NEListenTogetherChatCell *)cellWithTableView:(UITableView *)tableView
                                      indexPath:(NSIndexPath *)indexPath
                                          datas:
                                              (NSArray<NEListenTogetherChatViewMessage *> *)datas {
  NEListenTogetherChatCell *cell =
      [tableView dequeueReusableCellWithIdentifier:[NEListenTogetherChatCell description]];
  if ([datas count] > indexPath.row) {
    NEListenTogetherChatViewMessage *model = datas[indexPath.row];
    [cell installWithModel:model indexPath:indexPath];
  }
  return cell;
}

+ (CGFloat)heightWithIndexPath:(NSIndexPath *)indexPath
                         datas:(NSArray<NEListenTogetherChatViewMessage *> *)datas {
  if ([datas count] > indexPath.row) {
    NEListenTogetherChatViewMessage *model = datas[indexPath.row];
    return (model.size.height + 8.0 + 9.0);
  }
  return 0;
}

#pragma mark - Get
- (M80AttributedLabel *)attributedLabel {
  if (!_attributedLabel) {
    _attributedLabel = [[M80AttributedLabel alloc] init];
    _attributedLabel.numberOfLines = 0;
    _attributedLabel.font = [UIFont systemFontOfSize:14];
    _attributedLabel.backgroundColor = [UIColor clearColor];
    _attributedLabel.lineBreakMode = kCTLineBreakByCharWrapping;
  }
  return _attributedLabel;
}

@end

@interface NEListenTogetherChatView () <UITableViewDelegate, UITableViewDataSource> {
  CGRect _preRect;
}

@property(nonatomic, strong) UITableView *tableView;

@property(nonatomic, strong) NSMutableArray<NEListenTogetherChatViewMessage *> *messages;
/// 缓存的插入消息,聊天室需要在另外个线程计算高度,减少UI刷新
@property(nonatomic, strong) NSMutableArray<NEListenTogetherChatViewMessage *> *pendingMessages;

@end

@implementation NEListenTogetherChatView

- (instancetype)initWithFrame:(CGRect)frame {
  if ([super initWithFrame:frame]) {
    self.messages = [[NSMutableArray alloc] init];
    self.pendingMessages = [[NSMutableArray alloc] init];
    [self setupView];
  }
  return self;
}

- (void)setupView {
  [self addSubview:self.tableView];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  if (!CGRectEqualToRect(_preRect, self.bounds)) {
    _tableView.frame = self.bounds;
    _tableView.contentInset = UIEdgeInsetsMake(CGRectGetWidth(self.tableView.frame), 0, 0, 0);
    _preRect = self.bounds;
  }
}

- (void)addMessages:(NSArray<NEListenTogetherChatViewMessage *> *)messages {
  if (messages.count) {
    [self caculateHeight:messages];
  }
}

#pragma mark - getter

- (UITableView *)tableView {
  if (!_tableView) {
    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    [_tableView registerClass:[NEListenTogetherChatCell class]
        forCellReuseIdentifier:[NEListenTogetherChatCell description]];
    _tableView.delegate = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.backgroundColor = [UIColor clearColor];
  }
  return _tableView;
}

#pragma mark - Private

static const void *const NTESDispatchMessageDataPrepareSpecificKey =
    &NTESDispatchMessageDataPrepareSpecificKey;
dispatch_queue_t NTESMessageDataPrepareQueue() {
  static dispatch_queue_t queue;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    queue = dispatch_queue_create("nim.ktv.demo.message.queue", 0);
    dispatch_queue_set_specific(queue, NTESDispatchMessageDataPrepareSpecificKey,
                                (void *)NTESDispatchMessageDataPrepareSpecificKey, NULL);
  });
  return queue;
}

- (void)caculateHeight:(NSArray<NEListenTogetherChatViewMessage *> *)messages {
  dispatch_async(NTESMessageDataPrepareQueue(), ^{
    // 后台线程处理宽度计算，处理完之后同步抛到主线程插入
    BOOL noPendingMessage = self.pendingMessages.count == 0;
    [self.pendingMessages addObjectsFromArray:messages];
    if (noPendingMessage) {
      [self processPendingMessages];
    }
  });
}

- (void)processPendingMessages {
  __weak typeof(self) weakSelf = self;
  __block CGFloat width = 0;
  NSUInteger pendingMessageCount = self.pendingMessages.count;
  if (!weakSelf || pendingMessageCount == 0) {
    return;
  }
  dispatch_sync(dispatch_get_main_queue(), ^{
    __strong typeof(self) strongSelf = weakSelf;
    if (strongSelf) {
      if (strongSelf.tableView.isDecelerating || strongSelf.tableView.isDragging) {
        // 滑动的时候为保证流畅，暂停插入
        NSTimeInterval delay = 1;
        __weak typeof(self) weakSelfSec = strongSelf;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                       NTESMessageDataPrepareQueue(), ^{
                         __strong typeof(self) strongSelfSec = weakSelfSec;
                         if (strongSelfSec) {
                           [strongSelfSec processPendingMessages];
                         }
                       });
        return;
      }
      width = strongSelf.frame.size.width;
    }
  });

  // 获取一定量的消息计算高度，并扔回到主线程
  static NSInteger NTESMaxInsert = 2;
  NSArray *insert = nil;
  NSRange range;
  if (pendingMessageCount > NTESMaxInsert) {
    range = NSMakeRange(0, NTESMaxInsert);
  } else {
    range = NSMakeRange(0, pendingMessageCount);
  }
  insert = [self.pendingMessages subarrayWithRange:range];
  [self.pendingMessages removeObjectsInRange:range];

  NSMutableArray *models = [[NSMutableArray alloc] init];
  for (NEListenTogetherChatViewMessage *message in insert) {
    [message caculate:width - 2 * 8.0];
    [models addObject:message];
  }

  NSUInteger leftPendingMessageCount = self.pendingMessages.count;
  dispatch_sync(dispatch_get_main_queue(), ^{
    [weakSelf addModels:models];
  });

  if (leftPendingMessageCount) {
    NSTimeInterval delay = 0.1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)),
                   NTESMessageDataPrepareQueue(), ^{
                     [weakSelf processPendingMessages];
                   });
  }
}

- (void)addModels:(NSArray<NEListenTogetherChatViewMessage *> *)models {
  NSInteger count = self.messages.count;
  [self.messages addObjectsFromArray:models];

  NSMutableArray *insert = [[NSMutableArray alloc] init];
  for (NSInteger index = count; index < count + models.count; index++) {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [insert addObject:indexPath];
  }

  [self.tableView beginUpdates];
  [self.tableView insertRowsAtIndexPaths:insert withRowAnimation:UITableViewRowAnimationFade];
  [self.tableView endUpdates];
  [self.tableView layoutIfNeeded];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self scrollToBottom:models];
  });
}

- (void)scrollToBottom:(NSArray<NEListenTogetherChatViewMessage *> *)newModels {
  //    UIEdgeInsets insets = self.tableView.contentInset;
  //    if (insets.top != 0) {
  //        CGFloat height = 0;
  //        for (NEListenTogetherChatViewMessage *model in newModels) {
  //            height += (model.size.height + 8.0 + 9.0);
  //        }
  //        CGFloat top = insets.top - height;
  //        insets.top = MAX(top, 0);
  //        [UIView animateWithDuration:0.25 animations:^{
  //            self.tableView.contentInset = insets;
  //        }];
  //    } else {
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_messages.count - 1 inSection:0];
  [_tableView scrollToRowAtIndexPath:indexPath
                    atScrollPosition:UITableViewScrollPositionBottom
                            animated:YES];
  //    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.messages count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [NEListenTogetherChatCell heightWithIndexPath:indexPath datas:self.messages];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [NEListenTogetherChatCell cellWithTableView:tableView
                                           indexPath:indexPath
                                               datas:self.messages];
}

@end
