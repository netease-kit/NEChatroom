package com.netease.audioroom.demo.http;

import android.util.Log;

import com.netease.audioroom.demo.cache.DemoCache;
import com.netease.audioroom.demo.config.DemoServers;
import com.netease.audioroom.demo.model.AccountInfo;
import com.netease.yunxin.nertc.nertcvoiceroom.model.VoiceRoomInfo;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

/**
 * 网易云信Demo聊天室Http客户端。第三方开发者请连接自己的应用服务器。
 * <p>
 * 服务端文档：http://doc.hz.netease.com/pages/viewpage.action?pageId=174719257
 */
public class ChatRoomHttpClient {

    private static final String TAG = "AudioRoom";

    // code
    private static final int RESULT_CODE_SUCCESS = 200;

    // api
    private static final String API_CHAT_ROOM_LIST = "room/list";
    private static final String API_GET_USER = "user/get";
    private static final String API_CREATE_ROOM = "room/create";
    private static final String API_CLOSE_ROOM = "room/dissolve";
    private static final String API_ALL_MUTE = "room/mute";


    private static final String HEADER_KEY_CONTENT_TYPE = "Content-Type";

    // result
    private static final String RESULT_KEY_RES = "code";
    private static final String RESULT_KEY_MSG = "msg";
    private static final String RESULT_KEY_DATA = "data";

    // room list result
    private static final String RESULT_KEY_LIST = "list";
    private static final String RESULT_KEY_ROOM_ID = "roomId";
    private static final String RESULT_KEY_NAME = "name";
    private static final String RESULT_KEY_ONLINE_USER_COUNT = "onlineUserCount";
    private static final String RESULT_KEY_BACKGROUND_URL = "thumbnail";
    private static final String RESULT_KEY_CREATOR = "creator";

    //user account result
    private static final String RESULT_KEY_ACCOUNT = "accid";
    private static final String RESULT_KEY_NICK = "nickname";
    private static final String RESULT_KEY_TOKEN = "imToken";
    private static final String RESULT_KEY_AVATAR = "icon";
    private static final String RESULT_KEY_AVAILABLEAT = "availableAt";

    // request
    private static final String REQUEST_LIMIT = "limit";
    private static final String REQUEST_OFFSET = "offset";
    private static final String REQUEST_SID = "sid";
    private static final String REQUEST_ROOM_NAME = "roomName"; // 直播间名字
    private static final String REQUEST_IS_MUTE = "mute"; // 直播间名字


    public static ChatRoomHttpClient getInstance() {
        return InstanceHolder.INSTANCE;
    }

    private ChatRoomHttpClient() {
        NimHttpClient.getInstance().init(DemoCache.getContext());
    }

    /**
     * 向网易云信Demo应用服务器请求聊天室列表
     */
    public void fetchChatRoomList(int offset, int limit, final ChatRoomHttpCallback<ArrayList<VoiceRoomInfo>> callback) {
        String url = DemoServers.audioRoomAPIServer() + API_CHAT_ROOM_LIST;
        String body = null;
        if (offset >= 0 && limit > 0) {
            body = REQUEST_OFFSET + "=" + offset + "&" +
                    REQUEST_LIMIT + "=" + limit;
        }
        Map<String, String> headers = new HashMap<>(1);
        headers.put(HEADER_KEY_CONTENT_TYPE, "application/x-www-form-urlencoded;charset=utf-8");

        NimHttpClient.getInstance().execute(url, headers, body, (response, code, errorMsg) -> {
            if (callback == null) {
                return;
            }
            if (code != 0) {
                Log.e(TAG, "fetchChatRoomList failed : code = " + code + ", errorMsg = " + errorMsg);
                callback.onFailed(code, errorMsg);
                return;
            }
            Log.i(TAG, "fetchChatRoomList  : response = " + response);
            try {
                JSONObject res = new JSONObject(response);
                int resCode = res.optInt(RESULT_KEY_RES);
                errorMsg = res.optString(RESULT_KEY_MSG, null);
                if (resCode == RESULT_CODE_SUCCESS) {
                    JSONObject data = res.getJSONObject(RESULT_KEY_DATA);
                    ArrayList<VoiceRoomInfo> demoRoomInfoList = new ArrayList<>();
                    if (data != null) {
                        JSONArray jsonArray = data.getJSONArray(RESULT_KEY_LIST);
                        for (int i = 0; i < jsonArray.length(); i++) {
                            // room 3
                            JSONObject object = jsonArray.getJSONObject(i);

                            VoiceRoomInfo roomInfo = new VoiceRoomInfo();

                            roomInfo.setRoomId(object.optString(RESULT_KEY_ROOM_ID));
                            roomInfo.setName(object.optString(RESULT_KEY_NAME));
                            roomInfo.setOnlineUserCount(object.optInt(RESULT_KEY_ONLINE_USER_COUNT));
                            roomInfo.setThumbnail(object.optString(RESULT_KEY_BACKGROUND_URL));
                            roomInfo.setCreatorAccount(object.optString(RESULT_KEY_CREATOR));
                            demoRoomInfoList.add(roomInfo);
                        }
                    }
                    callback.onSuccess(demoRoomInfoList);
                    return;
                }

                callback.onFailed(resCode, errorMsg);

            } catch (JSONException e) {
                e.printStackTrace();
                callback.onFailed(-1, e.getMessage());
            } catch (Exception e) {
                e.printStackTrace();
                callback.onFailed(-2, e.getMessage());
            }
        });
    }

    /**
     * 获取帐号
     */
    public void fetchAccount(String accountId, final ChatRoomHttpCallback<AccountInfo> fetchAccountCallBack) {
        String url = DemoServers.audioRoomAPIServer() + API_GET_USER;
        String body = null;

        if (accountId != null) {
            body = REQUEST_SID + "=" + accountId;
        }
        Map<String, String> headers = new HashMap<>(1);
        headers.put(HEADER_KEY_CONTENT_TYPE, "application/x-www-form-urlencoded;charset=utf-8");
        NimHttpClient.getInstance().execute(url, headers, body, (response, code, errorMsg) -> {
            if (fetchAccountCallBack == null) {
                return;
            }

            if (code != 0) {
                Log.e(TAG, "fetchAccount failed : code = " + code + ", errorMsg = " + errorMsg);
                fetchAccountCallBack.onFailed(code, errorMsg);
                return;
            }
            Log.i(TAG, "fetchAccount  : response = " + response);
            try {
                JSONObject res = new JSONObject(response);
                int resCode = res.optInt(RESULT_KEY_RES);
                errorMsg = res.optString(RESULT_KEY_MSG, null);
                if (resCode == RESULT_CODE_SUCCESS) {
                    JSONObject data = res.getJSONObject(RESULT_KEY_DATA);
                    String account = data.optString(RESULT_KEY_ACCOUNT);
                    String nick = data.optString(RESULT_KEY_NICK);
                    String token = data.optString(RESULT_KEY_TOKEN);
                    String avatar = data.optString(RESULT_KEY_AVATAR);
                    long availableAt = data.optLong(RESULT_KEY_AVAILABLEAT);
                    AccountInfo accountInfo = new AccountInfo(account, nick, token, avatar, availableAt);
                    fetchAccountCallBack.onSuccess(accountInfo);
                    return;
                }
                fetchAccountCallBack.onFailed(resCode, errorMsg);
                return;
            } catch (JSONException e) {
                e.printStackTrace();
            }
            fetchAccountCallBack.onFailed(-1, errorMsg);

        });

    }


    /**
     * 主播创建直播间
     */
    public void createRoom(String account, String roomName, final ChatRoomHttpCallback<VoiceRoomInfo> callback) {

        String url = DemoServers.audioRoomAPIServer() + API_CREATE_ROOM;

        Map<String, String> headers = new HashMap<>(2);
        headers.put(HEADER_KEY_CONTENT_TYPE, "application/x-www-form-urlencoded;charset=utf-8");

        String bodyString = REQUEST_SID + "=" + account + "&" +
                REQUEST_ROOM_NAME + "=" + roomName;

        NimHttpClient.getInstance().execute(url, headers, bodyString, (response, code, errorMsg) -> {

            if (callback == null) {
                return;
            }
            if (code != 0) {
                Log.e(TAG, "createRoom failed : code = " + code + ", errorMsg = " + errorMsg);
                callback.onFailed(code, errorMsg);
                return;
            }
            Log.i(TAG, "createRoom  : response = " + response);
            try {
                JSONObject res = new JSONObject(response);
                int resCode = res.optInt(RESULT_KEY_RES);
                errorMsg = res.optString(RESULT_KEY_MSG, null);

                if (resCode == RESULT_CODE_SUCCESS) {
                    JSONObject msg = res.getJSONObject(RESULT_KEY_DATA);
                    VoiceRoomInfo param = null;
                    if (msg != null) {
                        param = new VoiceRoomInfo();
                        param.setRoomId(msg.optString(RESULT_KEY_ROOM_ID));
                        param.setName(msg.optString(RESULT_KEY_NAME));
                        param.setCreatorAccount(msg.optString(RESULT_KEY_CREATOR));

                    }
                    callback.onSuccess(param);
                    return;
                }


                Log.e(TAG, "createRoom failed : code = " + code);
                callback.onFailed(resCode, errorMsg);

            } catch (JSONException e) {
                e.printStackTrace();
                callback.onFailed(-1, e.getMessage());
            }
        });
    }

    /**
     * 解散房间
     *
     * @param account
     * @param roomID
     * @param callback
     */
    public void closeRoom(String account, String roomID, final ChatRoomHttpCallback callback) {
        String url = DemoServers.audioRoomAPIServer() + API_CLOSE_ROOM;
        Map<String, String> headers = new HashMap<>(2);
        headers.put(HEADER_KEY_CONTENT_TYPE, "application/x-www-form-urlencoded;charset=utf-8");

        String bodyString = REQUEST_SID + "=" + account + "&" +
                RESULT_KEY_ROOM_ID + "=" + roomID;
        NimHttpClient.getInstance().execute(url, headers, bodyString, (response, code, errorMsg) -> {

            if (callback == null) {
                return;
            }
            if (code != 0) {
                Log.e(TAG, "closeRoom failed : code = " + code + ", errorMsg = " + errorMsg);
                callback.onFailed(code, errorMsg);
                return;
            }
            Log.i(TAG, "closeRoom  : response = " + response);
            try {
                JSONObject res = new JSONObject(response);
                int resCode = res.optInt(RESULT_KEY_RES);
                errorMsg = res.optString(RESULT_KEY_MSG, null);

                if (resCode == RESULT_CODE_SUCCESS) {
                    callback.onSuccess(null);
                    return;
                }

                Log.e(TAG, "closeRoom failed : code = " + code);
                callback.onFailed(resCode, errorMsg);

            } catch (JSONException e) {
                e.printStackTrace();
                callback.onFailed(-1, e.getMessage());
            }

        });
    }


    /**
     * 禁言所有成员节目
     *
     * @param account
     * @param roomID
     * @param callback
     */
    public void muteAll(String account, String roomID, boolean mute, boolean needNotify, boolean notifyExt, final ChatRoomHttpCallback callback) {

        String url = DemoServers.audioRoomAPIServer() + API_ALL_MUTE;
        Map<String, String> headers = new HashMap<>(5);
        headers.put(HEADER_KEY_CONTENT_TYPE, "application/x-www-form-urlencoded;charset=utf-8");
        String bodyString = REQUEST_SID + "=" + account + "&" +
                RESULT_KEY_ROOM_ID + "=" + roomID + "&" +
                REQUEST_IS_MUTE + "=" + mute + "&" +
                "needNotify" + "=" + needNotify + "&" +
                "notifyExt" + "=" + notifyExt;
        NimHttpClient.getInstance().execute(url, headers, bodyString, (response, code, errorMsg) -> {

            if (callback == null) {
                return;
            }
            if (code != 0) {
                Log.e(TAG, "closeRoom failed : code = " + code + ", errorMsg = " + errorMsg);
                callback.onFailed(code, errorMsg);
                return;
            }
            Log.i(TAG, "closeRoom  : response = " + response);
            try {
                JSONObject res = new JSONObject(response);
                int resCode = res.optInt(RESULT_KEY_RES);
                errorMsg = res.optString(RESULT_KEY_MSG, null);

                if (resCode == RESULT_CODE_SUCCESS) {
                    callback.onSuccess(null);
                    return;
                }

                Log.e(TAG, "closeRoom failed : code = " + code);
                callback.onFailed(resCode, errorMsg);

            } catch (JSONException e) {
                e.printStackTrace();
                callback.onFailed(-1, e.getMessage());
            }

        });
    }


    private static class InstanceHolder {
        private static final ChatRoomHttpClient INSTANCE = new ChatRoomHttpClient();
    }


    public interface ChatRoomHttpCallback<T> {

        void onSuccess(T t);

        void onFailed(int code, String errorMsg);
    }


}
