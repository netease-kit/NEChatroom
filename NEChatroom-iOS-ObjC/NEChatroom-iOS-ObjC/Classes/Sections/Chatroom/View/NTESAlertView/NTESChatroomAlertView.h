//
//  NTESChatroomAlertView.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/31.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NTESAlertActionType) {
    NTESAlertActionTypeInviteMic = 0,
    NTESAlertActionTypeMaskMic,
    NTESAlertActionTypeFinishedMaskMic,
    NTESAlertActionTypeCloseMic,
    NTESAlertActionTypeKickMic,
    NTESAlertActionTypeOpenMic,
    NTESAlertActionTypeCancelMaskMic,
    NTESAlertActionTypeCancelOnMicRequest,
    NTESAlertActionTypeDropMic,
    NTESAlertActionTypeExistRoom,
};

typedef void(^NTESAlertActionHandle)(id info);

@interface NTESChatroomAlertAction : NSObject

@property (nonatomic, assign) NTESAlertActionType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NTESAlertActionHandle handle;

+ (NTESChatroomAlertAction *)actionWithTitle:(NSString *)title
                                        type:(NTESAlertActionType)type
                                     handler:(nullable NTESAlertActionHandle)handle;

@end


@interface NTESChatroomAlertView : NSObject

@property (nonatomic, copy) dispatch_block_t cancel;

- (instancetype)initWithActions:(NSMutableArray <NTESChatroomAlertAction *> *)actions;

- (void)showWithTypes:(NSArray<NSNumber *> *)types info:(id)info;

- (void)dismiss;

+ (void)showAlertWithMessage:(NSString *)message;

+ (void)showAlertWithMessage:(NSString *)message
                  completion:(nullable dispatch_block_t)completion;

@end


NS_ASSUME_NONNULL_END
