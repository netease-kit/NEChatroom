package com.netease.audioroom.demo.http.model;

import com.google.gson.annotations.SerializedName;
import com.netease.yunxin.nertc.nertcvoiceroom.model.ktv.Music;

import java.util.List;

public class MusicListResp {
    @SerializedName("total")
    public int total;

    @SerializedName("list")
    public List<Music> list;
}
