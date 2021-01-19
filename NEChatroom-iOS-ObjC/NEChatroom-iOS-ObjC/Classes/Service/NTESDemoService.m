//
//  NTESDemoService.m
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/15.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESDemoService.h"

@interface NTESDemoService ()
@property (nonatomic, assign) NSInteger currentRoomListPage;
@property (nonatomic, assign) NSInteger roomListCountPerPage;
@end

@implementation NTESDemoService

- (instancetype)init {
    if (self = [super init]) {
        _currentRoomListPage = 0;
        _roomListCountPerPage = 20;
    }
    return self;
}

+ (instancetype)sharedService
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

- (void)requestUserAccount:(NSString *)sid
                completion:(NTESAccountHandler)completion;
{
    NTESDemoAccountTask *task = [[NTESDemoAccountTask alloc] init];
    task.sid = sid;
    task.handler = completion;
    [self runTask:task];
}


- (void)requestRefreshChatroomList:(NTESChatroomHandler)completion {
    NTESDemoChatroomListTask *task = [[NTESDemoChatroomListTask alloc] init];
    task.limit = _currentRoomListPage * _roomListCountPerPage;
    task.offset = _roomListCountPerPage;
    task.handler = completion;
    [self runTask:task];
}

- (void)createChatroomWithSid:(NSString *)sid
                     roomName:(NSString *)roomName
                    pushType:(NSInteger)pushType
                   completion:(NTESCreateChatroomHandler)completion;
{
    NTESDemoCreateChatroomTask *task = [[NTESDemoCreateChatroomTask alloc] init];
    task.sid = sid;
    task.roomName = roomName;
    task.pushType = pushType;
    task.handler = completion;
    [self runTask:task];
}

- (void)closeChatroomWithSid:(NSString *)sid
                      roomId:(NSInteger )roomId
                  completion:(NTESCommonHandler)completion;
{
    NTESDemoCloseChatroomTask *task = [[NTESDemoCloseChatroomTask alloc] init];
    task.sid = sid;
    task.roomId = roomId;
    task.handler = completion;
    [self runTask:task];
}

- (void)muteChatroomWithSid:(NSString *)sid
                     roomId:(NSInteger)roomId
                       mute:(BOOL)mute
                 completion:(NTESCommonHandler)completion {
    NTESDemoMuteAllTask *task = [[NTESDemoMuteAllTask alloc] init];
    task.sid = sid;
    task.roomId = roomId;
    task.mute = mute;
    task.needNotifiy = YES;
    task.notifyExt = NO;
    task.handler = completion;
    [self runTask:task];
}

- (void)requestChatrommListWithLimit:(NSInteger)limit
                              offset:(NSInteger)offset
                          completion:(NTESChatroomHandler)completion {
    NTESDemoChatroomListTask *task = [[NTESDemoChatroomListTask alloc] init];
    task.limit = limit;
    task.offset = offset;
    task.handler = completion;
    [self runTask:task];
}

- (void)runTask:(id<NTESDemoServiceTask>)task
{
    NSURLRequest *request = [task taskRequest];
    
    NSURLSessionTask *sessionTask =
    [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable connectionError) {
                                        
                                        id jsonData = nil;
                                        NSError *error = nil;
                                        
                                        if (connectionError == nil && [response isKindOfClass:[NSHTTPURLResponse class]]) {
                                            NSInteger status = [(NSHTTPURLResponse *)response statusCode];
                                            if (status == 200 && data) {
                                                jsonData = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:0
                                                                                             error:nil];
                                                if ([jsonData isKindOfClass:[NSDictionary class]]) {
                                                    NSDictionary *dict = jsonData;
                                                    if ([dict objectForKey:@"code"]) {
                                                        long code = [[dict objectForKey:@"code"] longValue];
                                                        if (code != 200) {
                                                            error = [NSError errorWithDomain:@"ntes domain"
                                                                                        code:code
                                                                                    userInfo:nil];
                                                        }
                                                    }
                                                }
                                            }
                                            else{
                                                error = [NSError errorWithDomain:@"ntes domain"
                                                                            code:status
                                                                        userInfo:nil];
                                            }
                                        }
                                        else {
                                            error = [NSError errorWithDomain:@"ntes domain"
                                                                        code:-1
                                                                    userInfo:@{@"description" : @"connection error"}];
                                        }
                                        
                                        ntes_main_sync_safe(^{
                                            [task onGetResponse:jsonData error:error];
                                        });
                                    }];
    
    [sessionTask resume];
}




@end
