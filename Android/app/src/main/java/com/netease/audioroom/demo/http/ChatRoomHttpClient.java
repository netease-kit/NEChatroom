package com.netease.audioroom.demo.http;

import com.netease.audioroom.demo.http.model.AccountInfoResp;
import com.netease.audioroom.demo.http.model.MusicListResp;
import com.netease.audioroom.demo.http.model.RoomInfoResp;
import com.netease.audioroom.demo.model.AccountInfo;
import com.netease.yunxin.android.lib.network.common.BaseResponse;
import com.netease.yunxin.android.lib.network.common.NetworkClient;
import com.netease.yunxin.android.lib.network.common.transform.CommonScheduleThread;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.Music;

import org.json.JSONException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.reactivex.annotations.NonNull;
import io.reactivex.observers.ResourceSingleObserver;

/**
 * 网易云信Demo聊天室Http客户端。第三方开发者请连接自己的应用服务器。
 * <p>
 * 服务端文档：http://doc.hz.netease.com/pages/viewpage.action?pageId=174719257
 */
public class ChatRoomHttpClient {

    private static class InstanceHolder {
        private static final ChatRoomHttpClient INSTANCE = new ChatRoomHttpClient();
    }

    public static ChatRoomHttpClient getInstance() {
        return InstanceHolder.INSTANCE;
    }

    private ChatRoomHttpClient() {
    }

    /**
     * 向网易云信Demo应用服务器请求聊天室列表
     */
    public void fetchChatRoomList(int offset, int limit, int roomType, final ChatRoomHttpCallback<ArrayList<VoiceRoomInfo>> callback) {
        ChatRoomApi api = NetworkClient.getInstance().getService(ChatRoomApi.class);
        Map<String, Object> map = new HashMap<>(2);
        map.put(ChatRoomNetConstants.PARAM_OFFSET, offset);
        map.put(ChatRoomNetConstants.PARAM_LIMIT, limit);
        map.put(ChatRoomNetConstants.PARAM_ROOM_TYPE, roomType);
        api.fetchRoomList(map).compose(new CommonScheduleThread<>()).subscribe(new ResourceSingleObserver<BaseResponse<RoomInfoResp>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<RoomInfoResp> response) {
                if (callback == null) {
                    return;
                }
                if (response.isSuccessful() && response.data != null) {
                    callback.onSuccess(response.data.toVoiceRoomInfoList());
                } else {
                    callback.onFailed(response.code, response.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {
                if (callback == null) {
                    return;
                }
                e.printStackTrace();
                if (e instanceof JSONException) {
                    callback.onFailed(-1, e.getMessage());
                } else {
                    callback.onFailed(-2, e.getMessage());
                }
            }
        });
    }

    /**
     * 获取帐号
     */
    public void fetchAccount(String accountId, final ChatRoomHttpCallback<AccountInfo> fetchAccountCallBack) {
        ChatRoomApi api = NetworkClient.getInstance().getService(ChatRoomApi.class);
        Map<String, Object> map = new HashMap<>(1);
        map.put(ChatRoomNetConstants.PARAM_SID, accountId);
        api.fetchAccount(map).compose(new CommonScheduleThread<>()).subscribe(new ResourceSingleObserver<BaseResponse<AccountInfoResp>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<AccountInfoResp> response) {
                if (fetchAccountCallBack == null) {
                    return;
                }
                if (response.isSuccessful() && response.data != null) {
                    fetchAccountCallBack.onSuccess(response.data.toAccountInfo());
                } else {
                    fetchAccountCallBack.onFailed(response.code, response.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {
                if (fetchAccountCallBack != null) {
                    fetchAccountCallBack.onFailed(-1, e.getMessage());
                }
            }
        });
    }

    /**
     * 主播创建直播间
     */
    public void createRoom(String account, String roomName, int pushType, int roomType, final ChatRoomHttpCallback<VoiceRoomInfo> callback) {
        ChatRoomApi api = NetworkClient.getInstance().getService(ChatRoomApi.class);
        Map<String, Object> map = new HashMap<>(3);
        if (roomType != 0) {
            map.put(ChatRoomNetConstants.PARAM_ROOM_TYPE, roomType);
        }
        map.put(ChatRoomNetConstants.PARAM_SID, account);
        map.put(ChatRoomNetConstants.PARAM_ROOM_NAME, roomName);
        map.put(ChatRoomNetConstants.PARAM_PUSH_TYPE, pushType);
        api.createRoom(map).compose(new CommonScheduleThread<>()).subscribe(new ResourceSingleObserver<BaseResponse<RoomInfoResp.RoomInfoItem>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<RoomInfoResp.RoomInfoItem> response) {
                if (callback == null) {
                    return;
                }
                if (response.isSuccessful() && response.data != null) {
                    callback.onSuccess(response.data.toVoiceRoomInfo());
                } else {
                    callback.onFailed(response.code, response.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {
                if (callback == null) {
                    return;
                }
                e.printStackTrace();
                callback.onFailed(-1, e.getMessage());
            }
        });
    }

    /**
     * 解散房间
     */
    public void closeRoom(String account, String roomID, final ChatRoomHttpCallback<?> callback) {
        ChatRoomApi api = NetworkClient.getInstance().getService(ChatRoomApi.class);
        Map<String, Object> map = new HashMap<>(2);
        map.put(ChatRoomNetConstants.PARAM_SID, account);
        map.put(ChatRoomNetConstants.PARAM_ROOM_ID, roomID);
        api.closeRoom(map).compose(new CommonScheduleThread<>()).subscribe(new ResourceSingleObserver<BaseResponse<Void>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<Void> response) {
                if (callback == null) {
                    return;
                }
                if (response.isSuccessful()) {
                    callback.onSuccess(null);
                } else {
                    callback.onFailed(response.code, response.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {
                if (callback == null) {
                    return;
                }
                e.printStackTrace();
                callback.onFailed(-1, e.getMessage());
            }
        });
    }

    /**
     * 禁言所有成员节目
     */
    public void muteAll(String account, String roomID, boolean mute, boolean needNotify, boolean notifyExt, final ChatRoomHttpCallback<?> callback) {
        ChatRoomApi api = NetworkClient.getInstance().getService(ChatRoomApi.class);
        Map<String, Object> map = new HashMap<>(5);
        map.put(ChatRoomNetConstants.PARAM_SID, account);
        map.put(ChatRoomNetConstants.PARAM_ROOM_ID, roomID);
        map.put(ChatRoomNetConstants.PARAM_IS_MUTE, mute);
        map.put("needNotify", needNotify);
        map.put("notifyExt", notifyExt);

        api.muteAll(map).compose(new CommonScheduleThread<>()).subscribe(new ResourceSingleObserver<BaseResponse<Void>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<Void> response) {
                if (callback == null) {
                    return;
                }
                if (response.isSuccessful()) {
                    callback.onSuccess(null);
                } else {
                    callback.onFailed(response.code, response.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {
                if (callback == null) {
                    return;
                }
                e.printStackTrace();
                callback.onFailed(-1, e.getMessage());
            }
        });
    }

    public void getMusicList(final ChatRoomHttpCallback<List<Music>> callback, int limit, int offset) {
        ChatRoomApi api = NetworkClient.getInstance().getService(ChatRoomApi.class);
        Map<String, Object> params = new HashMap<>(2);
        params.put("limit", limit);
        params.put("offset", offset);
        api.getMusicList(params).compose(new CommonScheduleThread<>()).subscribe(new ResourceSingleObserver<BaseResponse<MusicListResp>>() {
            @Override
            public void onSuccess(@NonNull BaseResponse<MusicListResp> response) {
                if (callback == null) {
                    return;
                }
                if (response.isSuccessful()) {
                    callback.onSuccess(response.data.list);
                } else {
                    callback.onFailed(response.code, response.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {
                if (callback == null) {
                    return;
                }
                e.printStackTrace();
                callback.onFailed(-1, e.getMessage());
            }
        });
    }

    public void getRandomTopic(final ChatRoomHttpCallback<String> callback){
        ChatRoomApi api = NetworkClient.getInstance().getService(ChatRoomApi.class);
        api.getRandomTopic().compose(new CommonScheduleThread<>()).subscribe(new ResourceSingleObserver<BaseResponse<String>>() {

            @Override
            public void onSuccess(@NonNull BaseResponse<String> response) {
                if (callback == null) {
                    return;
                }
                if (response.isSuccessful()) {
                    callback.onSuccess(response.data);
                } else {
                    callback.onFailed(response.code, response.msg);
                }
            }

            @Override
            public void onError(@NonNull Throwable e) {
                if (callback == null) {
                    return;
                }
                e.printStackTrace();
                callback.onFailed(-1, e.getMessage());
            }
        });
    }

    public interface ChatRoomHttpCallback<T> {

        void onSuccess(T t);

        void onFailed(int code, String errorMsg);
    }
}
