package com.netease.audioroom.demo.http.model;

import com.google.gson.annotations.SerializedName;
import com.netease.audioroom.demo.model.AccountInfo;

/**
 * Created by luc on 12/24/20.
 */
public class AccountInfoResp {

    @SerializedName("accid")
    public String account;
    @SerializedName("nickname")
    public String nick;
    @SerializedName("imToken")
    public String token;
    @SerializedName("icon")
    public String avatar;
    @SerializedName("availableAt")
    public long availableAt;//应用服务器过期时间

    public AccountInfo toAccountInfo() {
        return new AccountInfo(account, nick, token, avatar, availableAt);
    }
}
