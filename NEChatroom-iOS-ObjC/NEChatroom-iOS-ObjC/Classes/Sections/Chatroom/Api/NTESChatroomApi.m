//
//  NTESChatroomApi.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESChatroomApi.h"
#import "NTESPickSongModel.h"
#import "NTESChatroomInfo.h"

@implementation NTESChatroomApi

+ (void)fetchListWithRoomType:(NTESCreateRoomType)roomType offset:(int32_t)offset limit:(int32_t)limit completionHandle:(NTESRequestCompletion)completionHandle errorHandle:(NTESRequestError)errorHandle
{
    NSString *liveType = @"4";//默认语聊房
    if (roomType == NTESCreateRoomTypeKTV) {
        liveType = @"5";
    }
    NTESApiOptions *options = [[NTESApiOptions alloc] init];
    options.baseUrl = @"/voicechat/room/list";
    options.apiMethod = NTESRequestMethodPOST;
    options.params = @{
        @"roomType": liveType,
        @"offset": @(offset),
        @"limit": @(limit)
    };
    options.modelMapping = @[
//        [NTESApiModelMapping mappingWith:@"/data/list" mappingClass:[NTESChatroomInfo class] isArray:YES],
        [NTESApiModelMapping mappingWith:@"/data" mappingClass:[NSDictionary class] isArray:NO]
    ];
    
    NTESRequest *resuest = [[NTESRequest alloc] initWithOptions:options];
    resuest.completionBlock = completionHandle;
    resuest.errorBlock = errorHandle;
    [resuest asyncRequest];
}


+ (void)fetchMusicListWithPageLimit:(int32_t)pageLimit
                         pageOffset:(int32_t)pageOffset
                       successBlock:(nullable NTESRequestCompletion)successBlock
                         errorBlock:(nullable NTESRequestError)errorBlock
{
    NTESApiOptions *options = [[NTESApiOptions alloc] init];
    NSString *url = [NSString stringWithFormat:@"/voicechat/room/music/list?limit=%d&offset=%d", pageLimit, pageOffset];
    options.baseUrl = url;
    options.apiMethod = NTESRequestMethodPOST;
    options.modelMapping = @[
        [NTESApiModelMapping mappingWith:@"/data" mappingClass:[NTESPickSongList class] isArray:NO]
    ];
    
    NTESRequest *resuest = [[NTESRequest alloc] initWithOptions:options];
    resuest.completionBlock = successBlock;
    resuest.errorBlock = errorBlock;
    
    [resuest asyncRequest];
}

+ (void)fetchRoomThemeWithSuccessBlock:(nullable NTESRequestCompletion)successBlock
                            errorBlock:(nullable NTESRequestError)errorBlock {
  
        NTESApiOptions *options = [[NTESApiOptions alloc] init];
        options.baseUrl = @"/voicechat/room/getRandomRoomTopic";
        options.apiMethod = NTESRequestMethodPOST;
        options.params = @{

        };
        options.modelMapping = @[
            [NTESApiModelMapping mappingWith:@"/" mappingClass:[NSDictionary class] isArray:NO]
        ];
        
        NTESRequest *resuest = [[NTESRequest alloc] initWithOptions:options];
        resuest.completionBlock = successBlock;
        resuest.errorBlock = errorBlock;
        [resuest asyncRequest];
}

@end
