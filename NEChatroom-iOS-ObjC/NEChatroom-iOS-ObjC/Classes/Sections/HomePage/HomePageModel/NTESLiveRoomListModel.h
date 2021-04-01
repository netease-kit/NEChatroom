//
//  NTESLiveRoomListModel.h
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 直播间配置模型
 */
@interface NETSLiveRoomConfigModel : NSObject

@property (nonatomic, copy)     NSString    *httpPullUrl;
@property (nonatomic, copy)     NSString    *rtmpPullUrl;
@property (nonatomic, copy)     NSString    *hlsPullUrl;
@property (nonatomic, copy)     NSString    *pushUrl;
@property (nonatomic, copy)     NSString    *cid;
@property (nonatomic, strong)   NSDictionary    *config;

@end


@interface NTESLiveRoomListModel : NSObject

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *creator;
@property (nonatomic, copy) NSString *thumbnail;
@property (nonatomic, assign) NSInteger onlineUserCount;
@property (nonatomic, assign) uint64_t createTime;
@property(nonatomic, assign) NSInteger pushType;
@property(nonatomic, assign) NSInteger roomType;
@property(nonatomic, copy) NSString *currentMusicName;
@property(nonatomic, copy) NSString *currentMusicAuthor;
@property(nonatomic, strong) NETSLiveRoomConfigModel *liveConfig;
@end



NS_ASSUME_NONNULL_END
