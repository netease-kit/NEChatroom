//
//  NTESEnumerationDefinition.h
//  NLiteAVDemo
//
//  Created by 徐善栋 on 2020/12/31.
//  Copyright © 2020 Netease. All rights reserved.
//

#ifndef NTESEnumerationDefinition_h
#define NTESEnumerationDefinition_h

typedef NS_ENUM(NSUInteger, NTESUserMode) {
    //主播
    NTESUserModeAnchor = 0,
    //观众
    NTESUserModeAudience = 1,
    //连麦者
    NTESUserModeConnector = 2,
};


typedef NS_ENUM(NSInteger,NTESCreateRoomType) {
    /// 语聊房
    NTESCreateRoomTypeChatRoom = 4,
    /// ktv
    NTESCreateRoomTypeKTV ,
};

typedef NS_ENUM(NSUInteger, NTESPushType)
{
    NTESPushTypeCdn = 0,//cdn方案
    NTESPushTypeRtc,//rtc方案

};





#endif /* NTESEnumerationDefinition_h */

