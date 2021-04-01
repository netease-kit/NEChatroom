package com.netease.audioroom.demo.http;

/**
 * Created by luc on 12/24/20.
 */
public @interface ChatRoomNetConstants {
    int PUSH_TYPE_RTC = 1; //rtc 推流
    int PUSH_TYPE_CDN = 0;//cdn 推流

    int ROOM_TYPE_CHAT = 4;// 语聊房
    int ROOM_TYPE_KTV = 5;// ktv

    // 请求参数
    String PARAM_LIMIT = "limit";
    String PARAM_OFFSET = "offset";
    String PARAM_SID = "sid";
    String PARAM_ROOM_NAME = "roomName"; // 直播间名字
    String PARAM_IS_MUTE = "mute"; // 直播间名字
    String PARAM_ROOM_ID = "roomId";
    String PARAM_PUSH_TYPE = "pushType"; //推流类型 1RTC推流, 0 CDN推流
    String PARAM_ROOM_TYPE = "roomType";//房间类型 4 语聊房 5 Ktv

    // 请求链接相对路径
    String URL_ACCOUNT_FETCH = "user/get";
    String URL_ROOM_LIST_FETCH = "room/list";
    String URL_ROOM_CREATE = "room/create";
    String URL_ROOM_DISSOLVE = "room/dissolve";
    String URL_ROOM_MUTE_ALL = "room/mute";
    String URL_ROOM_MUSIC_LIST = "room/music/list";
    String URL_ROOM_RANDOM_TOPIC = "room/getRandomRoomTopic";
}
