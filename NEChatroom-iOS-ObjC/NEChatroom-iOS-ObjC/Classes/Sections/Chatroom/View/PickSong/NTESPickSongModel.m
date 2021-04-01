//
//  NTESPickSongModel.m
//  NEChatroom-iOS-ObjC
//
//  Created by Think on 2021/2/2.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESPickSongModel.h"

@implementation NTESPickSongModel

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper;
{
    return @{ @"sid": @"id" };
}

@end

@implementation NTESPickSongList

+ (nullable NSDictionary<NSString *, id> *)modelContainerPropertyGenericClass
{
    return @{@"list": [NTESPickSongModel class]};
}

@end
