//
//  NTESPickSongModel.h
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 点歌模型
 */
@interface NTESPickSongModel : NSObject

@property (nonatomic, copy) NSString    *sid;
@property (nonatomic, copy) NSString    *name;
@property (nonatomic, copy) NSString    *singer;
@property (nonatomic, copy) NSString    *avatar;
@property (nonatomic, copy) NSString    *url;
@property (nonatomic, copy) NSString    *lyricUrl;
@property (nonatomic, copy) NSString    *duration;

@end

@interface NTESPickSongList : NSObject

@property (nonatomic, assign) int32_t   total;
@property (nonatomic, strong) NSArray<NTESPickSongModel *>   *list;

@end

NS_ASSUME_NONNULL_END
