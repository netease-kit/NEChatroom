//
//  NTESAccountInfo.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/16.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESAccountInfo.h"
#import "NSDictionary+NTESJson.h"

static NSString *const kSidKey = @"sid";
static NSString *const kAccountKey = @"account";
static NSString *const kNickNameKey = @"nickName";
static NSString *const kIconKey = @"icon";
static NSString *const kTokenKey = @"token";
static NSString *const kAvailableTimeKey = @"availableTime";

@implementation NTESAccountInfo

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (!dic) {
        return nil;
    }
    if (self = [super init]) {
        _sid = [dic jsonString:@"sid"];
        _account = [dic jsonString:@"accid"];
        _nickName = [dic jsonString:@"nickname"];
        _icon = [dic jsonString:@"icon"];
        _token = [dic jsonString:@"imToken"];
        _availableTime = [dic jsonInteger:@"availableAt"];
    }
    return self;
}

- (int64_t)uid {
    if ([_account hasPrefix:@"user"]) {
        return [[_account substringFromIndex:4] longLongValue];
    }
    return [_account longLongValue];
}

- (BOOL)valid {
//    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970]*1000;//当前时间戳
//    return (timestamp < _availableTime);
    return NO;
}

#pragma mark - <NSCoding>
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _sid = [aDecoder decodeObjectForKey:kSidKey];
        _account = [aDecoder decodeObjectForKey:kAccountKey];
        _nickName = [aDecoder decodeObjectForKey:kNickNameKey];
        _icon = [aDecoder decodeObjectForKey:kIconKey];
        _token = [aDecoder decodeObjectForKey:kTokenKey];
        _availableTime = [[aDecoder decodeObjectForKey:kAvailableTimeKey] integerValue];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_sid forKey:kSidKey];
    [aCoder encodeObject:_account forKey:kAccountKey];
    [aCoder encodeObject:_nickName forKey:kNickNameKey];
    [aCoder encodeObject:_icon forKey:kIconKey];
    [aCoder encodeObject:_token forKey:kTokenKey];
    [aCoder encodeObject:@(_availableTime) forKey:kAvailableTimeKey];
}

- (NSString *)description {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"account"] = _account ?: @"";
    dic[@"token"] = _token ?: @"";
    dic[@"nickName"] = _nickName ?: @"";
    dic[@"icon"] = _icon ?: @"";
    dic[@"sid"] = _sid ?: @"";
    dic[@"availableTime"] = @(_availableTime);
    return [dic description];
}

@end
