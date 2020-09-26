package com.netease.audioroom.demo.widget.unitepage.loadsir.callback;


import android.content.Context;
import android.view.View;

import com.netease.audioroom.demo.R;


public class EmptyChatRoomListCallback extends BaseCallback {
    @Override
    protected int onCreateView() {
        return R.layout.page_empty_member;
    }

    @Override
    public BaseCallback setCallback(View view, Context context, OnReloadListener onReloadListener) {
        return super.setCallback(view, context, onReloadListener);
    }
}
