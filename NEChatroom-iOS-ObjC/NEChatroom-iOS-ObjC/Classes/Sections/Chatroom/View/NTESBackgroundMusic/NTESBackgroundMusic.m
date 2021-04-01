//
//  NTESBackgroundMusic.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/29.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESBackgroundMusic.h"

@implementation NTESBackgroundMusic

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    NTESBackgroundMusic *other = object;
    if (self.title != other.title && ![self.title isEqual:other.title]) return NO;
    if (self.artist != other.artist && ![self.artist isEqual:other.artist]) return NO;
    if (self.albumName != other.albumName && ![self.albumName isEqual:other.albumName]) return NO;
    if (self.fileName != other.fileName && ![self.fileName isEqual:other.fileName]) return NO;
    return YES;
}

@end
