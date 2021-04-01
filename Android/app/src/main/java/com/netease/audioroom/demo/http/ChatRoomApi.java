package com.netease.audioroom.demo.http;

import com.netease.audioroom.demo.http.model.AccountInfoResp;
import com.netease.audioroom.demo.http.model.MusicListResp;
import com.netease.audioroom.demo.http.model.RoomInfoResp;
import com.netease.yunxin.android.lib.network.common.BaseResponse;

import java.util.Map;

import io.reactivex.Single;
import retrofit2.http.POST;
import retrofit2.http.QueryMap;

import static com.netease.audioroom.demo.http.ChatRoomNetConstants.URL_ACCOUNT_FETCH;
import static com.netease.audioroom.demo.http.ChatRoomNetConstants.URL_ROOM_CREATE;
import static com.netease.audioroom.demo.http.ChatRoomNetConstants.URL_ROOM_DISSOLVE;
import static com.netease.audioroom.demo.http.ChatRoomNetConstants.URL_ROOM_LIST_FETCH;
import static com.netease.audioroom.demo.http.ChatRoomNetConstants.URL_ROOM_MUSIC_LIST;
import static com.netease.audioroom.demo.http.ChatRoomNetConstants.URL_ROOM_MUTE_ALL;
import static com.netease.audioroom.demo.http.ChatRoomNetConstants.URL_ROOM_RANDOM_TOPIC;

/**
 * Created by luc on 12/23/20.
 */
public interface ChatRoomApi {

    /**
     * 获取聊天室房间列表
     */
    @POST(URL_ROOM_LIST_FETCH)
    Single<BaseResponse<RoomInfoResp>> fetchRoomList(@QueryMap Map<String, Object> body);

    /**
     * 获取 IM 账号
     */
    @POST(URL_ACCOUNT_FETCH)
    Single<BaseResponse<AccountInfoResp>> fetchAccount(@QueryMap Map<String, Object> body);

    /**
     * 创建聊天室房间
     */
    @POST(URL_ROOM_CREATE)
    Single<BaseResponse<RoomInfoResp.RoomInfoItem>> createRoom(@QueryMap Map<String, Object> body);

    /**
     * 关闭聊天室
     */
    @POST(URL_ROOM_DISSOLVE)
    Single<BaseResponse<Void>> closeRoom(@QueryMap Map<String, Object> body);

    /**
     * 全员禁言
     */
    @POST(URL_ROOM_MUTE_ALL)
    Single<BaseResponse<Void>> muteAll(@QueryMap Map<String, Object> body);

    /**
     * 获取歌单
     *
     * @param body
     * @return
     */
    @POST(URL_ROOM_MUSIC_LIST)
    Single<BaseResponse<MusicListResp>> getMusicList(@QueryMap Map<String, Object> body);

    /**
     * 获取随机主题
     */
    @POST(URL_ROOM_RANDOM_TOPIC)
    Single<BaseResponse<String>> getRandomTopic();


}
