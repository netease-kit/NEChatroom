//
//  NTESCdnStreamService.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/20.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESCdnStreamService.h"


@implementation NTESCdnStreamService

+ (BOOL)isContainUid:(uint64_t )uid dataSource:(NSMutableArray *)dataSource {
    for (NERtcLiveStreamUserTranscoding *liveStreamUser in dataSource) {
        if (liveStreamUser.uid == uid) {
            return YES;
        }
    }
    return NO;
}


+ (NERtcLiveStreamUserTranscoding *)getTargetDataWithUid:(uint64_t )uid dataSource:(NSMutableArray *)dataSource{
    for (NERtcLiveStreamUserTranscoding *liveStreamUser in dataSource) {
        if (liveStreamUser.uid == uid) {
            return liveStreamUser;
        }
    }
    return nil;
}
@end
