//
//  NTESChatroomInfo.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/17.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESChatroomInfo.h"
#import "NSDictionary+NTESJson.h"
#import "NSString+NTES.h"

@implementation NTESChatroomInfo

static NSString *const kRoomId = @"roomId";
static NSString *const kName = @"name";
static NSString *const kCreator = @"creator";
static NSString *const kThumbnail = @"thumbnail";
static NSString *const kOnlineUserCount = @"onlineUserCount";
static NSString *const kCreateTime = @"createTime";

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (!dic) {
        return nil;
    }
    if (self = [super init]) {
        _roomId = [dic jsonString:@"roomId"];
        _name = [dic jsonString:@"name"];
        _creator = [dic jsonString:@"creator"];
        _thumbnail = [dic jsonString:@"thumbnail"];
        _onlineUserCount = [dic jsonInteger:@"onlineUserCount"];
        _createTime = [dic jsonInteger:@"createTime"];
    }
    return self;
}

- (BOOL)valid {
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970]*1000;//当前时间戳
    return (timestamp - _createTime < 48*60*60*1000);
}

- (void)updateByChatroom:(NIMChatroom *)chatroom {
    _roomId = chatroom.roomId;
    _name = chatroom.name;
    _creator = chatroom.creator;
    _onlineUserCount = chatroom.onlineUserCount;
    
    NSString *ext = chatroom.ext;
    NSDictionary *dict = [ext jsonObject];
    NSInteger anchorMicMuteInt = dict ? [dict[@"anchorMute"] boolValue] : 0;
    _micMute = (anchorMicMuteInt ==  1 ? YES : NO);
}

#pragma mark - <NSCoding>
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _roomId = [aDecoder decodeObjectForKey:kRoomId];
        _name = [aDecoder decodeObjectForKey:kName];
        _creator = [aDecoder decodeObjectForKey:kCreator];
        _thumbnail = [aDecoder decodeObjectForKey:kThumbnail];
        _onlineUserCount = [[aDecoder decodeObjectForKey:kOnlineUserCount] integerValue];
        _createTime = [[aDecoder decodeObjectForKey:kCreateTime] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_roomId forKey:kRoomId];
    [aCoder encodeObject:_name forKey:kName];
    [aCoder encodeObject:_creator forKey:kCreator];
    [aCoder encodeObject:_thumbnail forKey:kThumbnail];
    [aCoder encodeObject:@(_onlineUserCount) forKey:kOnlineUserCount];
    [aCoder encodeObject:@(_createTime) forKey:kCreateTime];
}

@end

@implementation NTESChatroomList

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (!dic) {
        return nil;
    }
    if (self = [super init]) {
        _total = [dic jsonInteger:@"total"];
        NSMutableArray *list = [NSMutableArray array];
        NSArray *listDics = [dic jsonArray:@"list"];
        [listDics enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NTESChatroomInfo *info = [[NTESChatroomInfo alloc] initWithDictionary:obj];
            if (info) {
                [list addObject:info];
            }
        }];
        _list = list;
    }
    return self;
}

@end
