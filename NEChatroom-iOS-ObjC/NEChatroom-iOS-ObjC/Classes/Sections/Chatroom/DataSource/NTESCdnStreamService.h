//
//  NTESCdnStreamService.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/1/20.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NERtcSDK/NERtcSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESCdnStreamService : NSObject


/// 是否包含某uid
/// @param uid uid
/// @param dataSource users数组
+ (BOOL)isContainUid:(uint64_t )uid dataSource:(NSMutableArray *)dataSource;

/// 获取目标NERtcLiveStreamUserTranscoding
/// @param uid 进入或离开房间的uid
/// @param dataSource users数组
+ (NERtcLiveStreamUserTranscoding *)getTargetDataWithUid:(uint64_t )uid dataSource:(NSMutableArray *)dataSource;





@end

NS_ASSUME_NONNULL_END
