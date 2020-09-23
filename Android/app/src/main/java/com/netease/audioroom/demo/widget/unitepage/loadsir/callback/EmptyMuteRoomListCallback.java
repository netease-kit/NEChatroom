package com.netease.audioroom.demo.widget.unitepage.loadsir.callback;


import android.content.Context;
import android.view.View;

import com.netease.audioroom.demo.R;


public class EmptyMuteRoomListCallback extends BaseCallback {

    @Override
    protected int onCreateView() {
        return R.layout.page_empty_mute;
    }

    @Override
    protected boolean onReloadEvent(Context context, View view) {
        return super.onReloadEvent(context, view);
    }
}
