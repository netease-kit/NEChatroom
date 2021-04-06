//
//  NTESCustomAttachment.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/22.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, NTESVoiceChatAttachmentType) {
    NTESVoiceChatAttachmentTypePullStream   = 2,    // 发送的拉流消息
    NTESVoiceChatAttachmentTypePauseMusic   = 3,    // 音乐暂停
    NTESVoiceChatAttachmentTypeResumeMusic   = 4,    // 音乐继续
};


@interface NTESCustomAttachment : NSObject<NIMCustomAttachment>

@property(nonatomic, assign) NTESVoiceChatAttachmentType type;
@property(nonatomic, copy) NSString *operator;

+ (nullable NTESCustomAttachment *)getAttachmentWithMessage:(NIMMessage *)message;

@end

/**
 PK直播消息反序列化
 */
@interface NTESCustomAttachmentDecoder : NSObject<NIMCustomAttachmentCoding>

@end
NS_ASSUME_NONNULL_END
