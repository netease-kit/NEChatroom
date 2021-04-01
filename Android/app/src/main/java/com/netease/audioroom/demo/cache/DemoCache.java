package com.netease.audioroom.demo.cache;

import android.content.Context;
import android.content.SharedPreferences;

import com.netease.audioroom.demo.model.AccountInfo;
import com.netease.audioroom.demo.util.ToastHelper;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;


public class DemoCache {
    private static final String ACCOUNT_INFO_KEY = "account_info_key";

    private static Context context;

    private static String accountId;
    private static AccountInfo accountInfo;


    public static String getAccountId() {
        return accountId;
    }

    public static void setAccountId(String accid) {
        accountId = accid;
    }

    public static Context getContext() {
        return context;
    }

    public static void init(Context context) {
        DemoCache.context = context.getApplicationContext();
    }


    public static void saveAccountInfo(AccountInfo account) {
        accountInfo = account;
        getSharedPreferences().edit().putString(ACCOUNT_INFO_KEY, accountInfo.toString()).apply();
    }


    public static AccountInfo getAccountInfo() {
        if (accountInfo != null) {
//            //用户token过期
//            if (new Date().getTime() > accountInfo.availableAt) {
//                SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd hh:mm:ss", Locale.CHINESE);
//                String time = simpleDateFormat.format(new Date(accountInfo.availableAt));
//                ToastHelper.showToastLong("用户信息已过期，有效期为 " + time + "，请退出重新启动");
//                return new AccountInfo("null", "null", "null", "null", 0);
//            } else {
//                return accountInfo;
//            }
            return accountInfo;

        }
        String jsonStr = getSharedPreferences().getString(ACCOUNT_INFO_KEY, null);
        if (jsonStr == null) {
            return new AccountInfo("null", "null", "null", "null", 0);
        }
        accountInfo = new AccountInfo(jsonStr);

        return accountInfo;
    }

    private static SharedPreferences getSharedPreferences() {
        return context.getSharedPreferences("audio_demo", Context.MODE_PRIVATE);
    }

}
