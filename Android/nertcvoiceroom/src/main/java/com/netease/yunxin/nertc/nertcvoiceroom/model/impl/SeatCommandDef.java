package com.netease.yunxin.nertc.nertcvoiceroom.model.impl;

interface SeatCommandDef {
    /**
     * 请求连麦
     */
    int APPLY_SEAT = 1;

    /**
     * 主动下麦
     */
    int LEAVE_SEAT = 2;

    /**
     * 取消连麦请求
     */
    int CANCEL_SEAT_APPLY = 3;

    /**
     * 命令
     */
    String COMMAND = "command";

    /**
     * 麦位
     */
    String INDEX = "index";

    /**
     * 昵称
     */
    String NICK = "nick";

    /**
     * 头像
     */
    String AVATAR = "avatar";
}
