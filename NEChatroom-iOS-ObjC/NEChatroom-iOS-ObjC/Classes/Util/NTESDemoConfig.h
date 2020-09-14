//
//  NTESDemoConfig.h
//  NERtcAudioChatroom
//
//  Created by Simon Blue on 2019/1/16.
//  Copyright © 2019年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NTESDemoConfig : NSObject

+ (instancetype)sharedConfig;

@property (nonatomic,copy)  NSString    *appKey;
@property (nonatomic,copy)  NSString    *apiURL;

@end

