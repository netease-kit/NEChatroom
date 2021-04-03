package com.netease.yunxin.nertc.nertcvoiceroom.model.custom;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * 音乐控制
 */
public class MusicControl extends CustomAttachment {

    public String operator;

    public MusicControl(int type) {
        super(type);
    }

    public MusicControl(int type, String operator) {
        super(type);
        this.operator = operator;
    }


    @Override
    protected void parseData(JSONObject data) {
        try {
            operator = data.getString("operator");
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    protected JSONObject packData() {
        JSONObject jsonObject = new JSONObject();
        try {
            jsonObject.put("operator", operator);
            return jsonObject;
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }
}
