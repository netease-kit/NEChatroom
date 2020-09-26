package com.netease.yunxin.nertc.nertcvoiceroom.model.custom;

import org.json.JSONObject;

/**
 * 解散聊天室的自定义消息
 */
public class CloseRoomAttach extends CustomAttachment {
    public CloseRoomAttach() {
        super(CustomAttachmentType.CLOSER_ROOM);
    }

    @Override
    protected void parseData(JSONObject data) {

    }

    @Override
    protected JSONObject packData() {
        return null;
    }
}
