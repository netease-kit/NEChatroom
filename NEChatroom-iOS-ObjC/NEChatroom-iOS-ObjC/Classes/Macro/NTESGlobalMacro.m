//
//  NTESGlobalMacro.m
//  NERtcAudioChatroom
//
//  Created by Netease on 2019/3/4.
//  Copyright © 2019年 netease. All rights reserved.
//

#import "NTESGlobalMacro.h"

void ntes_main_sync_safe(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

void ntes_main_async_safe(dispatch_block_t block){
    if ([NSThread isMainThread]) {
        block();
    }else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

bool isEmptyString(NSString *string) {
    if (string && [string length] > 0) {
        return false;
    }
    return true;
}
