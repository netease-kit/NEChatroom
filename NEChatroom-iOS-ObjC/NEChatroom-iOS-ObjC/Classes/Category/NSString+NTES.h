//
//  NSString+NTES.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/25.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (NTES)

- (BOOL)isChinese;

- (nullable id)jsonObject;

@end

NS_ASSUME_NONNULL_END
