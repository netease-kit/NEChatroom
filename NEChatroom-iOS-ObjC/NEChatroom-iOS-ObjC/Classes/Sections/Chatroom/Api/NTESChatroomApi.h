//
//  NTESChatroomApi.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface NTESChatroomApi : NSObject

/// 请求直播列表
/// @param roomType 房间类型
/// @param offset 分页偏移量
/// @param limit 分页大小
/// @param completionHandle - 请求完成闭包
/// @param errorHandle - 请求失败闭包
+ (void)fetchListWithRoomType:(NTESCreateRoomType)roomType
                  offset:(int32_t)offset
                 limit:(int32_t)limit
         completionHandle:(nullable NTESRequestCompletion)completionHandle
              errorHandle:(nullable NTESRequestError)errorHandle;


/**
 获取点歌列表
 @param pageLimit       - 每页数据数量
 @param pageOffset      - 页面偏移
 @param successBlock    - 请求成功闭包
 @param errorBlock      - 请求失败闭包
 */
+ (void)fetchMusicListWithPageLimit:(int32_t)pageLimit
                         pageOffset:(int32_t)pageOffset
                       successBlock:(nullable NTESRequestCompletion)successBlock
                         errorBlock:(nullable NTESRequestError)errorBlock;


/**
 随机获取直播间主题
 @param successBlock    - 请求成功闭包
 @param errorBlock      - 请求失败闭包
 */
+ (void)fetchRoomThemeWithSuccessBlock:(nullable NTESRequestCompletion)successBlock
                         errorBlock:(nullable NTESRequestError)errorBlock;
@end

NS_ASSUME_NONNULL_END
