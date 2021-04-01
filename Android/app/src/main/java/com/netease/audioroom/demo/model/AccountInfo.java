package com.netease.audioroom.demo.model;


import com.netease.yunxin.nertc.nertcvoiceroom.util.JsonUtil;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;

public class AccountInfo implements Serializable {

    public final String account;
    public final String nick;
    public final String token;
    public final String avatar;
    public long availableAt;//应用服务器过期时间


    public AccountInfo(String account, String nick, String token, String avatar, long availableAt) {
        this.account = account;
        this.nick = nick;
        this.token = token;
        this.avatar = avatar;
        this.availableAt = availableAt;
    }


    public AccountInfo(String jsonStr) {
        JSONObject jsonObject = JsonUtil.parse(jsonStr);
        if (jsonObject == null) {
            account = null;
            nick = null;
            token = null;
            avatar = null;
            return;
        }
        account = jsonObject.optString("account");
        nick = jsonObject.optString("nick");
        token = jsonObject.optString("token");
        avatar = jsonObject.optString("avatar");
        availableAt = jsonObject.optLong("availableAt");
    }


    @Override
    public String toString() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("account", account);
            jsonObject.put("nick", nick);
            jsonObject.put("token", token);
            jsonObject.put("avatar", avatar);
            jsonObject.put("availableAt", availableAt);
            return jsonObject.toString();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    public static long accountToVoiceUid(String accountId) {
        long result = -1;
        try {
            result = Long.parseLong(accountId);
        } catch (Throwable tr) {
            tr.printStackTrace();
        }

        return result;
    }
}
