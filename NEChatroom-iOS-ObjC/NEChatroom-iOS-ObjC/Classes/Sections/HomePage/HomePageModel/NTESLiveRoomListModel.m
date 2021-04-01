//
//  NTESLiveRoomListModel.m
//  NEChatroom-iOS-ObjC
//
//  Created by vvj on 2021/2/3.
//  Copyright © 2021 netease. All rights reserved.
//

#import "NTESLiveRoomListModel.h"

@implementation NTESLiveRoomListModel

+ (NSDictionary *)modelContainerPropertyGenericClass
{
  return @{@"liveConfig" : [NETSLiveRoomConfigModel class]};
}

@end


@implementation NETSLiveRoomConfigModel


@end
