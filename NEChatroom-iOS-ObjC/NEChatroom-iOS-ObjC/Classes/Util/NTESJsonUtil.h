//
//  NTESJsonUtil.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/24.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NTESJsonUtil : NSObject

+ (nullable NSDictionary *)dictByJsonData:(NSData *)data;

+ (nullable NSDictionary *)dictByJsonString:(NSString *)jsonString;

+ (NSString *)jsonString:(NSString *)destinationJsonString addJsonString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
