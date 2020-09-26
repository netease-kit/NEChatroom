package com.netease.audioroom.demo.widget.unitepage.loadsir.callback;

import android.content.Context;
import android.view.View;
import android.widget.Toast;

import com.netease.audioroom.demo.R;


public class TimeoutCallback extends BaseCallback {

    @Override
    protected int onCreateView() {
        return R.layout.page_failure;
    }

    @Override
    protected boolean onReloadEvent(Context context, View view) {
        Toast.makeText(context.getApplicationContext(), "Connecting to the network again!", Toast.LENGTH_SHORT).show();
        return false;
    }

}
