//
//  NTESUserUtil.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/6.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESUserUtil.h"
#import "NTESDataCenter.h"

@implementation NTESUserUtil

+ (NSString *)fromNickNameWithMessage:(NIMMessage *)message {
    NTESAccountInfo *myAccount = [NTESDataCenter shareCenter].myAccount;
    NSString *nickName = @"";
    if ([message.from isEqualToString:myAccount.account]) {
        nickName = myAccount.nickName;
    } else {
        NIMMessageChatroomExtension *ext = [message.messageExt isKindOfClass:[NIMMessageChatroomExtension class]] ?
        (NIMMessageChatroomExtension *)message.messageExt : nil;
        nickName = ext.roomNickname;
    }
    return nickName ?: @"";
}

+ (UInt64)randomUid {
    UInt64 uid;
    arc4random_buf(&uid, sizeof(uid));
    return uid;
}

@end
