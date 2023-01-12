// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NEUIBarOperationType) {
  NEUIBarOperationTypeCancel = 0,
  NEUIBarOperationTypeArrow
};

@interface NEListenTogetherUINavigationBar : UIView
@property(nonatomic, strong) dispatch_block_t backBlock;

@property(nonatomic, strong) dispatch_block_t arrowBackBlock;
@property(nonatomic, copy) NSString *title;

@property(nonatomic, assign) NEUIBarOperationType operationType;
@end

NS_ASSUME_NONNULL_END
