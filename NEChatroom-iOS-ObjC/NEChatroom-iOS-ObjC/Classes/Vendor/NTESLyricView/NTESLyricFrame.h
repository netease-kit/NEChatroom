//
//  NTESLyricFrame.h
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/25.
//  Copyright © 2021 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESLyricFrame : NSObject

/**
 对应时间
 */
@property (nonatomic, assign) NSTimeInterval time;

/**
 歌词内容
 */
@property (nonatomic, copy) NSString *content;

/**
 解析歌词文件
 */
+ (NSArray<NTESLyricFrame *> *)arrayWithContentsOfFile:(NSString *)path;

/**
 解析歌词内容
 */
+ (NSArray<NTESLyricFrame *> *)arrayWithContents:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
