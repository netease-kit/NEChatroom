package com.netease.audioroom.demo.widget.unitepage.loadsir.callback;

import android.content.Context;
import android.view.View;

import com.netease.audioroom.demo.R;

public class NetErrCallback extends BaseCallback {

    @Override
    protected int onCreateView() {
        return R.layout.page_net_err;
    }

    @Override
    protected boolean onReloadEvent(final Context context, View view) {
        return true;
    }

}
