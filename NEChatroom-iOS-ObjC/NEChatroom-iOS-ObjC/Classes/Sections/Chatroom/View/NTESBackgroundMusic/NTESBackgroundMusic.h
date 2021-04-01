//
//  NTESBackgroundMusic.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/29.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESBackgroundMusic : NSObject

/**
 曲名
 */
@property (nonatomic, copy) NSString *title;

/**
 歌手
 */
@property (nonatomic, copy) NSString *artist;

/**
 专辑
 */
@property (nonatomic, copy) NSString *albumName;

/**
 路径
 */
@property (nonatomic, copy) NSString *fileName;


@end

NS_ASSUME_NONNULL_END
