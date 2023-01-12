// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NEUIAlertActionType) {
  NEUIAlertActionTypeInviteMic = 0,
  NEUIAlertActionTypeMaskMic,
  NEUIAlertActionTypeFinishedMaskMic,
  NEUIAlertActionTypeCloseMic,
  NEUIAlertActionTypeKickMic,
  NEUIAlertActionTypeOpenMic,
  NEUIAlertActionTypeCancelMaskMic,
  NEUIAlertActionTypeCancelOnMicRequest,
  NEUIAlertActionTypeDropMic,
  NEUIAlertActionTypeExistRoom,
};

typedef void (^NEUIAlertActionHandle)(id info);

@interface NEListenTogetherUIAlertAction : NSObject

@property(nonatomic, assign) NEUIAlertActionType type;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NEUIAlertActionHandle handle;

+ (NEListenTogetherUIAlertAction *)actionWithTitle:(NSString *)title
                                              type:(NEUIAlertActionType)type
                                           handler:(nullable NEUIAlertActionHandle)handle;

@end

@interface NEListenTogetherUIAlertView : NSObject

@property(nonatomic, copy) dispatch_block_t cancel;

- (instancetype)initWithActions:(NSMutableArray<NEListenTogetherUIAlertAction *> *)actions;

- (void)showWithTypes:(NSArray<NSNumber *> *)types info:(id)info;

- (void)dismiss;

+ (void)showAlertWithMessage:(NSString *)message;

+ (void)showAlertWithMessage:(NSString *)message completion:(nullable dispatch_block_t)completion;

@end

NS_ASSUME_NONNULL_END
