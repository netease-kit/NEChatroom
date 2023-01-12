// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
/**
 item的类型

 - NEUIActionSheetItemNoraml: 默认都是普通类型的
 */
typedef NS_OPTIONS(NSUInteger, NEUIActionSheetItemType) {
  NEUIActionSheetItemNoraml = 0,  // 普通
  NEUIActionSheetItemDelete,      // 删除
  NEUIActionSheetItemSure,        // 确定
};

@interface NEUIActionSheetModel : NSObject
/**
 标题
 */
@property(nonatomic, copy) NSString *title;

/**
 介绍，可为空
 */
@property(nonatomic, copy) NSString *subTitle;

/**
 标示id
 */
@property(nonatomic, assign) int sheetId;

/**
 选择item的类型
 */
@property(nonatomic, assign) NEUIActionSheetItemType itemType;

/**
 这个model所在的item被点击了触发这个block
 */
@property(nonatomic, copy) void (^actionBlock)(void);

@end

@interface NEListenTogetherUIActionSheet : UIView

/**
 显示sheetView

 @param desc 头部描述
 @param models 操作的item数据
 @param action 操作每个item时触发的事件
 */
+ (void)showWithDesc:(NSString *)desc
        actionModels:(NSArray<NEUIActionSheetModel *> *)models
              action:(void (^)(NEUIActionSheetModel *model))action;

+ (void)showWithDesc:(NSString *)desc
        actionModels:(NSArray<NEUIActionSheetModel *> *)models
              action:(void (^)(NEUIActionSheetModel *))action
              cancel:(dispatch_block_t)cancel;

/**
 隐藏
 */
+ (void)hide;

@end
