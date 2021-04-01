package com.netease.yunxin.nertc.nertcvoiceroom.util;

import com.netease.yunxin.kit.alog.ALog;

import org.json.JSONException;
import org.json.JSONObject;


public class JsonUtil {


    private static final String TAG = "JsonUtil";

    public static JSONObject parse(String json) {
        try {
            return new JSONObject(json);
        } catch (JSONException e) {
            ALog.e(TAG, "parse exception =" + e.getMessage());
            return null;
        }
    }

    public static String getUnescapeJson(String escapeJson){
        return null;
    }

}
