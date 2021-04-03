package com.netease.yunxin.nertc.nertcvoiceroom.model.ktv;

import java.util.List;

public interface MusicChangeListener {
    void onListChange(List<MusicOrderedItem> musicList, boolean isInit);

    void onSongChange(MusicOrderedItem music, boolean isMy, boolean isInit);

    void onError(String msg);
}
