//
//  NTESDemoTask.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/15.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESDemoTask.h"
#import "NTESAccountInfo.h"
#import "NTESDemoConfig.h"
#import "NTESChatroomInfo.h"
#import "NSDictionary+NTESJson.h"

@implementation NTESDemoAccountTask

- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[NTESDemoConfig sharedConfig].apiURL stringByAppendingString:@"/user/get"];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:10];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    if (self.sid) {
        NSString *postString = self.sid;
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error {
    NTESAccountInfo *accountInfo = nil;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *jsonDic = (NSDictionary *)jsonObject;
        NSDictionary *data = [jsonDic jsonDict:@"data"];
        accountInfo = [[NTESAccountInfo alloc] initWithDictionary:data];
    }
    if (_handler) {
        _handler(accountInfo, error);
    }
}
@end


@implementation NTESDemoChatroomListTask

- (instancetype)init {
    if (self = [super init]) {
        _limit = -1;
        _offset = -1;
    }
    return self;
}

- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[NTESDemoConfig sharedConfig].apiURL stringByAppendingString:@"/room/list"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:10];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableString *postString = [NSMutableString string];
    if (_limit >= 0) {
        [postString appendFormat:@"limit=%ld", (long)_limit];
    }
    if (postString.length > 0) {
        [postString appendString:@"&&"];
    }
    if (_offset >= 0) {
        [postString appendFormat:@"offset=%ld", (long)_offset];
    }
    if (postString.length > 0) {
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error {
    NTESChatroomList *chatroomList = nil;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *jsonDic = (NSDictionary *)jsonObject;
        NSDictionary *data = [jsonDic jsonDict:@"data"];
        chatroomList = [[NTESChatroomList alloc] initWithDictionary:data];
    }
    if (_handler) {
        _handler(chatroomList.list, error);
    }
}

@end

@implementation  NTESDemoCreateChatroomTask

- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[NTESDemoConfig sharedConfig].apiURL stringByAppendingString:@"/room/create"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:10];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postString = [NSString stringWithFormat:@"sid=%@&roomName=%@",self.sid ? : @"" ,self.roomName ? : @""];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error {
    NTESChatroomInfo *chatroomInfo = nil;
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *jsonDic = (NSDictionary *)jsonObject;
        NSDictionary *data = [jsonDic jsonDict:@"data"];
        chatroomInfo = [[NTESChatroomInfo alloc] initWithDictionary:data];
    }
    if (_handler) {
        _handler(chatroomInfo, error);
    }
}
@end


@implementation NTESDemoCloseChatroomTask

- (NSURLRequest *)taskRequest
{
    NSString *urlString = [[NTESDemoConfig sharedConfig].apiURL stringByAppendingString:@"/room/dissolve"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:10];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *postString = [NSString stringWithFormat:@"sid=%@&roomId=%ld",self.sid ? : @"" ,(long)_roomId];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error {
    if (_handler) {
        _handler(error);
    }
}

@end

@implementation NTESDemoMuteAllTask

- (instancetype)init {
    if (self = [super init]) {
        _needNotifiy = YES;
    }
    return self;
}

- (NSURLRequest *)taskRequest {
    NSString *urlString = [[NTESDemoConfig sharedConfig].apiURL stringByAppendingString:@"/room/mute"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:10];
    [request setHTTPMethod:@"Post"];
    [request addValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSMutableString *postString = [NSMutableString string];
    [postString appendFormat:@"sid=%@", _sid ?: @""];
    [postString appendFormat:@"&&roomId=%ld", (long)_roomId];
    [postString appendFormat:@"&&mute=%@", _mute?@"true":@"false"];
    [postString appendFormat:@"&&needNotify=%@", _needNotifiy?@"true":@"false"];
    [postString appendFormat:@"&&notifyExt=%@", _notifyExt?@"true":@"false"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    return request;
}

- (void)onGetResponse:(id)jsonObject error:(NSError *)error {
    if (_handler) {
        _handler(error);
    }
}
@end
