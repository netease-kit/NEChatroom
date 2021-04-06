//
//  NTESCustomAttachment.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/22.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESCustomAttachment.h"

@implementation NTESCustomAttachment


+ (nullable NTESCustomAttachment *)getAttachmentWithMessage:(NIMMessage *)message;
{
    if (message.messageType != NIMMessageTypeCustom) {
        return nil;
    }
    NIMCustomObject *object = message.messageObject;
    if (![object.attachment isKindOfClass:[NTESCustomAttachment class]]) {
        return nil;
    }
    return (NTESCustomAttachment *)object.attachment;
}


- (NSString *)encodeAttachment {
    NSDictionary *dict = @{
                            @"type"     : @(self.type),
                            @"data"     : @{@"operator" : self.operator ?: @""}
                          };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict  options:0  error:nil];
    NSString *content = nil;
    if (jsonData) {
        content = [[NSString alloc] initWithData:jsonData
                                        encoding:NSUTF8StringEncoding];
    }
    return content;
}

@end

@implementation NTESCustomAttachmentDecoder

// 所有的自定义消息都会走这个解码方法，如有多种自定义消息请在该方法中扩展，并自行做好类型判断和版本兼容。
- (id<NIMCustomAttachment>)decodeAttachment:(NSString *)content
{
    id<NIMCustomAttachment> attachment;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return attachment;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (![dict isKindOfClass:[NSDictionary class]]) {
        return attachment;
    }
    NSInteger type = [dict[@"type"] integerValue];
    switch (type) {
        case NTESVoiceChatAttachmentTypePullStream:
        case NTESVoiceChatAttachmentTypePauseMusic:
        case NTESVoiceChatAttachmentTypeResumeMusic:
            attachment = [self _decodeCustomAttachment:dict];
            break;
        default:
            break;
    }
    
    return attachment;
}

- (id<NIMCustomAttachment>)_decodeCustomAttachment:(nonnull NSDictionary *)dict {
    NTESCustomAttachment *attachment = [[NTESCustomAttachment alloc] init];
    attachment.type = [dict[@"type"] integerValue];
    attachment.operator = [dict[@"data"] objectForKey:@"operator"];
    return attachment;
}
@end
